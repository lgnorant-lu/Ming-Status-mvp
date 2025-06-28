/*
---------------------------------------------------------------
File name:          workshop_l10n.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Workshop L10n Export - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

import 'workshop_zh.dart';
import 'workshop_en.dart';

/// Workshop i18n导出所有
export 'workshop_zh.dart';
export 'workshop_en.dart';

/// Workshop本地化导出
class WorkshopL10n {
  /// 便捷翻译方法 - 自动查找当前语言的翻译
  static String t(String key) {
    return I18nService.instance.translate(key, packageName: 'workshop');
  }

  /// 获取所有Workshop的i18n提供者
  static List<PackageI18nProvider> getAllProviders() {
    return [
      WorkshopZhProvider(),
      WorkshopEnProvider(),
    ];
  }
} 