/*
---------------------------------------------------------------
File name:          display_mode_service_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        DisplayModeService单元测试 - 更新为新的枚举命名
---------------------------------------------------------------
Change History:
    2025/06/28: Initial creation and enum updates - Phase 2.1 三端UI框架;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core_services/core_services.dart';

void main() {
  group('DisplayModeService Tests', () {
    late DisplayModeService service;

    setUp(() async {
      // 清理SharedPreferences
      SharedPreferences.setMockInitialValues({});
      service = DisplayModeService();
    });

    tearDown(() async {
      await service.dispose();
    });

    group('初始化测试', () {
      test('should initialize with default mode', () async {
        await service.initialize();
        expect(service.isInitialized, isTrue);
        expect(service.currentMode, equals(DisplayMode.mobile));
      });

      test('should emit initialization event', () async {
        final events = <DisplayModeChangedEvent>[];
        
        // 在初始化前设置监听器
        final subscription = service.modeChangedStream.listen(events.add);

        await service.initialize();
        
        // 等待异步事件传播
        await Future.delayed(const Duration(milliseconds: 10));

        expect(events.length, equals(1));
        expect(events.first.reason, equals('Service initialized'));
        
        await subscription.cancel();
      });

      test('should not re-initialize if already initialized', () async {
        await service.initialize();
        final firstInit = service.isInitialized;
        
        await service.initialize();
        expect(service.isInitialized, equals(firstInit));
      });
    });

    group('显示模式切换测试', () {
      test('should switch to desktop mode', () async {
        await service.initialize();
        
        await service.switchToMode(DisplayMode.desktop);
        expect(service.currentMode, DisplayMode.desktop);
      });

      test('should switch to web mode', () async {
        await service.initialize();
        
        await service.switchToMode(DisplayMode.web);
        expect(service.currentMode, DisplayMode.web);
      });

      test('should not switch if already in target mode', () async {
        await service.initialize();
        
        final initialMode = service.currentMode;
        await service.switchToMode(service.currentMode);
        expect(service.currentMode, initialMode);
      });

      test('should cycle through all modes with switchToNextMode', () async {
        await service.initialize();
        
        // 从mobile开始 (默认模式)
        expect(service.currentMode, DisplayMode.mobile);
        
        // 切换到web (mobile的下一个)
        await service.switchToNextMode();
        expect(service.currentMode, DisplayMode.web);
        
        // 切换到desktop (web的下一个)
        await service.switchToNextMode();
        expect(service.currentMode, DisplayMode.desktop);
        
        // 循环回到mobile (desktop的下一个)
        await service.switchToNextMode();
        expect(service.currentMode, DisplayMode.mobile);
      });
    });

    group('持久化存储测试', () {
      test('should persist mode changes', () async {
        await service.initialize();
        
        await service.switchToMode(DisplayMode.desktop);
        
        // 创建新的服务实例验证持久化
        final newService = DisplayModeService();
        await newService.initialize();
        
        expect(newService.currentMode, DisplayMode.desktop);
        await newService.dispose();
      });

      test('should save change reason', () async {
        await service.initialize();
        
        const reason = 'Test switch';
        await service.switchToMode(DisplayMode.web, reason: reason);
        
        final savedReason = await service.getLastChangeReason();
        expect(savedReason, reason);
      });
    });

    group('模式支持和验证测试', () {
      test('should support all display modes', () async {
        await service.initialize();
        
        expect(service.isModeSupported(DisplayMode.desktop), isTrue);
        expect(service.isModeSupported(DisplayMode.mobile), isTrue);
        expect(service.isModeSupported(DisplayMode.web), isTrue);
      });

      test('should have correct supported modes list', () async {
        await service.initialize();
        
        final supportedModes = service.supportedModes;
        expect(supportedModes, hasLength(3));
        expect(supportedModes, contains(DisplayMode.desktop));
        expect(supportedModes, contains(DisplayMode.mobile));
        expect(supportedModes, contains(DisplayMode.web));
      });

      test('should reset to default mode', () async {
        await service.initialize();
        
        // 切换到非默认模式
        await service.switchToMode(DisplayMode.desktop);
        expect(service.currentMode, DisplayMode.desktop);
        
        // 重置为默认模式
        await service.resetToDefault();
        expect(service.currentMode, DisplayMode.mobile);
      });

      test('should validate configuration correctly', () async {
        await service.initialize();
        expect(service.validateConfiguration(), isTrue);
      });
    });

    group('错误处理测试', () {
      test('should throw exception when switching mode before initialization', () async {
        expect(
          () => service.switchToMode(DisplayMode.desktop),
          throwsA(isA<DisplayModeServiceException>()),
        );
      });

      test('should handle service disposal gracefully', () async {
        await service.initialize();
        await service.dispose();
        
        expect(service.isInitialized, isFalse);
      });
    });

    group('DisplayModeExtension 测试', () {
      test('should return correct display names', () {
        expect(DisplayMode.desktop.displayName, '桌面模式');
        expect(DisplayMode.mobile.displayName, '移动模式');
        expect(DisplayMode.web.displayName, 'Web模式');
      });

      test('should return correct descriptions', () {
        expect(DisplayMode.desktop.description, contains('PC端空间化桌面环境'));
        expect(DisplayMode.mobile.description, contains('移动端沉浸式应用'));
        expect(DisplayMode.web.description, contains('Web端响应式布局'));
      });

      test('should return correct identifiers', () {
        expect(DisplayMode.desktop.identifier, 'desktop');
        expect(DisplayMode.mobile.identifier, 'mobile');
        expect(DisplayMode.web.identifier, 'web');
      });

      test('should parse identifiers correctly', () {
        expect(DisplayModeExtension.fromIdentifier('desktop'), DisplayMode.desktop);
        expect(DisplayModeExtension.fromIdentifier('mobile'), DisplayMode.mobile);
        expect(DisplayModeExtension.fromIdentifier('web'), DisplayMode.web);
      });

      test('should support legacy identifiers for backward compatibility', () {
        expect(DisplayModeExtension.fromIdentifier('spatial_os'), DisplayMode.desktop);
        expect(DisplayModeExtension.fromIdentifier('super_app'), DisplayMode.mobile);
        expect(DisplayModeExtension.fromIdentifier('responsive_web'), DisplayMode.web);
      });

      test('should throw error for invalid identifiers', () {
        expect(
          () => DisplayModeExtension.fromIdentifier('invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('DisplayModeChangedEvent 测试', () {
      test('should emit events on mode changes', () async {
        await service.initialize();
        
        DisplayModeChangedEvent? receivedEvent;
        service.modeChangedStream.listen((event) {
          receivedEvent = event;
        });
        
        await service.switchToMode(DisplayMode.desktop);
        
        // 给事件流一些时间
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.newMode, DisplayMode.desktop);
        expect(receivedEvent!.previousMode, DisplayMode.mobile);
        expect(receivedEvent!.reason, 'User requested');
      });

      test('should emit initialization event', () async {
        DisplayModeChangedEvent? receivedEvent;
        service.modeChangedStream.listen((event) {
          receivedEvent = event;
        });
        
        await service.initialize();
        
        // 给事件流一些时间
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.reason, 'Service initialized');
      });
    });

    group('DisplayModeService 统计和工具方法测试', () {
      test('should return correct stats', () async {
        await service.initialize();
        
        final stats = service.getDisplayModeStats();
        expect(stats['currentMode'], 'mobile');
        expect(stats['currentModeDisplayName'], '移动模式');
        expect(stats['supportedModes'], ['desktop', 'mobile', 'web']);
        expect(stats['isInitialized'], isTrue);
      });
    });
  });

  group('DisplayModeServiceException Tests', () {
    test('should create exception with message only', () {
      const exception = DisplayModeServiceException('Test message');
      expect(exception.message, 'Test message');
      expect(exception.operation, isNull);
      expect(exception.mode, isNull);
      expect(exception.cause, isNull);
    });

    test('should create exception with all parameters', () {
      const exception = DisplayModeServiceException(
        'Test message',
        operation: 'test_operation',
        mode: DisplayMode.desktop,
        cause: 'Test cause',
      );
      
      expect(exception.message, 'Test message');
      expect(exception.operation, 'test_operation');
      expect(exception.mode, DisplayMode.desktop);
      expect(exception.cause, 'Test cause');
      
      final exceptionString = exception.toString();
      expect(exceptionString, contains('Test message'));
      expect(exceptionString, contains('test_operation'));
      expect(exceptionString, contains('桌面模式'));
      expect(exceptionString, contains('Test cause'));
    });
  });
} 