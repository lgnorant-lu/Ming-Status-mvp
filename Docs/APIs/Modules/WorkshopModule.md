# WorkshopModule API 文档

## 概述

**WorkshopModule** 是桌宠应用的创意工坊模块，专注于创意项目管理、灵感记录、作品展示和协作平台功能。该模块实现了完整的事件驱动架构，支持8种创意类型的统一管理，包括创意想法、设计方案、原型制作、艺术作品、文字创作、音乐创作、视频制作和代码项目。

**主要功能**: 创意项目管理、灵感记录、作品展示、状态跟踪、协作平台  
**设计模式**: Event-Driven Architecture、Module Pattern、Observer Pattern  
**核心技术**: Dart/Flutter、EventBus、内存数据管理、状态管理  
**文件位置**: `packages/workshop/lib/workshop_module.dart`

## 包化架构导入

### 基础导入
```dart
// 导入创意工坊模块包
import 'package:workshop/workshop.dart';

// 或导入具体模块文件
import 'package:workshop/workshop_module.dart';
import 'package:workshop/workshop_widget.dart';
```

### 核心服务依赖
```dart
// 核心服务包（提供EventBus、PetModuleInterface等）
import 'package:core_services/core_services.dart';

// 在主应用中集成
import 'package:workshop/workshop.dart';
import 'package:core_services/core_services.dart';
```

## 核心事件类型定义

### 抽象基类 - WorkshopEvent

创意工坊事件系统的基础抽象类，定义了所有创意工坊相关事件的通用属性。

```dart
abstract class WorkshopEvent {
  final DateTime timestamp;
  final String eventId;
  
  WorkshopEvent({
    required this.eventId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
```

**核心属性**:
- `timestamp`: 事件发生时间戳
- `eventId`: 事件唯一标识符

### 具体事件类

#### CreateCreativeItemEvent - 创建创意项目事件
```dart
class CreateCreativeItemEvent extends WorkshopEvent {
  final Map<String, dynamic> itemData;
  
  CreateCreativeItemEvent({
    required this.itemData,
    required String eventId,
    DateTime? timestamp,
  });
}
```

#### UpdateCreativeItemEvent - 更新创意项目事件
```dart
class UpdateCreativeItemEvent extends WorkshopEvent {
  final String itemId;
  final Map<String, dynamic> updates;
  
  UpdateCreativeItemEvent({
    required this.itemId,
    required this.updates,
    required String eventId,
    DateTime? timestamp,
  });
}
```

#### DeleteCreativeItemEvent - 删除创意项目事件
```dart
class DeleteCreativeItemEvent extends WorkshopEvent {
  final String itemId;
  
  DeleteCreativeItemEvent({
    required this.itemId,
    required String eventId,
    DateTime? timestamp,
  });
}
```

#### WorkshopStateChangedEvent - 状态变化事件
```dart
class WorkshopStateChangedEvent extends WorkshopEvent {
  final String changeType;
  final Map<String, dynamic>? data;
  
  WorkshopStateChangedEvent({
    required this.changeType,
    this.data,
    required String eventId,
    DateTime? timestamp,
  });
}
```

## 主模块类详解

### 类定义
```dart
class WorkshopModule implements PetModuleInterface
```

### 核心属性

#### 静态配置
- **moduleId**: `'workshop'` - 模块唯一标识符
- **_creativeTypes**: 静态Map，定义8种创意类型的配置信息

#### 实例状态
- **_isInitialized**: bool - 模块初始化状态
- **_isActive**: bool - 模块激活状态  
- **_creativeItems**: Map<String, dynamic> - 创意项目数据存储
- **_eventSubscription**: StreamSubscription? - 事件订阅管理器

### 生命周期方法

#### initialize(EventBus eventBus) → Future<void>
模块初始化方法，负责事件监听器注册和示例数据加载。

**执行流程**:
1. 检查重复初始化
2. 注册事件监听器 (`_registerEventListeners()`)
3. 加载示例数据 (`_loadSampleData()`)
4. 设置初始化状态
5. 发布初始化完成事件

**异常处理**: 初始化失败时记录错误日志并重新抛出异常

#### boot() → Future<bool>
模块启动方法，在初始化完成后激活模块功能。

**前置条件**: 模块必须已初始化  
**返回值**: bool - 启动成功/失败状态

#### dispose() → Future<void>
模块销毁方法，清理所有资源和订阅。

**清理内容**:
- 取消事件订阅
- 清理内存数据
- 发布销毁事件
- 重置状态标志

### 数据查询方法

#### getAllItems() → List<Map<String, dynamic>>
获取所有创意项目列表，支持类型安全的数据访问。

#### getItemsByType(String type) → List<Map<String, dynamic>>
根据创意类型过滤项目列表。

**支持的类型**: idea, design, prototype, artwork, writing, music, video, code

#### getItemsByStatus(String status) → List<Map<String, dynamic>>
根据项目状态过滤列表。

**支持的状态**: draft, in_progress, completed, published

#### getItem(String itemId) → Map<String, dynamic>?
获取指定ID的单个创意项目，不存在时返回null。

### 数据操作方法

#### createItem() → String
```dart
String createItem({
  required String title,
  required String type,
  String? description,
  String status = 'draft',
  Map<String, dynamic>? metadata,
})
```

创建新的创意项目，自动生成唯一ID并发布创建事件。

**返回值**: 新创建项目的ID

#### updateItem(String itemId, Map<String, dynamic> updates) → bool
更新指定创意项目的属性，自动更新时间戳并发布更新事件。

#### deleteItem(String itemId) → bool
删除指定的创意项目，发布删除事件。

### 统计信息方法

#### getStatistics() → Map<String, int>
获取创意工坊的统计信息。

**返回数据结构**:
```dart
{
  'total': int,        // 总项目数
  'draft': int,        // 草稿数量
  'inProgress': int,   // 进行中数量
  'completed': int,    // 已完成数量
  'published': int,    // 已发布数量
}
```

#### getCreativeTypes() → Map<String, Map<String, dynamic>> (static)
获取所有创意类型的配置信息，包括标题、图标、颜色等。

## 创意数据结构

### 标准创意项目结构
```dart
{
  'id': String,           // 唯一标识符 (workshop_timestamp格式)
  'title': String,        // 项目标题
  'type': String,         // 创意类型 (idea/design/prototype等)
  'description': String,  // 详细描述
  'status': String,       // 项目状态 (draft/in_progress/completed/published)
  'createdAt': String,    // 创建时间 (ISO8601格式)
  'updatedAt': String,    // 最后更新时间
  'metadata': Map,        // 扩展元数据 (标签、优先级、预估时间等)
}
```

### 支持的创意类型
- **idea**: 创意想法 - 💡 (0xFFFFC107)
- **design**: 设计方案 - 🎨 (0xFF9C27B0)
- **prototype**: 原型制作 - 🔧 (0xFF2196F3)
- **artwork**: 艺术作品 - 🖼️ (0xFFE91E63)
- **writing**: 文字创作 - ✍️ (0xFF4CAF50)
- **music**: 音乐创作 - 🎵 (0xFFFF5722)
- **video**: 视频制作 - 🎬 (0xFF795548)
- **code**: 代码项目 - 💻 (0xFF607D8B)

### 状态类型
- **draft**: 草稿 - 初始创建状态
- **in_progress**: 进行中 - 正在开发/制作
- **completed**: 已完成 - 项目完成待发布
- **published**: 已发布 - 公开展示状态

## 事件系统集成

### 事件监听
```dart
// 监听创意工坊事件
EventBus.instance.on<WorkshopEvent>().listen((event) {
  // 处理事件
});

// 监听状态变化
EventBus.instance.on<WorkshopStateChangedEvent>().listen((event) {
  // 更新UI或缓存
});
```

### 事件发布
```dart
// 发布创建事件
EventBus.instance.fire(CreateCreativeItemEvent(
  itemData: newItem,
  eventId: 'create_${timestamp}',
));

// 发布状态变化事件
EventBus.instance.fire(WorkshopStateChangedEvent(
  changeType: 'item_updated',
  data: {'itemId': id, 'changes': updates},
  eventId: 'state_${timestamp}',
));
```

## 使用示例

### 基本模块使用
```dart
// 在主应用中集成创意工坊模块
import 'package:workshop/workshop.dart';
import 'package:core_services/core_services.dart';

// 初始化模块
final workshop = WorkshopModule();
await workshop.initialize(EventBus.instance);
await workshop.boot();

// 创建创意项目
final itemId = workshop.createItem(
  type: CreativeItemType.design,
  title: '智能桌宠UI设计',
  description: 'Material Design 3风格的桌宠界面设计',
  content: '详细的设计描述和需求...',
  priority: CreativeItemPriority.high,
  tags: ['UI设计', 'Material Design'],
  metadata: {
    'estimatedHours': 20,
    'designTool': 'Figma',
  },
);

// 查询项目
final allItems = workshop.getAllItems();
final designItems = workshop.getItemsByType(CreativeItemType.design);
final drafts = workshop.getItemsByStatus(CreativeItemStatus.draft);

// 更新项目状态
workshop.updateItem(itemId, 
  status: CreativeItemStatus.developing,
  metadata: {'progress': 0.3},
);

// 获取统计信息
final stats = workshop.getStatistics();
print('总项目数: ${stats['total']}');
```

### 事件驱动集成
```dart
// 监听模块状态变化
EventBus.instance.on<WorkshopStateChangedEvent>().listen((event) {
  switch (event.changeType) {
    case 'initialized':
      print('创意工坊模块已初始化');
      break;
    case 'item_created':
      print('新创意项目已创建');
      _refreshUI();
      break;
    case 'item_updated':
      print('创意项目已更新');
      _updateLocalCache();
      break;
  }
});
```

## 最佳实践指南

### ID生成策略
- 使用 `workshop_${timestamp}` 格式确保唯一性
- 时间戳使用 `DateTime.now().millisecondsSinceEpoch`
- 避免手动设置ID，使用模块提供的创建方法

### 批量操作
```dart
// 批量创建示例数据
final items = [
  {'title': '项目A', 'type': 'idea'},
  {'title': '项目B', 'type': 'design'},
  {'title': '项目C', 'type': 'code'},
];

for (final item in items) {
  workshop.createItem(
    title: item['title']!,
    type: item['type']!,
  );
}
```

### 状态管理最佳实践
- 使用状态机模式: draft → in_progress → completed → published
- 支持状态回退: published → draft (重新编辑)
- 在状态变更时记录变更原因

### 错误处理
```dart
try {
  final item = workshop.getItem('invalid_id');
  if (item == null) {
    print('项目不存在');
    return;
  }
  // 处理项目数据
} catch (e) {
  print('获取项目失败: $e');
}
```

## 性能考虑

### 内存管理
- 内存存储适用于小规模数据集 (< 1000项目)
- 大规模应用建议集成持久化存储
- 定期清理已删除项目的内存占用

### 事件频率控制
- 批量更新时使用防抖机制
- 避免频繁发布状态变化事件
- 合并相似的连续更新操作

### 数据同步建议
```dart
// 定期保存状态到持久化存储
Timer.periodic(Duration(minutes: 5), (_) {
  _saveWorkshopState();
});

// 应用启动时恢复状态
await _loadWorkshopState();
```

## 扩展性说明

### 自定义创意类型
```dart
// 扩展创意类型配置
static const Map<String, Map<String, dynamic>> _customTypes = {
  'experiment': {'title': '实验项目', 'icon': '🧪', 'color': 0xFF00BCD4},
  'research': {'title': '研究笔记', 'icon': '📚', 'color': 0xFF3F51B5},
};
```

### 持久化集成
- 实现 `IPersistenceRepository` 接口
- 支持 SQLite、Hive、或云端存储
- 提供数据迁移和同步功能

### 同步功能扩展
- 多设备数据同步
- 协作编辑支持
- 版本历史管理
- 冲突解决机制

## 故障排除

### 常见问题

**Q: 模块初始化失败**
A: 检查EventBus是否已正确注册，确保依赖服务可用

**Q: 事件监听器未触发**
A: 验证事件类型匹配，检查EventBus订阅是否正确设置

**Q: 数据丢失问题**
A: 内存存储在应用重启后会丢失，建议集成持久化存储

**Q: 性能问题**
A: 大量数据时考虑分页加载、延迟初始化、或数据库存储

### 调试指南
```dart
// 启用调试日志
void _logDebug(String message) {
  if (kDebugMode) {
    print('[WorkshopModule] $message');
  }
}

// 检查模块状态
print('Is Initialized: ${workshop.isInitialized}');
print('Is Active: ${workshop.isActive}');
print('Item Count: ${workshop.getAllItems().length}');
```

## 版本历史

### v1.0.0 (Phase 1) - 2025/06/25
**初始功能特性**:
- ✅ 完整的事件驱动架构实现
- ✅ 8种创意类型支持 (想法/设计/原型/艺术/文字/音乐/视频/代码)
- ✅ 4种状态管理 (草稿/进行中/已完成/已发布)
- ✅ CRUD操作完整实现
- ✅ 实时状态同步和事件发布
- ✅ 统计信息和数据查询API
- ✅ 内存数据管理和示例数据
- ✅ 调试日志系统集成
- ✅ 模块生命周期完整管理

**技术特点**:
- EventBus事件总线集成
- PetModuleInterface标准接口实现
- 类型安全的数据访问
- 异常处理和状态验证
- 可扩展的创意类型系统 