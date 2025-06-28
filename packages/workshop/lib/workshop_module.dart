/*
---------------------------------------------------------------
File name:          workshop_module.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Dart Version:       3.32.4
Description:        创意工坊模块 - 支持8种创意类型的创作与管理平台，提供灵感记录、项目孵化、作品展示等功能
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 模块修复 - 恢复完整的API文档规范实现;
    2025/06/25: Initial creation - 创意工坊模块基础实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:developer' as developer;
import 'package:core_services/core_services.dart' hide ItemType, ItemStatus;
import 'package:ui_framework/ui_framework.dart';

/// 创意类型枚举
enum CreativeItemType {
  idea,        // 想法/点子
  design,      // 设计方案
  prototype,   // 原型
  experiment,  // 实验
  project,     // 项目
  template,    // 模板
  resource,    // 资源
  showcase,    // 作品展示
}

/// 创意状态枚举
enum CreativeItemStatus {
  draft,       // 草稿
  developing,  // 开发中
  testing,     // 测试中
  completed,   // 已完成
  published,   // 已发布
  archived,    // 已归档
}

/// 创意优先级枚举
enum CreativeItemPriority {
  low,         // 低
  medium,      // 中
  high,        // 高
  urgent,      // 紧急
}

/// 创意工坊事件基类
abstract class WorkshopEvent {
  final DateTime timestamp;
  final String eventId;
  
  WorkshopEvent({
    required this.eventId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 创建创意事件
class CreateCreativeItemEvent extends WorkshopEvent {
  final Map<String, dynamic> itemData;
  final CreativeItemType itemType;
  
  CreateCreativeItemEvent({
    required String eventId,
    required this.itemData,
    required this.itemType,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 更新创意事件
class UpdateCreativeItemEvent extends WorkshopEvent {
  final String itemId;
  final Map<String, dynamic> updatedData;
  final CreativeItemType itemType;
  
  UpdateCreativeItemEvent({
    required String eventId,
    required this.itemId,
    required this.updatedData,
    required this.itemType,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 删除创意事件
class DeleteCreativeItemEvent extends WorkshopEvent {
  final String itemId;
  final CreativeItemType itemType;
  
  DeleteCreativeItemEvent({
    required String eventId,
    required this.itemId,
    required this.itemType,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 发布创意事件
class PublishCreativeItemEvent extends WorkshopEvent {
  final String itemId;
  final CreativeItemType itemType;
  final Map<String, dynamic> publishData;
  
  PublishCreativeItemEvent({
    required String eventId,
    required this.itemId,
    required this.itemType,
    required this.publishData,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 状态变化事件
class CreativeItemStatusChangedEvent extends WorkshopEvent {
  final String itemId;
  final CreativeItemType itemType;
  final CreativeItemStatus oldStatus;
  final CreativeItemStatus newStatus;
  
  CreativeItemStatusChangedEvent({
    required String eventId,
    required this.itemId,
    required this.itemType,
    required this.oldStatus,
    required this.newStatus,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 创意项目模型
class CreativeItem implements EditableItem {
  final String id;
  final CreativeItemType type;
  final String title;
  final String description;
  final String content;
  final CreativeItemStatus status;
  final CreativeItemPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final List<String> tags;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  const CreativeItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.content,
    this.status = CreativeItemStatus.draft,
    this.priority = CreativeItemPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.tags = const [],
    this.attachments = const [],
    this.metadata = const {},
  });

  /// 实现EditableItem接口所需的copyWith方法
  @override
  CreativeItem copyWith({
    String? id,
    CreativeItemType? type,
    String? title,
    String? description,
    String? content,
    CreativeItemStatus? status,
    CreativeItemPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    List<String>? tags,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return CreativeItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'description': description,
      'content': content,
      'status': status.toString(),
      'priority': priority.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'tags': tags,
      'attachments': attachments,
      'metadata': metadata,
    };
  }
}

/// 创意工坊模块 - 创作与管理平台
class WorkshopModule implements PetModuleInterface {
  // === 模块基本信息 ===
  @override
  String get id => 'workshop';
  
  @override
  String get name => '创意工坊';
  
  @override
  String get description => '支持8种创意类型的创作与管理平台，提供灵感记录、项目孵化、原型开发、作品展示等全流程创意支持。';
  
  @override
  String get version => '1.1.0';
  
  @override
  String get author => 'Ignorant-lu';
  
  @override
  List<String> get dependencies => [];
  
  @override
  Map<String, dynamic> get metadata => {
    'category': 'builtin',
    'features': ['ideas', 'designs', 'prototypes', 'experiments', 'projects', 'templates', 'resources', 'showcase'],
    'supportedTypes': ['idea', 'design', 'prototype', 'experiment', 'project', 'template', 'resource', 'showcase'],
    'maxItemsPerType': 500,
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
  final Map<CreativeItemType, List<CreativeItem>> _itemsByType = {
    CreativeItemType.idea: [],
    CreativeItemType.design: [],
    CreativeItemType.prototype: [],
    CreativeItemType.experiment: [],
    CreativeItemType.project: [],
    CreativeItemType.template: [],
    CreativeItemType.resource: [],
    CreativeItemType.showcase: [],
  };

  // === 生命周期方法 ===
  
  @override
  Future<void> initialize(EventBus eventBus) async {
    developer.log('开始初始化创意工坊模块...', name: 'WorkshopModule');
    
    try {
      _eventBus = eventBus;
      
      // 注册事件监听器
      _setupEventListeners();
      
      // 加载示例数据
      _loadSampleData();
      
      _isInitialized = true;
      
      developer.log('创意工坊模块初始化完成', name: 'WorkshopModule');
    } catch (e) {
      developer.log('创意工坊模块初始化失败: $e', name: 'WorkshopModule');
      rethrow;
    }
  }

  @override
  Future<void> boot() async {
    if (!_isInitialized) {
      throw StateError('模块未初始化，请先调用initialize()');
    }
    
    developer.log('启动创意工坊模块...', name: 'WorkshopModule');
    
    _isActive = true;
    
    developer.log('创意工坊模块已激活', name: 'WorkshopModule');
  }

  @override
  void dispose() {
    developer.log('销毁创意工坊模块...', name: 'WorkshopModule');
    
    _isActive = false;
    _isInitialized = false;
    _eventBus = null;
    
    for (final list in _itemsByType.values) {
      list.clear();
    }
    
    developer.log('创意工坊模块已销毁', name: 'WorkshopModule');
  }

  // === 核心业务方法 ===

  /// 创建新创意项目
  String createItem({
    required CreativeItemType type,
    required String title,
    required String description,
    String content = '',
    CreativeItemPriority priority = CreativeItemPriority.medium,
    DateTime? dueDate,
    List<String> tags = const [],
    List<String> attachments = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();
    final item = CreativeItem(
      id: '${type.toString()}_${now.millisecondsSinceEpoch}',
      type: type,
      title: title,
      description: description,
      content: content,
      priority: priority,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      tags: tags,
      attachments: attachments,
      metadata: metadata,
    );

    _itemsByType[type]!.add(item);

    // 发布创建事件
    _publishCreateItemEvent(item);

    developer.log('创建新创意项目: ${item.id} (${type.toString()})', name: 'WorkshopModule');
    return item.id;
  }

  /// 更新创意项目
  bool updateItem(String itemId, {
    String? title,
    String? description,
    String? content,
    CreativeItemStatus? status,
    CreativeItemPriority? priority,
    DateTime? dueDate,
    List<String>? tags,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    CreativeItem? item;
    CreativeItemType? itemType;
    
    // 查找项目
    for (final type in CreativeItemType.values) {
      final list = _itemsByType[type]!;
      final index = list.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        item = list[index];
        itemType = type;
        break;
      }
    }

    if (item == null || itemType == null) {
      developer.log('更新创意项目失败: 未找到 $itemId', name: 'WorkshopModule');
      return false;
    }

    // 创建更新后的项目
    final oldStatus = item.status;
    final updatedItem = item.copyWith(
      title: title,
      description: description,
      content: content,
      status: status,
      priority: priority,
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      tags: tags,
      attachments: attachments,
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

    developer.log('更新创意项目: $itemId', name: 'WorkshopModule');
    return true;
  }

  /// 删除创意项目
  bool deleteItem(String itemId) {
    for (final type in CreativeItemType.values) {
      final list = _itemsByType[type]!;
      final index = list.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        final item = list.removeAt(index);
        
        // 发布删除事件
        _publishDeleteItemEvent(item);
        
        developer.log('删除创意项目: $itemId', name: 'WorkshopModule');
        return true;
      }
    }
    
    developer.log('删除创意项目失败: 未找到 $itemId', name: 'WorkshopModule');
    return false;
  }

  /// 发布创意项目
  bool publishItem(String itemId) {
    // 查找并更新状态为已发布
    final success = updateItem(itemId, status: CreativeItemStatus.published);
    
    if (success) {
      // 查找项目信息
      CreativeItem? item;
      CreativeItemType? itemType;
      
      for (final type in CreativeItemType.values) {
        final list = _itemsByType[type]!;
        final foundItem = list.where((item) => item.id == itemId).firstOrNull;
        if (foundItem != null) {
          item = foundItem;
          itemType = type;
          break;
        }
      }

      if (item != null && itemType != null) {
        _publishPublishItemEvent(item, itemType);
        developer.log('发布创意项目: $itemId', name: 'WorkshopModule');
      }
    }
    
    return success;
  }

  // === 查询方法 ===

  /// 获取所有创意项目
  List<CreativeItem> getAllItems() {
    final allItems = <CreativeItem>[];
    for (final list in _itemsByType.values) {
      allItems.addAll(list);
    }
    
    // 按更新时间倒序排列
    allItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return allItems;
  }

  /// 根据类型获取项目
  List<CreativeItem> getItemsByType(CreativeItemType type) {
    final items = List<CreativeItem>.from(_itemsByType[type] ?? []);
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// 根据状态获取项目
  List<CreativeItem> getItemsByStatus(CreativeItemStatus status) {
    final items = <CreativeItem>[];
    for (final list in _itemsByType.values) {
      items.addAll(list.where((item) => item.status == status));
    }
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// 根据优先级获取项目
  List<CreativeItem> getItemsByPriority(CreativeItemPriority priority) {
    final items = <CreativeItem>[];
    for (final list in _itemsByType.values) {
      items.addAll(list.where((item) => item.priority == priority));
    }
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// 搜索创意项目
  List<CreativeItem> searchItems(String query) {
    if (query.trim().isEmpty) return [];
    
    final items = <CreativeItem>[];
    final lowerQuery = query.toLowerCase();
    
    for (final list in _itemsByType.values) {
      items.addAll(list.where((item) =>
        item.title.toLowerCase().contains(lowerQuery) ||
        item.description.toLowerCase().contains(lowerQuery) ||
        item.content.toLowerCase().contains(lowerQuery) ||
        item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
      ));
    }
    
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// 根据ID查找项目
  CreativeItem? getItemById(String itemId) {
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
      'draftItems': 0,
      'developingItems': 0,
      'testingItems': 0,
      'completedItems': 0,
      'publishedItems': 0,
      'archivedItems': 0,
    };

    // 按类型统计
    for (final type in CreativeItemType.values) {
      final items = _itemsByType[type] ?? [];
      stats['${type.toString()}Count'] = items.length;
      
      stats['totalItems'] += items.length;
      stats['draftItems'] += items.where((item) => item.status == CreativeItemStatus.draft).length;
      stats['developingItems'] += items.where((item) => item.status == CreativeItemStatus.developing).length;
      stats['testingItems'] += items.where((item) => item.status == CreativeItemStatus.testing).length;
      stats['completedItems'] += items.where((item) => item.status == CreativeItemStatus.completed).length;
      stats['publishedItems'] += items.where((item) => item.status == CreativeItemStatus.published).length;
      stats['archivedItems'] += items.where((item) => item.status == CreativeItemStatus.archived).length;
    }

    // 按优先级统计
    for (final priority in CreativeItemPriority.values) {
      final items = getItemsByPriority(priority);
      stats['${priority.toString()}PriorityCount'] = items.length;
    }

    return stats;
  }

  // === 内部方法 ===

  /// 设置事件监听器
  void _setupEventListeners() {
    // 当前版本暂不监听外部事件
    developer.log('创意工坊事件监听器注册完成', name: 'WorkshopModule');
  }

  /// 加载示例数据
  void _loadSampleData() {
    final now = DateTime.now();
    
    // 添加示例想法
    _itemsByType[CreativeItemType.idea]!.addAll([
      CreativeItem(
        id: 'idea_${now.millisecondsSinceEpoch}',
        type: CreativeItemType.idea,
        title: '智能桌宠交互系统',
        description: '基于AI的智能桌面宠物，能够学习用户习惯并提供个性化服务',
        content: '想法详情：结合大语言模型和情感计算，开发一个真正智能的桌面助手...',
        priority: CreativeItemPriority.high,
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        tags: ['AI', '桌宠', '智能助手'],
        metadata: {'inspiration': 'daily_usage', 'feasibility': 'high'},
      ),
    ]);

    // 添加示例原型
    _itemsByType[CreativeItemType.prototype]!.addAll([
      CreativeItem(
        id: 'prototype_${now.millisecondsSinceEpoch + 1}',
        type: CreativeItemType.prototype,
        title: '打卡系统原型',
        description: '游戏化打卡系统的早期原型，包含经验值和成就系统',
        content: '原型说明：基本的打卡功能已实现，正在完善游戏化元素...',
        status: CreativeItemStatus.developing,
        priority: CreativeItemPriority.medium,
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        tags: ['打卡', '游戏化', '原型'],
        metadata: {'progress': 60, 'tech_stack': 'Flutter'},
      ),
    ]);

    // 添加示例项目
    _itemsByType[CreativeItemType.project]!.addAll([
      CreativeItem(
        id: 'project_${now.millisecondsSinceEpoch + 2}',
        type: CreativeItemType.project,
        title: '桌宠应用重构',
        description: '将现有桌宠应用重构为模块化架构，提升可维护性和扩展性',
        content: '项目计划：Phase 1 - 基础架构，Phase 1.5 - 包驱动重构...',
        status: CreativeItemStatus.testing,
        priority: CreativeItemPriority.high,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
        tags: ['重构', '架构', '模块化'],
        metadata: {'phase': 'Phase 1.5', 'completion': 85},
      ),
    ]);

    developer.log('创意工坊示例数据加载完成', name: 'WorkshopModule');
  }

  // === 事件发布方法 ===

  /// 发布创建项目事件
  void _publishCreateItemEvent(CreativeItem item) {
    try {
      final event = CreateCreativeItemEvent(
        eventId: 'create_creative_item_${DateTime.now().millisecondsSinceEpoch}',
        itemData: item.toMap(),
        itemType: item.type,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布创建项目事件失败: $e', name: 'WorkshopModule');
    }
  }

  /// 发布更新项目事件
  void _publishUpdateItemEvent(CreativeItem item) {
    try {
      final event = UpdateCreativeItemEvent(
        eventId: 'update_creative_item_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        updatedData: item.toMap(),
        itemType: item.type,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布更新项目事件失败: $e', name: 'WorkshopModule');
    }
  }

  /// 发布删除项目事件
  void _publishDeleteItemEvent(CreativeItem item) {
    try {
      final event = DeleteCreativeItemEvent(
        eventId: 'delete_creative_item_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        itemType: item.type,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布删除项目事件失败: $e', name: 'WorkshopModule');
    }
  }

  /// 发布项目发布事件
  void _publishPublishItemEvent(CreativeItem item, CreativeItemType itemType) {
    try {
      final event = PublishCreativeItemEvent(
        eventId: 'publish_creative_item_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        itemType: itemType,
        publishData: item.toMap(),
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布项目发布事件失败: $e', name: 'WorkshopModule');
    }
  }

  /// 发布状态变化事件
  void _publishStatusChangedEvent(String itemId, CreativeItemType itemType, CreativeItemStatus oldStatus, CreativeItemStatus newStatus) {
    try {
      final event = CreativeItemStatusChangedEvent(
        eventId: 'creative_status_changed_${DateTime.now().millisecondsSinceEpoch}',
        itemId: itemId,
        itemType: itemType,
        oldStatus: oldStatus,
        newStatus: newStatus,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布状态变化事件失败: $e', name: 'WorkshopModule');
    }
  }
}