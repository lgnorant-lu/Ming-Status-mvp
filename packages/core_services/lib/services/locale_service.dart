/*
---------------------------------------------------------------
File name:          locale_service.dart
Author:             Ignorant-lu  
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        语言服务 - Phase 2.2 Sprint 2 国际化系统重建，响应式语言切换管理
---------------------------------------------------------------
Change History:
    2025/06/28: Phase 2.2 Sprint 2 - 创建LocaleService，实现响应式语言切换;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 支持的语言环境枚举
enum SupportedLocale {
  chinese(Locale('zh', 'CN'), '中文', '简体中文'),
  english(Locale('en', 'US'), 'English', 'English (US)');

  const SupportedLocale(this.locale, this.displayName, this.description);

  final Locale locale;
  final String displayName;
  final String description;

  /// 从Locale查找对应的SupportedLocale
  static SupportedLocale fromLocale(Locale locale) {
    for (final supportedLocale in SupportedLocale.values) {
      if (supportedLocale.locale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    return SupportedLocale.chinese; // 默认中文
  }

  /// 从字符串查找对应的SupportedLocale
  static SupportedLocale fromString(String localeString) {
    for (final supportedLocale in SupportedLocale.values) {
      if (supportedLocale.locale.toString() == localeString) {
        return supportedLocale;
      }
    }
    return SupportedLocale.chinese; // 默认中文
  }
}

/// 语言服务 - 管理应用语言切换和持久化
/// 
/// 基于DisplayModeService的成功架构模式，实现：
/// - 响应式语言状态管理
/// - 用户偏好持久化存储
/// - 系统语言自动检测
/// - 动态语言切换
class LocaleService {
  static const String _localeKey = 'user_preferred_locale';
  
  SupportedLocale _currentLocale = SupportedLocale.chinese;
  SharedPreferences? _prefs;
  
  // 响应式流控制器
  final StreamController<SupportedLocale> _localeController = 
      StreamController<SupportedLocale>.broadcast();

  /// 当前语言环境
  SupportedLocale get currentLocale => _currentLocale;
  
  /// 当前语言的Locale对象
  Locale get currentFlutterLocale => _currentLocale.locale;

  /// 语言切换事件流
  Stream<SupportedLocale> get localeStream => _localeController.stream;

  /// 初始化服务
  Future<void> initialize() async {
    try {
      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // 加载用户偏好语言
      await _loadUserPreferredLocale();
      
      if (kDebugMode) {
        print('✅ LocaleService 初始化完成 - 当前语言: ${_currentLocale.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ LocaleService 初始化失败: $e');
      }
      // 使用默认语言继续运行
      _currentLocale = SupportedLocale.chinese;
    }
  }

  /// 加载用户偏好语言
  Future<void> _loadUserPreferredLocale() async {
    if (_prefs == null) return;

    try {
      final savedLocaleString = _prefs!.getString(_localeKey);
      
      if (savedLocaleString != null) {
        // 加载保存的语言偏好
        _currentLocale = SupportedLocale.fromString(savedLocaleString);
        if (kDebugMode) {
          print('📱 已加载用户偏好语言: ${_currentLocale.displayName}');
        }
      } else {
        // 检测系统语言
        _currentLocale = _detectSystemLocale();
        // 保存检测到的语言
        await _saveLocalePreference(_currentLocale);
        if (kDebugMode) {
          print('🔍 已检测系统语言: ${_currentLocale.displayName}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 加载语言偏好失败: $e');
      }
      _currentLocale = SupportedLocale.chinese;
    }
  }

  /// 检测系统语言
  SupportedLocale _detectSystemLocale() {
    try {
      final systemLocales = PlatformDispatcher.instance.locales;
      
      for (final systemLocale in systemLocales) {
        // 检查是否支持该语言
        for (final supportedLocale in SupportedLocale.values) {
          if (supportedLocale.locale.languageCode == systemLocale.languageCode) {
            return supportedLocale;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 系统语言检测失败: $e');
      }
    }
    
    // 默认返回中文
    return SupportedLocale.chinese;
  }

  /// 切换到指定语言
  Future<void> switchToLocale(SupportedLocale newLocale) async {
    if (newLocale == _currentLocale) {
      if (kDebugMode) {
        print('💡 语言未改变: ${newLocale.displayName}');
      }
      return;
    }

    try {
      final previousLocale = _currentLocale;
      _currentLocale = newLocale;

      // 保存到SharedPreferences
      await _saveLocalePreference(newLocale);

      // 发送语言切换事件
      _localeController.add(_currentLocale);

      if (kDebugMode) {
        print('🌐 语言已切换: ${previousLocale.displayName} → ${newLocale.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 语言切换失败: $e');
      }
      // 回滚到之前的语言
      _currentLocale = _currentLocale;
      rethrow;
    }
  }

  /// 切换到下一种语言
  Future<void> switchToNextLocale() async {
    final currentIndex = SupportedLocale.values.indexOf(_currentLocale);
    final nextIndex = (currentIndex + 1) % SupportedLocale.values.length;
    final nextLocale = SupportedLocale.values[nextIndex];
    
    await switchToLocale(nextLocale);
  }

  /// 切换到中文
  Future<void> switchToChinese() async {
    await switchToLocale(SupportedLocale.chinese);
  }

  /// 切换到英文
  Future<void> switchToEnglish() async {
    await switchToLocale(SupportedLocale.english);
  }

  /// 获取所有支持的语言
  List<SupportedLocale> getAllSupportedLocales() {
    return SupportedLocale.values;
  }

  /// 检查是否为当前语言
  bool isCurrentLocale(SupportedLocale locale) {
    return _currentLocale == locale;
  }

  /// 保存语言偏好到本地存储
  Future<void> _saveLocalePreference(SupportedLocale locale) async {
    if (_prefs == null) return;

    try {
      await _prefs!.setString(_localeKey, locale.locale.toString());
      if (kDebugMode) {
        print('💾 语言偏好已保存: ${locale.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 保存语言偏好失败: $e');
      }
    }
  }

  /// 重置为系统语言
  Future<void> resetToSystemLocale() async {
    final systemLocale = _detectSystemLocale();
    await switchToLocale(systemLocale);
  }

  /// 清理资源
  void dispose() {
    _localeController.close();
    if (kDebugMode) {
      print('🧹 LocaleService 资源已清理');
    }
  }
}

/// 全局LocaleService实例
late LocaleService localeService; 