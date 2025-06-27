# InMemoryRepository API 文档

## 概述

InMemoryRepository是桌宠应用的内存数据存储实现，提供快速的数据访问和基础的CRUD操作。它实现了IPersistenceRepository接口，为Phase 1开发阶段提供简单高效的数据存储解决方案，支持数据过滤、查询和内存优化管理。

- **主要功能**: 内存存储、基础CRUD、简单查询、数据过滤
- **设计模式**: Repository模式 + 单例模式
- **存储方式**: 内存Map集合 + 简单索引
- **位置**: `lib/core/services/repositories/in_memory_repository.dart`

## 核心类定义

### InMemoryRepository 主实现类
```dart
class InMemoryRepository implements IPersistenceRepository {
  static final InMemoryRepository _instance = InMemoryRepository._internal();
  static InMemoryRepository get instance => _instance;
  
  InMemoryRepository._internal();
  
  // 主数据存储
  final Map<String, BaseItem> _items = {};
  
  // 类型索引（用于快速类型查询）
  final Map<ItemType, Set<String>> _typeIndex = {};
  
  // 状态索引（用于快速状态查询）
  final Map<ItemStatus, Set<String>> _statusIndex = {};
  
  // 用于生成唯一ID的计数器
  int _idCounter = 1;
  
  // 是否启用调试日志
  bool _debugLogging = false;
}
```

## 基础CRUD操作

### `getById` 根据ID获取项目
```dart
@override
Future<RepositoryResult<BaseItem>> getById(String id) async {
  _logDebug('getById called with id: $id');
  
  try {
    final item = _items[id];
    if (item != null) {
      _logDebug('getById found item: ${item.itemType}');
      return RepositoryResult.success(item);
    } else {
      _logDebug('getById item not found for id: $id');
      return RepositoryResult.failure(
        error: RepositoryErrorType.notFound,
        message: 'Item with id $id not found',
      );
    }
  } catch (e) {
    _logDebug('getById error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to get item: ${e.toString()}',
    );
  }
}
```

### `save` 保存或更新项目
```dart
@override
Future<RepositoryResult<BaseItem>> save(BaseItem item) async {
  _logDebug('save called for item: ${item.itemType} with id: ${item.id}');
  
  try {
    // 如果是新项目且没有ID，生成新ID
    BaseItem itemToSave = item;
    if (item.id.isEmpty || item.id == 'temp_id') {
      final newId = _generateId();
      itemToSave = item.copyWith(
        id: newId,
        updatedAt: DateTime.now(),
      ) as BaseItem;
      _logDebug('Generated new id: $newId');
    } else {
      // 更新现有项目
      itemToSave = item.copyWith(
        updatedAt: DateTime.now(),
      ) as BaseItem;
    }
    
    // 保存到主存储
    _items[itemToSave.id] = itemToSave;
    
    // 更新索引
    _updateIndexes(itemToSave);
    
    _logDebug('save completed for id: ${itemToSave.id}');
    return RepositoryResult.success(itemToSave);
    
  } catch (e) {
    _logDebug('save error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to save item: ${e.toString()}',
    );
  }
}
```

### `deleteById` 根据ID删除项目
```dart
@override
Future<RepositoryResult<BaseItem>> deleteById(String id) async {
  _logDebug('deleteById called with id: $id');
  
  try {
    final item = _items.remove(id);
    if (item != null) {
      // 从索引中移除
      _removeFromIndexes(item);
      
      _logDebug('deleteById completed for id: $id');
      return RepositoryResult.success(item);
    } else {
      _logDebug('deleteById item not found for id: $id');
      return RepositoryResult.failure(
        error: RepositoryErrorType.notFound,
        message: 'Item with id $id not found',
      );
    }
  } catch (e) {
    _logDebug('deleteById error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to delete item: ${e.toString()}',
    );
  }
}
```

### `exists` 检查项目是否存在
```dart
@override
Future<RepositoryResult<bool>> exists(String id) async {
  _logDebug('exists called with id: $id');
  
  try {
    final exists = _items.containsKey(id);
    _logDebug('exists result for id $id: $exists');
    return RepositoryResult.success(exists);
  } catch (e) {
    _logDebug('exists error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to check existence: ${e.toString()}',
    );
  }
}
```

## 查询操作

### `getAll` 获取所有项目（可选类型过滤）
```dart
@override
Future<RepositoryResult<List<BaseItem>>> getAll({ItemType? itemType}) async {
  _logDebug('getAll called with itemType: $itemType');
  
  try {
    List<BaseItem> items;
    
    if (itemType != null) {
      // 使用类型索引进行过滤
      final typeIds = _typeIndex[itemType] ?? {};
      items = typeIds
          .map((id) => _items[id])
          .where((item) => item != null)
          .cast<BaseItem>()
          .toList();
    } else {
      // 返回所有项目
      items = _items.values.toList();
    }
    
    // 按更新时间倒序排列
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    _logDebug('getAll found ${items.length} items');
    return RepositoryResult.success(items);
    
  } catch (e) {
    _logDebug('getAll error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to get items: ${e.toString()}',
    );
  }
}
```

### `getByType` 根据类型获取项目
```dart
@override
Future<RepositoryResult<List<BaseItem>>> getByType(ItemType itemType) async {
  return getAll(itemType: itemType);
}
```

### `getByStatus` 根据状态获取项目
```dart
@override
Future<RepositoryResult<List<BaseItem>>> getByStatus(ItemStatus status) async {
  _logDebug('getByStatus called with status: $status');
  
  try {
    // 使用状态索引进行过滤
    final statusIds = _statusIndex[status] ?? {};
    final items = statusIds
        .map((id) => _items[id])
        .where((item) => item != null)
        .cast<BaseItem>()
        .toList();
    
    // 按更新时间倒序排列
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    _logDebug('getByStatus found ${items.length} items');
    return RepositoryResult.success(items);
    
  } catch (e) {
    _logDebug('getByStatus error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to get items by status: ${e.toString()}',
    );
  }
}
```

### `query` 复杂查询（简化实现）
```dart
@override
Future<RepositoryResult<List<BaseItem>>> query(QueryBuilder queryBuilder) async {
  _logDebug('query called with conditions: ${queryBuilder.conditions.length}');
  
  try {
    // 获取所有项目作为起始点
    var items = _items.values.toList();
    
    // 应用查询条件
    for (final condition in queryBuilder.conditions) {
      items = _applyCondition(items, condition);
    }
    
    // 应用排序
    if (queryBuilder.orderBy.isNotEmpty) {
      items = _applySorting(items, queryBuilder.orderBy);
    }
    
    // 应用分页
    if (queryBuilder.offset > 0 || queryBuilder.limit > 0) {
      final start = queryBuilder.offset;
      final end = queryBuilder.limit > 0 
          ? (start + queryBuilder.limit).clamp(0, items.length)
          : items.length;
      items = items.sublist(start.clamp(0, items.length), end);
    }
    
    _logDebug('query result: ${items.length} items');
    return RepositoryResult.success(items);
    
  } catch (e) {
    _logDebug('query error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to execute query: ${e.toString()}',
    );
  }
}
```

## 批量操作

### `saveAll` 批量保存
```dart
@override
Future<RepositoryResult<List<BaseItem>>> saveAll(List<BaseItem> items) async {
  _logDebug('saveAll called with ${items.length} items');
  
  try {
    final savedItems = <BaseItem>[];
    
    for (final item in items) {
      final result = await save(item);
      if (result.isSuccess) {
        savedItems.add(result.data!);
      } else {
        // 如果任何一个保存失败，返回错误
        return RepositoryResult.failure(
          error: result.error!,
          message: 'Batch save failed at item ${item.id}: ${result.message}',
        );
      }
    }
    
    _logDebug('saveAll completed: ${savedItems.length} items saved');
    return RepositoryResult.success(savedItems);
    
  } catch (e) {
    _logDebug('saveAll error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to save all items: ${e.toString()}',
    );
  }
}
```

### `deleteAll` 批量删除
```dart
@override
Future<RepositoryResult<List<BaseItem>>> deleteAll(List<String> ids) async {
  _logDebug('deleteAll called with ${ids.length} ids');
  
  try {
    final deletedItems = <BaseItem>[];
    
    for (final id in ids) {
      final result = await deleteById(id);
      if (result.isSuccess) {
        deletedItems.add(result.data!);
      } else {
        // 继续删除其他项目，不因单个失败而停止
        _logDebug('deleteAll: failed to delete id $id: ${result.message}');
      }
    }
    
    _logDebug('deleteAll completed: ${deletedItems.length} items deleted');
    return RepositoryResult.success(deletedItems);
    
  } catch (e) {
    _logDebug('deleteAll error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to delete all items: ${e.toString()}',
    );
  }
}
```

## 数据管理

### `count` 统计项目数量
```dart
@override
Future<RepositoryResult<int>> count({ItemType? itemType}) async {
  _logDebug('count called with itemType: $itemType');
  
  try {
    int count;
    
    if (itemType != null) {
      final typeIds = _typeIndex[itemType] ?? {};
      count = typeIds.length;
    } else {
      count = _items.length;
    }
    
    _logDebug('count result: $count');
    return RepositoryResult.success(count);
    
  } catch (e) {
    _logDebug('count error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to count items: ${e.toString()}',
    );
  }
}
```

### `clear` 清空所有数据
```dart
@override
Future<RepositoryResult<bool>> clear() async {
  _logDebug('clear called');
  
  try {
    final itemCount = _items.length;
    
    // 清空主存储
    _items.clear();
    
    // 清空索引
    _typeIndex.clear();
    _statusIndex.clear();
    
    // 重置ID计数器
    _idCounter = 1;
    
    _logDebug('clear completed: $itemCount items removed');
    return RepositoryResult.success(true);
    
  } catch (e) {
    _logDebug('clear error: $e');
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to clear repository: ${e.toString()}',
    );
  }
}
```

## 内部方法

### 索引管理
```dart
void _updateIndexes(BaseItem item) {
  // 更新类型索引
  _typeIndex.putIfAbsent(item.itemType, () => {}).add(item.id);
  
  // 更新状态索引
  _statusIndex.putIfAbsent(item.status, () => {}).add(item.id);
}

void _removeFromIndexes(BaseItem item) {
  // 从类型索引移除
  _typeIndex[item.itemType]?.remove(item.id);
  if (_typeIndex[item.itemType]?.isEmpty == true) {
    _typeIndex.remove(item.itemType);
  }
  
  // 从状态索引移除
  _statusIndex[item.status]?.remove(item.id);
  if (_statusIndex[item.status]?.isEmpty == true) {
    _statusIndex.remove(item.status);
  }
}
```

### ID生成
```dart
String _generateId() {
  return 'item_${_idCounter++}_${DateTime.now().millisecondsSinceEpoch}';
}
```

### 查询条件应用
```dart
List<BaseItem> _applyCondition(List<BaseItem> items, QueryCondition condition) {
  return items.where((item) {
    final value = _getPropertyValue(item, condition.field);
    return _evaluateCondition(value, condition.operator, condition.value);
  }).toList();
}

dynamic _getPropertyValue(BaseItem item, String field) {
  switch (field) {
    case 'id':
      return item.id;
    case 'itemType':
      return item.itemType;
    case 'status':
      return item.status;
    case 'createdAt':
      return item.createdAt;
    case 'updatedAt':
      return item.updatedAt;
    case 'title':
      return item.title;
    case 'description':
      return item.description;
    default:
      return null;
  }
}

bool _evaluateCondition(dynamic value, QueryOperator operator, dynamic target) {
  switch (operator) {
    case QueryOperator.equals:
      return value == target;
    case QueryOperator.notEquals:
      return value != target;
    case QueryOperator.contains:
      return value.toString().toLowerCase().contains(target.toString().toLowerCase());
    case QueryOperator.startsWith:
      return value.toString().toLowerCase().startsWith(target.toString().toLowerCase());
    case QueryOperator.endsWith:
      return value.toString().toLowerCase().endsWith(target.toString().toLowerCase());
    case QueryOperator.greaterThan:
      return value.compareTo(target) > 0;
    case QueryOperator.lessThan:
      return value.compareTo(target) < 0;
    case QueryOperator.greaterThanOrEqual:
      return value.compareTo(target) >= 0;
    case QueryOperator.lessThanOrEqual:
      return value.compareTo(target) <= 0;
    case QueryOperator.inList:
      return (target as List).contains(value);
    default:
      return false;
  }
}
```

### 排序应用
```dart
List<BaseItem> _applySorting(List<BaseItem> items, List<OrderByClause> orderBy) {
  items.sort((a, b) {
    for (final clause in orderBy) {
      final valueA = _getPropertyValue(a, clause.field);
      final valueB = _getPropertyValue(b, clause.field);
      
      int comparison = 0;
      if (valueA != null && valueB != null) {
        comparison = valueA.compareTo(valueB);
      } else if (valueA != null) {
        comparison = 1;
      } else if (valueB != null) {
        comparison = -1;
      }
      
      if (comparison != 0) {
        return clause.ascending ? comparison : -comparison;
      }
    }
    return 0;
  });
  
  return items;
}
```

### 调试日志
```dart
void _logDebug(String message) {
  if (_debugLogging) {
    print('[InMemoryRepository] $message');
  }
}

void enableDebugLogging(bool enable) {
  _debugLogging = enable;
  _logDebug('Debug logging ${enable ? 'enabled' : 'disabled'}');
}
```

## 数据统计

### `getStatistics` 获取存储统计信息
```dart
Future<RepositoryResult<Map<String, dynamic>>> getStatistics() async {
  try {
    final stats = <String, dynamic>{
      'totalItems': _items.length,
      'idCounter': _idCounter,
      'typeBreakdown': <String, int>{},
      'statusBreakdown': <String, int>{},
      'memoryUsage': _estimateMemoryUsage(),
    };
    
    // 统计各类型数量
    for (final entry in _typeIndex.entries) {
      stats['typeBreakdown'][entry.key.value] = entry.value.length;
    }
    
    // 统计各状态数量
    for (final entry in _statusIndex.entries) {
      stats['statusBreakdown'][entry.key.value] = entry.value.length;
    }
    
    return RepositoryResult.success(stats);
  } catch (e) {
    return RepositoryResult.failure(
      error: RepositoryErrorType.operationFailed,
      message: 'Failed to get statistics: ${e.toString()}',
    );
  }
}

int _estimateMemoryUsage() {
  // 粗略估算内存使用量（字节）
  int totalSize = 0;
  
  // 主数据存储
  totalSize += _items.length * 1024; // 假设每个项目平均1KB
  
  // 索引存储
  totalSize += _typeIndex.values.fold(0, (sum, set) => sum + set.length * 50);
  totalSize += _statusIndex.values.fold(0, (sum, set) => sum + set.length * 50);
  
  return totalSize;
}
```

## 使用示例

### 基础使用
```dart
final repository = InMemoryRepository.instance;

// 启用调试日志
repository.enableDebugLogging(true);

// 保存项目
final newItem = BaseItem.createNote(
  title: '测试笔记',
  description: '这是一个测试笔记',
);

final saveResult = await repository.save(newItem);
if (saveResult.isSuccess) {
  print('保存成功: ${saveResult.data!.id}');
}

// 查询项目
final allItems = await repository.getAll();
if (allItems.isSuccess) {
  print('共有 ${allItems.data!.length} 个项目');
}

// 按类型查询
final notes = await repository.getByType(ItemType.note);
if (notes.isSuccess) {
  print('共有 ${notes.data!.length} 个笔记');
}
```

### 复杂查询示例
```dart
// 构建查询：查找最近7天创建的活跃笔记
final query = QueryBuilder()
  .where('itemType', QueryOperator.equals, ItemType.note)
  .where('status', QueryOperator.equals, ItemStatus.active)
  .where('createdAt', QueryOperator.greaterThan, 
         DateTime.now().subtract(Duration(days: 7)))
  .orderBy('updatedAt', ascending: false)
  .limit(10);

final result = await repository.query(query);
if (result.isSuccess) {
  print('找到 ${result.data!.length} 个匹配项目');
}
```

### 批量操作示例
```dart
// 批量保存
final items = [
  BaseItem.createNote(title: '笔记1', description: '内容1'),
  BaseItem.createTodo(title: '任务1', description: '任务内容1'),
  BaseItem.createIdea(title: '想法1', description: '想法内容1'),
];

final batchResult = await repository.saveAll(items);
if (batchResult.isSuccess) {
  print('批量保存成功: ${batchResult.data!.length} 个项目');
}

// 获取统计信息
final stats = await repository.getStatistics();
if (stats.isSuccess) {
  final data = stats.data!;
  print('总项目数: ${data['totalItems']}');
  print('内存使用: ${data['memoryUsage']} 字节');
  print('类型分布: ${data['typeBreakdown']}');
}
```

## 性能特性

### 内存优化
- **索引加速**: 使用类型和状态索引加速查询
- **延迟加载**: 查询结果按需生成，避免不必要的内存占用
- **批量操作**: 支持批量保存和删除，减少操作开销

### 查询性能
- **O(1)查询**: 基于ID的查询复杂度为O(1)
- **索引查询**: 基于类型和状态的查询通过索引优化
- **内存排序**: 所有排序操作在内存中进行，响应快速

### 限制说明
- **持久化**: 数据仅存储在内存中，应用重启后丢失
- **容量限制**: 受系统内存限制，不适合大量数据
- **并发安全**: 当前实现非线程安全，适用于单线程场景

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 基础CRUD操作
  - 简单查询和过滤
  - 类型和状态索引
  - 批量操作支持
  - 内存使用统计
  - 调试日志功能 