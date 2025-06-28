/*
---------------------------------------------------------------
File name:          i18n_service.dart
Author:             Ignorant-lu  
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        分布式国际化服务 - Phase 2.2 Sprint 2 实现包级i18n管理与多级失效策略
---------------------------------------------------------------
Change History:
    2025/06/28: Phase 2.2 Sprint 2 - 创建分布式I18nService，支持包级i18n注册;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'locale_service.dart';

/// 包级i18n提供者接口
abstract class PackageI18nProvider {
  /// 包名
  String get packageName;
  
  /// 支持的语言列表
  List<SupportedLocale> get supportedLocales;
  
  /// 获取指定语言的翻译文本
  /// [locale] 目标语言
  /// [key] 翻译键
  /// 返回null表示该包不包含此键的翻译
  String? getTranslation(SupportedLocale locale, String key);
  
  /// 获取所有翻译键列表（用于调试和验证）
  List<String> getAllKeys();
}

/// 分布式国际化服务
class I18nService {
  static I18nService? _instance;
  static I18nService get instance => _instance ??= I18nService._();
  
  I18nService._();

  /// 已注册的包级i18n提供者
  final Map<String, PackageI18nProvider> _providers = {};
  
  /// 当前语言环境（来自LocaleService）
  SupportedLocale _currentLocale = SupportedLocale.chinese;
  
  /// 语言变更监听器
  StreamSubscription<SupportedLocale>? _localeSubscription;
  
  /// 是否已初始化
  bool _isInitialized = false;
  
  /// 调试模式
  bool _debugMode = kDebugMode;

  /// 初始化i18n服务
  Future<void> initialize(LocaleService localeService) async {
    if (_isInitialized) {
      _debugLog('I18nService already initialized');
      return;
    }

    try {
      // 监听语言变更
      _currentLocale = localeService.currentLocale;
      _localeSubscription = localeService.localeStream.listen((locale) {
        _currentLocale = locale;
        _debugLog('I18nService语言已更新: ${locale.displayName}');
      });

      _isInitialized = true;
      _debugLog('I18nService初始化完成 - 当前语言: ${_currentLocale.displayName}');
    } catch (e) {
      _debugLog('I18nService初始化失败: $e');
      rethrow;
    }
  }

  /// 注册包级i18n提供者
  void registerProvider(PackageI18nProvider provider) {
    if (_providers.containsKey(provider.packageName)) {
      _debugLog('警告: 包 ${provider.packageName} 的i18n提供者已存在，将被覆盖');
    }
    
    _providers[provider.packageName] = provider;
    _debugLog('已注册包级i18n提供者: ${provider.packageName} (支持语言: ${provider.supportedLocales.map((l) => l.locale.languageCode).join(', ')})');
  }

  /// 注销包级i18n提供者
  void unregisterProvider(String packageName) {
    if (_providers.remove(packageName) != null) {
      _debugLog('已注销包级i18n提供者: $packageName');
    }
  }

  /// 翻译文本 - 核心方法
  /// 
  /// 多级失效策略:
  /// Level 1: 当前语言的包级翻译
  /// Level 2: 中文包级翻译（兜底）
  /// Level 3: 硬编码翻译映射
  /// Level 4: 返回key本身（最后兜底）
  String translate(String key, {
    String? packageName,
    SupportedLocale? locale,
    Map<String, String>? fallbackMappings,
  }) {
    final targetLocale = locale ?? _currentLocale;
    
    try {
      // Level 1: 尝试当前语言的包级翻译
      if (packageName != null) {
        final translation = _getPackageTranslation(packageName, targetLocale, key);
        if (translation != null) {
          return translation;
        }
      } else {
        // 没有指定包名，尝试当前语言的所有包
        final languageCode = targetLocale.locale.languageCode;
        
        for (final entry in _providers.entries) {
          final packageNameWithLocale = entry.key;
          final provider = entry.value;
          
          // 只查找当前语言的提供者
          if (packageNameWithLocale.endsWith('_$languageCode')) {
            final translation = provider.getTranslation(targetLocale, key);
            if (translation != null) {
              return translation;
            }
          }
        }
      }

      // Level 2: 如果当前不是中文，尝试中文兜底
      if (targetLocale != SupportedLocale.chinese) {
        if (packageName != null) {
          final fallbackTranslation = _getPackageTranslation(packageName, SupportedLocale.chinese, key);
          if (fallbackTranslation != null) {
            _debugLog('使用中文兜底翻译: $key -> $fallbackTranslation');
            return fallbackTranslation;
          }
        } else {
          // 尝试中文兜底
          for (final entry in _providers.entries) {
            final packageNameWithLocale = entry.key;
            final provider = entry.value;
            
            // 只查找中文提供者
            if (packageNameWithLocale.endsWith('_zh')) {
              final fallbackTranslation = provider.getTranslation(SupportedLocale.chinese, key);
              if (fallbackTranslation != null) {
                _debugLog('使用中文兜底翻译: $key -> $fallbackTranslation');
                return fallbackTranslation;
              }
            }
          }
        }
      }

      // Level 3: 硬编码映射兜底
      if (fallbackMappings != null && fallbackMappings.containsKey(key)) {
        final hardcodedTranslation = fallbackMappings[key]!;
        _debugLog('使用硬编码兜底翻译: $key -> $hardcodedTranslation');
        return hardcodedTranslation;
      }

      // Level 4: 最后兜底 - 返回key本身
      _debugLog('未找到翻译，返回key本身: $key');
      return key;
    } catch (e) {
      _debugLog('翻译过程中发生错误: $e，返回key本身');
      return key;
    }
  }

  /// 获取包级翻译
  String? _getPackageTranslation(String packageName, SupportedLocale locale, String key) {
    // 构建语言特定的包名 (packageName_languageCode)
    final languageCode = locale.locale.languageCode;
    final packageNameWithLocale = '${packageName}_$languageCode';
    
    final provider = _providers[packageNameWithLocale];
    if (provider == null) {
      _debugLog('未找到包级提供者: $packageNameWithLocale');
      return null;
    }

    try {
      return provider.getTranslation(locale, key);
    } catch (e) {
      _debugLog('包 $packageNameWithLocale 获取翻译失败: $e');
      return null;
    }
  }

  /// 便捷方法：翻译UI框架相关文本
  String translateUI(String key, {Map<String, String>? fallbackMappings}) {
    // 使用无包名查找模式，让系统自动查找当前语言的ui_framework提供者
    return translate(key, fallbackMappings: fallbackMappings);
  }

  /// 便捷方法：翻译核心服务相关文本
  String translateCore(String key, {Map<String, String>? fallbackMappings}) {
    return translate(key, packageName: 'core_services', fallbackMappings: fallbackMappings);
  }

  /// 便捷方法：翻译路由相关文本
  String translateRouting(String key, {Map<String, String>? fallbackMappings}) {
    // 使用无包名查找模式，让系统自动查找当前语言的app_routing提供者
    return translate(key, fallbackMappings: fallbackMappings);
  }

  /// 获取调试信息
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'currentLocale': _currentLocale.locale.languageCode,
      'registeredProviders': _providers.keys.toList(),
      'providerDetails': _providers.map((name, provider) => MapEntry(
        name,
        {
          'supportedLocales': provider.supportedLocales.map((l) => l.locale.languageCode).toList(),
          'totalKeys': provider.getAllKeys().length,
        },
      )),
    };
  }

  /// 验证翻译完整性（开发调试用）
  Map<String, List<String>> validateTranslations() {
    final issues = <String, List<String>>{};
    
    for (final entry in _providers.entries) {
      final packageName = entry.key;
      final provider = entry.value;
      final packageIssues = <String>[];
      
      final allKeys = provider.getAllKeys();
      for (final locale in SupportedLocale.values) {
        if (!provider.supportedLocales.contains(locale)) {
          packageIssues.add('不支持语言: ${locale.locale.languageCode}');
          continue;
        }
        
        final missingKeys = <String>[];
        for (final key in allKeys) {
          final translation = provider.getTranslation(locale, key);
          if (translation == null || translation.isEmpty) {
            missingKeys.add(key);
          }
        }
        
        if (missingKeys.isNotEmpty) {
          packageIssues.add('${locale.locale.languageCode}缺少翻译: ${missingKeys.join(', ')}');
        }
      }
      
      if (packageIssues.isNotEmpty) {
        issues[packageName] = packageIssues;
      }
    }
    
    return issues;
  }

  /// 获取所有已注册的包名
  List<String> getRegisteredPackages() {
    return _providers.keys.toList();
  }

  /// 检查包是否已注册
  bool isPackageRegistered(String packageName) {
    return _providers.containsKey(packageName);
  }

  /// 清理资源
  void dispose() {
    _localeSubscription?.cancel();
    _localeSubscription = null;
    _providers.clear();
    _isInitialized = false;
    _debugLog('I18nService已清理');
  }

  /// 调试日志
  void _debugLog(String message) {
    if (_debugMode) {
      debugPrint('[I18nService] $message');
    }
  }

  /// 设置调试模式
  void setDebugMode(bool debug) {
    _debugMode = debug;
  }
}

/// 包级i18n提供者的基础实现
abstract class BasePackageI18nProvider implements PackageI18nProvider {
  @override
  final String packageName;
  
  /// 翻译数据映射 [locale][key] = translation
  final Map<SupportedLocale, Map<String, String>> _translations = {};

  BasePackageI18nProvider(this.packageName);

  /// 添加翻译数据
  void addTranslations(SupportedLocale locale, Map<String, String> translations) {
    _translations[locale] = {..._translations[locale] ?? {}, ...translations};
  }

  @override
  List<SupportedLocale> get supportedLocales => _translations.keys.toList();

  @override
  String? getTranslation(SupportedLocale locale, String key) {
    return _translations[locale]?[key];
  }

  @override
  List<String> getAllKeys() {
    final allKeys = <String>{};
    for (final localeMap in _translations.values) {
      allKeys.addAll(localeMap.keys);
    }
    return allKeys.toList();
  }
}

/// 便捷的扩展方法
extension I18nServiceExtension on I18nService {
  /// 批量注册硬编码翻译（临时兜底方案）
  void registerHardcodedFallbacks(Map<String, Map<SupportedLocale, String>> hardcodedMappings) {
    for (final entry in hardcodedMappings.entries) {
      final key = entry.key;
      final translations = entry.value;
      
      // 可以创建一个临时的硬编码提供者
      final hardcodedProvider = _HardcodedProvider('hardcoded_fallbacks');
      for (final locale in translations.keys) {
        hardcodedProvider.addTranslations(locale, {key: translations[locale]!});
      }
      
      registerProvider(hardcodedProvider);
    }
  }
}

/// 硬编码提供者（临时兜底方案）
class _HardcodedProvider extends BasePackageI18nProvider {
  _HardcodedProvider(super.packageName);
} 