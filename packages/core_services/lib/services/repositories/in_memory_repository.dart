/*
---------------------------------------------------------------
File name:          in_memory_repository.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/25
Description:        内存数据仓储实现，提供Repository接口的测试实现
---------------------------------------------------------------
Change History:
    2025/06/25: Initial creation - 实现基于内存的数据持久化;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../models/base_item.dart';
import '../../models/repository_result.dart';
import './persistence_repository.dart';

/// 内存数据仓储实现
/// 
/// 基于内存的Repository实现，适用于测试和快速原型开发。
/// 提供完整的CRUD操作、查询功能和事务支持，但数据不会持久化。
class InMemoryRepository implements IPersistenceRepository {
  // ============================================================================
  // 内部数据存储 (Internal Data Storage)
  // ============================================================================

  /// 主数据存储 - 使用Map模拟数据库表
  final Map<String, BaseItem> _storage = <String, BaseItem>{};

  /// 同步标记存储 - 记录需要同步的实体ID
  final Set<String> _syncMarked = <String>{};

  /// 事务状态管理
  bool _inTransaction = false;
  Map<String, BaseItem>? _transactionSnapshot;

  /// 统计信息缓存
  DateTime? _lastStatsUpdate;
  Map<String, dynamic>? _cachedStats;

  // ============================================================================
  // 基础CRUD操作实现 (Core CRUD Operations Implementation)
  // ============================================================================

  @override
  Future<RepositoryResult<BaseItem>> getById(String id) async {
    try {
      final item = _storage[id];
      if (item == null) {
        return RepositoryResult.failure(
          status: RepositoryResultStatus.notFound,
          errorMessage: '未找到ID为 $id 的实体',
        );
      }
      return RepositoryResult.success(item);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '获取实体失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<BaseItem>> save(BaseItem item) async {
    try {
      // 数据验证
      final validationResult = _validateItem(item);
      if (!validationResult.isValid) {
        return RepositoryResult.failure(
          status: RepositoryResultStatus.validationError,
          errorMessage: validationResult.errorMessage!,
        );
      }

      // 准备保存的实体
      // 注意：由于BaseItem的copyWith不支持id/时间字段，这里直接使用原item
      // 在具体的实体类实现中会有完整的时间戳处理
      BaseItem savedItem = item;

      // 保存到存储
      _storage[savedItem.id] = savedItem;
      
      // 标记需要同步
      _syncMarked.add(savedItem.id);
      
      // 清除统计缓存
      _invalidateStatsCache();

      return RepositoryResult.success(savedItem);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '保存实体失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<BaseItem>> deleteById(String id) async {
    try {
      final item = _storage.remove(id);
      if (item == null) {
        return RepositoryResult.failure(
          status: RepositoryResultStatus.notFound,
          errorMessage: '未找到ID为 $id 的实体',
        );
      }
      
      // 移除同步标记
      _syncMarked.remove(id);
      
      // 清除统计缓存
      _invalidateStatsCache();

      return RepositoryResult.success(item);
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
      final exists = _storage.containsKey(id);
      return RepositoryResult.success(exists);
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
  Future<RepositoryResult<List<BaseItem>>> getAll({ItemType? itemType}) async {
    try {
      List<BaseItem> items = _storage.values.toList();
      
      if (itemType != null) {
        items = items.where((item) => item.itemType == itemType).toList();
      }
      
      // 按创建时间降序排列
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return RepositoryResult.success(items);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '获取实体列表失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<List<BaseItem>>> query(QueryBuilder queryBuilder) async {
    try {
      List<BaseItem> items = _storage.values.toList();
      
      // 应用查询条件
      items = _applyQueryBuilder(items, queryBuilder);
      
      return RepositoryResult.success(items);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '查询失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<PagedResult<BaseItem>>> queryPaged(
    PaginationConfig config, {
    QueryBuilder? queryBuilder,
  }) async {
    try {
      // 验证分页配置
      if (!config.isValid) {
        return RepositoryResult.failure(
          status: RepositoryResultStatus.validationError,
          errorMessage: '分页配置无效: 页码和页大小必须大于0，页大小不能超过100',
        );
      }

      List<BaseItem> allItems = _storage.values.toList();
      
      // 应用查询条件
      if (queryBuilder != null) {
        allItems = _applyQueryBuilder(allItems, queryBuilder);
      }
      
      // 应用排序
      if (config.sortBy != null) {
        _applySorting(allItems, config.sortBy!, config.descending);
      } else {
        // 默认按创建时间降序
        allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      final totalCount = allItems.length;
      
      // 计算分页
      final startIndex = config.offset;
      final endIndex = (startIndex + config.pageSize).clamp(0, totalCount);
      
      final pagedItems = startIndex < totalCount 
          ? allItems.sublist(startIndex, endIndex)
          : <BaseItem>[];
      
      final result = PagedResult<BaseItem>(
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
      List<BaseItem> items = _storage.values.toList();
      
      if (queryBuilder != null) {
        items = _applyQueryBuilder(items, queryBuilder);
      }
      
      return RepositoryResult.success(items.length);
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
  Future<RepositoryResult<List<BaseItem>>> saveAll(
    List<BaseItem> items, {
    BatchConfig? config,
  }) async {
    final batchConfig = config ?? const BatchConfig();
    final successItems = <BaseItem>[];
    final errors = <String>[];

    try {
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        
        if (batchConfig.validateBeforeSave) {
          final validationResult = _validateItem(item);
          if (!validationResult.isValid) {
            final error = '索引 $i: ${validationResult.errorMessage}';
            errors.add(error);
            
            if (!batchConfig.continueOnError) {
              return RepositoryResult.failure(
                status: RepositoryResultStatus.validationError,
                errorMessage: '批量保存中断: $error',
                metadata: {'successCount': successItems.length, 'errors': errors},
              );
            }
            continue;
          }
        }
        
        final saveResult = await save(item);
        if (saveResult.isSuccess) {
          successItems.add(saveResult.data!);
        } else {
          final error = '索引 $i: ${saveResult.errorMessage}';
          errors.add(error);
          
          if (!batchConfig.continueOnError) {
            return RepositoryResult.failure(
              status: saveResult.status,
              errorMessage: '批量保存中断: $error',
              metadata: {'successCount': successItems.length, 'errors': errors},
            );
          }
        }
      }
      
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
      for (final id in ids) {
        final deleteResult = await deleteById(id);
        if (deleteResult.isSuccess) {
          deletedIds.add(id);
        } else if (deleteResult.status == RepositoryResultStatus.notFound) {
          notFoundIds.add(id);
          if (!batchConfig.continueOnError) {
            break;
          }
        } else {
          errors.add('$id: ${deleteResult.errorMessage}');
          if (!batchConfig.continueOnError) {
            break;
          }
        }
      }
      
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
    if (_inTransaction) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '不支持嵌套事务',
      );
    }

    try {
      // 开始事务 - 创建数据快照
      _inTransaction = true;
      _transactionSnapshot = Map<String, BaseItem>.from(_storage);
      
      // 执行事务操作
      final result = await operation(this);
      
      // 提交事务 - 清除快照
      _transactionSnapshot = null;
      _inTransaction = false;
      
      return RepositoryResult.success(result);
    } catch (e) {
      // 回滚事务 - 恢复快照
      if (_transactionSnapshot != null) {
        _storage.clear();
        _storage.addAll(_transactionSnapshot!);
        _transactionSnapshot = null;
      }
      _inTransaction = false;
      
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
    ItemType? itemType,
    required bool confirm,
  }) async {
    if (!confirm) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.validationError,
        errorMessage: '清空操作需要确认',
      );
    }

    try {
      final beforeCount = _storage.length;
      
      if (itemType == null) {
        // 清空所有数据
        _storage.clear();
        _syncMarked.clear();
      } else {
        // 清空指定类型的数据
        final idsToRemove = _storage.entries
            .where((entry) => entry.value.itemType == itemType)
            .map((entry) => entry.key)
            .toList();
            
        for (final id in idsToRemove) {
          _storage.remove(id);
          _syncMarked.remove(id);
        }
      }
      
      _invalidateStatsCache();
      
      final afterCount = _storage.length;
      final deletedCount = beforeCount - afterCount;
      
      final result = {
        'beforeCount': beforeCount,
        'afterCount': afterCount,
        'deletedCount': deletedCount,
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
      // 使用缓存避免重复计算
      if (_cachedStats != null && _lastStatsUpdate != null &&
          DateTime.now().difference(_lastStatsUpdate!).inSeconds < 60) {
        return RepositoryResult.success(_cachedStats!);
      }
      
      final stats = <String, dynamic>{};
      
      // 总数统计
      stats['totalCount'] = _storage.length;
      stats['syncMarkedCount'] = _syncMarked.length;
      
      // 按类型统计
      final typeCounts = <ItemType, int>{};
      for (final item in _storage.values) {
        typeCounts[item.itemType] = (typeCounts[item.itemType] ?? 0) + 1;
      }
      stats['typeStatistics'] = typeCounts.map(
        (type, count) => MapEntry(type.toString(), count),
      );
      
      // 按状态统计
      final statusCounts = <ItemStatus, int>{};
      for (final item in _storage.values) {
        statusCounts[item.status] = (statusCounts[item.status] ?? 0) + 1;
      }
      stats['statusStatistics'] = statusCounts.map(
        (status, count) => MapEntry(status.toString(), count),
      );
      
      // 时间统计
      if (_storage.isNotEmpty) {
        final items = _storage.values.toList();
        items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        stats['oldestItem'] = items.first.createdAt.toIso8601String();
        stats['newestItem'] = items.last.createdAt.toIso8601String();
      }
      
      // 存储信息
      stats['memoryUsageEstimate'] = _estimateMemoryUsage();
      stats['lastUpdated'] = DateTime.now().toIso8601String();
      
      // 缓存结果
      _cachedStats = stats;
      _lastStatsUpdate = DateTime.now();
      
      return RepositoryResult.success(stats);
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
      final issues = <String>[];
      final warnings = <String>[];
      
      // 检查数据完整性
      for (final entry in _storage.entries) {
        final id = entry.key;
        final item = entry.value;
        
        // 检查ID一致性
        if (item.id != id) {
          issues.add('ID不一致: 存储键 $id != 实体ID ${item.id}');
        }
        
        // 检查基础字段
        if (item.title.trim().isEmpty) {
          warnings.add('实体 $id 的标题为空');
        }
        
        // 检查时间逻辑
        if (item.updatedAt.isBefore(item.createdAt)) {
          issues.add('实体 $id 的更新时间早于创建时间');
        }
        
        // 检查内容哈希
        final expectedHash = _calculateContentHash(item);
        if (item.contentHash != expectedHash) {
          warnings.add('实体 $id 的内容哈希可能过期');
        }
      }
      
      final result = {
        'isValid': issues.isEmpty,
        'totalItems': _storage.length,
        'issueCount': issues.length,
        'warningCount': warnings.length,
        'issues': issues,
        'warnings': warnings,
        'checkedAt': DateTime.now().toIso8601String(),
      };
      
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
  Future<RepositoryResult<List<BaseItem>>> getModifiedSince(
    DateTime since, {
    ItemType? itemType,
  }) async {
    try {
      List<BaseItem> modifiedItems = _storage.values
          .where((item) => item.updatedAt.isAfter(since))
          .toList();
          
      if (itemType != null) {
        modifiedItems = modifiedItems
            .where((item) => item.itemType == itemType)
            .toList();
      }
      
      // 按更新时间排序
      modifiedItems.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      
      return RepositoryResult.success(modifiedItems);
    } catch (e) {
      return RepositoryResult.failure(
        status: RepositoryResultStatus.storageError,
        errorMessage: '获取修改记录失败: $e',
      );
    }
  }

  @override
  Future<RepositoryResult<void>> markForSync(List<String> ids) async {
    try {
      int markedCount = 0;
      final notFoundIds = <String>[];
      
      for (final id in ids) {
        if (_storage.containsKey(id)) {
          _syncMarked.add(id);
          markedCount++;
        } else {
          notFoundIds.add(id);
        }
      }
      
      final metadata = {
        'requestedCount': ids.length,
        'markedCount': markedCount,
        'notFoundCount': notFoundIds.length,
        'notFoundIds': notFoundIds,
      };
      
      return RepositoryResult(
        status: RepositoryResultStatus.success,
        data: null,
        metadata: metadata,
        timestamp: DateTime.now(),
      );
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
    _storage.clear();
    _syncMarked.clear();
    _transactionSnapshot = null;
    _inTransaction = false;
    _cachedStats = null;
    _lastStatsUpdate = null;
  }

  @override
  Future<RepositoryResult<Map<String, dynamic>>> healthCheck() async {
    try {
      final health = <String, dynamic>{
        'status': 'healthy',
        'type': 'in_memory',
        'itemCount': _storage.length,
        'inTransaction': _inTransaction,
        'syncMarkedCount': _syncMarked.length,
        'memoryUsageEstimate': _estimateMemoryUsage(),
        'uptime': DateTime.now().toIso8601String(),
      };
      
      return RepositoryResult.success(health);
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

  /// 验证实体数据
  ({bool isValid, String? errorMessage}) _validateItem(BaseItem item) {
    if (item.title.trim().isEmpty) {
      return (isValid: false, errorMessage: '实体标题不能为空');
    }
    
    if (item.description.isNotEmpty && item.description.length > 10000) {
      return (isValid: false, errorMessage: '实体描述过长 (最大10000字符)');
    }
    
    return (isValid: true, errorMessage: null);
  }

  /// 应用查询构建器
  List<BaseItem> _applyQueryBuilder(List<BaseItem> items, QueryBuilder queryBuilder) {
    // 这里简化实现，在实际项目中需要解析queryBuilder的条件
    // 目前只支持基础过滤
    
    List<BaseItem> filteredItems = items;
    
    // 示例：支持按状态过滤
    // 在实际实现中，需要解析queryBuilder的完整条件语法
    
    return filteredItems;
  }

  /// 应用排序
  void _applySorting(List<BaseItem> items, String sortBy, bool descending) {
    switch (sortBy.toLowerCase()) {
      case 'title':
        items.sort((a, b) => descending 
            ? b.title.compareTo(a.title)
            : a.title.compareTo(b.title));
        break;
      case 'createdat':
      case 'created_at':
        items.sort((a, b) => descending 
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt));
        break;
      case 'updatedat':
      case 'updated_at':
        items.sort((a, b) => descending 
            ? b.updatedAt.compareTo(a.updatedAt)
            : a.updatedAt.compareTo(b.updatedAt));
        break;
      default:
        // 默认按创建时间排序
        items.sort((a, b) => descending 
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt));
        break;
    }
  }

  /// 计算内容哈希
  String _calculateContentHash(BaseItem item) {
    final content = '${item.title}|${item.description}|${item.itemType}';
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 估算内存使用
  String _estimateMemoryUsage() {
    int totalBytes = 0;
    
    for (final item in _storage.values) {
      // 简单估算：每个字符2字节 + 对象开销
      totalBytes += (item.title.length + item.description.length) * 2;
      totalBytes += 200; // 对象开销估算
    }
    
    if (totalBytes < 1024) {
      return '${totalBytes}B';
    } else if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 清除统计缓存
  void _invalidateStatsCache() {
    _cachedStats = null;
    _lastStatsUpdate = null;
  }
}

/// 内存Repository工厂实现
class InMemoryRepositoryFactory implements IRepositoryFactory {
  @override
  Future<IPersistenceRepository> createRepository(Map<String, dynamic> config) async {
    return InMemoryRepository();
  }

  @override
  List<String> getSupportedTypes() {
    return ['memory', 'in_memory', 'test'];
  }
} 