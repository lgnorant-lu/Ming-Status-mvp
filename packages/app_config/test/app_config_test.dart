/*
---------------------------------------------------------------
File name:          app_config_test.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        AppConfig单元测试 - Sprint 2.0d分层测试策略
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:app_config/app_config.dart';

void main() {
  group('AppConstants Tests', () {
    test('should provide app basic information', () {
      expect(AppConstants.appName, '桌宠助手');
      expect(AppConstants.appVersion, '1.0.0');
      expect(AppConstants.appBuildNumber, '1');
      expect(AppConstants.appDescription, isNotEmpty);
    });

    test('should provide network configuration', () {
      expect(AppConstants.baseApiUrl, isNotEmpty);
      expect(AppConstants.wsBaseUrl, isNotEmpty);
      expect(AppConstants.connectTimeout, greaterThan(0));
      expect(AppConstants.receiveTimeout, greaterThan(0));
    });

    test('should provide UI configuration', () {
      expect(AppConstants.animationDuration, isA<Duration>());
      expect(AppConstants.shortAnimationDuration, isA<Duration>());
      expect(AppConstants.longAnimationDuration, isA<Duration>());
    });
  });

  group('AppEnvironment Tests', () {
    test('should handle different environments', () {
      expect(AppEnvironment.development, isA<AppEnvironment>());
      expect(AppEnvironment.production, isA<AppEnvironment>());
      expect(AppEnvironment.testing, isA<AppEnvironment>());
      expect(AppEnvironment.staging, isA<AppEnvironment>());
    });

    test('should provide environment properties', () {
      expect(AppEnvironment.development.isDevelopment, true);
      expect(AppEnvironment.production.isProduction, true);
      expect(AppEnvironment.development.isDebugEnvironment, true);
      expect(AppEnvironment.production.isReleaseEnvironment, true);
    });

    test('should parse from string', () {
      expect(AppEnvironment.fromString('dev'), AppEnvironment.development);
      expect(AppEnvironment.fromString('prod'), AppEnvironment.production);
      expect(AppEnvironment.fromString('test'), AppEnvironment.testing);
      expect(AppEnvironment.fromString('invalid'), AppEnvironment.development);
    });
  });

  group('FeatureFlags Tests', () {
    test('should create default feature flags', () {
      const flags = FeatureFlags();
      expect(flags.enableNotesHub, true);
      expect(flags.enableWorkshop, true);
      expect(flags.enablePunchIn, true);
      expect(flags.enableAdvancedLogging, false);
    });

    test('should copy with changes', () {
      const original = FeatureFlags();
      final modified = original.copyWith(
        enableAdvancedLogging: true,
        enableBetaFeatures: true,
      );
      
      expect(modified.enableAdvancedLogging, true);
      expect(modified.enableBetaFeatures, true);
      expect(modified.enableNotesHub, true); // Unchanged
    });

    test('should provide enabled features list', () {
      const flags = FeatureFlags(
        enableNotesHub: true,
        enableWorkshop: false,
        enablePunchIn: true,
      );
      
      final enabled = flags.enabledFeatures;
      expect(enabled, contains('NotesHub'));
      expect(enabled, contains('PunchIn'));
      expect(enabled, isNot(contains('Workshop')));
    });
  });

  group('AppConfig Integration Tests', () {
    setUp(() async {
      // Reset before each test
      AppConfig.reset();
    });

    test('should initialize successfully', () async {
      expect(AppConfig.isInitialized, false);
      
      await AppConfig.initialize(
        environment: AppEnvironment.testing,
      );
      
      expect(AppConfig.isInitialized, true);
      final config = AppConfig.instance;
      expect(config.environment, AppEnvironment.testing);
    });

    test('should provide environment config', () async {
      await AppConfig.initialize(environment: AppEnvironment.development);
      
      final config = AppConfig.instance;
      expect(config.environmentConfig.environment, AppEnvironment.development);
      expect(config.environmentConfig.enableDebugMode, isA<bool>());
      expect(config.environmentConfig.apiBaseUrl, isNotEmpty);
    });

    test('should provide feature flags', () async {
      await AppConfig.initialize(environment: AppEnvironment.production);
      
      final config = AppConfig.instance;
      expect(config.featureFlags, isA<FeatureFlags>());
      expect(config.featureFlags.enabledFeatures, isA<List<String>>());
    });

    test('should throw error when not initialized', () {
      AppConfig.reset();
      expect(() => AppConfig.instance, throwsStateError);
    });
  });
} 