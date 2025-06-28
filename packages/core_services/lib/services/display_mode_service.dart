/*
---------------------------------------------------------------
File name:          display_mode_service.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        显示模式服务 - 管理应用在不同设备上的显示模式切换
---------------------------------------------------------------
Change History:
    2025/06/28: Initial creation - Phase 2.1 三端UI框架;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i18n_service.dart';

/// 显示模式枚举
/// 定义应用支持的三种显示模式，与AppShell的ShellType对应
enum DisplayMode {
  /// 桌面模式 - PC端空间化桌面环境，使用SpatialOsShell
  desktop,
  
  /// 移动模式 - 移动端沉浸式应用，使用StandardAppShell
  mobile,
  
  /// Web模式 - Web端响应式布局，基于SpatialOsShell的Web适配
  web,
}

/// 显示模式扩展方法
extension DisplayModeExtension on DisplayMode {
  /// 获取显示模式的显示名称（支持国际化）
  String get displayName {
    try {
      // 尝试从I18nService获取翻译
      final i18nService = I18nService.instance;
      final translationKey = 'display_mode_${identifier}';
      final translated = i18nService.translate(translationKey, packageName: 'app_routing');
      
      // 如果翻译不是键值本身（说明找到了翻译），则返回翻译
      if (translated != translationKey) {
        return translated;
      }
    } catch (e) {
      // I18nService可能未初始化，忽略错误
    }
    
    // 回退到中文硬编码（默认语言）
    switch (this) {
      case DisplayMode.desktop:
        return '桌面模式';
      case DisplayMode.mobile:
        return '移动模式';
      case DisplayMode.web:
        return 'Web模式';
    }
  }
  
  /// 获取显示模式的描述（支持国际化）
  String get description {
    try {
      // 尝试从I18nService获取翻译
      final i18nService = I18nService.instance;
      final translationKey = 'display_mode_${identifier}_desc';
      final translated = i18nService.translate(translationKey, packageName: 'app_routing');
      
      // 如果翻译不是键值本身（说明找到了翻译），则返回翻译
      if (translated != translationKey) {
        return translated;
      }
    } catch (e) {
      // I18nService可能未初始化，忽略错误
    }
    
    // 回退到中文硬编码（默认语言）
    switch (this) {
      case DisplayMode.desktop:
        return 'PC端空间化桌面环境，模块以独立浮动窗口形式存在';
      case DisplayMode.mobile:
        return '移动端沉浸式应用，遵循原生Material Design体验';
      case DisplayMode.web:
        return 'Web端响应式布局，自适应不同屏幕尺寸和浏览器环境';
    }
  }
  
  /// 获取显示模式的英文标识
  String get identifier {
    switch (this) {
      case DisplayMode.desktop:
        return 'desktop';
      case DisplayMode.mobile:
        return 'mobile';
      case DisplayMode.web:
        return 'web';
    }
  }
  
  /// 从标识符解析显示模式
  static DisplayMode fromIdentifier(String identifier) {
    switch (identifier) {
      case 'desktop':
        return DisplayMode.desktop;
      case 'mobile':
        return DisplayMode.mobile;
      case 'web':
        return DisplayMode.web;
      // 向后兼容旧的标识符
      case 'spatial_os':
        return DisplayMode.desktop;
      case 'super_app':
        return DisplayMode.mobile;
      case 'responsive_web':
        return DisplayMode.web;
      default:
        throw ArgumentError('Unknown display mode identifier: $identifier');
    }
  }
}

/// 显示模式变更事件
class DisplayModeChangedEvent {
  /// 新的显示模式
  final DisplayMode newMode;
  
  /// 之前的显示模式
  final DisplayMode previousMode;
  
  /// 变更时间戳
  final DateTime timestamp;
  
  /// 变更原因
  final String reason;
  
  DisplayModeChangedEvent({
    required this.newMode,
    required this.previousMode,
    required this.reason,
  }) : timestamp = DateTime.now();
  
  @override
  String toString() {
    return 'DisplayModeChangedEvent(${previousMode.displayName} -> ${newMode.displayName}, reason: $reason)';
  }
}

/// 显示模式服务
/// 管理应用的显示模式，支持持久化存储和切换逻辑
class DisplayModeService {
  static const String _storageKey = 'display_mode';
  static const String _lastChangeReasonKey = 'display_mode_last_change_reason';
  
  /// 默认显示模式
  static const DisplayMode _defaultMode = DisplayMode.mobile;
  
  /// 当前显示模式主题
  final BehaviorSubject<DisplayMode> _currentModeSubject = BehaviorSubject.seeded(_defaultMode);
  
  /// 显示模式变更事件流
  final PublishSubject<DisplayModeChangedEvent> _modeChangedSubject = PublishSubject<DisplayModeChangedEvent>();
  
  /// 初始化完成标志
  bool _isInitialized = false;
  
  /// SharedPreferences实例
  SharedPreferences? _prefs;
  
  /// 服务初始化状态
  bool get isInitialized => _isInitialized;
  
  /// 当前显示模式流
  Stream<DisplayMode> get currentModeStream => _currentModeSubject.stream;
  
  /// 当前显示模式值
  DisplayMode get currentMode => _currentModeSubject.value;
  
  /// 显示模式变更事件流
  Stream<DisplayModeChangedEvent> get modeChangedStream => _modeChangedSubject.stream;
  
  /// 支持的显示模式列表
  List<DisplayMode> get supportedModes => DisplayMode.values;
  
  /// 初始化服务
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    
    try {
      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // 从持久化存储加载显示模式
      await _loadDisplayMode();
      
      _isInitialized = true;
      
      // 发送初始化完成事件
      _emitModeChangedEvent(
        newMode: currentMode,
        previousMode: currentMode,
        reason: 'Service initialized',
      );
      
    } catch (e) {
      throw DisplayModeServiceException(
        'Failed to initialize DisplayModeService: $e',
        operation: 'initialize',
      );
    }
  }
  
  /// 从持久化存储加载显示模式
  Future<void> _loadDisplayMode() async {
    try {
      final storedIdentifier = _prefs?.getString(_storageKey);
      
      if (storedIdentifier != null) {
        final mode = DisplayModeExtension.fromIdentifier(storedIdentifier);
        _currentModeSubject.add(mode);
      } else {
        // 首次启动，使用默认模式并保存
        await _saveDisplayMode(_defaultMode);
      }
      
    } catch (e) {
      // 如果加载失败，使用默认模式
      _currentModeSubject.add(_defaultMode);
      await _saveDisplayMode(_defaultMode);
    }
  }
  
  /// 保存显示模式到持久化存储
  Future<void> _saveDisplayMode(DisplayMode mode, {String? reason}) async {
    try {
      await _prefs?.setString(_storageKey, mode.identifier);
      
      if (reason != null) {
        await _prefs?.setString(_lastChangeReasonKey, reason);
      }
      
    } catch (e) {
      throw DisplayModeServiceException(
        'Failed to save display mode: $e',
        operation: 'save',
        mode: mode,
      );
    }
  }
  
  /// 切换到指定的显示模式
  Future<void> switchToMode(DisplayMode newMode, {String reason = 'User requested'}) async {
    if (!_isInitialized) {
      throw DisplayModeServiceException(
        'Service not initialized',
        operation: 'switchToMode',
        mode: newMode,
      );
    }
    
    final previousMode = currentMode;
    
    // 如果已经是目标模式，不需要切换
    if (previousMode == newMode) {
      return;
    }
    
    try {
      // 保存到持久化存储
      await _saveDisplayMode(newMode, reason: reason);
      
      // 更新当前模式
      _currentModeSubject.add(newMode);
      
      // 发送模式变更事件
      _emitModeChangedEvent(
        newMode: newMode,
        previousMode: previousMode,
        reason: reason,
      );
      
    } catch (e) {
      throw DisplayModeServiceException(
        'Failed to switch display mode',
        operation: 'switchToMode',
        mode: newMode,
        cause: e,
      );
    }
  }
  
  /// 切换到下一个显示模式（循环切换）
  Future<void> switchToNextMode({String reason = 'Cycle switch'}) async {
    final currentIndex = supportedModes.indexOf(currentMode);
    final nextIndex = (currentIndex + 1) % supportedModes.length;
    final nextMode = supportedModes[nextIndex];
    
    await switchToMode(nextMode, reason: reason);
  }
  
  /// 检查指定模式是否可用
  bool isModeSupported(DisplayMode mode) {
    return supportedModes.contains(mode);
  }
  
  /// 获取上次模式变更的原因
  Future<String?> getLastChangeReason() async {
    return _prefs?.getString(_lastChangeReasonKey);
  }
  
  /// 重置为默认模式
  Future<void> resetToDefault({String reason = 'Reset to default'}) async {
    await switchToMode(_defaultMode, reason: reason);
  }
  
  /// 发送模式变更事件
  void _emitModeChangedEvent({
    required DisplayMode newMode,
    required DisplayMode previousMode,
    required String reason,
  }) {
    final event = DisplayModeChangedEvent(
      newMode: newMode,
      previousMode: previousMode,
      reason: reason,
    );
    
    _modeChangedSubject.add(event);
  }
  
  /// 清理资源
  Future<void> dispose() async {
    await _currentModeSubject.close();
    await _modeChangedSubject.close();
    _isInitialized = false;
  }
  
  /// 获取显示模式统计信息
  Map<String, dynamic> getDisplayModeStats() {
    return {
      'currentMode': currentMode.identifier,
      'currentModeDisplayName': currentMode.displayName,
      'supportedModes': supportedModes.map((mode) => mode.identifier).toList(),
      'isInitialized': _isInitialized,
    };
  }
  
  /// 验证显示模式配置
  bool validateConfiguration() {
    try {
      // 检查当前模式是否在支持列表中
      if (!isModeSupported(currentMode)) {
        return false;
      }
      
      // 检查初始化状态
      if (!_isInitialized) {
        return false;
      }
      
      // 检查持久化存储
      if (_prefs == null) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// 显示模式服务异常
class DisplayModeServiceException implements Exception {
  final String message;
  final String? operation;
  final DisplayMode? mode;
  final dynamic cause;

  const DisplayModeServiceException(
    this.message, {
    this.operation,
    this.mode,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('DisplayModeServiceException: $message');
    if (operation != null) buffer.write(' (Operation: $operation)');
    if (mode != null) buffer.write(' (Mode: ${mode!.displayName})');
    if (cause != null) buffer.write(' (Cause: $cause)');
    return buffer.toString();
  }
}

/// 全局显示模式服务实例
late final DisplayModeService displayModeService; 