/*
---------------------------------------------------------------
File name:          in_memory_repository_test.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/25
Dart Version:       3.32.4
Description:        内存仓储单元测试 - 验证CRUD操作、查询功能、数据一致性等核心功能
---------------------------------------------------------------
Change History:
    2025/06/25: Initial creation - 完整的内存仓储测试套件;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:core_services/core_services.dart';

void main() {
  group('InMemoryRepository Tests', () {
    late InMemoryRepository repository;

    setUp(() {
      repository = InMemoryRepository();
    });

    tearDown(() {
      // 清理测试数据
    });

    group('Basic CRUD Operations', () {
      test('should save and get item successfully', () async {
        final item = SimpleItem(
          id: 'test-1',
          title: 'Test Item',
          description: 'Test Description',
          itemType: ItemType.note,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final saveResult = await repository.save(item);
        expect(saveResult.isSuccess, isTrue);
        
        final getResult = await repository.getById('test-1');
        expect(getResult.isSuccess, isTrue);
        expect(getResult.data?.id, equals('test-1'));
      });

      test('should delete item successfully', () async {
        final item = SimpleItem(
          id: 'test-1',
          title: 'Test Item',
          description: 'Test Description',
          itemType: ItemType.note,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.save(item);
        final deleteResult = await repository.deleteById('test-1');
        
        expect(deleteResult.isSuccess, isTrue);
        
        final getResult = await repository.getById('test-1');
        expect(getResult.isFailure, isTrue);
      });
    });

    group('Query Operations', () {
      test('should get all items', () async {
        final items = [
          SimpleItem(
            id: 'test-1',
            title: 'Item 1',
            description: 'Description 1',
            itemType: ItemType.note,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SimpleItem(
            id: 'test-2',
            title: 'Item 2',
            description: 'Description 2',
            itemType: ItemType.todo,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final item in items) {
          await repository.save(item);
        }

        final result = await repository.getAll();
        
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, equals(2));
      });

      test('should query items by type', () async {
        final items = [
          SimpleItem(
            id: 'test-1',
            title: 'Item 1',
            description: 'Description 1',
            itemType: ItemType.note,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SimpleItem(
            id: 'test-2',
            title: 'Item 2',
            description: 'Description 2',
            itemType: ItemType.todo,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final item in items) {
          await repository.save(item);
        }

        final result = await repository.getAll(itemType: ItemType.note);
        
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, equals(1));
        expect(result.data?.first.itemType, equals(ItemType.note));
      });
    });

    group('Pagination', () {
      test('should handle pagination correctly', () async {
        // 创建多个测试项
        for (int i = 1; i <= 10; i++) {
          final item = SimpleItem(
            id: 'test-$i',
            title: 'Item $i',
            description: 'Description $i',
            itemType: ItemType.note,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await repository.save(item);
        }

        final config = PaginationConfig(page: 1, pageSize: 5);
        final result = await repository.queryPaged(config);
        
        expect(result.isSuccess, isTrue);
        expect(result.data?.items.length, equals(5));
      });
    });

    group('Error Handling', () {
      test('should handle item not found', () async {
        final result = await repository.getById('non-existent');
        
        expect(result.isFailure, isTrue);
        expect(result.status, equals(RepositoryResultStatus.notFound));
      });

      test('should check item existence', () async {
        final item = SimpleItem(
          id: 'test-1',
          title: 'Test Item',
          description: 'Test Description',
          itemType: ItemType.note,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final existsResult1 = await repository.exists('test-1');
        expect(existsResult1.data, isFalse);

        await repository.save(item);
        
        final existsResult2 = await repository.exists('test-1');
        expect(existsResult2.data, isTrue);
      });
    });

    group('Statistics', () {
      test('should provide repository statistics', () async {
        final item = SimpleItem(
          id: 'test-1',
          title: 'Test Item',
          description: 'Test Description',
          itemType: ItemType.note,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.save(item);
        
        final statsResult = await repository.getStatistics();
        expect(statsResult.isSuccess, isTrue);
        expect(statsResult.data?['totalCount'], equals(1));
      });
    });
  });
} 