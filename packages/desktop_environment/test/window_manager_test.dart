/*
---------------------------------------------------------------
File name:          window_manager_test.dart
Author:             Ignorant-lu
Date created:       2025/06/27
Last modified:      2025/06/27
Dart Version:       3.32.4
Description:        Desktop Environment WindowManager测试
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0b - 创建WindowManager测试;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_environment/desktop_environment.dart';

void main() {
  group('Desktop Environment WindowManager Tests', () {
    late WindowManager windowManager;

    setUp(() {
      windowManager = WindowManager();
    });

    test('should initialize WindowManager', () {
      expect(windowManager, isNotNull);
      expect(windowManager.windowCount, equals(0));
      expect(windowManager.activeWindows, isEmpty);
      expect(windowManager.focusedWindow, isNull);
    });

    test('should create and manage windows', () async {
      final config = WindowConfig(
        windowId: 'test_window',
        title: 'Test Window',
        content: Container(),
        initialSize: const Size(400, 300),
      );

      final success = await windowManager.createWindow(config);
      
      expect(success, isTrue);
      expect(windowManager.windowCount, equals(1));
      expect(windowManager.activeWindows, contains('test_window'));
      expect(windowManager.focusedWindow, equals('test_window'));
    });

    test('should prevent duplicate window creation', () async {
      final config = WindowConfig(
        windowId: 'duplicate_window',
        title: 'Duplicate Window',
        content: Container(),
      );

      // 第一次创建应该成功
      final firstAttempt = await windowManager.createWindow(config);
      expect(firstAttempt, isTrue);
      expect(windowManager.windowCount, equals(1));

      // 第二次创建应该成功（但不会重复创建，而是置顶）
      final secondAttempt = await windowManager.createWindow(config);
      expect(secondAttempt, isTrue);
      expect(windowManager.windowCount, equals(1)); // 仍然是1个窗口
    });

    test('should handle window states correctly', () async {
      final config = WindowConfig(
        windowId: 'state_window',
        title: 'State Window',
        content: Container(),
      );

      await windowManager.createWindow(config);
      
      // 测试最小化
      windowManager.minimizeWindow('state_window');
      expect(windowManager.getWindowState('state_window'), equals(WindowState.minimized));
      
      // 测试最大化
      windowManager.maximizeWindow('state_window');
      expect(windowManager.getWindowState('state_window'), equals(WindowState.maximized));
      
      // 测试恢复
      windowManager.restoreWindow('state_window');
      expect(windowManager.getWindowState('state_window'), equals(WindowState.normal));
    });

    test('should update window position and size', () async {
      final config = WindowConfig(
        windowId: 'geometry_window',
        title: 'Geometry Window',
        content: Container(),
        initialSize: const Size(400, 300),
      );

      await windowManager.createWindow(config);
      
      // 更新位置
      const newPosition = Offset(100, 50);
      windowManager.updateWindowPosition('geometry_window', newPosition);
      
      final geometry = windowManager.getWindowGeometry('geometry_window');
      expect(geometry?.position, equals(newPosition));
      
      // 更新大小
      const newSize = Size(500, 400);
      windowManager.updateWindowSize('geometry_window', newSize);
      
      final updatedGeometry = windowManager.getWindowGeometry('geometry_window');
      expect(updatedGeometry?.size, equals(newSize));
    });

    test('should enforce minimum window size', () async {
      final config = WindowConfig(
        windowId: 'min_size_window',
        title: 'Min Size Window',
        content: Container(),
      );

      await windowManager.createWindow(config);
      
      // 尝试设置过小的尺寸
      const tooSmallSize = Size(50, 50);
      windowManager.updateWindowSize('min_size_window', tooSmallSize);
      
      final geometry = windowManager.getWindowGeometry('min_size_window');
      expect(geometry?.size.width, greaterThanOrEqualTo(DesktopUtils.minWindowWidth));
      expect(geometry?.size.height, greaterThanOrEqualTo(DesktopUtils.minWindowHeight));
    });

    test('should close windows correctly', () async {
      final config = WindowConfig(
        windowId: 'close_window',
        title: 'Close Window',
        content: Container(),
      );

      await windowManager.createWindow(config);
      expect(windowManager.windowCount, equals(1));
      
      final success = await windowManager.closeWindow('close_window');
      expect(success, isTrue);
      expect(windowManager.windowCount, equals(0));
      expect(windowManager.activeWindows, isEmpty);
    });

    test('should handle window focus correctly', () async {
      // 创建两个窗口
      final config1 = WindowConfig(
        windowId: 'focus_window_1',
        title: 'Focus Window 1',
        content: Container(),
      );
      
      final config2 = WindowConfig(
        windowId: 'focus_window_2',
        title: 'Focus Window 2',
        content: Container(),
      );

      await windowManager.createWindow(config1);
      expect(windowManager.focusedWindow, equals('focus_window_1'));
      
      await windowManager.createWindow(config2);
      expect(windowManager.focusedWindow, equals('focus_window_2'));
      
      // 将第一个窗口置顶
      windowManager.bringToFront('focus_window_1');
      expect(windowManager.focusedWindow, equals('focus_window_1'));
    });

    test('should respect maximum window limit', () async {
      // 创建超过限制的窗口数量
      for (int i = 0; i < DesktopUtils.maxConcurrentWindows + 5; i++) {
        final config = WindowConfig(
          windowId: 'limit_window_$i',
          title: 'Limit Window $i',
          content: Container(),
        );
        
        await windowManager.createWindow(config);
      }
      
      // 应该只创建了最大允许数量的窗口
      expect(windowManager.windowCount, equals(DesktopUtils.maxConcurrentWindows));
    });

    test('should calculate next window position correctly', () async {
      // 创建多个窗口，测试层叠位置
      final configs = List.generate(3, (i) => WindowConfig(
        windowId: 'cascade_window_$i',
        title: 'Cascade Window $i',
        content: Container(),
      ));

      final positions = <Offset>[];
      
      for (final config in configs) {
        await windowManager.createWindow(config);
        final geometry = windowManager.getWindowGeometry(config.windowId);
        positions.add(geometry!.position);
      }

      // 验证窗口位置呈现层叠效果
      expect(positions[1].dx, greaterThan(positions[0].dx));
      expect(positions[1].dy, greaterThan(positions[0].dy));
      expect(positions[2].dx, greaterThan(positions[1].dx));
      expect(positions[2].dy, greaterThan(positions[1].dy));
    });
  });
} 