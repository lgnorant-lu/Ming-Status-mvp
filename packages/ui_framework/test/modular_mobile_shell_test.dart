/*
---------------------------------------------------------------
File name:          modular_mobile_shell_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        ModularMobileShell Widget测试 - 测试移动端模块化功能
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
  group('ModularMobileShell Widget Tests', () {
    testWidgets('should render mobile shell layout correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证基本布局元素
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('模块化移动平台'), findsOneWidget);
      expect(find.text('Phase 2.1 - 每个模块都是独立应用'), findsOneWidget);
      expect(find.text('点击底部图标启动模块'), findsOneWidget);
    });

    testWidgets('should display system status bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证系统状态栏
      expect(find.text('系统状态'), findsOneWidget);
      expect(find.text('活跃模块: 0'), findsOneWidget);
      expect(find.textContaining('时间:'), findsOneWidget);
    });

    testWidgets('should show module launcher buttons', (WidgetTester tester) async {
      final testModules = _getTestModules();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: testModules,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证模块启动器中的图标按钮
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.science), findsOneWidget);
      
      // 验证模块启动器容器
      expect(find.text('模块启动器'), findsOneWidget);
    });

    testWidgets('should launch module when tapped', (WidgetTester tester) async {
      final testModules = _getTestModules();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: testModules,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击首页模块图标
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // 验证模块被启动
      expect(find.text('活跃模块: 1'), findsOneWidget);
      expect(find.text('首页模块测试'), findsOneWidget);
    });

    testWidgets('should show task manager when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 启动一个模块先
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // 点击任务管理器按钮
      await tester.tap(find.byIcon(Icons.apps));
      await tester.pumpAndSettle();

      // 验证任务管理器显示
      expect(find.text('任务管理器'), findsOneWidget);
      expect(find.text('运行中的模块'), findsOneWidget);
    });

    testWidgets('should close module from task manager', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 启动一个模块
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // 打开任务管理器
      await tester.tap(find.byIcon(Icons.apps));
      await tester.pumpAndSettle();

      // 关闭模块（点击关闭按钮）
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // 验证模块被关闭
      expect(find.text('活跃模块: 0'), findsOneWidget);
    });

    testWidgets('should minimize module', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 启动模块
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // 最小化模块（点击最小化按钮）
      await tester.tap(find.byIcon(Icons.minimize));
      await tester.pumpAndSettle();

      // 验证回到主界面但模块仍在运行
      expect(find.text('活跃模块: 1'), findsOneWidget);
      expect(find.text('模块化移动平台'), findsOneWidget);
    });

    testWidgets('should switch between modules', (WidgetTester tester) async {
      final testModules = _getTestModules();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: testModules,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 启动第一个模块
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('首页模块测试'), findsOneWidget);

      // 最小化
      await tester.tap(find.byIcon(Icons.minimize));
      await tester.pumpAndSettle();

      // 启动第二个模块
      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();
      expect(find.text('测试模块内容'), findsOneWidget);

      // 验证有两个活跃模块
      expect(find.text('活跃模块: 2'), findsOneWidget);
    });

    testWidgets('should handle empty modules list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ModularMobileShell(
            modules: [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证基本界面仍然显示，但没有模块按钮
      expect(find.text('模块化移动平台'), findsOneWidget);
      expect(find.text('模块启动器'), findsOneWidget);
    });

    testWidgets('should handle locale changes', (WidgetTester tester) async {
      bool localeChangeHandled = false;
      Locale? receivedLocale;

      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
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
      
      // ModularMobileShell应该接收并正确处理locale change回调
      // 这里主要验证回调参数被正确传递，实际的语言切换需要外部触发
    });

    testWidgets('should maintain module state between switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 启动模块
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // 最小化
      await tester.tap(find.byIcon(Icons.minimize));
      await tester.pumpAndSettle();

      // 启动另一个模块
      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();

      // 回到第一个模块（通过任务管理器）
      await tester.tap(find.byIcon(Icons.apps));
      await tester.pumpAndSettle();

      // 点击第一个模块切换过去
      await tester.tap(find.text('首页').first);
      await tester.pumpAndSettle();

      // 验证模块状态被保持
      expect(find.text('首页模块测试'), findsOneWidget);
    });
  });

  group('ModularMobileShell Module Lifecycle Tests', () {
    testWidgets('should properly manage module instances', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ModularMobileShell(
            modules: _getTestModules(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证初始状态没有运行的模块
      expect(find.text('活跃模块: 0'), findsOneWidget);

      // 启动多个模块
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.minimize));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.minimize));
      await tester.pumpAndSettle();

      // 验证两个模块都在运行
      expect(find.text('活跃模块: 2'), findsOneWidget);

      // 通过任务管理器关闭所有模块
      await tester.tap(find.byIcon(Icons.apps));
      await tester.pumpAndSettle();

      // 关闭第一个模块
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      expect(find.text('活跃模块: 1'), findsOneWidget);

      // 关闭第二个模块
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      expect(find.text('活跃模块: 0'), findsOneWidget);
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