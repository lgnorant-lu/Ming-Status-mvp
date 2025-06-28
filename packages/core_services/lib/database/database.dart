/*
---------------------------------------------------------------
File name:          database.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Drift数据库定义 - Phase 2.2B 数据持久化系统 (跨平台兼容)
---------------------------------------------------------------
*/

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// import '../models/base_item.dart';

// Phase 2.2B: Drift数据库表定义
part 'database.g.dart';

/// 基础项目表定义 - 对应BaseItem模型
class BaseItems extends Table {
  /// 主键ID
  TextColumn get id => text()();
  
  /// 标题
  TextColumn get title => text().withLength(min: 1, max: 255)();
  
  /// 描述内容
  TextColumn get description => text().withDefault(const Constant(''))();
  
  /// 项目类型
  TextColumn get itemType => text()();
  
  /// 元数据JSON
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  
  /// 状态
  TextColumn get status => text().withDefault(const Constant('draft'))();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();
  
  /// 更新时间  
  DateTimeColumn get updatedAt => dateTime()();
  
  /// 标签JSON数组
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  
  /// 内容哈希 - 用于数据变更检测
  TextColumn get contentHash => text().nullable()();
  
  /// 同步标记
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  
  /// 软删除标记
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
  
  // 索引将在migration中创建
}

/// 同步状态表 - 用于追踪数据同步状态
class SyncStatus extends Table {
  /// 同步ID
  IntColumn get id => integer().autoIncrement()();
  
  /// 实体ID
  TextColumn get entityId => text()();
  
  /// 实体类型
  TextColumn get entityType => text()();
  
  /// 同步状态: pending, syncing, completed, failed
  TextColumn get status => text()();
  
  /// 同步时间戳
  DateTimeColumn get syncTimestamp => dateTime().nullable()();
  
  /// 重试次数
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  
  /// 错误信息
  TextColumn get errorMessage => text().nullable()();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();
  
  // 索引将在migration中创建
}

/// 应用数据库类
@DriftDatabase(tables: [BaseItems, SyncStatus])
class AppDatabase extends _$AppDatabase {
  // 使用drift_flutter的driftDatabase函数，为Web平台提供必需的web配置
  AppDatabase() : super(_createDatabase());
  
  /// 创建数据库连接，处理平台特定配置
  static QueryExecutor _createDatabase() {
    if (kIsWeb) {
      // Web平台配置：提供必需参数，先让应用启动
      return driftDatabase(
        name: 'pet_app_db',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.wasm'),
          driftWorker: Uri.parse('assets/drift_worker.js'),
        ),
      );
    } else {
      // 原生平台使用默认配置
      return driftDatabase(name: 'pet_app_db');
    }
  }
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // 初始化时插入一些示例数据或执行初始化SQL
        await _initializeDatabase();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 数据库升级逻辑
        await _handleDatabaseUpgrade(m, from, to);
      },
      beforeOpen: (details) async {
        // 原生平台特定的优化设置
        if (details.wasCreated) {
          // 数据库刚创建时的初始化
        }
      },
    );
  }
  
  /// 初始化数据库
  Future<void> _initializeDatabase() async {
    // 创建索引提高查询性能
    await customStatement('CREATE INDEX IF NOT EXISTS idx_base_items_type ON base_items (item_type)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_base_items_status ON base_items (status)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_base_items_created ON base_items (created_at)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_base_items_updated ON base_items (updated_at)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_base_items_deleted ON base_items (is_deleted)');
    
    await customStatement('CREATE INDEX IF NOT EXISTS idx_sync_status_entity ON sync_status (entity_id)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_sync_status_type ON sync_status (entity_type)');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_sync_status_status ON sync_status (status)');
  }
  
  /// 处理数据库升级
  Future<void> _handleDatabaseUpgrade(Migrator m, int from, int to) async {
    // 根据版本号执行相应的升级脚本
    if (from == 1 && to == 2) {
      // 示例：添加新列
      // await m.addColumn(baseItems, baseItems.someNewColumn);
    }
  }
  
  /// 健康检查 - 验证数据库连接和基本操作
  Future<bool> healthCheck() async {
    try {
      // 执行一个简单查询验证连接
      await customSelect('SELECT 1').getSingle();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 获取数据库统计信息
  Future<Map<String, dynamic>> getStatistics() async {
    final totalCount = await _getTableCount('base_items');
    final deletedCount = await _getTableCount('base_items', where: 'is_deleted = 1');
    final activeCount = totalCount - deletedCount;
    
    // 按类型统计
    final typeStats = await customSelect('''
      SELECT item_type, COUNT(*) as count 
      FROM base_items 
      WHERE is_deleted = 0 
      GROUP BY item_type
    ''').get();
    
    // 按状态统计
    final statusStats = await customSelect('''
      SELECT status, COUNT(*) as count 
      FROM base_items 
      WHERE is_deleted = 0 
      GROUP BY status
    ''').get();
    
    return {
      'totalCount': totalCount,
      'activeCount': activeCount,
      'deletedCount': deletedCount,
      'typeStatistics': {
        for (final row in typeStats)
          row.read<String>('item_type'): row.read<int>('count')
      },
      'statusStatistics': {
        for (final row in statusStats)
          row.read<String>('status'): row.read<int>('count')
      },
      'syncPendingCount': await _getTableCount('sync_status', where: 'status = "pending"'),
    };
  }
  
  /// 获取表行数
  Future<int> _getTableCount(String tableName, {String? where}) async {
    final query = where != null 
        ? 'SELECT COUNT(*) as count FROM $tableName WHERE $where'
        : 'SELECT COUNT(*) as count FROM $tableName';
    final result = await customSelect(query).getSingle();
    return result.read<int>('count');
  }
} 