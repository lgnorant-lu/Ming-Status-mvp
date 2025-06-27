# IPersistenceRepository API 文档

## 概述

IPersistenceRepository是整个应用的数据持久化核心接口，定义了统一的数据访问契约。它支持从内存存储到SQLite等不同存储实现的演进，为Repository模式提供了类型安全、功能完整的数据操作基础。

- **主要功能**: CRUD操作、高级查询、分页查询、批量操作、事务处理、数据管理
- **设计模式**: Repository模式 + 工厂模式
- **依赖关系**: 依赖于BaseItem数据模型
- **位置**: `lib/core/services/repositories/persistence_repository.dart`

## 核心接口定义

### IPersistenceRepository 接口
```dart
abstract class IPersistenceRepository {
  // 基础CRUD操作
  Future<RepositoryResult<BaseItem>> getById(String id);
  Future<RepositoryResult<BaseItem>> save(BaseItem item);
  Future<RepositoryResult<BaseItem>> deleteById(String id);
  Future<RepositoryResult<bool>> exists(String id);
  
  // 查询操作
  Future<RepositoryResult<List<BaseItem>>> getAll({ItemType? itemType});
  Future<RepositoryResult<List<BaseItem>>> query(QueryBuilder queryBuilder);
  Future<RepositoryResult<PagedResult<BaseItem>>> queryPaged(PaginationConfig config, {QueryBuilder? queryBuilder});
  Future<RepositoryResult<int>> count({QueryBuilder? queryBuilder});
  
  // 批量操作
  Future<RepositoryResult<List<BaseItem>>> saveAll(List<BaseItem> items, {BatchConfig? config});
  Future<RepositoryResult<Map<String, dynamic>>> deleteAll(List<String> ids, {BatchConfig? config});
  
  // 事务支持
  Future<RepositoryResult<T>> transaction<T>(Future<T> Function(IPersistenceRepository repo) operation);
  
  // 数据管理
  Future<RepositoryResult<Map<String, dynamic>>> clear({ItemType? itemType, required bool confirm});
  Future<RepositoryResult<Map<String, dynamic>>> getStatistics();
  Future<RepositoryResult<Map<String, dynamic>>> validateIntegrity();
  
  // 同步支持（预留）
  Future<RepositoryResult<List<BaseItem>>> getModifiedSince(DateTime since, {ItemType? itemType});
  Future<RepositoryResult<void>> markForSync(List<String> ids);
  
  // 资源管理
  Future<void> dispose();
  Future<RepositoryResult<Map<String, dynamic>>> healthCheck();
}
```

## 核心类型定义

### RepositoryResult<T> 类
```dart
class RepositoryResult<T> {
  final RepositoryResultStatus status;
  final T? data;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const RepositoryResult({
    required this.status,
    this.data,
    this.errorMessage,
    this.metadata,
  });

  /// 创建成功结果
  RepositoryResult.success(this.data);

  /// 创建失败结果
  RepositoryResult.failure({required this.status, required this.errorMessage, this.metadata});

  /// 判断操作是否成功
  bool get isSuccess => status == RepositoryResultStatus.success;
  bool get isFailure => !isSuccess;
}
```

### RepositoryResultStatus 枚举
```dart
enum RepositoryResultStatus {
  success,
  notFound,
  conflict,
  validationError,
  storageError,
  networkError,
  unauthorized
}
```

### PaginationConfig 类
```dart
class PaginationConfig {
  final int page;
  final int pageSize;
  final String? sortBy;
  final bool descending;

  const PaginationConfig({
    required this.page,
    required this.pageSize,
    this.sortBy,
    this.descending = false,
  });

  /// 计算偏移量
  int get offset => (page - 1) * pageSize;

  /// 验证分页参数
  bool get isValid => page > 0 && pageSize > 0 && pageSize <= 100;
}
```

### PagedResult<T> 类
```dart
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
  });

  /// 计算是否有下一页
  bool get hasNextPage => currentPage * pageSize < totalCount;

  /// 计算是否有上一页
  bool get hasPreviousPage => currentPage > 1;

  /// 计算总页数
  int get totalPages => (totalCount / pageSize).ceil();
}
```

### BatchConfig 类
```dart
class BatchConfig {
  final int batchSize;
  final bool continueOnError;
  final bool validateBeforeSave;

  const BatchConfig({
    this.batchSize = 50,
    this.continueOnError = false,
    this.validateBeforeSave = true,
  });
}
```

## 主要接口详解

### CRUD操作

#### `getById`
- **描述**: 根据ID获取单个实体
- **签名**: `Future<RepositoryResult<BaseItem>> getById(String id)`
- **参数**: `id` - 实体唯一标识符
- **返回值**: RepositoryResult包装的实体数据，如果未找到则返回notFound状态
- **示例**:
```dart
final result = await repository.getById('item_123');
if (result.isSuccess && result.data != null) {
  print('找到项目: ${result.data!.title}');
} else {
  print('项目不存在或查询失败');
}
```

#### `save`
- **描述**: 保存实体（新增或更新）
- **签名**: `Future<RepositoryResult<BaseItem>> save(BaseItem item)`
- **参数**: `item` - 要保存的实体对象
- **行为**: 如果实体ID存在则更新，否则新增
- **返回值**: RepositoryResult包装的保存后的实体数据
- **示例**:
```dart
final noteItem = MyNoteItem(
  title: '重要笔记',
  itemType: ItemType.note,
  description: '这是笔记内容',
);

final result = await repository.save(noteItem);
if (result.isSuccess) {
  print('保存成功: ${result.data?.id}');
} else {
  print('保存失败: ${result.errorMessage}');
}
```

#### `deleteById`
- **描述**: 根据ID删除实体
- **签名**: `Future<RepositoryResult<BaseItem>> deleteById(String id)`
- **参数**: `id` - 要删除的实体ID
- **返回值**: RepositoryResult包含被删除的实体数据（如果存在）
- **示例**:
```dart
final result = await repository.deleteById('item_123');
if (result.isSuccess) {
  print('删除成功');
} else {
  print('删除失败: ${result.errorMessage}');
}
```

#### `exists`
- **描述**: 检查实体是否存在
- **签名**: `Future<RepositoryResult<bool>> exists(String id)`
- **参数**: `id` - 实体ID
- **返回值**: RepositoryResult包装的存在性布尔值
- **示例**:
```dart
final result = await repository.exists('item_123');
if (result.isSuccess && result.data == true) {
  print('项目存在');
}
```

### 查询操作

#### `getAll`
- **描述**: 获取所有实体
- **签名**: `Future<RepositoryResult<List<BaseItem>>> getAll({ItemType? itemType})`
- **参数**: `itemType` - 可选的实体类型过滤
- **返回值**: RepositoryResult包装的指定类型实体列表
- **示例**:
```dart
// 获取所有笔记
final result = await repository.getAll(itemType: ItemType.note);
if (result.isSuccess) {
  print('找到 ${result.data?.length} 个笔记');
}
```

#### `query`
- **描述**: 使用QueryBuilder进行高级查询
- **签名**: `Future<RepositoryResult<List<BaseItem>>> query(QueryBuilder queryBuilder)`
- **参数**: `queryBuilder` - 查询构建器，支持复杂条件组合
- **返回值**: RepositoryResult包装的符合条件实体列表
- **示例**:
```dart
final queryBuilder = QueryBuilder()
  .whereType(ItemType.note)
  .whereStatus(ItemStatus.active)
  .whereTag('重要');

final result = await repository.query(queryBuilder);
if (result.isSuccess) {
  print('找到 ${result.data?.length} 个重要笔记');
}
```

#### `queryPaged`
- **描述**: 分页查询
- **签名**: `Future<RepositoryResult<PagedResult<BaseItem>>> queryPaged(PaginationConfig config, {QueryBuilder? queryBuilder})`
- **参数**:
  - `config` - 分页配置（页码、页大小、排序等）
  - `queryBuilder` - 可选的查询条件
- **返回值**: RepositoryResult包装的分页结果
- **示例**:
```dart
final config = PaginationConfig(
  page: 1,
  pageSize: 10,
  sortBy: 'createdAt',
  descending: true,
);

final queryBuilder = QueryBuilder().whereType(ItemType.note);
final result = await repository.queryPaged(config, queryBuilder: queryBuilder);

if (result.isSuccess) {
  final pagedData = result.data!;
  print('第${pagedData.currentPage}页，共${pagedData.totalPages}页');
  print('本页${pagedData.items.length}条，总共${pagedData.totalCount}条');
}
```

#### `count`
- **描述**: 统计符合条件的实体数量
- **签名**: `Future<RepositoryResult<int>> count({QueryBuilder? queryBuilder})`
- **参数**: `queryBuilder` - 可选的查询条件，如果不提供则统计全部
- **返回值**: RepositoryResult包装的实体数量
- **示例**:
```dart
// 统计所有活跃笔记
final queryBuilder = QueryBuilder()
  .whereType(ItemType.note)
  .whereStatus(ItemStatus.active);

final result = await repository.count(queryBuilder: queryBuilder);
if (result.isSuccess) {
  print('活跃笔记数量: ${result.data}');
}
```

### 批量操作

#### `saveAll`
- **描述**: 批量保存实体
- **签名**: `Future<RepositoryResult<List<BaseItem>>> saveAll(List<BaseItem> items, {BatchConfig? config})`
- **参数**:
  - `items` - 要保存的实体列表
  - `config` - 批量操作配置
- **返回值**: RepositoryResult包装的成功保存的实体列表
- **示例**:
```dart
final items = [noteItem1, noteItem2, noteItem3];
final config = BatchConfig(
  batchSize: 50,
  continueOnError: true,
  validateBeforeSave: true,
);

final result = await repository.saveAll(items, config: config);
if (result.isSuccess) {
  print('成功保存 ${result.data?.length} 个项目');
}
```

#### `deleteAll`
- **描述**: 批量删除实体
- **签名**: `Future<RepositoryResult<Map<String, dynamic>>> deleteAll(List<String> ids, {BatchConfig? config})`
- **参数**:
  - `ids` - 要删除的实体ID列表
  - `config` - 批量操作配置
- **返回值**: RepositoryResult包装的删除操作统计信息
- **示例**:
```dart
final idsToDelete = ['item_1', 'item_2', 'item_3'];
final result = await repository.deleteAll(idsToDelete);

if (result.isSuccess) {
  final stats = result.data!;
  print('删除统计: ${stats['deleted']} 成功, ${stats['failed']} 失败');
}
```

### 事务支持

#### `transaction`
- **描述**: 在事务中执行操作
- **签名**: `Future<RepositoryResult<T>> transaction<T>(Future<T> Function(IPersistenceRepository repo) operation)`
- **参数**: `operation` - 要在事务中执行的操作函数
- **返回值**: RepositoryResult包装的操作结果
- **示例**:
```dart
final result = await repository.transaction<bool>((repo) async {
  // 在事务中执行多个操作
  await repo.save(noteItem1);
  await repo.save(noteItem2);
  await repo.deleteById('old_item_id');
  
  return true; // 事务成功
});

if (result.isSuccess) {
  print('事务执行成功');
} else {
  print('事务回滚: ${result.errorMessage}');
}
```

### 数据管理

#### `clear`
- **描述**: 清空指定类型的所有数据
- **签名**: `Future<RepositoryResult<Map<String, dynamic>>> clear({ItemType? itemType, required bool confirm})`
- **参数**:
  - `itemType` - 要清空的实体类型，如果不指定则清空所有数据
  - `confirm` - 确认标识，防止误操作
- **返回值**: RepositoryResult包装的清理操作统计信息
- **示例**:
```dart
// 清空所有草稿笔记
final result = await repository.clear(
  itemType: ItemType.note,
  confirm: true,
);

if (result.isSuccess) {
  final stats = result.data!;
  print('清理完成: ${stats['deletedCount']} 个项目');
}
```

#### `getStatistics`
- **描述**: 获取存储统计信息
- **签名**: `Future<RepositoryResult<Map<String, dynamic>>> getStatistics()`
- **返回值**: RepositoryResult包装的各类型实体数量统计、存储大小等信息
- **示例**:
```dart
final result = await repository.getStatistics();
if (result.isSuccess) {
  final stats = result.data!;
  print('统计信息:');
  print('总项目数: ${stats['totalItems']}');
  print('各类型分布: ${stats['typeDistribution']}');
  print('存储大小: ${stats['storageSize']}');
}
```

#### `validateIntegrity`
- **描述**: 执行数据完整性检查
- **签名**: `Future<RepositoryResult<Map<String, dynamic>>> validateIntegrity()`
- **返回值**: RepositoryResult包装的检查结果和发现的问题列表
- **示例**:
```dart
final result = await repository.validateIntegrity();
if (result.isSuccess) {
  final report = result.data!;
  print('完整性检查: ${report['status']}');
  if (report['issues'] != null) {
    print('发现问题: ${report['issues']}');
  }
}
```

### 同步支持（预留）

#### `getModifiedSince`
- **描述**: 获取指定时间后修改的实体
- **签名**: `Future<RepositoryResult<List<BaseItem>>> getModifiedSince(DateTime since, {ItemType? itemType})`
- **参数**:
  - `since` - 起始时间戳
  - `itemType` - 可选的实体类型过滤
- **返回值**: RepositoryResult包装的修改过的实体列表，用于增量同步

#### `markForSync`
- **描述**: 标记实体需要同步
- **签名**: `Future<RepositoryResult<void>> markForSync(List<String> ids)`
- **参数**: `ids` - 需要同步的实体ID列表
- **用途**: 为云同步功能预留的接口

### 资源管理

#### `dispose`
- **描述**: 关闭并释放Repository资源
- **签名**: `Future<void> dispose()`
- **用途**: 在应用退出或服务销毁时调用，确保资源正确释放
- **示例**:
```dart
await repository.dispose();
```

#### `healthCheck`
- **描述**: 检查Repository健康状态
- **签名**: `Future<RepositoryResult<Map<String, dynamic>>> healthCheck()`
- **返回值**: RepositoryResult包装的Repository连接状态、性能指标等健康信息
- **示例**:
```dart
final result = await repository.healthCheck();
if (result.isSuccess) {
  final health = result.data!;
  print('连接状态: ${health['isConnected']}');
  print('响应时间: ${health['responseTime']}ms');
}
```

## 工厂接口

### IRepositoryFactory 接口
```dart
abstract class IRepositoryFactory {
  /// 创建Repository实例
  Future<IPersistenceRepository> createRepository(Map<String, dynamic> config);

  /// 获取支持的Repository类型列表
  List<String> getSupportedTypes();
}
```

## 错误处理

### 异常处理最佳实践
```dart
final result = await repository.save(item);
if (!result.isSuccess) {
  switch (result.status) {
    case RepositoryResultStatus.validationError:
      showUserFriendlyError('数据格式错误，请检查输入');
      break;
    case RepositoryResultStatus.storageError:
      showUserFriendlyError('存储错误，请稍后重试');
      break;
    case RepositoryResultStatus.networkError:
      showUserFriendlyError('网络连接失败，请检查网络');
      break;
    default:
      showUserFriendlyError('操作失败：${result.errorMessage}');
  }
}
```

## 实现策略

### 渐进式演进
1. **Phase 1**: InMemoryRepository - 内存存储，快速开发和测试
2. **Phase 2**: SQLiteRepository - 本地持久化，离线支持
3. **Phase 3**: CloudRepository - 云端同步，多设备支持

## 使用最佳实践

1. **分页查询**: 大数据集使用queryPaged而非getAll
2. **批量操作**: 多项目操作使用saveAll/deleteAll
3. **事务管理**: 相关操作包装在事务中
4. **资源清理**: 适时调用dispose释放资源
5. **错误处理**: 根据status提供用户友好的错误提示

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 完整的Repository接口定义
  - CRUD操作和高级查询支持
  - 批量操作和事务处理
  - 分页查询和数据管理
  - 同步接口预留
  - InMemoryRepository参考实现 