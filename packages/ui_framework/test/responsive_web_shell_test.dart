/*
---------------------------------------------------------------
File name:          responsive_web_shell_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        ResponsiveWebShell Widget测试 - 测试Web端响应式功能
---------------------------------------------------------------
Change History:
    2025/06/28: Initial creation - Phase 2.1 Step 8 测试编写;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_framework/ui_framework.dart';
// import 'package:core_services/core_services.dart';

void main() {
  group('ResponsiveWebShell Widget Tests', () {
    testWidgets('should render web shell layout correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证基本布局元素
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Web响应式平台'), findsOneWidget);
      expect(find.text('Phase 2.1 - 多设备适配的Web体验'), findsOneWidget);
    });

    testWidgets('should display navigation rail on larger screens', (WidgetTester tester) async {
      // 设置较大的屏幕尺寸
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证NavigationRail在大屏幕上显示
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('导航'), findsOneWidget);
      
      // 重置屏幕尺寸
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display bottom navigation bar on smaller screens', (WidgetTester tester) async {
      // 设置较小的屏幕尺寸（模拟移动设备）
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证BottomNavigationBar在小屏幕上显示
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // 重置屏幕尺寸
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should show responsive grid layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证响应式网格布局
      expect(find.text('模块网格'), findsOneWidget);
      expect(find.text('智能响应式布局'), findsOneWidget);
      
      // 验证模块卡片显示
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('测试模块'), findsOneWidget);
    });

    testWidgets('should handle module tap in web environment', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击首页模块卡片
      await tester.tap(find.text('首页').first);
      await tester.pumpAndSettle();

      // 验证模块内容显示
      expect(find.text('首页模块测试'), findsOneWidget);
    });

    testWidgets('should display web-specific status bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证Web特有的状态信息
      expect(find.text('Web环境'), findsOneWidget);
      expect(find.text('支持键盘和鼠标操作'), findsOneWidget);
    });

    testWidgets('should show breadcrumb navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证面包屑导航
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('路径导航'), findsOneWidget);
    });

    testWidgets('should adapt layout for tablet size', (WidgetTester tester) async {
      // 设置平板尺寸
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证平板尺寸下的布局适配
      expect(find.text('Web响应式平台'), findsOneWidget);
      
      // 重置屏幕尺寸
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should handle empty modules list gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveWebShell(
            modules: [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证基本界面仍然显示
      expect(find.text('Web响应式平台'), findsOneWidget);
      expect(find.text('模块网格'), findsOneWidget);
    });

    testWidgets('should handle locale changes', (WidgetTester tester) async {
      bool localeChangeHandled = false;
      Locale? receivedLocale;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
            onLocaleChanged: (locale) {
              localeChangeHandled = true;
              receivedLocale = locale;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证locale回调被正确传递
      expect(localeChangeHandled, isFalse); // 初始状态
      expect(receivedLocale, isNull); // 验证初始locale未设置
    });

    testWidgets('should show web-specific features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证Web端特有功能
      expect(find.text('浏览器环境优化'), findsOneWidget);
      expect(find.text('URL路由支持'), findsOneWidget);
      expect(find.text('SEO友好'), findsOneWidget);
    });
  });

  group('ResponsiveWebShell Responsive Behavior Tests', () {
    testWidgets('should adjust grid columns based on screen width', (WidgetTester tester) async {
      // 测试不同屏幕宽度下的网格列数
      final List<Size> testSizes = [
        const Size(320, 800),  // 小屏手机
        const Size(480, 800),  // 大屏手机
        const Size(768, 1024), // 平板
        const Size(1024, 768), // 桌面
        const Size(1920, 1080), // 大屏桌面
      ];

      for (final size in testSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        
        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveWebShell(
              modules: _getTestModules(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 验证响应式布局正确显示
        expect(find.text('Web响应式平台'), findsOneWidget);
        expect(find.text('智能响应式布局'), findsOneWidget);
      }
      
      // 重置屏幕尺寸
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should handle orientation changes', (WidgetTester tester) async {
      // 纵向
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWebShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Web响应式平台'), findsOneWidget);

      // 横向
      tester.view.physicalSize = const Size(800, 400);
      await tester.pumpAndSettle();
      expect(find.text('Web响应式平台'), findsOneWidget);
      
      // 重置屏幕尺寸
      addTearDown(tester.view.resetPhysicalSize);
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