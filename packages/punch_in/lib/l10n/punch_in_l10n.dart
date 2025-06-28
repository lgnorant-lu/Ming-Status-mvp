/*
---------------------------------------------------------------
File name:          punch_in_l10n.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Punch In L10n Export - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

import 'punch_in_zh.dart';
import 'punch_in_en.dart';

/// Punch In i18n导出所有
export 'punch_in_zh.dart';
export 'punch_in_en.dart';

/// Punch In本地化导出
class PunchInL10n {
  /// 便捷翻译方法 - 自动查找当前语言的翻译
  static String t(String key) {
    return I18nService.instance.translate(key, packageName: 'punch_in');
  }

  /// 获取所有Punch In的i18n提供者
  static List<PackageI18nProvider> getAllProviders() {
    return [
      PunchInZhProvider(),
      PunchInEnProvider(),
    ];
  }
} 