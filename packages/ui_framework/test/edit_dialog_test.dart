/*
---------------------------------------------------------------
File name:          edit_dialog_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Description:        UniversalEditDialog组件测试 - Phase 2.2 Sprint 1编辑功能验证
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_framework/ui_framework.dart';

// 测试用的EditableItem实现
class TestEditableItem implements EditableItem {
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String content;
  @override
  final List<String> tags;

  const TestEditableItem({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.tags,
  });

  @override
  TestEditableItem copyWith({
    String? title,
    String? description,
    String? content,
    List<String>? tags,
  }) {
    return TestEditableItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      tags: tags ?? this.tags,
    );
  }
}

void main() {
  group('EditableItem Interface Tests', () {
    late TestEditableItem testItem;

    setUp(() {
      testItem = const TestEditableItem(
        id: 'test_1',
        title: '测试标题',
        description: '测试描述',
        content: '测试内容',
        tags: ['标签1', '标签2'],
      );
    });

    test('should implement EditableItem interface correctly', () {
      expect(testItem, isA<EditableItem>());
      expect(testItem.id, 'test_1');
      expect(testItem.title, '测试标题');
      expect(testItem.description, '测试描述');
      expect(testItem.content, '测试内容');
      expect(testItem.tags, ['标签1', '标签2']);
    });

    test('copyWith should create new instance with changes', () {
      final editedItem = testItem.copyWith(
        title: '新标题',
        content: '新内容',
        tags: ['新标签'],
      );

      expect(editedItem.title, '新标题');
      expect(editedItem.description, '测试描述'); // 未修改
      expect(editedItem.content, '新内容');
      expect(editedItem.tags, ['新标签']);
      expect(editedItem.id, testItem.id); // ID保持不变
    });
  });

  group('EditItemType Enum Tests', () {
    test('should have all required item types', () {
      expect(EditItemType.values.length, 5);
      expect(EditItemType.values.contains(EditItemType.note), true);
      expect(EditItemType.values.contains(EditItemType.todo), true);
      expect(EditItemType.values.contains(EditItemType.project), true);
      expect(EditItemType.values.contains(EditItemType.creative), true);
      expect(EditItemType.values.contains(EditItemType.punchRecord), true);
    });
  });

  group('UniversalEditDialog Widget Tests', () {
    late TestEditableItem testItem;

    setUp(() {
      testItem = const TestEditableItem(
        id: 'test_dialog_1',
        title: '对话框测试项目',
        description: '这是一个用于测试编辑对话框的项目',
        content: '详细的项目内容用于测试编辑功能',
        tags: ['测试', '对话框', '编辑'],
      );
    });

    testWidgets('should display UniversalEditDialog correctly', (WidgetTester tester) async {
      bool saveCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalEditDialog(
              item: testItem,
              itemType: EditItemType.project,
              onSave: (editedItem) {
                saveCallbackCalled = true;
                // 验证回调参数类型正确
                expect(editedItem, isA<TestEditableItem>());
              },
            ),
          ),
        ),
      );

      // 验证对话框标题
      expect(find.text('编辑 项目'), findsOneWidget);

      // 验证表单字段存在（通过标签文本验证）
      expect(find.text('标题'), findsOneWidget);
      expect(find.text('描述'), findsOneWidget);
      expect(find.text('内容'), findsOneWidget);

      // 验证各个标签芯片单独显示
      expect(find.text('测试'), findsOneWidget);
      expect(find.text('对话框'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);

      // 验证按钮存在
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);

      // 确保回调未被调用
      expect(saveCallbackCalled, false);
    });

    testWidgets('should handle cancel action correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalEditDialog(
              item: testItem,
              itemType: EditItemType.note,
              onSave: (editedItem) {},
            ),
          ),
        ),
      );

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 验证对话框关闭（通过检查是否还能找到对话框标题）
      expect(find.text('编辑 笔记'), findsNothing);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalEditDialog(
              item: testItem,
              itemType: EditItemType.todo,
              onSave: (editedItem) {},
            ),
          ),
        ),
      );

      // 清空标题字段
      await tester.enterText(find.widgetWithText(TextFormField, '对话框测试项目'), '');
      
      // 尝试保存
      await tester.tap(find.text('保存'));
      await tester.pump();

      // 验证错误消息显示
      expect(find.text('标题不能为空'), findsOneWidget);
    });

    testWidgets('should handle save action with valid data', (WidgetTester tester) async {
      bool saveCallbackCalled = false;
      TestEditableItem? savedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalEditDialog(
              item: testItem,
              itemType: EditItemType.creative,
              onSave: (editedItem) {
                saveCallbackCalled = true;
                savedItem = editedItem as TestEditableItem;
              },
            ),
          ),
        ),
      );

      // 修改标题
      await tester.enterText(find.widgetWithText(TextFormField, '对话框测试项目'), '修改后的标题');
      
      // 修改描述
      final descriptionFields = find.widgetWithText(TextFormField, '这是一个用于测试编辑对话框的项目');
      await tester.enterText(descriptionFields, '修改后的描述');

      // 点击保存按钮
      await tester.tap(find.text('保存'));
      await tester.pump();

      // 验证回调被调用且数据正确
      expect(saveCallbackCalled, true);
      expect(savedItem, isNotNull);
      expect(savedItem!.title, '修改后的标题');
      expect(savedItem!.description, '修改后的描述');
    });

    testWidgets('should handle different item types correctly', (WidgetTester tester) async {
      // 测试不同类型的对话框标题
      final testCases = [
        (EditItemType.note, '编辑 笔记'),
        (EditItemType.todo, '编辑 待办'),
        (EditItemType.project, '编辑 项目'),
        (EditItemType.creative, '编辑 创意项目'),
        (EditItemType.punchRecord, '编辑 打卡记录'),
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UniversalEditDialog(
                item: testItem,
                itemType: testCase.$1,
                onSave: (editedItem) {},
              ),
            ),
          ),
        );

        // 验证对话框标题正确
        expect(find.text(testCase.$2), findsOneWidget);

        // 清理widget树以准备下一个测试
        await tester.pumpWidget(Container());
        await tester.pump();
      }
    });

    testWidgets('should handle save action correctly', (WidgetTester tester) async {
      bool onSaveCompleted = false;
      TestEditableItem? savedItem;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalEditDialog(
              item: testItem,
              itemType: EditItemType.note,
              onSave: (editedItem) {
                onSaveCompleted = true;
                savedItem = editedItem as TestEditableItem;
              },
            ),
          ),
        ),
      );

      // 验证初始状态 - 保存按钮应该可用
      expect(find.text('保存'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      
      // 点击保存按钮（表单已经有默认数据）
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle(); // 等待所有动画和异步操作完成
      
      // 验证保存已完成
      expect(onSaveCompleted, true);
      expect(savedItem, isNotNull);
      expect(savedItem!.title, testItem.title);
    });

    testWidgets('should display and edit tags correctly', (WidgetTester tester) async {
      bool saveCallbackCalled = false;
      TestEditableItem? savedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalEditDialog(
              item: testItem,
              itemType: EditItemType.note,
              onSave: (editedItem) {
                saveCallbackCalled = true;
                savedItem = editedItem as TestEditableItem;
              },
            ),
          ),
        ),
      );

      // 验证现有标签芯片显示
      expect(find.text('测试'), findsOneWidget);
      expect(find.text('对话框'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);

      // 查找标签输入字段（通过hint text定位）
      final tagInputField = find.widgetWithText(TextFormField, '输入标签并按回车添加');
      expect(tagInputField, findsOneWidget);

      // 添加新标签
      await tester.enterText(tagInputField, '新标签');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // 验证新标签显示
      expect(find.text('新标签'), findsOneWidget);

      // 填入必需的表单字段
      await tester.enterText(find.byType(TextFormField).first, '有效标题');
      await tester.enterText(find.byType(TextFormField).at(2), '有效内容');

      // 保存
      await tester.tap(find.text('保存'));
      await tester.pump();

      // 验证保存成功
      expect(saveCallbackCalled, true);
      expect(savedItem!.tags.contains('新标签'), true);
    });
  });

  group('UniversalEditDialog Error Handling Tests', () {
    testWidgets('should handle empty content gracefully', (WidgetTester tester) async {
      final emptyItem = const TestEditableItem(
        id: 'empty_test',
        title: '',
        description: '',
        content: '',
        tags: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalEditDialog(
              item: emptyItem,
              itemType: EditItemType.note,
              onSave: (editedItem) {},
            ),
          ),
        ),
      );

      // 验证对话框可以正常渲染空内容
      expect(find.text('编辑 笔记'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4)); // 标题、描述、内容、标签
    });

    testWidgets('should handle null values in onSave gracefully', (WidgetTester tester) async {
      bool saveCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalEditDialog(
              item: const TestEditableItem(
                id: 'test',
                title: '测试',
                description: '描述',
                content: '内容',
                tags: ['标签'],
              ),
              itemType: EditItemType.note,
              onSave: (editedItem) {
                saveCallbackCalled = true;
                // 不抛出异常，正常处理
              },
            ),
          ),
        ),
      );

      // 输入有效数据并保存
      await tester.enterText(find.widgetWithText(TextFormField, '测试'), '有效标题');
      await tester.tap(find.text('保存'));
      await tester.pump();

      // 验证回调被调用
      expect(saveCallbackCalled, true);
    });
  });
} 