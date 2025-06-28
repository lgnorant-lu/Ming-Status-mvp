/*
---------------------------------------------------------------
File name:          routing_l10n.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        路由i18n初始化 - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';
import 'routing_zh.dart';
import 'routing_en.dart';

/// 路由国际化初始化
class AppRoutingL10n {
  static bool _isRegistered = false;

  /// 注册路由的i18n提供者
  static void register() {
    if (_isRegistered) {
      return;
    }

    final i18nService = I18nService.instance;
    
    // 注册中文翻译提供者
    i18nService.registerProvider(AppRoutingZhProvider());
    
    // 注册英文翻译提供者
    i18nService.registerProvider(AppRoutingEnProvider());
    
    _isRegistered = true;
  }

  /// 是否已注册
  static bool get isRegistered => _isRegistered;
}

/// 路由翻译便捷方法
class RoutingL10n {
  static String t(String key, {Map<String, String>? fallback}) {
    final hardcodedFallback = _getHardcodedFallback(key);
    final fallbackMappings = {
      if (hardcodedFallback != null) key: hardcodedFallback,
      ...?fallback,
    };
    
    return I18nService.instance.translateRouting(key, fallbackMappings: fallbackMappings);
  }

  /// 硬编码兜底翻译（保证基本可用）
  static String? _getHardcodedFallback(String key) {
    const fallbacks = {
      // 页面标题硬编码兜底
      'settings_title': '设置',
      'home_title': '首页',
      'about_title': '关于',
      
      // 设置页面硬编码兜底
      'language_settings': '语言设置',
      'display_mode_settings': '显示模式',
      'current_language': '当前语言',
      'current_mode': '当前模式',
      'switch_to_next_language': '切换到下一种语言',
      'switch_to_next_mode': '切换到下一种模式',
      'language_switched': '语言已切换',
      'language_switch_failed': '语言切换失败',
      
      // 通用按钮硬编码兜底
      'switch_button': '切换',
      'back_button': '返回',
      'home_button': '首页',
      
      // 错误信息硬编码兜底
      'page_not_found': '页面未找到',
      'navigation_error': '导航错误',
    };
    
    return fallbacks[key];
  }
} 