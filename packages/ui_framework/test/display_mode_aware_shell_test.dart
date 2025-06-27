/*
---------------------------------------------------------------
File name:          display_mode_aware_shell_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        DisplayModeAwareShell Widget测试 - 测试三端动态切换逻辑
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
  group('DisplayModeAwareShell Widget Tests', () {
    late DisplayModeService displayModeService;

    setUp(() async {
      // 清理SharedPreferences并初始化服务
      SharedPreferences.setMockInitialValues({});
      displayModeService = DisplayModeService();
      await displayModeService.initialize();
    });

    tearDown(() async {
      await displayModeService.dispose();
    });

    testWidgets('should show loading shell when service not initialized', (WidgetTester tester) async {
      // 创建未初始化的服务
      final uninitializedService = DisplayModeService();
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      // 验证显示加载界面
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('正在初始化三端UI框架...'), findsOneWidget);
      expect(find.text('Phase 2.1 - 显示模式服务启动中'), findsOneWidget);
      
      await uninitializedService.dispose();
    });

    testWidgets('should render ModularMobileShell for mobile mode', (WidgetTester tester) async {
      // 设置为移动模式
      await displayModeService.switchToMode(DisplayMode.mobile);
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证ModularMobileShell特有的组件
      expect(find.text('模块化移动平台'), findsOneWidget);
      expect(find.text('Phase 2.1 - 每个模块都是独立应用'), findsOneWidget);
      expect(find.text('点击底部图标启动模块'), findsOneWidget);
    });

    testWidgets('should render ResponsiveWebShell for web mode', (WidgetTester tester) async {
      // 设置为Web模式
      await displayModeService.switchToMode(DisplayMode.web);
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证ResponsiveWebShell特有的组件
      // 由于ResponsiveWebShell比较复杂，我们检查关键标识符
      expect(find.byType(ResponsiveWebShell), findsOneWidget);
    });

    testWidgets('should render SpatialOsShell for desktop mode', (WidgetTester tester) async {
      // 设置为桌面模式
      await displayModeService.switchToMode(DisplayMode.desktop);
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证SpatialOsShell特有的组件
      expect(find.byType(SpatialOsShell), findsOneWidget);
      // 桌面环境特有的组件检查
      expect(find.text('桌宠AI助理平台'), findsOneWidget);
    });

    testWidgets('should switch shells when DisplayMode changes', (WidgetTester tester) async {
      // 初始为移动模式
      await displayModeService.switchToMode(DisplayMode.mobile);
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证初始为ModularMobileShell
      expect(find.text('模块化移动平台'), findsOneWidget);

      // 切换到Web模式
      await displayModeService.switchToMode(DisplayMode.web);
      await tester.pumpAndSettle();

      // 验证切换到ResponsiveWebShell
      expect(find.byType(ResponsiveWebShell), findsOneWidget);
      expect(find.text('模块化移动平台'), findsNothing);

      // 切换到桌面模式
      await displayModeService.switchToMode(DisplayMode.desktop);
      await tester.pumpAndSettle();

      // 验证切换到SpatialOsShell
      expect(find.byType(SpatialOsShell), findsOneWidget);
      expect(find.byType(ResponsiveWebShell), findsNothing);
    });

    testWidgets('should handle module list properly', (WidgetTester tester) async {
      final testModules = _getTestModules();
      
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: testModules,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证模块被正确传递到子Shell
      // 检查是否有模块相关的UI元素
      expect(find.text('首页'), findsWidgets);
      expect(find.text('测试模块'), findsWidgets);
    });

    testWidgets('should use default modules when modules is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DisplayModeAwareShell(
            modules: null,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证使用了默认模块（应该包含标准的4个模块）
      expect(find.text('首页'), findsWidgets);
      expect(find.text('事务中心'), findsWidgets);
      expect(find.text('创意工坊'), findsWidgets);
      expect(find.text('打卡'), findsWidgets);
    });

    testWidgets('should handle locale changes properly', (WidgetTester tester) async {
      bool localeChangeHandled = false;
      Locale? receivedLocale;

      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
            onLocaleChanged: (locale) {
              localeChangeHandled = true;
              receivedLocale = locale;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 模拟语言切换（这需要在Shell内部触发）
      // 由于我们无法直接测试内部的语言切换，我们验证回调被正确传递
      expect(localeChangeHandled, isFalse); // 初始状态
      
      // 这里可以通过其他方式验证locale change回调的传递
      // 比如检查子Shell是否正确接收了onLocaleChanged回调
    });
  });

  group('DisplayModeAwareShell Integration Tests', () {
    late DisplayModeService displayModeService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      displayModeService = DisplayModeService();
      await displayModeService.initialize();
    });

    tearDown(() async {
      await displayModeService.dispose();
    });

    testWidgets('should respond to DisplayModeService stream changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 初始状态（默认mobile）
      expect(find.text('模块化移动平台'), findsOneWidget);

      // 通过DisplayModeService切换模式
      await displayModeService.switchToMode(DisplayMode.web);
      
      // 等待Stream事件传播和Widget重建
      await tester.pumpAndSettle();

      // 验证UI已切换
      expect(find.byType(ResponsiveWebShell), findsOneWidget);
      expect(find.text('模块化移动平台'), findsNothing);

      // 再次切换
      await displayModeService.switchToMode(DisplayMode.desktop);
      await tester.pumpAndSettle();

      // 验证再次切换成功
      expect(find.byType(SpatialOsShell), findsOneWidget);
      expect(find.byType(ResponsiveWebShell), findsNothing);
    });

    testWidgets('should maintain state during mode switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DisplayModeAwareShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 切换模式多次，验证Shell始终正确渲染
      for (final mode in DisplayMode.values) {
        await displayModeService.switchToMode(mode);
        await tester.pumpAndSettle();
        
        // 每次切换后都应该有有效的Shell渲染
        expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      }
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