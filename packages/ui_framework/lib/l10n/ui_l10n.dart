/*
---------------------------------------------------------------
File name:          ui_l10n.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        UI框架i18n初始化 - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';
import 'ui_zh.dart';
import 'ui_en.dart';

/// UI框架国际化初始化
class UIFrameworkL10n {
  static bool _isRegistered = false;

  /// 注册UI框架的i18n提供者
  static void register() {
    if (_isRegistered) {
      return;
    }

    final i18nService = I18nService.instance;
    
    // 注册中文翻译提供者
    i18nService.registerProvider(UIFrameworkZhProvider());
    
    // 注册英文翻译提供者
    i18nService.registerProvider(UIFrameworkEnProvider());
    
    _isRegistered = true;
  }

  /// 是否已注册
  static bool get isRegistered => _isRegistered;
}

/// UI框架翻译便捷方法
class UIL10n {
  static String t(String key, {Map<String, String>? fallback}) {
    final hardcodedFallback = _getHardcodedFallback(key);
    final fallbackMappings = {
      if (hardcodedFallback != null) key: hardcodedFallback,
      ...?fallback,
    };
    
    return I18nService.instance.translateUI(key, fallbackMappings: fallbackMappings);
  }

  /// 硬编码兜底翻译（保证基本可用）
  static String? _getHardcodedFallback(String key) {
    const fallbacks = {
      // EditDialog 硬编码兜底
      'edit_note': '编辑 笔记',
      'edit_todo': '编辑 待办',
      'edit_project': '编辑 项目',
      'edit_creative': '编辑 创意项目',
      'edit_punch_record': '编辑 打卡记录',
      
      'note_type': '笔记',
      'todo_type': '待办',
      'project_type': '项目',
      'creative_type': '创意项目',
      'punch_record_type': '打卡记录',
      
      'title_label': '标题',
      'title_empty_error': '标题不能为空',
      'title_min_length_error': '标题至少需要2个字符',
      'description_label': '描述',
      'content_label': '内容',
      'content_empty_error': '内容不能为空',
      'tags_label': '标签',
      'add_tag': '添加标签',
      'no_tags': '暂无标签',
      
      'save_button': '保存',
      'cancel_button': '取消',
      'close_button': '关闭',
      'save_failed': '保存失败',
      
      // 通用UI硬编码兜底
      'loading': '加载中...',
      'error': '错误',
      'success': '成功',
      'confirm': '确认',
      'yes': '是',
      'no': '否',
      'ok': 'OK',
    };
    
    return fallbacks[key];
  }
} 