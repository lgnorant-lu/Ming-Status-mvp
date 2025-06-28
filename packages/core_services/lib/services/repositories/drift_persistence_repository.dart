/*
---------------------------------------------------------------
File name:          drift_persistence_repository.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Python Version:     N/A (Dart)
Description:        Drift数据库持久化仓储实现 - 替换InMemoryRepository提供真正的数据持久化
---------------------------------------------------------------
Change History:
    2025/06/28: Initial creation for Phase 2.2B Sprint 2;
    2025/06/28: 修复BaseItem类型冲突 - 使用import alias和类型转换;
---------------------------------------------------------------
*/

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:core_services/database/database.dart' as db;
import 'package:core_services/services/repositories/persistence_repository.dart';
import 'package:core_services/models/base_item.dart' as models;
import 'package:core_services/models/repository_result.dart';

/// Drift数据库持久化仓储实现
/// 
/// 实现IPersistenceRepository接口，使用SQLite数据库进行数据持久化
/// 支持所有业务模块的数据存储需求，包括Notes、Workshop、PunchIn等
class DriftPersistenceRepository implements IPersistenceRepository {
  final db.AppDatabase _database;
  
  /// 构造函数，注入数据库实例
  DriftPersistenceRepository(this._database);

  // ============================================================================
  // 基础CRUD操作实现 (Core CRUD Operations Implementation)
  // ============================================================================

  @override
  Future<RepositoryResult<models.BaseItem>> getById(String id) async {
    try {
      final query = _database.select(_database.baseItems)
        ..where((item) => item.id.equals(id))
        ..where((item) => item.isDeleted.equals(false));
      
      final item = await query.getSingleOrNull();
      if (item == null) {
        return RepositoryResult.failure(
          status: RepositoryResultStatus.notFound,
          errorMessage: '未找到ID为 $id 的实体',
        );
      }
      
      return RepositoryResult.success(_driftItemToBaseItem(item));
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '获取实体失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<models.BaseItem>> save(models.BaseItem item) async {
    try {
      final companion = _baseItemToDriftCompanion(item);
      
      // 检查是否已存在
      final existingItem = await getById(item.id);
      
      if (existingItem.isSuccess) {
        // 更新现有项目
        await (_database.update(_database.baseItems)
          ..where((t) => t.id.equals(item.id)))
          .write(companion);
      } else {
        // 插入新项目
        await _database.into(_database.baseItems).insert(companion);
      }
      
      // 更新同步状态
      await _updateSyncStatus(item.id, item.itemType.code, 'pending');
      
      return RepositoryResult.success(item);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '保存实体失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<models.BaseItem>> deleteById(String id) async {
    try {
      // 首先获取项目以返回删除的项目
      final getResult = await getById(id);
      if (!getResult.isSuccess) {
        return getResult;
      }
      
      // 软删除：标记为已删除
      await (_database.update(_database.baseItems)
        ..where((item) => item.id.equals(id)))
        .write(db.BaseItemsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
      
      await _updateSyncStatus(id, getResult.data!.itemType.code, 'pending');
      
      return getResult;
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '删除实体失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<bool>> exists(String id) async {
    try {
      final result = await getById(id);
      return RepositoryResult.success(result.isSuccess);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '检查实体存在性失败: $e',
      );
    }
  }

  // ============================================================================
  // 查询操作实现 (Query Operations Implementation)
  // ============================================================================

  @override
  Future<RepositoryResult<List<models.BaseItem>>> getAll({models.ItemType? itemType}) async {
    try {
      final query = _database.select(_database.baseItems)
        ..where((item) => item.isDeleted.equals(false))
        ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]);
      
      if (itemType != null) {
        query.where((item) => item.itemType.equals(itemType.code));
      }
      
      final items = await query.get();
      final baseItems = items.map((item) => _driftItemToBaseItem(item)).toList();
      
      return RepositoryResult.success(baseItems);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '获取实体列表失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<List<models.BaseItem>>> query(QueryBuilder queryBuilder) async {
    try {
      // 简化实现：获取所有项目然后在内存中应用过滤器
      final allResult = await getAll();
      if (!allResult.isSuccess) {
        return allResult;
      }
      
      // TODO: 实现更高效的数据库查询
      final filtered = _applyQueryBuilder(allResult.data!, queryBuilder);
      return RepositoryResult.success(filtered);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '查询失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<PagedResult<models.BaseItem>>> queryPaged(
    PaginationConfig config, {
    QueryBuilder? queryBuilder,
  }) async {
    try {
      // 简化实现：获取所有项目然后在内存中分页
      List<models.BaseItem> allItems = [];
      
      if (queryBuilder != null) {
        final queryResult = await query(queryBuilder);
        if (!queryResult.isSuccess) {
          return RepositoryResult.failure(
            status: queryResult.status,
            errorMessage: queryResult.errorMessage!,
          );
        }
        allItems = queryResult.data!;
      } else {
        final allResult = await getAll();
        if (!allResult.isSuccess) {
          return RepositoryResult.failure(
            status: allResult.status,
            errorMessage: allResult.errorMessage!,
          );
        }
        allItems = allResult.data!;
      }
      
      final totalCount = allItems.length;
      final startIndex = config.offset;
      final endIndex = (startIndex + config.pageSize).clamp(0, totalCount);
      
      final pagedItems = startIndex < totalCount 
          ? allItems.sublist(startIndex, endIndex)
          : <models.BaseItem>[];
      
      final result = PagedResult<models.BaseItem>(
        items: pagedItems,
        totalCount: totalCount,
        currentPage: config.page,
        pageSize: config.pageSize,
      );
      
      return RepositoryResult.success(result);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '分页查询失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<int>> count({QueryBuilder? queryBuilder}) async {
    try {
      if (queryBuilder == null) {
        final query = _database.select(_database.baseItems)
          ..where((item) => item.isDeleted.equals(false));
        final items = await query.get();
        return RepositoryResult.success(items.length);
      } else {
        final queryResult = await query(queryBuilder);
        if (!queryResult.isSuccess) {
          return RepositoryResult.failure(
            status: queryResult.status,
            errorMessage: queryResult.errorMessage!,
          );
        }
        return RepositoryResult.success(queryResult.data!.length);
      }
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '统计失败: $e',
      );
    }
  }

  // ============================================================================
  // 批量操作实现 (Batch Operations Implementation)
  // ============================================================================

  @override
  Future<RepositoryResult<List<models.BaseItem>>> saveAll(
    List<models.BaseItem> items, {
    BatchConfig? config,
  }) async {
    final batchConfig = config ?? const BatchConfig();
    final successItems = <models.BaseItem>[];
    final errors = <String>[];

    try {
      await _database.transaction(() async {
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          
          try {
            final saveResult = await save(item);
            if (saveResult.isSuccess) {
              successItems.add(saveResult.data!);
            } else {
              final error = '索引 $i: ${saveResult.errorMessage}';
              errors.add(error);
              
              if (!batchConfig.continueOnError) {
                throw Exception(error);
              }
            }
          } catch (e) {
            final error = '索引 $i: $e';
            errors.add(error);
            
            if (!batchConfig.continueOnError) {
              throw Exception(error);
            }
          }
        }
      });
      
      final metadata = {
        'totalCount': items.length,
        'successCount': successItems.length,
        'errorCount': errors.length,
        'errors': errors,
      };
      
      return RepositoryResult(
        status: RepositoryResultStatus.success,
        data: successItems,
        metadata: metadata,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '批量保存失败: $e',
        metadata: {'successCount': successItems.length, 'errors': errors},
      );
    }
  }

  @override
  Future<RepositoryResult<Map<String, dynamic>>> deleteAll(
    List<String> ids, {
    BatchConfig? config,
  }) async {
    final batchConfig = config ?? const BatchConfig();
    final deletedIds = <String>[];
    final notFoundIds = <String>[];
    final errors = <String>[];

    try {
      await _database.transaction(() async {
        for (final id in ids) {
          try {
            final deleteResult = await deleteById(id);
            if (deleteResult.isSuccess) {
              deletedIds.add(id);
            } else if (deleteResult.status == RepositoryResultStatus.notFound) {
              notFoundIds.add(id);
              if (!batchConfig.continueOnError) {
                throw Exception('未找到ID: $id');
              }
            } else {
              errors.add('$id: ${deleteResult.errorMessage}');
              if (!batchConfig.continueOnError) {
                throw Exception(deleteResult.errorMessage!);
              }
            }
          } catch (e) {
            errors.add('$id: $e');
            if (!batchConfig.continueOnError) {
              throw Exception('$id: $e');
            }
          }
        }
      });
      
      final metadata = {
        'totalCount': ids.length,
        'deletedCount': deletedIds.length,
        'notFoundCount': notFoundIds.length,
        'errorCount': errors.length,
        'deletedIds': deletedIds,
        'notFoundIds': notFoundIds,
        'errors': errors,
      };
      
      return RepositoryResult.success(metadata);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '批量删除失败: $e',
        metadata: {
          'deletedCount': deletedIds.length,
          'errors': errors,
        },
      );
    }
  }

  // ============================================================================
  // 事务支持实现 (Transaction Support Implementation)
  // ============================================================================

  @override
  Future<RepositoryResult<T>> transaction<T>(
    Future<T> Function(IPersistenceRepository repo) operation,
  ) async {
    try {
      final result = await _database.transaction(() async {
        return await operation(this);
      });
      
      return RepositoryResult.success(result);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '事务执行失败: $e',
      );
    }
  }

  // ============================================================================
  // 数据管理实现 (Data Management Implementation)
  // ============================================================================

  @override
  Future<RepositoryResult<Map<String, dynamic>>> clear({
    models.ItemType? itemType,
    required bool confirm,
  }) async {
    if (!confirm) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.validationError,
        errorMessage: '清空操作需要确认',
      );
    }

    try {
      final beforeQuery = _database.select(_database.baseItems)
        ..where((item) => item.isDeleted.equals(false));
      if (itemType != null) {
        beforeQuery.where((item) => item.itemType.equals(itemType.code));
      }
      final beforeCount = (await beforeQuery.get()).length;
      
      final updateQuery = _database.update(_database.baseItems)
        ..where((item) => item.isDeleted.equals(false));
      if (itemType != null) {
        updateQuery.where((item) => item.itemType.equals(itemType.code));
      }
      
      await updateQuery.write(db.BaseItemsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
      
      // 清理同步状态
      if (itemType == null) {
        await _database.delete(_database.syncStatus).go();
      }
      
      final result = {
        'beforeCount': beforeCount,
        'deletedCount': beforeCount,
        'itemType': itemType?.toString() ?? 'all',
      };
      
      return RepositoryResult.success(result);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '清空操作失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<Map<String, dynamic>>> getStatistics() async {
    try {
      final dbStats = await _database.getStatistics();
      return RepositoryResult.success(dbStats);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '获取统计信息失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<Map<String, dynamic>>> validateIntegrity() async {
    try {
      final healthCheck = await _database.healthCheck();
      final result = {
        'healthy': healthCheck,
        'timestamp': DateTime.now().toIso8601String(),
        'issues': <String>[],
      };
      
      if (!healthCheck) {
        result['issues'] = ['数据库健康检查失败'];
      }
      
      return RepositoryResult.success(result);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '完整性检查失败: $e',
      );
    }
  }

  // ============================================================================
  // 同步支持实现 (Synchronization Support Implementation)
  // ============================================================================

  @override
  Future<RepositoryResult<List<models.BaseItem>>> getModifiedSince(
    DateTime since, {
    models.ItemType? itemType,
  }) async {
    try {
      final query = _database.select(_database.baseItems)
        ..where((item) => item.isDeleted.equals(false))
        ..where((item) => item.updatedAt.isBiggerThanValue(since));
      
      if (itemType != null) {
        query.where((item) => item.itemType.equals(itemType.code));
      }
      
      final items = await query.get();
      final baseItems = items.map((item) => _driftItemToBaseItem(item)).toList();
      
      return RepositoryResult.success(baseItems);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '获取修改项目失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<void>> markForSync(List<String> ids) async {
    try {
      await _database.transaction(() async {
        for (final id in ids) {
          await _updateSyncStatus(id, 'unknown', 'pending');
        }
      });
      
      return RepositoryResult.success(null);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '标记同步失败: $e',
      );
    }
  }

  // ============================================================================
  // 资源管理实现 (Resource Management Implementation)
  // ============================================================================

  @override
  Future<void> dispose() async {
    await _database.close();
  }

  @override
  Future<RepositoryResult<Map<String, dynamic>>> healthCheck() async {
    try {
      final isHealthy = await _database.healthCheck();
      final statistics = await _database.getStatistics();
      
      final result = {
        'healthy': isHealthy,
        'statistics': statistics,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      return RepositoryResult.success(result);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '健康检查失败: $e',
      );
    }
  }

  // ============================================================================
  // 私有辅助方法 (Private Helper Methods)
  // ============================================================================

  /// 将Drift的BaseItem转换为业务模型的BaseItem
  models.BaseItem _driftItemToBaseItem(db.BaseItem driftItem) {
    // 解析JSON字段
    Map<String, dynamic> metadata = {};
    List<String> tags = [];
    
    try {
      metadata = jsonDecode(driftItem.metadata) as Map<String, dynamic>;
    } catch (e) {
      // 如果解析失败，使用空的Map
      metadata = {};
    }
    
    try {
      tags = List<String>.from(jsonDecode(driftItem.tags));
    } catch (e) {
      // 如果解析失败，使用空列表
      tags = [];
    }
    
    // 转换枚举类型
    final itemType = models.ItemType.values.firstWhere(
      (type) => type.code == driftItem.itemType,
      orElse: () => models.ItemType.note,
    );
    
    final status = models.ItemStatus.values.firstWhere(
      (status) => status.code == driftItem.status,
      orElse: () => models.ItemStatus.draft,
    );
    
    return models.SimpleItem(
      id: driftItem.id,
      title: driftItem.title,
      description: driftItem.description,
      itemType: itemType,
      metadata: metadata,
      status: status,
      createdAt: driftItem.createdAt,
      updatedAt: driftItem.updatedAt,
      tags: tags,
    );
  }

  /// 将业务模型的BaseItem转换为Drift的Companion
  db.BaseItemsCompanion _baseItemToDriftCompanion(models.BaseItem item) {
    return db.BaseItemsCompanion.insert(
      id: item.id,
      title: item.title,
      description: Value(item.description),
      itemType: item.itemType.code,
      metadata: Value(jsonEncode(item.metadata)),
      status: Value(item.status.code),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      tags: Value(jsonEncode(item.tags)),
      contentHash: Value(item.contentHash),
      needsSync: const Value(true),
      isDeleted: const Value(false),
    );
  }

  /// 更新同步状态
  Future<void> _updateSyncStatus(String entityId, String entityType, String status) async {
    try {
      final companion = db.SyncStatusCompanion.insert(
        entityId: entityId,
        entityType: entityType,
        status: status,
        syncTimestamp: Value(DateTime.now()),
        retryCount: const Value(0),
        createdAt: DateTime.now(),
      );

      await _database.into(_database.syncStatus).insertOnConflictUpdate(companion);
    } catch (e) {
      // 同步状态更新失败不应该影响主要操作
      print('警告：同步状态更新失败: $e');
    }
  }

  /// 应用查询构建器过滤器（简化实现）
  List<models.BaseItem> _applyQueryBuilder(List<models.BaseItem> items, QueryBuilder queryBuilder) {
    final conditions = queryBuilder.build();
    
    return items.where((item) {
      // 简化的过滤逻辑
      if (conditions.containsKey('status') && item.status.code != conditions['status']) {
        return false;
      }
      if (conditions.containsKey('itemType') && item.itemType.code != conditions['itemType']) {
        return false;
      }
      if (conditions.containsKey('tags')) {
        final requiredTags = List<String>.from(conditions['tags']);
        if (!requiredTags.every((tag) => item.tags.contains(tag))) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
} 