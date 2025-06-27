# Notes Hub Package

事务中心模块，提供基础的事务管理功能。

## 概述

`notes_hub` 包包含 `NotesHubModule` 和 `NotesHubWidget` 两个核心组件。`NotesHubModule` 基于事件驱动架构，管理事务的创建和删除。`NotesHubWidget` 提供 Material Design 3 风格的用户界面。

## ⚠️ **当前功能状态**

**已实现功能**:
- ✅ 事务项目创建
- ✅ 事务项目删除  
- ✅ 事务项目列表展示
- ✅ 6种事务类型支持
- ✅ 基础统计信息显示

**功能限制**:
- ❌ **编辑功能暂未实现** - 无法修改已创建的事务内容
- ❌ **数据持久化限制** - 数据仅存储在内存中，应用重启后丢失
- ❌ **高级功能未实现** - 无富文本编辑、搜索、协作等功能

## 安装

```yaml
dependencies:
  notes_hub:
    path: ../notes_hub
```

## 核心组件

### NotesHubModule

实现 `PetModuleInterface` 的事务管理模块：

```dart
class NotesHubModule implements PetModuleInterface {
  String get name => 'notes_hub';
  Map<String, int> get statistics; // 获取统计信息
  bool get isInitialized; // 检查初始化状态
  
  // 生命周期管理
  Future<void> initialize(EventBus eventBus);
  Future<void> boot();
  void dispose();
  
  // 数据访问方法
  List<Map<String, dynamic>> getAllItems();
  List<Map<String, dynamic>> getItemsByType(String type);
  List<Map<String, dynamic>> getItemsByStatus(String status);
  Map<String, dynamic>? getItem(String id);
}
```

### NotesHubWidget

事务管理的UI组件：

```dart
class NotesHubWidget extends StatefulWidget {
  final NotesHubModule notesHubModule;
  
  // 提供完整的事务管理界面
}
```

**实际UI功能**：
- 统计信息卡片（总计、活跃、已完成）
- 状态过滤器（全部、活跃、已完成）
- 类型过滤器（支持6种事务类型）
- 事务列表展示
- 创建、删除事务（**注意：编辑功能未实现**）

## 事件系统

模块通过 `EventBus` 处理以下事件：

### 事务操作事件

```dart
// 创建事务事件
class CreateItemEvent extends NotesHubEvent {
  final String id;
  final String itemType;
  final String title;
  final String? description;
}

// 更新事务事件  
class UpdateItemEvent extends NotesHubEvent {
  final String id;
  final Map<String, dynamic> updates;
}

// 删除事务事件
class DeleteItemEvent extends NotesHubEvent {
  final String id;
}

// 状态变化事件
class NotesHubStateChangedEvent {
  final int totalItems;
  final int activeItems;
  final int completedItems;
  final DateTime lastUpdate;
}
```

## 支持的事务类型

模块内置支持6种事务类型配置：

| 类型 | 显示名称 | 图标 | 颜色 |
|------|----------|------|------|
| note | 笔记 | note_alt_outlined | 蓝色 |
| todo | 任务 | check_box_outlined | 绿色 |
| project | 项目 | folder_outlined | 橙色 |
| reminder | 提醒 | notification_important_outlined | 红色 |
| habit | 习惯 | repeat_outlined | 紫色 |
| goal | 目标 | flag_outlined | 青色 |

## 使用方法

### 基础使用

```dart
import 'package:notes_hub/notes_hub.dart';

// 初始化模块
final notesHub = NotesHubModule();
await notesHub.initialize(eventBus);
await notesHub.boot();

// 使用UI组件
NotesHubWidget(
  notesHubModule: notesHub,
)
```

### 事务操作

```dart
// 创建新事务
EventBus.instance.fire(CreateItemEvent(
  id: 'unique_id',
  itemType: 'note',
  title: '我的笔记',
  description: '笔记内容',
));

// 删除事务
EventBus.instance.fire(DeleteItemEvent(id: 'item_id'));
```

### ⚠️ 暂不支持的操作

```dart
// 以下操作将在未来版本中支持：
// EventBus.instance.fire(UpdateItemEvent(id: 'task_id', updates: {...})); // 编辑功能待实现
```

### 数据查询

```dart
// 获取所有事务
final allItems = notesHub.getAllItems();

// 按类型获取
final notes = notesHub.getItemsByType('note');

// 按状态获取
final activeItems = notesHub.getItemsByStatus('active');

// 获取统计信息
final stats = notesHub.statistics;
print('总计: ${stats['total']}');
print('活跃: ${stats['active']}');
print('完成: ${stats['completed']}');
```

## UI组件特性

### 统计信息卡片

显示事务的数量统计：
- 总计事务数
- 进行中事务数
- 已完成事务数

### 过滤功能

- **状态过滤**: 全部、进行中、已完成
- **类型过滤**: 下拉选择事务类型

### 事务操作

- **创建**: 通过右上角+按钮选择类型创建
- **状态切换**: 点击事务项切换完成状态  
- **编辑**: ⚠️ **功能未实现** - 当前无法编辑事务内容
- **删除**: 长按显示删除确认对话框

### 动画效果

- 刷新动画：数据更新时的旋转动画
- 列表动画：事务列表的入场动画

## 示例数据

模块初始化时会创建3个示例事务：

1. **项目设计思路**（笔记类型，活跃状态）
2. **完成UI框架设计**（任务类型，已完成状态）
3. **Phase 1 开发**（项目类型，活跃状态）

## 数据结构

### 事务项结构

```dart
{
  'id': 'unique_identifier',
  'type': 'note|todo|project|reminder|habit|goal',
  'title': '事务标题',
  'description': '事务描述',
  'status': 'active|completed',
  'createdAt': DateTime,
  'updatedAt': DateTime,
}
```

## 技术特性

- **事件驱动**: 基于 EventBus 的松耦合事件系统
- **状态管理**: 本地状态管理，支持实时更新
- **Material Design 3**: 现代化的UI设计风格
- **类型安全**: 强类型的事务数据结构
- **动画支持**: 流畅的UI交互动画

## 依赖关系

- `flutter`: Flutter SDK
- `core_services`: 事件总线和模块接口
- `ui_framework`: 基础UI组件

## 模块集成

```dart
// 在模块管理器中注册
moduleManager.registerModule(notesHub);

// 监听状态变化
EventBus.instance.on<NotesHubStateChangedEvent>().listen((event) {
  print('事务状态变化: ${event.totalItems} 个事务');
});
```

## 注意事项

- 模块必须先初始化再使用
- 事务操作通过事件系统进行
- UI组件需要传入已初始化的模块实例
- 支持基础的事务CRUD操作
- 数据暂存在内存中，重启后丢失

## 当前功能限制

⚠️ **重要提醒**: 本模块目前处于早期开发阶段，仅实现了基础功能。

**已实现功能**:
- 基础事务创建和删除
- 简单的事务列表展示
- 状态切换（活跃/已完成）
- 6种事务类型支持
- 基础统计信息

**计划实现功能**（未来版本）:
- 事务内容编辑和更新
- 富文本编辑器支持
- 搜索和筛选功能
- 数据持久化存储
- 协作和分享功能

## 快速开始

### 1. 模块初始化

```dart
import 'package:notes_hub/notes_hub.dart';
import 'package:core_services/core_services.dart';

void main() async {
  // 初始化核心服务
  final serviceLocator = ServiceLocator.instance;
  
  // 初始化笔记中心模块
  final notesHubModule = NotesHubModule();
  await notesHubModule.initialize();
  
  // 注册模块
  serviceLocator.registerModule(notesHubModule);
}
```

### 2. 使用笔记组件

```dart
import 'package:notes_hub/notes_hub.dart';

class MyNotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('笔记中心')),
      body: NotesHubWidget(),
    );
  }
}
```

## 总结

此包为PetApp项目的事务中心模块早期版本，当前实现了基础的创建、删除和状态切换功能。完整的编辑功能、高级UI组件和数据持久化将在后续版本中实现。

## 依赖关系

- `flutter`: Flutter SDK
- `core_services`: 事件总线和模块接口
- `ui_framework`: 基础UI组件

## 许可证

本包作为 PetApp 项目的一部分，遵循项目整体许可协议。 