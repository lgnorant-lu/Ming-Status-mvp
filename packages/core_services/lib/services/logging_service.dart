/*
---------------------------------------------------------------
File name:          logging_service.dart
Author:             Ig
Date created:       2025/06/26
Last modified:      2025/06/27
Dart Version:       3.32.4
Description:        结构化日志服务 - 提供统一的日志记录接口和基础实现
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 1.5 Finalization - 实现FileLogOutput的完整文件写入功能;
    2025/06/26: Phase 1.5 重构 - 核心服务框架补强，创建日志服务;
---------------------------------------------------------------
*/

import 'dart:io';
import 'dart:async';

/// 日志级别枚举
enum LogLevel {
  /// 调试信息
  debug,
  /// 普通信息
  info,
  /// 警告信息
  warning,
  /// 错误信息
  error,
  /// 严重错误
  fatal;

  /// 获取日志级别的数值表示
  int get priority {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 1;
      case LogLevel.warning:
        return 2;
      case LogLevel.error:
        return 3;
      case LogLevel.fatal:
        return 4;
    }
  }

  /// 获取日志级别的字符串表示
  String get displayName {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }
}

/// 日志条目数据类
class LogEntry {
  /// 日志时间戳
  final DateTime timestamp;
  
  /// 日志级别
  final LogLevel level;
  
  /// 日志消息
  final String message;
  
  /// 标签/模块名称
  final String? tag;
  
  /// 额外数据
  final Map<String, dynamic>? data;
  
  /// 错误对象（可选）
  final Object? error;
  
  /// 堆栈跟踪（可选）
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.data,
    this.error,
    this.stackTrace,
  });

  /// 创建工厂方法
  factory LogEntry.create({
    required LogLevel level,
    required String message,
    String? tag,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.displayName,
      'message': message,
      if (tag != null) 'tag': tag,
      if (data != null) 'data': data,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  /// 格式化为字符串
  String format() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.displayName}] ');
    if (tag != null) {
      buffer.write('[$tag] ');
    }
    buffer.write(message);
    
    if (data != null && data!.isNotEmpty) {
      buffer.write(' | Data: $data');
    }
    
    if (error != null) {
      buffer.write('\nError: $error');
    }
    
    if (stackTrace != null) {
      buffer.write('\nStack Trace:\n$stackTrace');
    }
    
    return buffer.toString();
  }
}

/// 日志输出器接口
abstract class LogOutput {
  /// 输出日志条目
  void output(LogEntry entry);
  
  /// 关闭输出器
  void close();
}

/// 控制台日志输出器
class ConsoleLogOutput implements LogOutput {
  /// 是否启用彩色输出
  final bool enableColors;
  
  /// 是否显示详细信息
  final bool verbose;

  const ConsoleLogOutput({
    this.enableColors = true,
    this.verbose = false,
  });

  @override
  void output(LogEntry entry) {
    final formattedMessage = verbose ? entry.format() : _formatSimple(entry);
    
    if (enableColors) {
      print(_colorize(formattedMessage, entry.level));
    } else {
      print(formattedMessage);
    }
  }

  @override
  void close() {
    // Console output doesn't need explicit closing
  }

  /// 简单格式化
  String _formatSimple(LogEntry entry) {
    final buffer = StringBuffer();
    buffer.write('[${entry.level.displayName}] ');
    if (entry.tag != null) {
      buffer.write('[${entry.tag}] ');
    }
    buffer.write(entry.message);
    return buffer.toString();
  }

  /// 彩色化输出（简化版，实际项目中可使用ansi_color包）
  String _colorize(String message, LogLevel level) {
    // 这里简化处理，实际项目中可以使用ANSI颜色码
    switch (level) {
      case LogLevel.debug:
        return message; // 默认颜色
      case LogLevel.info:
        return message; // 默认颜色
      case LogLevel.warning:
        return message; // 可以添加黄色
      case LogLevel.error:
        return message; // 可以添加红色
      case LogLevel.fatal:
        return message; // 可以添加红色背景
    }
  }
}

/// 文件日志输出器（完整实现）
class FileLogOutput implements LogOutput {
  /// 文件路径
  final String filePath;
  
  /// 是否自动刷新
  final bool autoFlush;
  
  /// 最大文件大小（字节），超过后轮转
  final int? maxFileSize;
  
  /// 文件写入流
  IOSink? _sink;
  
  /// 当前文件对象
  File? _file;
  
  /// 是否已关闭
  bool _isClosed = false;
  
  /// 写入锁，确保线程安全
  final Completer<void> _initCompleter = Completer<void>();
  
  FileLogOutput({
    required this.filePath,
    this.autoFlush = true,
    this.maxFileSize,
  });

  /// 初始化文件和流（懒加载）
  Future<void> _ensureInitialized() async {
    if (_sink != null || _isClosed) return;
    
    if (!_initCompleter.isCompleted) {
      try {
        // 创建文件对象
        _file = File(filePath);
        
        // 确保目录存在
        final directory = _file!.parent;
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        // 检查文件大小轮转
        if (maxFileSize != null && await _file!.exists()) {
          final fileSize = await _file!.length();
          if (fileSize > maxFileSize!) {
            await _rotateFile();
          }
        }
        
        // 打开文件写入流
        _sink = _file!.openWrite(mode: FileMode.append);
        
        _initCompleter.complete();
      } catch (e) {
        _initCompleter.completeError(e);
        rethrow;
      }
    }
    
    return _initCompleter.future;
  }

  /// 轮转文件
  Future<void> _rotateFile() async {
    if (_file == null) return;
    
    // 生成备份文件名
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '$filePath.$timestamp.bak';
    
    try {
      // 重命名当前文件为备份文件
      await _file!.rename(backupPath);
      
      // 重新创建文件对象
      _file = File(filePath);
    } catch (e) {
      // 轮转失败时记录错误但不中断日志记录
      print('[LOGGING ERROR] Failed to rotate log file: $e');
    }
  }

  @override
  void output(LogEntry entry) {
    if (_isClosed) return;
    
    // 异步处理文件写入，避免阻塞日志调用
    _writeToFileAsync(entry).catchError((error) {
      // 文件写入失败时降级到控制台输出
      print('[LOGGING ERROR] Failed to write to file $filePath: $error');
      print('[FALLBACK] ${entry.format()}');
    });
  }

  /// 异步写入文件
  Future<void> _writeToFileAsync(LogEntry entry) async {
    try {
      await _ensureInitialized();
      
      if (_sink == null || _isClosed) {
        throw StateError('FileLogOutput is not initialized or closed');
      }
      
      // 写入日志条目
      final logLine = '${entry.format()}\n';
      _sink!.write(logLine);
      
      // 自动刷新
      if (autoFlush) {
        await _sink!.flush();
      }
      
      // 检查文件大小轮转
      if (maxFileSize != null && _file != null) {
        final fileSize = await _file!.length();
        if (fileSize > maxFileSize!) {
          await _closeCurrentSink();
          await _rotateFile();
          // 重新初始化将在下次写入时发生
          _sink = null;
        }
      }
    } catch (e) {
      // 重新抛出错误让调用者处理
      rethrow;
    }
  }

  /// 关闭当前文件流
  Future<void> _closeCurrentSink() async {
    if (_sink != null) {
      try {
        await _sink!.flush();
        await _sink!.close();
      } catch (e) {
        print('[LOGGING ERROR] Failed to close sink: $e');
      }
      _sink = null;
    }
  }

  @override
  void close() {
    if (_isClosed) return;
    
    _isClosed = true;
    
    // 异步关闭文件流
    _closeCurrentSink().catchError((error) {
      print('[LOGGING ERROR] Failed to close FileLogOutput: $error');
    });
  }
}

/// 日志服务接口
abstract class LoggingService {
  /// 设置最小日志级别
  void setMinLevel(LogLevel level);
  
  /// 添加日志输出器
  void addOutput(LogOutput output);
  
  /// 移除日志输出器
  void removeOutput(LogOutput output);
  
  /// 记录调试日志
  void debug(String message, {String? tag, Map<String, dynamic>? data});
  
  /// 记录信息日志
  void info(String message, {String? tag, Map<String, dynamic>? data});
  
  /// 记录警告日志
  void warning(String message, {String? tag, Map<String, dynamic>? data});
  
  /// 记录错误日志
  void error(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// 记录严重错误日志
  void fatal(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// 记录自定义级别日志
  void log(LogLevel level, String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// 关闭日志服务
  void close();
}

/// 基础日志服务实现
class BasicLoggingService implements LoggingService {
  /// 最小日志级别
  LogLevel _minLevel = LogLevel.debug;
  
  /// 日志输出器列表
  final List<LogOutput> _outputs = [];
  
  /// 是否已关闭
  bool _isClosed = false;

  /// 构造函数
  BasicLoggingService({LogLevel? minLevel}) {
    if (minLevel != null) {
      _minLevel = minLevel;
    }
    
    // 默认添加控制台输出器
    _outputs.add(const ConsoleLogOutput());
  }

  @override
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  @override
  void addOutput(LogOutput output) {
    if (!_isClosed) {
      _outputs.add(output);
    }
  }

  @override
  void removeOutput(LogOutput output) {
    if (!_isClosed) {
      _outputs.remove(output);
    }
  }

  @override
  void debug(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.debug, message, tag: tag, data: data);
  }

  @override
  void info(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.info, message, tag: tag, data: data);
  }

  @override
  void warning(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.warning, message, tag: tag, data: data);
  }

  @override
  void error(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    log(LogLevel.error, message, tag: tag, data: data, error: error, stackTrace: stackTrace);
  }

  @override
  void fatal(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    log(LogLevel.fatal, message, tag: tag, data: data, error: error, stackTrace: stackTrace);
  }

  @override
  void log(LogLevel level, String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    if (_isClosed || level.priority < _minLevel.priority) {
      return;
    }

    final entry = LogEntry.create(
      level: level,
      message: message,
      tag: tag,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );

    for (final output in _outputs) {
      try {
        output.output(entry);
      } catch (e) {
        // 避免日志记录本身产生错误导致程序崩溃
        print('[LOGGING ERROR] Failed to output log: $e');
      }
    }
  }

  @override
  void close() {
    if (_isClosed) return;
    
    _isClosed = true;
    
    for (final output in _outputs) {
      try {
        output.close();
      } catch (e) {
        print('[LOGGING ERROR] Failed to close output: $e');
      }
    }
    
    _outputs.clear();
  }
} 