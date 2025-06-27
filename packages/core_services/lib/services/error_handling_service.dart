/*
---------------------------------------------------------------
File name:          error_handling_service.dart
Author:             Ig
Date created:       2025/06/26
Last modified:      2025/06/26
Dart Version:       3.32.4
Description:        统一错误处理服务 - 提供应用级错误处理、上报和恢复机制
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 重构 - 核心服务框架补强，创建错误处理服务;
---------------------------------------------------------------
*/

/// 错误严重级别
enum ErrorSeverity {
  /// 低级别 - 不影响主要功能
  low,
  /// 中等级别 - 影响部分功能
  medium,
  /// 高级别 - 影响核心功能
  high,
  /// 临界级别 - 可能导致应用崩溃
  critical;

  /// 获取严重级别的数值表示
  int get priority {
    switch (this) {
      case ErrorSeverity.low:
        return 0;
      case ErrorSeverity.medium:
        return 1;
      case ErrorSeverity.high:
        return 2;
      case ErrorSeverity.critical:
        return 3;
    }
  }

  /// 获取严重级别的显示名称
  String get displayName {
    switch (this) {
      case ErrorSeverity.low:
        return 'LOW';
      case ErrorSeverity.medium:
        return 'MEDIUM';
      case ErrorSeverity.high:
        return 'HIGH';
      case ErrorSeverity.critical:
        return 'CRITICAL';
    }
  }
}

/// 错误类别
enum ErrorCategory {
  /// 网络错误
  network,
  /// 数据库/存储错误
  storage,
  /// 业务逻辑错误
  business,
  /// UI/界面错误
  ui,
  /// 系统级错误
  system,
  /// 用户输入错误
  validation,
  /// 权限/安全错误
  security,
  /// 未知错误
  unknown;

  String get displayName {
    switch (this) {
      case ErrorCategory.network:
        return 'NETWORK';
      case ErrorCategory.storage:
        return 'STORAGE';
      case ErrorCategory.business:
        return 'BUSINESS';
      case ErrorCategory.ui:
        return 'UI';
      case ErrorCategory.system:
        return 'SYSTEM';
      case ErrorCategory.validation:
        return 'VALIDATION';
      case ErrorCategory.security:
        return 'SECURITY';
      case ErrorCategory.unknown:
        return 'UNKNOWN';
    }
  }
}

/// 应用异常基类
class AppException implements Exception {
  /// 错误消息
  final String message;
  
  /// 错误代码
  final String? code;
  
  /// 错误严重级别
  final ErrorSeverity severity;
  
  /// 错误类别
  final ErrorCategory category;
  
  /// 原始错误
  final Object? originalError;
  
  /// 堆栈跟踪
  final StackTrace? stackTrace;
  
  /// 是否可恢复
  final bool recoverable;
  
  /// 用户友好的错误消息
  final String? userMessage;
  
  /// 额外数据
  final Map<String, dynamic>? data;

  const AppException({
    required this.message,
    this.code,
    this.severity = ErrorSeverity.medium,
    this.category = ErrorCategory.unknown,
    this.originalError,
    this.stackTrace,
    this.recoverable = true,
    this.userMessage,
    this.data,
  });

  /// 工厂方法 - 网络错误
  factory AppException.network({
    required String message,
    String? code,
    ErrorSeverity severity = ErrorSeverity.medium,
    Object? originalError,
    StackTrace? stackTrace,
    String? userMessage,
    Map<String, dynamic>? data,
  }) {
    return AppException(
      message: message,
      code: code,
      severity: severity,
      category: ErrorCategory.network,
      originalError: originalError,
      stackTrace: stackTrace,
      userMessage: userMessage ?? '网络连接出现问题，请检查网络设置',
      data: data,
    );
  }

  /// 工厂方法 - 业务逻辑错误
  factory AppException.business({
    required String message,
    String? code,
    ErrorSeverity severity = ErrorSeverity.medium,
    Object? originalError,
    StackTrace? stackTrace,
    String? userMessage,
    Map<String, dynamic>? data,
  }) {
    return AppException(
      message: message,
      code: code,
      severity: severity,
      category: ErrorCategory.business,
      originalError: originalError,
      stackTrace: stackTrace,
      userMessage: userMessage,
      data: data,
    );
  }

  /// 工厂方法 - 验证错误
  factory AppException.validation({
    required String message,
    String? code,
    String? field,
    String? userMessage,
    Map<String, dynamic>? data,
  }) {
    return AppException(
      message: message,
      code: code,
      severity: ErrorSeverity.low,
      category: ErrorCategory.validation,
      userMessage: userMessage ?? '输入数据不符合要求',
      data: {
        if (field != null) 'field': field,
        ...?data,
      },
    );
  }

  /// 工厂方法 - 系统错误
  factory AppException.system({
    required String message,
    String? code,
    ErrorSeverity severity = ErrorSeverity.high,
    Object? originalError,
    StackTrace? stackTrace,
    String? userMessage,
    Map<String, dynamic>? data,
  }) {
    return AppException(
      message: message,
      code: code,
      severity: severity,
      category: ErrorCategory.system,
      originalError: originalError,
      stackTrace: stackTrace,
      recoverable: false,
      userMessage: userMessage ?? '系统出现错误，请稍后重试',
      data: data,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'severity': severity.displayName,
      'category': category.displayName,
      'recoverable': recoverable,
      'userMessage': userMessage,
      'data': data,
      'originalError': originalError?.toString(),
      'stackTrace': stackTrace?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AppException(${category.displayName}/${severity.displayName}): $message';
  }
}

/// 错误处理器接口
abstract class ErrorHandler {
  /// 处理错误
  Future<bool> handle(AppException error);
  
  /// 判断是否可以处理此类错误
  bool canHandle(AppException error);
}

/// 错误上报器接口
abstract class ErrorReporter {
  /// 上报错误
  Future<void> report(AppException error);
}

/// 错误恢复策略接口
abstract class ErrorRecoveryStrategy {
  /// 尝试恢复
  Future<bool> recover(AppException error);
  
  /// 判断是否可以恢复此类错误
  bool canRecover(AppException error);
}

/// 基础错误处理器 - 控制台输出
class ConsoleErrorHandler implements ErrorHandler {
  @override
  bool canHandle(AppException error) => true;

  @override
  Future<bool> handle(AppException error) async {
    print('[ERROR HANDLER] ${error.toString()}');
    if (error.originalError != null) {
      print('[ORIGINAL ERROR] ${error.originalError}');
    }
    if (error.stackTrace != null) {
      print('[STACK TRACE]\n${error.stackTrace}');
    }
    return true;
  }
}

/// 基础错误上报器 - 日志上报
class LogErrorReporter implements ErrorReporter {
  @override
  Future<void> report(AppException error) async {
    // 实际项目中可以集成Crashlytics、Sentry等服务
    print('[ERROR REPORT] ${error.toJson()}');
  }
}

/// 网络错误恢复策略
class NetworkErrorRecoveryStrategy implements ErrorRecoveryStrategy {
  @override
  bool canRecover(AppException error) {
    return error.category == ErrorCategory.network && error.recoverable;
  }

  @override
  Future<bool> recover(AppException error) async {
    // 实现网络重连逻辑
    // 例如：检查网络状态、重试请求等
    
    // 模拟恢复过程
    await Future.delayed(const Duration(seconds: 1));
    
    // 简单的成功率模拟
    return DateTime.now().millisecond % 2 == 0;
  }
}

/// 错误处理服务接口
abstract class ErrorHandlingService {
  /// 注册错误处理器
  void registerHandler(ErrorHandler handler);
  
  /// 注册错误上报器
  void registerReporter(ErrorReporter reporter);
  
  /// 注册错误恢复策略
  void registerRecoveryStrategy(ErrorRecoveryStrategy strategy);
  
  /// 处理错误
  Future<bool> handleError(Object error, [StackTrace? stackTrace]);
  
  /// 处理应用异常
  Future<bool> handleAppException(AppException error);
  
  /// 创建并处理业务异常
  Future<bool> handleBusinessError(String message, {String? code, String? userMessage, Map<String, dynamic>? data});
  
  /// 创建并处理网络异常
  Future<bool> handleNetworkError(String message, {Object? originalError, String? userMessage, Map<String, dynamic>? data});
  
  /// 创建并处理验证异常
  Future<bool> handleValidationError(String message, {String? field, String? userMessage, Map<String, dynamic>? data});
  
  /// 尝试错误恢复
  Future<bool> attemptRecovery(AppException error);
  
  /// 上报错误
  Future<void> reportError(AppException error);
}

/// 基础错误处理服务实现
class BasicErrorHandlingService implements ErrorHandlingService {
  /// 错误处理器列表
  final List<ErrorHandler> _handlers = [];
  
  /// 错误上报器列表
  final List<ErrorReporter> _reporters = [];
  
  /// 错误恢复策略列表
  final List<ErrorRecoveryStrategy> _recoveryStrategies = [];

  /// 构造函数
  BasicErrorHandlingService() {
    // 注册默认处理器和策略
    _registerDefaults();
  }

  /// 注册默认处理器
  void _registerDefaults() {
    registerHandler(ConsoleErrorHandler());
    registerReporter(LogErrorReporter());
    registerRecoveryStrategy(NetworkErrorRecoveryStrategy());
  }

  @override
  void registerHandler(ErrorHandler handler) {
    _handlers.add(handler);
  }

  @override
  void registerReporter(ErrorReporter reporter) {
    _reporters.add(reporter);
  }

  @override
  void registerRecoveryStrategy(ErrorRecoveryStrategy strategy) {
    _recoveryStrategies.add(strategy);
  }

  @override
  Future<bool> handleError(Object error, [StackTrace? stackTrace]) async {
    AppException appError;
    
    if (error is AppException) {
      appError = error;
    } else {
      // 将普通错误包装为AppException
      appError = AppException(
        message: error.toString(),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.unknown,
        originalError: error,
        stackTrace: stackTrace,
        userMessage: '应用出现未知错误',
      );
    }

    return await handleAppException(appError);
  }

  @override
  Future<bool> handleAppException(AppException error) async {
    bool handled = false;

    // 1. 尝试恢复
    if (error.recoverable) {
      final recovered = await attemptRecovery(error);
      if (recovered) {
        return true;
      }
    }

    // 2. 执行错误处理
    for (final handler in _handlers) {
      if (handler.canHandle(error)) {
        try {
          final result = await handler.handle(error);
          if (result) {
            handled = true;
          }
        } catch (e) {
          print('[ERROR HANDLING SERVICE] Handler failed: $e');
        }
      }
    }

    // 3. 上报错误
    await reportError(error);

    return handled;
  }

  @override
  Future<bool> handleBusinessError(String message, {String? code, String? userMessage, Map<String, dynamic>? data}) async {
    final error = AppException.business(
      message: message,
      code: code,
      userMessage: userMessage,
      data: data,
    );
    return await handleAppException(error);
  }

  @override
  Future<bool> handleNetworkError(String message, {Object? originalError, String? userMessage, Map<String, dynamic>? data}) async {
    final error = AppException.network(
      message: message,
      originalError: originalError,
      userMessage: userMessage,
      data: data,
    );
    return await handleAppException(error);
  }

  @override
  Future<bool> handleValidationError(String message, {String? field, String? userMessage, Map<String, dynamic>? data}) async {
    final error = AppException.validation(
      message: message,
      field: field,
      userMessage: userMessage,
      data: data,
    );
    return await handleAppException(error);
  }

  @override
  Future<bool> attemptRecovery(AppException error) async {
    for (final strategy in _recoveryStrategies) {
      if (strategy.canRecover(error)) {
        try {
          final recovered = await strategy.recover(error);
          if (recovered) {
            return true;
          }
        } catch (e) {
          print('[ERROR HANDLING SERVICE] Recovery strategy failed: $e');
        }
      }
    }
    return false;
  }

  @override
  Future<void> reportError(AppException error) async {
    for (final reporter in _reporters) {
      try {
        await reporter.report(error);
      } catch (e) {
        print('[ERROR HANDLING SERVICE] Reporter failed: $e');
      }
    }
  }
} 