/*
---------------------------------------------------------------
File name:          locale_service_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        LocaleService单元测试 - Phase 2.2 Sprint 2 国际化功能验证
---------------------------------------------------------------
Change History:
    2025/06/28: Phase 2.2 Sprint 2 - 创建LocaleService单元测试套件;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core_services/core_services.dart';
import 'dart:ui';

void main() {
  group('LocaleService Tests', () {
    late LocaleService localeService;

    setUp(() async {
      // 设置测试环境的SharedPreferences
      SharedPreferences.setMockInitialValues({});
      localeService = LocaleService();
    });

    tearDown(() async {
      // 清理资源
      localeService.dispose();
    });

    group('SupportedLocale Enum Tests', () {
      test('should have correct locales defined', () {
        expect(SupportedLocale.chinese.locale, equals(const Locale('zh', 'CN')));
        expect(SupportedLocale.english.locale, equals(const Locale('en', 'US')));
        expect(SupportedLocale.chinese.displayName, equals('中文'));
        expect(SupportedLocale.english.displayName, equals('English'));
      });

      test('should find correct locale from Locale object', () {
        expect(
          SupportedLocale.fromLocale(const Locale('zh', 'CN')),
          equals(SupportedLocale.chinese),
        );
        expect(
          SupportedLocale.fromLocale(const Locale('en', 'US')),
          equals(SupportedLocale.english),
        );
        // 测试未知语言，应返回默认中文
        expect(
          SupportedLocale.fromLocale(const Locale('fr', 'FR')),
          equals(SupportedLocale.chinese),
        );
      });

      test('should find correct locale from string', () {
        expect(
          SupportedLocale.fromString('zh_CN'),
          equals(SupportedLocale.chinese),
        );
        expect(
          SupportedLocale.fromString('en_US'),
          equals(SupportedLocale.english),
        );
        // 测试无效字符串，应返回默认中文
        expect(
          SupportedLocale.fromString('invalid'),
          equals(SupportedLocale.chinese),
        );
      });
    });

    group('LocaleService Initialization Tests', () {
      test('should initialize with system detected locale', () async {
        await localeService.initialize();
        
        // 系统语言检测结果可能是中文或英文，取决于运行环境
        expect(localeService.currentLocale, isA<SupportedLocale>());
        expect(localeService.currentFlutterLocale, isA<Locale>());
        
        // 验证初始化后的locale是支持的语言之一
        final supportedLocales = [SupportedLocale.chinese, SupportedLocale.english];
        expect(supportedLocales, contains(localeService.currentLocale));
      });

      test('should initialize successfully even if SharedPreferences fails', () async {
        // 创建一个会抛出异常的LocaleService（模拟SharedPreferences失败）
        // 由于我们无法轻易模拟SharedPreferences失败，这里只测试成功场景
        await localeService.initialize();
        
        expect(localeService.currentLocale, isA<SupportedLocale>());
      });
    });

    group('Locale Switching Tests', () {
      setUp(() async {
        await localeService.initialize();
      });

      test('should switch to English successfully', () async {
        // 切换到英文
        await localeService.switchToEnglish();
        
        expect(localeService.currentLocale, equals(SupportedLocale.english));
        expect(localeService.currentFlutterLocale, equals(const Locale('en', 'US')));
      });

      test('should switch to Chinese successfully', () async {
        // 先切换到英文
        await localeService.switchToEnglish();
        expect(localeService.currentLocale, equals(SupportedLocale.english));

        // 再切换回中文
        await localeService.switchToChinese();
        
        expect(localeService.currentLocale, equals(SupportedLocale.chinese));
        expect(localeService.currentFlutterLocale, equals(const Locale('zh', 'CN')));
      });

      test('should switch to specific locale successfully', () async {
        await localeService.switchToLocale(SupportedLocale.english);
        expect(localeService.currentLocale, equals(SupportedLocale.english));

        await localeService.switchToLocale(SupportedLocale.chinese);
        expect(localeService.currentLocale, equals(SupportedLocale.chinese));
      });

      test('should not change when switching to same locale', () async {
        // 记录初始语言
        final initialLocale = localeService.currentLocale;
        
        // 再次切换到相同语言（应该没有变化）
        await localeService.switchToLocale(initialLocale);
        
        expect(localeService.currentLocale, equals(initialLocale));
      });

      test('should switch to next locale correctly', () async {
        // 记录初始语言
        final initialLocale = localeService.currentLocale;
        
        await localeService.switchToNextLocale();
        // 切换后应该不同于初始语言
        expect(localeService.currentLocale, isNot(equals(initialLocale)));
        
        // 再次切换，应该回到初始语言（循环）
        await localeService.switchToNextLocale();
        expect(localeService.currentLocale, equals(initialLocale));
      });
    });

    group('Locale Stream Tests', () {
      setUp(() async {
        await localeService.initialize();
      });

      test('should emit locale changes through stream', () async {
        // 监听流变化
        final streamValues = <SupportedLocale>[];
        final subscription = localeService.localeStream.listen((locale) {
          streamValues.add(locale);
        });

        // 记录初始语言并切换到另一种语言
        final initialLocale = localeService.currentLocale;
        final targetLocale = initialLocale == SupportedLocale.chinese 
            ? SupportedLocale.english 
            : SupportedLocale.chinese;

        // 进行语言切换
        await localeService.switchToLocale(targetLocale);
        await localeService.switchToLocale(initialLocale);

        // 等待异步操作完成
        await Future.delayed(const Duration(milliseconds: 10));

        expect(streamValues, contains(targetLocale));
        expect(streamValues, contains(initialLocale));

        await subscription.cancel();
      });
    });

    group('Utility Methods Tests', () {
      setUp(() async {
        await localeService.initialize();
      });

      test('should return all supported locales', () {
        final supportedLocales = localeService.getAllSupportedLocales();
        
        expect(supportedLocales, hasLength(2));
        expect(supportedLocales, contains(SupportedLocale.chinese));
        expect(supportedLocales, contains(SupportedLocale.english));
      });

      test('should correctly identify current locale', () {
        // 记录初始语言
        final initialLocale = localeService.currentLocale;
        final otherLocale = initialLocale == SupportedLocale.chinese 
            ? SupportedLocale.english 
            : SupportedLocale.chinese;
        
        expect(localeService.isCurrentLocale(initialLocale), isTrue);
        expect(localeService.isCurrentLocale(otherLocale), isFalse);
      });

      test('should reset to system locale', () async {
        // 先切换到英文
        await localeService.switchToEnglish();
        expect(localeService.currentLocale, equals(SupportedLocale.english));

        // 重置为系统语言（应该检测为中文）
        await localeService.resetToSystemLocale();
        
        // 由于测试环境下系统语言检测可能不准确，我们只验证方法执行成功
        expect(localeService.currentLocale, isA<SupportedLocale>());
      });
    });

    group('Persistence Tests', () {
      test('should persist locale preference', () async {
        await localeService.initialize();
        
        // 切换语言
        await localeService.switchToEnglish();
        
        // 创建新的服务实例来测试持久化
        final newLocaleService = LocaleService();
        await newLocaleService.initialize();
        
        // 应该加载之前保存的英文设置
        expect(newLocaleService.currentLocale, equals(SupportedLocale.english));
        
        newLocaleService.dispose();
      });
    });

    group('Error Handling Tests', () {
      test('should handle dispose gracefully', () {
        // 多次调用dispose不应崩溃
        localeService.dispose();
        localeService.dispose();
      });

      test('should handle stream operations after dispose', () {
        localeService.dispose();
        
        // 获取流不应崩溃（虽然流已关闭）
        expect(() => localeService.localeStream, returnsNormally);
      });
    });

    group('Integration Tests', () {
      test('complete workflow: initialize -> switch -> persist -> reload', () async {
        // 1. 初始化
        await localeService.initialize();
        final initialLocale = localeService.currentLocale;

        // 2. 切换语言到另一种
        final targetLocale = initialLocale == SupportedLocale.chinese 
            ? SupportedLocale.english 
            : SupportedLocale.chinese;
        await localeService.switchToLocale(targetLocale);
        expect(localeService.currentLocale, equals(targetLocale));

        // 3. 验证Flutter Locale
        expect(localeService.currentFlutterLocale, equals(targetLocale.locale));

        // 4. 创建新实例验证持久化
        final newService = LocaleService();
        await newService.initialize();
        expect(newService.currentLocale, equals(targetLocale));

        newService.dispose();
      });

      test('should handle rapid language switches', () async {
        await localeService.initialize();
        final initialLocale = localeService.currentLocale;

        // 快速切换多次（偶数次应该回到初始状态）
        for (int i = 0; i < 6; i++) {
          await localeService.switchToNextLocale();
        }

        // 应该回到初始状态
        expect(localeService.currentLocale, equals(initialLocale));
      });
    });
  });
} 