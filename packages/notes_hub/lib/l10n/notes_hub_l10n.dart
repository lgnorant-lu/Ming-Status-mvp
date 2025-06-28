/*
---------------------------------------------------------------
File name:          notes_hub_l10n.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Notes Hub L10n Export - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

import 'notes_hub_zh.dart';
import 'notes_hub_en.dart';

/// Notes Hub i18n导出所有
export 'notes_hub_zh.dart';
export 'notes_hub_en.dart';

/// Notes Hub本地化导出
class NotesHubL10n {
  /// 便捷翻译方法 - 自动查找当前语言的翻译
  static String t(String key) {
    return I18nService.instance.translate(key, packageName: 'notes_hub');
  }

  /// 获取所有Notes Hub的i18n提供者
  static List<PackageI18nProvider> getAllProviders() {
    return [
      NotesHubZhProvider(),
      NotesHubEnProvider(),
    ];
  }
} 