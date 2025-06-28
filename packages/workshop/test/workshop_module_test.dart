/*
---------------------------------------------------------------
File name:          workshop_module_test.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Description:        Workshop模块单元测试 - Phase 2.2 Sprint 1编辑功能验证
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:workshop/workshop_module.dart';
import 'package:ui_framework/ui_framework.dart';

void main() {
  group('CreativeItem EditableItem Interface Tests', () {
    late CreativeItem testItem;
    
    setUp(() {
      testItem = CreativeItem(
        id: 'test_item_1',
        type: CreativeItemType.project,
        title: '测试创意项目',
        description: '这是一个测试项目的描述',
        content: '详细的项目内容和计划',
        status: CreativeItemStatus.draft,
        priority: CreativeItemPriority.high,
        createdAt: DateTime(2025, 6, 28, 15, 30),
        updatedAt: DateTime(2025, 6, 28, 15, 30),
        tags: ['测试', '项目', 'Phase2.2'],
        attachments: [],
        metadata: {'category': 'development'},
      );
    });

    test('CreativeItem should implement EditableItem interface', () {
      expect(testItem, isA<EditableItem>());
    });

    test('EditableItem interface methods should work correctly', () {
      // 测试接口属性
      expect(testItem.id, 'test_item_1');
      expect(testItem.title, '测试创意项目');
      expect(testItem.description, '这是一个测试项目的描述');
      expect(testItem.content, '详细的项目内容和计划');
      expect(testItem.tags, ['测试', '项目', 'Phase2.2']);
    });

    test('EditableItem copyWith should create new instance with changes', () {
      final editedItem = testItem.copyWith(
        title: '已编辑的创意项目',
        description: '更新后的项目描述',
        content: '修改后的详细内容',
        tags: ['编辑', '更新', 'Phase2.2'],
      );

      // 验证新实例的属性
      expect(editedItem.title, '已编辑的创意项目');
      expect(editedItem.description, '更新后的项目描述');
      expect(editedItem.content, '修改后的详细内容');
      expect(editedItem.tags, ['编辑', '更新', 'Phase2.2']);
      
      // 验证原实例未被修改
      expect(testItem.title, '测试创意项目');
      expect(testItem.description, '这是一个测试项目的描述');
      
      // 验证其他属性保持不变
      expect(editedItem.id, testItem.id);
      expect(editedItem.type, testItem.type);
      expect(editedItem.status, testItem.status);
      expect(editedItem.priority, testItem.priority);
      expect(editedItem.createdAt, testItem.createdAt);
    });

    test('EditableItem copyWith should preserve updatedAt when not specified', () {
      final originalTime = testItem.updatedAt;
      
      final editedItem = testItem.copyWith(title: '新标题');
      
      // copyWith不应该自动更新时间戳，应该保持原值
      expect(editedItem.updatedAt, originalTime);
      
      // 但可以手动指定新的时间戳
      final newTime = DateTime.now();
      final editedWithTime = testItem.copyWith(
        title: '新标题',
        updatedAt: newTime,
      );
      expect(editedWithTime.updatedAt, newTime);
    });
  });

  group('WorkshopModule Edit Functionality Tests', () {
    late WorkshopModule module;

    setUp(() {
      module = WorkshopModule();
    });

    test('should create creative item successfully', () {
      final itemId = module.createItem(
        type: CreativeItemType.idea,
        title: '新创意想法',
        description: '创意描述',
        content: '详细内容',
        tags: ['创意', '想法'],
      );

      expect(itemId, isNotNull);
      expect(itemId.isNotEmpty, true);
      
      final createdItem = module.getItemById(itemId);
      expect(createdItem, isNotNull);
      expect(createdItem!.title, '新创意想法');
      expect(createdItem.type, CreativeItemType.idea);
    });

    test('should update creative item successfully', () {
      // 创建测试项目
      final itemId = module.createItem(
        type: CreativeItemType.project,
        title: '原始项目',
        description: '原始描述',
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
      
      final updatedItem = module.getItemById(itemId);
      expect(updatedItem, isNotNull);
      expect(updatedItem!.title, '更新后的项目');
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
        type: CreativeItemType.project,
        title: '测试项目',
        description: '项目描述',
        content: '项目内容',
        tags: ['项目'],
      );

      // 第一次编辑
      module.updateItem(itemId, title: '编辑1');
      final firstEdit = module.getItemById(itemId);
      
      // 第二次编辑
      module.updateItem(itemId, content: '编辑后内容');
      final secondEdit = module.getItemById(itemId);

      expect(firstEdit!.title, '编辑1');
      expect(secondEdit!.title, '编辑1'); // 标题保持
      expect(secondEdit.content, '编辑后内容'); // 内容更新
      expect(secondEdit.id, itemId); // ID不变
      expect(secondEdit.type, CreativeItemType.project); // 类型不变
    });
  });

  group('WorkshopModule Data Persistence Tests', () {
    late WorkshopModule module;

    setUp(() {
      module = WorkshopModule();
    });

    test('should persist items across module operations', () {
      // 创建多个项目
      final id1 = module.createItem(
        type: CreativeItemType.idea,
        title: '想法1',
        description: '描述1',
        content: '内容1',
      );
      
      final id2 = module.createItem(
        type: CreativeItemType.project,
        title: '项目2',
        description: '描述2',
        content: '内容2',
      );

      // 编辑一个项目
      module.updateItem(id1, title: '已编辑的想法1');

      // 验证所有项目仍然存在且数据正确
      final item1 = module.getItemById(id1);
      final item2 = module.getItemById(id2);

      expect(item1, isNotNull);
      expect(item2, isNotNull);
      expect(item1!.title, '已编辑的想法1');
      expect(item2!.title, '项目2');
      
      // 验证列表包含所有项目
      final allItems = module.getAllItems();
      expect(allItems.length, greaterThanOrEqualTo(2));
      expect(allItems.any((item) => item.id == id1), true);
      expect(allItems.any((item) => item.id == id2), true);
    });
  });
} 