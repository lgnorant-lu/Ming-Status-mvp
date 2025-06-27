/*
---------------------------------------------------------------
File name:          persistence_repository.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/25
Description:        数据持久化Repository接口定义，提供统一的CRUD操作和查询抽象
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 重构 - 添加新的基础服务框架：日志、错误处理、性能监控服务;
    2025/06/25: Initial creation - 定义Repository模式的核心接口;
---------------------------------------------------------------
*/

import '../../models/base_item.dart';
import '../../models/repository_result.dart';

/// 查询构建器，用于复杂查询条件构建
class QueryBuilder {
  final Map<String, dynamic> _conditions = {};
  final Map<String, dynamic> _sorting = {};
  final List<String> _fields = [];
  
  ItemStatus? _status;
  ItemType? _itemType;
  List<String> _tags = [];
  DateTime? _createdAfter;
  DateTime? _createdBefore;
  DateTime? _updatedAfter;
  DateTime? _updatedBefore;

  QueryBuilder();

  /// 设置状态过滤
  QueryBuilder whereStatus(ItemStatus status) {
    _status = status;
    return this;
  }

  /// 设置类型过滤
  QueryBuilder whereType(ItemType itemType) {
    _itemType = itemType;
    return this;
  }

  /// 设置标签过滤
  QueryBuilder whereTags(List<String> tags) {
    _tags = tags;
    return this;
  }

  /// 设置创建时间范围
  QueryBuilder whereCreatedBetween(DateTime after, DateTime before) {
    _createdAfter = after;
    _createdBefore = before;
    return this;
  }

  /// 设置更新时间范围
  QueryBuilder whereUpdatedBetween(DateTime after, DateTime before) {
    _updatedAfter = after;
    _updatedBefore = before;
    return this;
  }

  /// 添加自定义条件
  QueryBuilder where(String field, dynamic value) {
    _conditions[field] = value;
    return this;
  }

  /// 设置排序
  QueryBuilder orderBy(String field, {bool descending = false}) {
    _sorting[field] = descending ? 'desc' : 'asc';
    return this;
  }

  /// 选择特定字段
  QueryBuilder select(List<String> fields) {
    _fields.addAll(fields);
    return this;
  }

  /// 构建查询条件
  Map<String, dynamic> build() {
    final result = Map<String, dynamic>.from(_conditions);
    
    if (_status != null) result['status'] = _status!.code;
    if (_itemType != null) result['itemType'] = _itemType!.code;
    if (_tags.isNotEmpty) result['tags'] = _tags;
    if (_createdAfter != null) result['createdAfter'] = _createdAfter!.toIso8601String();
    if (_createdBefore != null) result['createdBefore'] = _createdBefore!.toIso8601String();
    if (_updatedAfter != null) result['updatedAfter'] = _updatedAfter!.toIso8601String();
    if (_updatedBefore != null) result['updatedBefore'] = _updatedBefore!.toIso8601String();
    if (_sorting.isNotEmpty) result['_sort'] = _sorting;
    if (_fields.isNotEmpty) result['_fields'] = _fields;

    return result;
  }
}

/// 数据持久化Repository核心接口
/// 
/// 定义所有数据存储操作的统一契约，支持CRUD操作、高级查询、
/// 批量操作、事务处理和数据同步功能
abstract class IPersistenceRepository {
  // ============================================================================
  // 基础CRUD操作 (Core CRUD Operations)
  // ============================================================================

  /// 根据ID获取单个实体
  /// 
  /// [id] 实体唯一标识符
  /// 返回包装在RepositoryResult中的实体数据，如果未找到则返回notFound状态
  Future<RepositoryResult<BaseItem>> getById(String id);

  /// 保存实体（新增或更新）
  /// 
  /// [item] 要保存的实体对象
  /// 如果实体ID存在则更新，否则新增
  /// 返回保存后的实体数据（包含生成的ID或更新后的字段）
  Future<RepositoryResult<BaseItem>> save(BaseItem item);

  /// 根据ID删除实体
  /// 
  /// [id] 要删除的实体ID
  /// 返回操作结果，包含被删除的实体数据（如果存在）
  Future<RepositoryResult<BaseItem>> deleteById(String id);

  /// 检查实体是否存在
  /// 
  /// [id] 实体ID
  /// 返回布尔值表示实体是否存在
  Future<RepositoryResult<bool>> exists(String id);

  // ============================================================================
  // 查询操作 (Query Operations)
  // ============================================================================

  /// 获取所有实体
  /// 
  /// [itemType] 可选的实体类型过滤
  /// 返回指定类型的所有实体列表
  Future<RepositoryResult<List<BaseItem>>> getAll({ItemType? itemType});

  /// 使用QueryBuilder进行高级查询
  /// 
  /// [queryBuilder] 查询构建器，支持复杂条件组合
  /// 返回符合条件的实体列表
  Future<RepositoryResult<List<BaseItem>>> query(QueryBuilder queryBuilder);

  /// 分页查询
  /// 
  /// [config] 分页配置（页码、页大小、排序等）
  /// [queryBuilder] 可选的查询条件
  /// 返回分页结果，包含数据和分页元信息
  Future<RepositoryResult<PagedResult<BaseItem>>> queryPaged(
    PaginationConfig config, {
    QueryBuilder? queryBuilder,
  });

  /// 统计符合条件的实体数量
  /// 
  /// [queryBuilder] 可选的查询条件，如果不提供则统计全部
  /// 返回实体数量
  Future<RepositoryResult<int>> count({QueryBuilder? queryBuilder});

  // ============================================================================
  // 批量操作 (Batch Operations)
  // ============================================================================

  /// 批量保存实体
  /// 
  /// [items] 要保存的实体列表
  /// [config] 批量操作配置
  /// 返回成功保存的实体列表和失败信息
  Future<RepositoryResult<List<BaseItem>>> saveAll(
    List<BaseItem> items, {
    BatchConfig? config,
  });

  /// 批量删除实体
  /// 
  /// [ids] 要删除的实体ID列表
  /// [config] 批量操作配置
  /// 返回删除操作的统计信息
  Future<RepositoryResult<Map<String, dynamic>>> deleteAll(
    List<String> ids, {
    BatchConfig? config,
  });

  // ============================================================================
  // 事务支持 (Transaction Support)
  // ============================================================================

  /// 在事务中执行操作
  /// 
  /// [operation] 要在事务中执行的操作函数
  /// 如果操作失败则自动回滚，成功则提交事务
  /// 返回操作结果
  Future<RepositoryResult<T>> transaction<T>(
    Future<T> Function(IPersistenceRepository repo) operation,
  );

  // ============================================================================
  // 数据管理 (Data Management)
  // ============================================================================

  /// 清空指定类型的所有数据
  /// 
  /// [itemType] 要清空的实体类型，如果不指定则清空所有数据
  /// [confirm] 确认标识，防止误操作
  /// 返回清理操作的统计信息
  Future<RepositoryResult<Map<String, dynamic>>> clear({
    ItemType? itemType,
    required bool confirm,
  });

  /// 获取存储统计信息
  /// 
  /// 返回各类型实体的数量统计、存储大小等信息
  Future<RepositoryResult<Map<String, dynamic>>> getStatistics();

  /// 执行数据完整性检查
  /// 
  /// 检查数据一致性、引用完整性等
  /// 返回检查结果和发现的问题列表
  Future<RepositoryResult<Map<String, dynamic>>> validateIntegrity();

  // ============================================================================
  // 同步支持 (Synchronization Support) - 为未来云同步预留
  // ============================================================================

  /// 获取指定时间后修改的实体
  /// 
  /// [since] 起始时间戳
  /// [itemType] 可选的实体类型过滤
  /// 返回修改过的实体列表，用于增量同步
  Future<RepositoryResult<List<BaseItem>>> getModifiedSince(
    DateTime since, {
    ItemType? itemType,
  });

  /// 标记实体需要同步
  /// 
  /// [ids] 需要同步的实体ID列表
  /// 为云同步功能预留的接口
  Future<RepositoryResult<void>> markForSync(List<String> ids);

  // ============================================================================
  // 资源管理 (Resource Management)
  // ============================================================================

  /// 关闭并释放Repository资源
  /// 
  /// 在应用退出或服务销毁时调用，确保资源正确释放
  Future<void> dispose();

  /// 检查Repository健康状态
  /// 
  /// 返回Repository的连接状态、性能指标等健康信息
  Future<RepositoryResult<Map<String, dynamic>>> healthCheck();
}

/// Repository工厂接口
/// 
/// 用于创建不同类型的Repository实现（内存、SQLite、云端等）
abstract class IRepositoryFactory {
  /// 创建Repository实例
  /// 
  /// [config] 创建配置（连接字符串、选项等）
  /// 返回初始化后的Repository实例
  Future<IPersistenceRepository> createRepository(Map<String, dynamic> config);

  /// 获取支持的Repository类型列表
  List<String> getSupportedTypes();
} 