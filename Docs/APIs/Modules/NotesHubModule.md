# NotesHubModule API 文档

## 概述

NotesHubModule是事务中心模块，负责统一管理用户的所有事务性内容，包括笔记、任务、项目、提醒、习惯和目标等业务实体。该模块实现了事件驱动架构，支持完整的CRUD操作和实时状态同步，是桌宠应用的核心业务模块。

- **主要功能**: 事务管理、事件驱动架构、状态同步、数据查询、生命周期管理
- **设计模式**: 事件驱动模式 + 观察者模式 + 策略模式
- **核心技术**: EventBus + 内存存储 + 状态管理
- **位置**: `packages/notes_hub/lib/notes_hub_module.dart`

## 包化架构导入

### 基础导入
```dart
// 导入笔记中心模块包
import 'package:notes_hub/notes_hub.dart';

// 或导入具体模块文件
import 'package:notes_hub/notes_hub_module.dart';
import 'package:notes_hub/notes_hub_widget.dart';
```

### 核心服务依赖
```dart
// 核心服务包（提供EventBus、PetModuleInterface等）
import 'package:core_services/core_services.dart';

// 在主应用中集成
import 'package:notes_hub/notes_hub.dart';
import 'package:core_services/core_services.dart';
```

## 核心事件类型定义

### 事务操作事件基类

```dart
abstract class NotesHubEvent {
  final String id;
  final DateTime timestamp;
  
  NotesHubEvent({
    required this.id,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
```

### 具体事件类型

#### CreateItemEvent - 创建事务事件

```dart
class CreateItemEvent extends NotesHubEvent {
  final String itemType;    // 事务类型 (note/todo/project/reminder/habit/goal)
  final String title;       // 事务标题
  final String? description; // 事务描述
  
  CreateItemEvent({
    required super.id,
    required this.itemType,
    required this.title,
    this.description,
    super.timestamp,
  });
}
```

#### UpdateItemEvent - 更新事务事件

```dart
class UpdateItemEvent extends NotesHubEvent {
  final Map<String, dynamic> updates; // 要更新的字段和值
  
  UpdateItemEvent({
    required super.id,
    required this.updates,
    super.timestamp,
  });
}
```

#### DeleteItemEvent - 删除事务事件

```dart
class DeleteItemEvent extends NotesHubEvent {
  DeleteItemEvent({
    required super.id,
    super.timestamp,
  });
}
```

#### NotesHubStateChangedEvent - 模块状态变化事件

```dart
class NotesHubStateChangedEvent {
  final int totalItems;    // 总事务数
  final int activeItems;   // 活跃事务数
  final int completedItems; // 已完成事务数
  final DateTime lastUpdate; // 最后更新时间
  
  NotesHubStateChangedEvent({
    required this.totalItems,
    required this.activeItems,
    required this.completedItems,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();
}
```

## 主模块类 - NotesHubModule

### 基本属性

| 属性 | 类型 | 描述 |
|------|------|------|
| `name` | `String` | 模块名称，固定为 'notes_hub' |
| `statistics` | `Map<String, int>` | 获取模块统计信息 |
| `isInitialized` | `bool` | 检查模块是否已初始化 |

### 生命周期方法

#### initialize()

```dart
Future<void> initialize(EventBus eventBus) async
```

**功能**: 初始化模块，注册事件监听器，加载初始数据  
**参数**:
- `eventBus`: 全局事件总线实例

**执行步骤**:
1. 保存事件总线引用
2. 注册事件监听器
3. 加载初始数据（包含示例数据）
4. 设置初始化状态
5. 发布状态变化事件

#### boot()

```dart
Future<void> boot() async
```

**功能**: 启动模块，执行启动后的初始化任务  
**前置条件**: 模块必须已初始化  
**异常**: 如果模块未初始化会抛出 `StateError`

#### dispose()

```dart
void dispose()
```

**功能**: 清理模块资源，取消事件监听器  
**执行步骤**:
1. 清理事件监听器
2. 保存当前状态
3. 清理内存数据
4. 重置初始化状态

### 数据查询方法

#### getAllItems()

```dart
List<Map<String, dynamic>> getAllItems()
```

**功能**: 获取所有事务项  
**返回**: 事务项列表，每个项包含完整的事务信息

#### getItemsByType()

```dart
List<Map<String, dynamic>> getItemsByType(String type)
```

**功能**: 根据类型获取事务项  
**参数**:
- `type`: 事务类型 (note/todo/project/reminder/habit/goal)

**返回**: 指定类型的事务项列表

#### getItemsByStatus()

```dart
List<Map<String, dynamic>> getItemsByStatus(String status)
```

**功能**: 根据状态获取事务项  
**参数**:
- `status`: 事务状态 (active/completed/archived/etc.)

**返回**: 指定状态的事务项列表

#### getItem()

```dart
Map<String, dynamic>? getItem(String id)
```

**功能**: 获取特定事务项  
**参数**:
- `id`: 事务项ID

**返回**: 事务项数据或null（如果不存在）

### 统计信息

#### statistics 属性

```dart
Map<String, int> get statistics
```

**返回值结构**:
```dart
{
  'total': int,      // 总事务数
  'active': int,     // 活跃事务数
  'completed': int,  // 已完成事务数
}
```

## 事务数据结构

### 标准事务项结构

```dart
{
  'id': String,              // 唯一标识符
  'type': String,            // 事务类型
  'title': String,           // 标题
  'description': String?,    // 描述
  'status': String,          // 状态
  'createdAt': DateTime,     // 创建时间
  'updatedAt': DateTime,     // 更新时间
}
```

### 支持的事务类型

| 类型 | 描述 | 示例用途 |
|------|------|----------|
| `note` | 笔记 | 记录想法、会议纪要 |
| `todo` | 任务 | 待办事项、行动项 |
| `project` | 项目 | 大型工作项目 |
| `reminder` | 提醒 | 定时提醒事项 |
| `habit` | 习惯 | 习惯养成跟踪 |
| `goal` | 目标 | 长期目标管理 |

### 支持的状态类型

| 状态 | 描述 |
|------|------|
| `active` | 活跃/进行中 |
| `completed` | 已完成 |
| `archived` | 已归档 |
| `deleted` | 已删除 |
| `draft` | 草稿 |
| `inactive` | 非活跃 |

## 事件系统集成

### 事件监听

模块会自动监听以下事件：
- `CreateItemEvent`: 创建新事务
- `UpdateItemEvent`: 更新现有事务
- `DeleteItemEvent`: 删除事务

### 事件发布

模块会发布以下事件：
- `NotesHubStateChangedEvent`: 当模块状态发生变化时

### 使用示例

#### 模块集成示例

```dart
// 在主应用中集成笔记中心模块
import 'package:notes_hub/notes_hub.dart';
import 'package:core_services/core_services.dart';

// 初始化和使用
final notesHub = NotesHubModule();
await notesHub.initialize(EventBus.instance);
await notesHub.boot();

// 创建新事务
final itemId = notesHub.createItem(
  type: ItemType.note,
  title: '会议纪要',
  content: '今日产品讨论会议的要点记录',
  priority: ItemPriority.high,
  tags: ['工作', '会议'],
);
```

#### 创建新事务事件

```dart
// 发布创建事务事件
EventBus.instance.fire(CreateItemEvent(
  eventId: 'create_note_${DateTime.now().millisecondsSinceEpoch}',
  itemData: {
    'title': '会议纪要',
    'content': '今日产品讨论会议的要点记录',
  },
  itemType: ItemType.note,
));
```

#### 更新事务状态

```dart
// 将事务标记为完成
EventBus.instance.fire(UpdateItemEvent(
  id: 'todo_001',
  updates: {
    'status': 'completed',
    'completedAt': DateTime.now(),
  },
));
```

#### 删除事务

```dart
// 删除指定事务
EventBus.instance.fire(DeleteItemEvent(id: 'note_001'));
```

#### 监听状态变化

```dart
// 监听模块状态变化
EventBus.instance.on<NotesHubStateChangedEvent>().listen((event) {
  print('统计更新: 总计${event.totalItems}, 活跃${event.activeItems}');
});
```

## 最佳实践

### 1. 事务ID生成

```dart
// 推荐的ID格式
String generateItemId(String type) {
  return '${type}_${DateTime.now().millisecondsSinceEpoch}';
}
```

### 2. 批量操作

```dart
// 批量创建事务
void createMultipleItems(List<Map<String, dynamic>> items) {
  for (final item in items) {
    EventBus.instance.fire(CreateItemEvent(
      id: item['id'],
      itemType: item['type'],
      title: item['title'],
      description: item['description'],
    ));
  }
}
```

### 3. 状态管理

```dart
// 获取统计信息
final stats = notesHubModule.statistics;
print('完成率: ${(stats['completed']! / stats['total']! * 100).toStringAsFixed(1)}%');
```

### 4. 错误处理

```dart
// 安全的事务查询
Map<String, dynamic>? getItemSafely(NotesHubModule module, String id) {
  try {
    return module.getItem(id);
  } catch (e) {
    print('获取事务失败: $e');
    return null;
  }
}
```

## 性能考虑

### 内存管理
- 模块内部使用Map存储事务数据，适合中等规模的数据集
- 对于大量数据，建议与持久化存储集成

### 事件频率
- 避免过于频繁的状态更新事件
- 批量操作时考虑延迟事件发布

### 数据同步
- 状态变化事件提供实时同步能力
- UI组件可以通过监听事件自动更新

## 扩展性

### 自定义事务类型
- 可通过配置扩展支持的事务类型
- 新类型需要在UI层面相应支持

### 持久化集成
- 当前版本提供内存存储
- 可扩展与SQLite、Hive等持久化方案集成

### 同步功能
- 模块设计支持未来的云同步功能
- 事件系统可以轻松集成同步逻辑

## 故障排除

### 常见问题

**问题**: 模块未正确初始化  
**解决**: 确保在使用前调用 `initialize()` 方法

**问题**: 事件监听器未响应  
**解决**: 检查EventBus实例是否正确配置

**问题**: 统计信息不准确  
**解决**: 确保所有状态变更都通过事件系统进行

### 调试

模块内置调试日志，在开发模式下会输出详细信息：
- 模块生命周期事件
- 事务操作详情
- 状态变化通知

日志标识: `[NotesHubModule]`

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 实现PetModuleInterface接口
  - 事件驱动架构设计
  - 支持6种事务类型管理
  - 完整的CRUD操作
  - 实时状态同步
  - 内存存储实现
  - 调试日志系统 