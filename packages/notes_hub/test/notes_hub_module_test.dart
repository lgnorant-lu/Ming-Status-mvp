/*
---------------------------------------------------------------
File name:          notes_hub_module_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Description:        NotesHub模块单元测试 - Phase 2.2 Sprint 1编辑功能验证
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:notes_hub/notes_hub_module.dart';
import 'package:ui_framework/ui_framework.dart';

void main() {
  group('NotesHubItem EditableItem Interface Tests', () {
    late NotesHubItem testItem;
    
    setUp(() {
      testItem = NotesHubItem(
        id: 'test_note_1',
        type: ItemType.note,
        title: '测试笔记',
        content: '这是一个测试笔记的详细内容',
        status: ItemStatus.active,
        priority: ItemPriority.medium,
        createdAt: DateTime(2025, 6, 28, 16, 0),
        updatedAt: DateTime(2025, 6, 28, 16, 0),
        tags: ['测试', '笔记', 'Phase2.2'],
        metadata: {'category': 'test'},
      );
    });

    test('NotesHubItem should implement EditableItem interface', () {
      expect(testItem, isA<EditableItem>());
    });

    test('EditableItem interface methods should work correctly', () {
      // 测试接口属性
      expect(testItem.id, 'test_note_1');
      expect(testItem.title, '测试笔记');
      expect(testItem.description, '这是一个测试笔记的详细内容'); // description映射到content
      expect(testItem.content, '这是一个测试笔记的详细内容');
      expect(testItem.tags, ['测试', '笔记', 'Phase2.2']);
    });

    test('EditableItem copyWith should create new instance with changes', () {
      final editedItem = testItem.copyWith(
        title: '已编辑的笔记',
        description: '更新后的笔记内容',
        tags: ['编辑', '更新', 'Phase2.2'],
      );

      // 验证新实例的属性
      expect(editedItem.title, '已编辑的笔记');
      expect(editedItem.content, '更新后的笔记内容'); // description映射到content
      expect(editedItem.tags, ['编辑', '更新', 'Phase2.2']);
      
      // 验证原实例未被修改
      expect(testItem.title, '测试笔记');
      expect(testItem.content, '这是一个测试笔记的详细内容');
      
      // 验证其他属性保持不变
      expect(editedItem.id, testItem.id);
      expect(editedItem.type, testItem.type);
      expect(editedItem.status, testItem.status);
      expect(editedItem.priority, testItem.priority);
      expect(editedItem.createdAt, testItem.createdAt);
    });

    test('EditableItem copyWith should update updatedAt timestamp', () async {
      final originalTime = testItem.updatedAt;
      
      // 等待至少1毫秒确保时间戳不同
      await Future.delayed(const Duration(milliseconds: 1));
      
      final editedItem = testItem.copyWith(title: '新标题');
      
      expect(editedItem.updatedAt.isAfter(originalTime), true);
    });

    test('should handle different item types correctly', () {
      final todoItem = NotesHubItem(
        id: 'test_todo_1',
        type: ItemType.todo,
        title: '测试待办',
        content: '待办事项内容',
        status: ItemStatus.active,
        priority: ItemPriority.high,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['待办'],
      );

      expect(todoItem, isA<EditableItem>());
      expect(todoItem.type, ItemType.todo);
      expect(todoItem.title, '测试待办');
      expect(todoItem.description, '待办事项内容'); // description映射到content
    });
  });

  group('NotesHubModule Edit Functionality Tests', () {
    late NotesHubModule module;

    setUp(() {
      module = NotesHubModule();
    });

    test('should create notes hub item successfully', () {
      final itemId = module.createItem(
        type: ItemType.note,
        title: '新建笔记',
        content: '笔记内容',
        tags: ['创建', '测试'],
      );

      expect(itemId, isNotNull);
      expect(itemId.isNotEmpty, true);
      
      final items = module.getItemsByType(ItemType.note);
      final createdItem = items.firstWhere((item) => item.id == itemId);
      expect(createdItem.title, '新建笔记');
      expect(createdItem.type, ItemType.note);
    });

    test('should update notes hub item successfully', () {
      // 创建测试项目
      final itemId = module.createItem(
        type: ItemType.project,
        title: '原始项目',
        content: '原始内容',
        tags: ['原始'],
      );

      // 更新项目
      final success = module.updateItem(
        itemId,
        title: '更新后的项目',
        content: '更新后的内容',
        tags: ['更新', '编辑'],
      );

      expect(success, true);
      
      final items = module.getItemsByType(ItemType.project);
      final updatedItem = items.firstWhere((item) => item.id == itemId);
      expect(updatedItem.title, '更新后的项目');
      expect(updatedItem.content, '更新后的内容');
      expect(updatedItem.tags, ['更新', '编辑']);
    });

    test('should handle non-existent item update gracefully', () {
      final success = module.updateItem(
        'non_existent_id',
        title: '不存在的项目',
      );

      expect(success, false);
    });

    test('should maintain data integrity after multiple edits', () {
      final itemId = module.createItem(
        type: ItemType.reminder,
        title: '测试提醒',
        content: '提醒内容',
        tags: ['提醒'],
      );

      // 第一次编辑
      module.updateItem(itemId, title: '编辑1');
      final items1 = module.getItemsByType(ItemType.reminder);
      final firstEdit = items1.firstWhere((item) => item.id == itemId);
      
      // 第二次编辑
      module.updateItem(itemId, content: '编辑后内容');
      final items2 = module.getItemsByType(ItemType.reminder);
      final secondEdit = items2.firstWhere((item) => item.id == itemId);

      expect(firstEdit.title, '编辑1');
      expect(secondEdit.title, '编辑1'); // 标题保持
      expect(secondEdit.content, '编辑后内容'); // 内容更新
      expect(secondEdit.id, itemId); // ID不变
      expect(secondEdit.type, ItemType.reminder); // 类型不变
    });
  });

  group('NotesHubModule Data Persistence Tests', () {
    late NotesHubModule module;

    setUp(() {
      module = NotesHubModule();
    });

    test('should persist items across module operations', () {
      // 创建多个不同类型的项目
      final id1 = module.createItem(
        type: ItemType.note,
        title: '笔记1',
        content: '内容1',
      );
      
      final id2 = module.createItem(
        type: ItemType.todo,
        title: '待办2',
        content: '内容2',
      );

      final id3 = module.createItem(
        type: ItemType.habit,
        title: '习惯3',
        content: '内容3',
      );

      // 编辑一个项目
      module.updateItem(id1, title: '已编辑的笔记1');

      // 验证所有项目仍然存在且数据正确
      final noteItems = module.getItemsByType(ItemType.note);
      final todoItems = module.getItemsByType(ItemType.todo);
      final habitItems = module.getItemsByType(ItemType.habit);

      final item1 = noteItems.firstWhere((item) => item.id == id1);
      final item2 = todoItems.firstWhere((item) => item.id == id2);
      final item3 = habitItems.firstWhere((item) => item.id == id3);

      expect(item1.title, '已编辑的笔记1');
      expect(item2.title, '待办2');
      expect(item3.title, '习惯3');
      
      // 验证所有项目总数
      final allItems = module.getAllItems();
      expect(allItems.length, greaterThanOrEqualTo(3));
    });

    test('should handle mixed item type operations correctly', () {
      // 创建多种类型的项目
      final noteId = module.createItem(type: ItemType.note, title: '笔记', content: '笔记内容');
      final todoId = module.createItem(type: ItemType.todo, title: '待办', content: '待办内容');
      final projectId = module.createItem(type: ItemType.project, title: '项目', content: '项目内容');
      final reminderId = module.createItem(type: ItemType.reminder, title: '提醒', content: '提醒内容');
      final habitId = module.createItem(type: ItemType.habit, title: '习惯', content: '习惯内容');
      final goalId = module.createItem(type: ItemType.goal, title: '目标', content: '目标内容');

      // 验证每种类型都能正确存储和检索
      expect(module.getItemsByType(ItemType.note).any((item) => item.id == noteId), true);
      expect(module.getItemsByType(ItemType.todo).any((item) => item.id == todoId), true);
      expect(module.getItemsByType(ItemType.project).any((item) => item.id == projectId), true);
      expect(module.getItemsByType(ItemType.reminder).any((item) => item.id == reminderId), true);
      expect(module.getItemsByType(ItemType.habit).any((item) => item.id == habitId), true);
      expect(module.getItemsByType(ItemType.goal).any((item) => item.id == goalId), true);

      // 验证总项目数
      final allItems = module.getAllItems();
      expect(allItems.length, greaterThanOrEqualTo(6));
    });
  });
} 