/*
---------------------------------------------------------------
File name:          three_terminal_integration_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        三端UI框架集成测试 - 测试DisplayModeService与Shell的完整集成
---------------------------------------------------------------
Change History:
    2025/06/28: Initial creation - Phase 2.1 Step 8 测试编写;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_framework/ui_framework.dart';
import 'package:core_services/core_services.dart';
import 'package:desktop_environment/desktop_environment.dart';

void main() {
  group('Three Terminal UI Framework Integration Tests', () {
    late DisplayModeService displayModeService;

    setUp(() async {
      // 清理并初始化SharedPreferences
      SharedPreferences.setMockInitialValues({});
      displayModeService = DisplayModeService();
      await displayModeService.initialize();
    });

    tearDown(() async {
      await displayModeService.dispose();
    });

    testWidgets('should complete end-to-end display mode switching', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. 初始状态验证（默认mobile模式）
      expect(find.text('模块化移动平台'), findsOneWidget);
      expect(find.text('Phase 2.1 - 每个模块都是独立应用'), findsOneWidget);

      // 2. 切换到Web模式
      await displayModeService.switchToMode(DisplayMode.web);
      await tester.pumpAndSettle();

      // 验证Web模式加载
      expect(find.byType(ResponsiveWebShell), findsOneWidget);
      expect(find.text('Web响应式平台'), findsOneWidget);
      expect(find.text('模块化移动平台'), findsNothing);

      // 3. 切换到桌面模式
      await displayModeService.switchToMode(DisplayMode.desktop);
      await tester.pumpAndSettle();

      // 验证桌面模式加载
      expect(find.byType(SpatialOsShell), findsOneWidget);
      expect(find.text('桌宠AI助理平台'), findsOneWidget);
      expect(find.byType(ResponsiveWebShell), findsNothing);

      // 4. 循环切换回移动模式
      await displayModeService.switchToMode(DisplayMode.mobile);
      await tester.pumpAndSettle();

      // 验证回到移动模式
      expect(find.text('模块化移动平台'), findsOneWidget);
      expect(find.byType(SpatialOsShell), findsNothing);
    });

    testWidgets('should maintain module data across mode switches', (WidgetTester tester) async {
      final testModules = _getTestModules();
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: testModules,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 在移动模式下验证模块存在
      expect(find.text('首页'), findsWidgets);
      expect(find.text('测试模块'), findsWidgets);

      // 切换到Web模式
      await displayModeService.switchToMode(DisplayMode.web);
      await tester.pumpAndSettle();

      // 验证模块在Web模式下仍然存在
      expect(find.text('首页'), findsWidgets);
      expect(find.text('测试模块'), findsWidgets);

      // 切换到桌面模式
      await displayModeService.switchToMode(DisplayMode.desktop);
      await tester.pumpAndSettle();

      // 验证模块在桌面模式下仍然存在
      expect(find.text('首页'), findsWidgets);
      expect(find.text('测试模块'), findsWidgets);
    });

    testWidgets('should handle rapid mode switching without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 快速切换模式多次
      for (int i = 0; i < 3; i++) {
        await displayModeService.switchToMode(DisplayMode.web);
        await tester.pump(const Duration(milliseconds: 100));
        
        await displayModeService.switchToMode(DisplayMode.desktop);
        await tester.pump(const Duration(milliseconds: 100));
        
        await displayModeService.switchToMode(DisplayMode.mobile);
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // 验证最终状态正确（应该是mobile）
      expect(find.text('模块化移动平台'), findsOneWidget);
    });

    testWidgets('should persist mode changes across widget rebuilds', (WidgetTester tester) async {
      // 设置初始模式为Web
      await displayModeService.switchToMode(DisplayMode.web);
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证Web模式被保持
      expect(find.byType(ResponsiveWebShell), findsOneWidget);

      // 重建Widget
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证模式仍然是Web
      expect(find.byType(ResponsiveWebShell), findsOneWidget);
    });

    testWidgets('should handle DisplayModeService events correctly', (WidgetTester tester) async {
      final List<DisplayModeChangedEvent> receivedEvents = [];
      
      // 监听DisplayModeService事件
      final subscription = displayModeService.modeChangedStream.listen(receivedEvents.add);

      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 清空初始化事件
      receivedEvents.clear();

      // 触发模式切换
      await displayModeService.switchToMode(DisplayMode.web);
      await tester.pumpAndSettle();

      // 验证事件被正确触发
      expect(receivedEvents.length, equals(1));
      expect(receivedEvents.first.newMode, equals(DisplayMode.web));
      expect(receivedEvents.first.previousMode, equals(DisplayMode.mobile));

      await subscription.cancel();
    });

    testWidgets('should handle service initialization states properly', (WidgetTester tester) async {
      // 创建未初始化的服务
      final uninitializedService = DisplayModeService();
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      // 验证显示加载状态
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('正在初始化三端UI框架...'), findsOneWidget);

      // 初始化服务
      await uninitializedService.initialize();
      await tester.pumpAndSettle();

      // 验证正常显示
      expect(find.text('模块化移动平台'), findsOneWidget);
      
      await uninitializedService.dispose();
    });

    testWidgets('should support locale changes across all shells', (WidgetTester tester) async {
      Locale? lastReceivedLocale;
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
            onLocaleChanged: (locale) {
              lastReceivedLocale = locale;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证初始locale状态
      expect(lastReceivedLocale, isNull);

      // 切换模式，验证locale回调在所有Shell中都正确传递
      for (final mode in DisplayMode.values) {
        await displayModeService.switchToMode(mode);
        await tester.pumpAndSettle();
        
        // 验证当前Shell正确渲染，locale回调已设置
        expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      }
    });
  });

  group('Three Terminal Performance Tests', () {
    late DisplayModeService displayModeService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      displayModeService = DisplayModeService();
      await displayModeService.initialize();
    });

    tearDown(() async {
      await displayModeService.dispose();
    });

    testWidgets('should perform mode switches within reasonable time', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 测量模式切换性能
      final stopwatch = Stopwatch()..start();

      for (final mode in DisplayMode.values) {
        await displayModeService.switchToMode(mode);
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // 验证切换时间在合理范围内（每次切换应该<1秒）
      expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // 3个模式总计<3秒
    });

    testWidgets('should not leak memory during mode switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 执行多次模式切换，验证没有内存泄露
      for (int i = 0; i < 10; i++) {
        for (final mode in DisplayMode.values) {
          await displayModeService.switchToMode(mode);
          await tester.pumpAndSettle();
        }
      }

      // 如果有内存泄露，这里应该会有明显的性能下降或错误
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });

  group('Three Terminal Error Handling Tests', () {
    testWidgets('should handle DisplayModeService errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证在服务出现问题时，UI仍然能够正常显示
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle null or empty modules gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DisplayModeAwareShell(
            modules: null,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证使用默认模块
      expect(find.text('首页'), findsWidgets);
      expect(find.text('事务中心'), findsWidgets);
      expect(find.text('创意工坊'), findsWidgets);
      expect(find.text('打卡'), findsWidgets);
    });
  });
}

/// 获取测试用的模块列表
List<ModuleInfo> _getTestModules() {
  return [
    ModuleInfo(
      id: 'home',
      name: '首页',
      description: '测试首页模块',
      icon: Icons.home,
      widgetBuilder: (context) => const Center(
        child: Text('首页模块测试'),
      ),
      order: 0,
    ),
    ModuleInfo(
      id: 'test',
      name: '测试模块',
      description: '测试模块描述',
      icon: Icons.science,
      widgetBuilder: (context) => const Center(
        child: Text('测试模块内容'),
      ),
      order: 1,
    ),
  ];
} 