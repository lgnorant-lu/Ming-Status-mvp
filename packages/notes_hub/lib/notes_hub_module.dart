/*
---------------------------------------------------------------
File name:          notes_hub_module.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Dart Version:       3.32.4
Description:        笔记中心模块 - 提供统一的事务管理平台，支持笔记、待办、项目、提醒、习惯、目标6种事务类型
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 模块修复 - 恢复完整的API文档规范实现;
    2025/06/25: Initial creation - 笔记中心模块基础实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:developer' as developer;
import 'package:core_services/core_services.dart';
import 'package:ui_framework/ui_framework.dart';

/// 事务类型枚举
enum ItemType {
  note,      // 笔记
  todo,      // 待办事项
  project,   // 项目
  reminder,  // 提醒
  habit,     // 习惯
  goal,      // 目标
}

/// 事务状态枚举
enum ItemStatus {
  active,      // 活跃
  completed,   // 已完成
  archived,    // 已归档
  deleted,     // 已删除
}

/// 事务优先级枚举
enum ItemPriority {
  low,       // 低
  medium,    // 中
  high,      // 高
  urgent,    // 紧急
}

/// 笔记中心事件基类
abstract class NotesHubEvent {
  final DateTime timestamp;
  final String eventId;
  
  NotesHubEvent({
    required this.eventId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 创建事务事件
class CreateItemEvent extends NotesHubEvent {
  final Map<String, dynamic> itemData;
  final ItemType itemType;
  
  CreateItemEvent({
    required String eventId,
    required this.itemData,
    required this.itemType,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 更新事务事件
class UpdateItemEvent extends NotesHubEvent {
  final String itemId;
  final Map<String, dynamic> updatedData;
  final ItemType itemType;
  
  UpdateItemEvent({
    required String eventId,
    required this.itemId,
    required this.updatedData,
    required this.itemType,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 删除事务事件
class DeleteItemEvent extends NotesHubEvent {
  final String itemId;
  final ItemType itemType;
  
  DeleteItemEvent({
    required String eventId,
    required this.itemId,
    required this.itemType,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 状态变化事件
class ItemStatusChangedEvent extends NotesHubEvent {
  final String itemId;
  final ItemType itemType;
  final ItemStatus oldStatus;
  final ItemStatus newStatus;
  
  ItemStatusChangedEvent({
    required String eventId,
    required this.itemId,
    required this.itemType,
    required this.oldStatus,
    required this.newStatus,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 数据同步事件
class DataSyncEvent extends NotesHubEvent {
  final String syncType;  // 'imported' | 'exported' | 'synced'
  final Map<String, dynamic> syncData;
  
  DataSyncEvent({
    required String eventId,
    required this.syncType,
    required this.syncData,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 基础事务模型
class NotesHubItem implements EditableItem {
  final String id;
  final ItemType type;
  final String title;
  final String content;
  final ItemStatus status;
  final ItemPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const NotesHubItem({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.status = ItemStatus.active,
    this.priority = ItemPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.tags = const [],
    this.metadata = const {},
  });

  // EditableItem interface implementation
  @override
  String get description => content;

  /// EditableItem interface copyWith implementation
  @override
  NotesHubItem copyWith({
    String? title,
    String? description,
    String? content,
    List<String>? tags,
  }) {
    return NotesHubItem(
      id: id,
      type: type,
      title: title ?? this.title,
      content: content ?? description ?? this.content,
      status: status,
      priority: priority,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      tags: tags ?? this.tags,
      metadata: metadata,
    );
  }

  /// Extended copyWith method for full NotesHubItem properties
  NotesHubItem copyWithFull({
    String? id,
    ItemType? type,
    String? title,
    String? content,
    ItemStatus? status,
    ItemPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return NotesHubItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'content': content,
      'status': status.toString(),
      'priority': priority.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'tags': tags,
      'metadata': metadata,
    };
  }
}

/// 笔记中心模块 - 统一事务管理平台
class NotesHubModule implements PetModuleInterface {
  // === 模块基本信息 ===
  @override
  String get id => 'notes_hub';
  
  @override
  String get name => '笔记中心';
  
  @override
  String get description => '统一的事务管理平台，支持笔记、待办、项目、提醒、习惯、目标6种事务类型的创建、编辑、分类和统计管理。';
  
  @override
  String get version => '1.1.0';

  @override
  String get author => 'Ignorant-lu';

  @override
  List<String> get dependencies => [];
  
  @override
  Map<String, dynamic> get metadata => {
    'category': 'builtin',
    'features': ['notes', 'todos', 'projects', 'reminders', 'habits', 'goals'],
    'supportedTypes': ['note', 'todo', 'project', 'reminder', 'habit', 'goal'],
    'maxItemsPerType': 1000,
  };

  // === 状态管理 ===
  bool _isInitialized = false;
  bool _isActive = false;
  EventBus? _eventBus;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isActive => _isActive;

  // === 数据存储 ===
  final Map<ItemType, List<NotesHubItem>> _itemsByType = {
    ItemType.note: [],
    ItemType.todo: [],
    ItemType.project: [],
    ItemType.reminder: [],
    ItemType.habit: [],
    ItemType.goal: [],
  };

  // === 生命周期方法 ===

  @override
  Future<void> initialize(EventBus eventBus) async {
    developer.log('开始初始化笔记中心模块...', name: 'NotesHubModule');
    
    try {
    _eventBus = eventBus;
    
    // 注册事件监听器
      _setupEventListeners();
    
      // 加载示例数据
      _loadSampleData();
    
    _isInitialized = true;
    
      developer.log('笔记中心模块初始化完成', name: 'NotesHubModule');
    } catch (e) {
      developer.log('笔记中心模块初始化失败: $e', name: 'NotesHubModule');
      rethrow;
    }
  }

  @override
  Future<void> boot() async {
    if (!_isInitialized) {
      throw StateError('模块未初始化，请先调用initialize()');
    }
    
    developer.log('启动笔记中心模块...', name: 'NotesHubModule');
    
    _isActive = true;
    
    developer.log('笔记中心模块已激活', name: 'NotesHubModule');
  }

  @override
  void dispose() {
    developer.log('销毁笔记中心模块...', name: 'NotesHubModule');
    
    _isActive = false;
    _isInitialized = false;
    _eventBus = null;
    
    for (final list in _itemsByType.values) {
      list.clear();
    }
    
    developer.log('笔记中心模块已销毁', name: 'NotesHubModule');
  }

  // === 核心业务方法 ===

  /// 创建新事务
  String createItem({
    required ItemType type,
    required String title,
    required String content,
    ItemPriority priority = ItemPriority.medium,
    DateTime? dueDate,
    List<String> tags = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();
    final item = NotesHubItem(
      id: '${type.toString()}_${now.millisecondsSinceEpoch}',
      type: type,
      title: title,
      content: content,
      priority: priority,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      tags: tags,
      metadata: metadata,
    );

    _itemsByType[type]!.add(item);

    // 发布创建事件
    _publishCreateItemEvent(item);

    developer.log('创建新事务: ${item.id} (${type.toString()})', name: 'NotesHubModule');
    return item.id;
  }

  /// 更新事务
  bool updateItem(String itemId, {
    String? title,
    String? content,
    ItemStatus? status,
    ItemPriority? priority,
    DateTime? dueDate,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    NotesHubItem? item;
    ItemType? itemType;
    
    // 查找事务
    for (final type in ItemType.values) {
      final list = _itemsByType[type]!;
      final index = list.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        item = list[index];
        itemType = type;
        break;
      }
    }

    if (item == null || itemType == null) {
      developer.log('更新事务失败: 未找到 $itemId', name: 'NotesHubModule');
      return false;
    }

    // 创建更新后的事务
    final oldStatus = item.status;
    final updatedItem = item.copyWithFull(
      title: title,
      content: content,
      status: status,
      priority: priority,
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      tags: tags,
      metadata: metadata,
    );

    // 更新存储
    final list = _itemsByType[itemType]!;
    final index = list.indexWhere((item) => item.id == itemId);
    list[index] = updatedItem;

    // 发布更新事件
    _publishUpdateItemEvent(updatedItem);

    // 如果状态改变，发布状态变化事件
    if (status != null && status != oldStatus) {
      _publishStatusChangedEvent(itemId, itemType, oldStatus, status);
    }

    developer.log('更新事务: $itemId', name: 'NotesHubModule');
    return true;
  }

  /// 删除事务
  bool deleteItem(String itemId) {
    for (final type in ItemType.values) {
      final list = _itemsByType[type]!;
      final index = list.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        final item = list.removeAt(index);
        
        // 发布删除事件
        _publishDeleteItemEvent(item);
        
        developer.log('删除事务: $itemId', name: 'NotesHubModule');
        return true;
      }
    }
    
    developer.log('删除事务失败: 未找到 $itemId', name: 'NotesHubModule');
    return false;
  }

  // === 查询方法 ===

  /// 获取所有事务
  List<NotesHubItem> getAllItems() {
    final allItems = <NotesHubItem>[];
    for (final list in _itemsByType.values) {
      allItems.addAll(list);
    }
    
    // 按更新时间倒序排列
    allItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return allItems;
  }

  /// 根据类型获取事务
  List<NotesHubItem> getItemsByType(ItemType type) {
    final items = List<NotesHubItem>.from(_itemsByType[type] ?? []);
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// 根据状态获取事务
  List<NotesHubItem> getItemsByStatus(ItemStatus status) {
    final items = <NotesHubItem>[];
    for (final list in _itemsByType.values) {
      items.addAll(list.where((item) => item.status == status));
    }
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// 根据优先级获取事务
  List<NotesHubItem> getItemsByPriority(ItemPriority priority) {
    final items = <NotesHubItem>[];
    for (final list in _itemsByType.values) {
      items.addAll(list.where((item) => item.priority == priority));
    }
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// 搜索事务
  List<NotesHubItem> searchItems(String query) {
    if (query.trim().isEmpty) return [];
    
    final items = <NotesHubItem>[];
    final lowerQuery = query.toLowerCase();
    
    for (final list in _itemsByType.values) {
      items.addAll(list.where((item) =>
        item.title.toLowerCase().contains(lowerQuery) ||
        item.content.toLowerCase().contains(lowerQuery) ||
        item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
      ));
    }
    
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// 获取根据ID查找事务
  NotesHubItem? getItemById(String itemId) {
    for (final list in _itemsByType.values) {
      try {
        return list.firstWhere((item) => item.id == itemId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'totalItems': 0,
      'activeItems': 0,
      'completedItems': 0,
      'archivedItems': 0,
      'deletedItems': 0,
    };

    // 按类型统计
    for (final type in ItemType.values) {
      final items = _itemsByType[type] ?? [];
      stats['${type.toString()}Count'] = items.length;
      
      stats['totalItems'] += items.length;
      stats['activeItems'] += items.where((item) => item.status == ItemStatus.active).length;
      stats['completedItems'] += items.where((item) => item.status == ItemStatus.completed).length;
      stats['archivedItems'] += items.where((item) => item.status == ItemStatus.archived).length;
      stats['deletedItems'] += items.where((item) => item.status == ItemStatus.deleted).length;
    }

    // 按优先级统计
    for (final priority in ItemPriority.values) {
      final items = getItemsByPriority(priority);
      stats['${priority.toString()}PriorityCount'] = items.length;
    }

    return stats;
  }

  // === 内部方法 ===

  /// 设置事件监听器
  void _setupEventListeners() {
    // 当前版本暂不监听外部事件
    developer.log('笔记中心事件监听器注册完成', name: 'NotesHubModule');
  }

  /// 加载示例数据
  void _loadSampleData() {
    final now = DateTime.now();
    
    // 添加示例笔记
    _itemsByType[ItemType.note]!.addAll([
      NotesHubItem(
        id: 'note_${now.millisecondsSinceEpoch}',
        type: ItemType.note,
        title: '欢迎使用笔记中心',
        content: '这里是您的个人事务管理中心，支持笔记、待办、项目等多种类型的事务管理。',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        tags: ['欢迎', '介绍'],
      ),
    ]);

    // 添加示例待办
    _itemsByType[ItemType.todo]!.addAll([
      NotesHubItem(
        id: 'todo_${now.millisecondsSinceEpoch + 1}',
        type: ItemType.todo,
        title: '完成项目文档',
        content: '整理并完善项目的技术文档和用户手册',
        priority: ItemPriority.high,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
        tags: ['工作', '文档'],
      ),
    ]);

    // 添加示例项目
    _itemsByType[ItemType.project]!.addAll([
      NotesHubItem(
        id: 'project_${now.millisecondsSinceEpoch + 2}',
        type: ItemType.project,
        title: '桌宠应用开发',
        content: '开发一个功能丰富的桌面宠物应用，包含打卡、笔记、创意工坊等模块',
        priority: ItemPriority.high,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        tags: ['开发', '应用', '桌宠'],
        metadata: {'progress': 75, 'phase': 'Phase 1.5'},
      ),
    ]);

    developer.log('笔记中心示例数据加载完成', name: 'NotesHubModule');
  }

  // === 事件发布方法 ===

  /// 发布创建事务事件
  void _publishCreateItemEvent(NotesHubItem item) {
    try {
      final event = CreateItemEvent(
        eventId: 'create_item_${DateTime.now().millisecondsSinceEpoch}',
        itemData: item.toMap(),
        itemType: item.type,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布创建事务事件失败: $e', name: 'NotesHubModule');
    }
  }

  /// 发布更新事务事件
  void _publishUpdateItemEvent(NotesHubItem item) {
    try {
      final event = UpdateItemEvent(
        eventId: 'update_item_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        updatedData: item.toMap(),
        itemType: item.type,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布更新事务事件失败: $e', name: 'NotesHubModule');
    }
  }

  /// 发布删除事务事件
  void _publishDeleteItemEvent(NotesHubItem item) {
    try {
      final event = DeleteItemEvent(
        eventId: 'delete_item_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        itemType: item.type,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布删除事务事件失败: $e', name: 'NotesHubModule');
    }
  }

  /// 发布状态变化事件
  void _publishStatusChangedEvent(String itemId, ItemType itemType, ItemStatus oldStatus, ItemStatus newStatus) {
    try {
      final event = ItemStatusChangedEvent(
        eventId: 'status_changed_${DateTime.now().millisecondsSinceEpoch}',
        itemId: itemId,
        itemType: itemType,
        oldStatus: oldStatus,
        newStatus: newStatus,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布状态变化事件失败: $e', name: 'NotesHubModule');
    }
  }
} 