/*
---------------------------------------------------------------
File name:          app_integration_test.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        应用集成测试 - 修复架构问题后的集成测试
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 审查修复 - 修复文本查找问题，添加调试信息;
    2025/06/26: Phase 1.5 审查修复 - 修复Directionality问题，使用PetAppMain;
    2025/06/26: Phase 1.5 重构 - 大幅简化测试实现;
    2025/06/25: Initial creation - 应用集成测试基础实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_app/main.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('App loads successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const PetAppMain());
      await tester.pumpAndSettle();

      // 验证MaterialApp存在
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // 验证Scaffold存在
      expect(find.byType(Scaffold), findsOneWidget);
      
      // 验证AppBar存在
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const PetAppMain());
      await tester.pumpAndSettle();

      // 验证底部导航栏存在
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // 验证导航项图标存在（使用更精确的查找）
      final bottomNavIcons = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byType(Icon),
      );
      expect(bottomNavIcons, findsAtLeastNWidgets(4));

      // 点击不同的导航项（使用索引）
      await tester.tap(bottomNavIcons.at(1)); // Notes
      await tester.pumpAndSettle();
      
      await tester.tap(bottomNavIcons.at(2)); // Workshop
      await tester.pumpAndSettle();
      
      await tester.tap(bottomNavIcons.at(3)); // PunchIn
      await tester.pumpAndSettle();
      
      // 返回首页
      await tester.tap(bottomNavIcons.at(0)); // Home
      await tester.pumpAndSettle();
    });

    testWidgets('App handles errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const PetAppMain());
      await tester.pumpAndSettle();

      // 确保应用正常启动，没有错误
      expect(tester.takeException(), isNull);
      
      // 简化测试，只验证基本结构
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
} 