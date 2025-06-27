/*
---------------------------------------------------------------
File name:          theme_service_test.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        ThemeService单元测试 - Sprint 2.0d分层测试策略
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_framework/core/theme_service.dart';

void main() {
  group('ThemeConfig Tests', () {
    test('should create default config', () {
      const config = ThemeConfig();
      expect(config.themeMode, AppThemeMode.system);
      expect(config.colorSchemeType, ColorSchemeType.material);
      expect(config.fontStyleType, FontStyleType.system);
      expect(config.useMaterial3, true);
      expect(config.fontScale, 1.0);
    });

    test('should copy with changes', () {
      const original = ThemeConfig();
      final modified = original.copyWith(
        themeMode: AppThemeMode.dark,
        colorSchemeType: ColorSchemeType.blue,
      );
      
      expect(modified.themeMode, AppThemeMode.dark);
      expect(modified.colorSchemeType, ColorSchemeType.blue);
      expect(modified.fontStyleType, FontStyleType.system); // Unchanged
    });

    test('should convert to/from JSON', () {
      const config = ThemeConfig(
        themeMode: AppThemeMode.dark,
        colorSchemeType: ColorSchemeType.blue,
        fontScale: 1.2,
      );
      
      final json = config.toJson();
      final restored = ThemeConfig.fromJson(json);
      
      expect(restored.themeMode, config.themeMode);
      expect(restored.colorSchemeType, config.colorSchemeType);
      expect(restored.fontScale, config.fontScale);
    });
  });

  group('AppThemeMode Tests', () {
    test('should convert to Flutter ThemeMode', () {
      expect(AppThemeMode.light.flutterThemeMode, ThemeMode.light);
      expect(AppThemeMode.dark.flutterThemeMode, ThemeMode.dark);
      expect(AppThemeMode.system.flutterThemeMode, ThemeMode.system);
    });

    test('should parse from string', () {
      expect(AppThemeMode.fromString('light'), AppThemeMode.light);
      expect(AppThemeMode.fromString('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromString('system'), AppThemeMode.system);
      expect(AppThemeMode.fromString('invalid'), AppThemeMode.system);
    });

    test('should provide display names', () {
      expect(AppThemeMode.light.displayName, '浅色主题');
      expect(AppThemeMode.dark.displayName, '深色主题');
      expect(AppThemeMode.system.displayName, '跟随系统');
    });
  });

  group('ColorSchemeType Tests', () {
    test('should provide seed colors', () {
      expect(ColorSchemeType.blue.seedColor, Colors.blue);
      expect(ColorSchemeType.green.seedColor, Colors.green);
      expect(ColorSchemeType.red.seedColor, Colors.red);
    });

    test('should parse from string', () {
      expect(ColorSchemeType.fromString('blue'), ColorSchemeType.blue);
      expect(ColorSchemeType.fromString('green'), ColorSchemeType.green);
      expect(ColorSchemeType.fromString('invalid'), ColorSchemeType.material);
    });
  });

  group('FontStyleType Tests', () {
    test('should provide font families', () {
      expect(FontStyleType.system.fontFamily, null);
      expect(FontStyleType.pingFang.fontFamily, 'PingFang SC');
      expect(FontStyleType.noto.fontFamily, 'Noto Sans SC');
    });
  });

  group('InMemoryThemeStorage Tests', () {
    late InMemoryThemeStorage storage;

    setUp(() {
      storage = InMemoryThemeStorage();
    });

    test('should save and load config', () async {
      const config = ThemeConfig(themeMode: AppThemeMode.dark);
      
      await storage.saveThemeConfig(config);
      final loaded = await storage.loadThemeConfig();
      
      expect(loaded, config);
    });

    test('should clear config', () async {
      const config = ThemeConfig(themeMode: AppThemeMode.dark);
      await storage.saveThemeConfig(config);
      
      await storage.clearThemeConfig();
      final loaded = await storage.loadThemeConfig();
      
      expect(loaded, null);
    });
  });
} 