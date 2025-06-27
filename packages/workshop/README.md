# Workshop Package

创意工坊模块，提供基础的创意项目管理功能。

## 概述

`workshop` 包包含 `WorkshopModule` 和 `WorkshopWidget` 两个核心组件。`WorkshopModule` 基于事件驱动架构，管理创意项目的创建和删除。`WorkshopWidget` 提供 Material Design 3 风格的创意项目管理界面。

## ⚠️ **当前功能状态**

**已实现功能**:
- ✅ 创意项目创建
- ✅ 创意项目删除  
- ✅ 项目列表展示
- ✅ 8种创意类型支持
- ✅ 基础统计信息

**功能限制**:
- ❌ **编辑功能暂未实现** - 点击编辑显示"编辑功能待实现"消息
- ❌ **数据持久化限制** - 数据仅存储在内存中，应用重启后丢失
- ❌ **高级功能未实现** - 无协作、多媒体编辑、模板系统等功能

## 安装

```yaml
dependencies:
  workshop:
    path: ../workshop
```

## 核心组件

### WorkshopModule

实现 `PetModuleInterface` 的创意项目管理模块：

```dart
class WorkshopModule implements PetModuleInterface {
  String get id => 'workshop';
  String get name => '创意工坊';
  String get description => '创意项目管理、灵感记录、作品展示和协作平台';
  String get version => '1.0.0';
  String get author => 'PetApp Development Team';
  
  bool get isInitialized;
  bool get isActive;
  List<String> get dependencies => [];
  Map<String, dynamic> get metadata;
  
  // 生命周期管理
  Future<void> initialize(EventBus eventBus);
  Future<bool> boot();
  Future<void> dispose();
}
```

### WorkshopWidget

创意项目管理的UI组件：

```dart
class WorkshopWidget extends StatefulWidget {
  final WorkshopModule module;
  
  // 提供完整的创意项目管理界面
}
```

## 数据访问API

### 已实现操作

```dart
// 获取创意项目
List<CreativeItem> getAllItems();

// 创建创意项目
String createItem({
  required CreativeItemType type,
  required String title,
  required String description,
  required String content,
});

// 删除创意项目
bool deleteItem(String itemId);
```

### ⚠️ 暂未实现的API

```dart
// 以下API在未来版本中实现：
// bool updateItem(String itemId, Map<String, dynamic> updates);
// List<CreativeItem> getItemsByType(String type);
// List<CreativeItem> getItemsByStatus(String status);
// Map<String, int> getStatistics();
```

## 事件系统

模块通过 `EventBus` 处理以下事件：

### 创意工坊事件

```dart
// 创建创意项目事件
class CreateCreativeItemEvent extends WorkshopEvent {
  final Map<String, dynamic> itemData;
  final String eventId;
}

// 更新创意项目事件
class UpdateCreativeItemEvent extends WorkshopEvent {
  final String itemId;
  final Map<String, dynamic> updates;
  final String eventId;
}

// 删除创意项目事件
class DeleteCreativeItemEvent extends WorkshopEvent {
  final String itemId;
  final String eventId;
}

// 状态变化事件
class WorkshopStateChangedEvent extends WorkshopEvent {
  final String changeType;
  final Map<String, dynamic>? data;
  final String eventId;
}
```

## 支持的创意类型

模块内置支持8种创意类型：

| 类型 | 标题 | 图标 | 颜色 |
|------|------|------|------|
| idea | 创意想法 | 💡 | #FFC107 |
| design | 设计方案 | 🎨 | #9C27B0 |
| prototype | 原型制作 | 🔧 | #2196F3 |
| artwork | 艺术作品 | 🖼️ | #E91E63 |
| writing | 文字创作 | ✍️ | #4CAF50 |
| music | 音乐创作 | 🎵 | #FF5722 |
| video | 视频制作 | 🎬 | #795548 |
| code | 代码项目 | 💻 | #607D8B |

```dart
// 获取创意类型配置
static Map<String, Map<String, dynamic>> getCreativeTypes();
```

## 使用方法

### 基础使用

```dart
import 'package:workshop/workshop.dart';

// 初始化模块
final workshop = WorkshopModule();
await workshop.initialize(eventBus);
await workshop.boot();

// 使用UI组件
WorkshopWidget(
  module: workshop,
)
```

### 创意项目操作

```dart
// 创建新项目
final itemId = workshop.createItem(
  type: CreativeItemType.idea,
  title: '智能桌宠交互系统',
  description: '基于AI的智能桌面宠物设计',
  content: '详细的创意描述...',
);

// 删除项目  
workshop.deleteItem(itemId);
```

### ⚠️ 暂不支持的操作

```dart
// 以下操作将在未来版本中支持：
// workshop.updateItem(itemId, updates); // 编辑功能待实现
// workshop.updateStatus(itemId, newStatus); // 状态管理待实现
```

### 数据查询

```dart
// 获取所有项目（当前唯一可用的查询方法）
final allItems = workshop.getAllItems();
print('共有 ${allItems.length} 个创意项目');
```

### ⚠️ 暂不支持的查询

```dart
// 以下查询功能将在未来版本中实现：
// final ideas = workshop.getItemsByType('idea');
// final inProgress = workshop.getItemsByStatus('in_progress');
// final stats = workshop.getStatistics();
```

## UI组件特性

### 项目列表展示

- 项目卡片显示：标题、描述、类型标签、状态标签
- 空状态友好提示：无项目时显示创建引导

### 项目操作

- **创建**: 通过浮动按钮创建新项目（固定为"创意想法"类型）
- **编辑**: ⚠️ 显示"编辑功能待实现"提示信息
- **删除**: 通过右上角菜单删除项目

### 导航功能  

- 搜索按钮（界面已实现，功能待开发）
- 渐变色应用栏设计

### ⚠️ 暂未实现的UI功能

- 统计信息卡片
- 状态/类型过滤器  
- 项目状态切换
- 类型选择创建
- 搜索功能
- 动画效果

## 项目状态流

创意项目支持四种状态的流转：

```
draft → in_progress → completed → published
  ↑                                     ↓
  ←----- (可循环回到任意状态) --------←
```

## 示例数据

模块初始化时会创建3个示例项目：

1. **智能桌宠交互系统**（创意想法，进行中）
2. **Material You界面设计**（设计方案，已完成）
3. **Flutter模块化架构**（代码项目，进行中）

## 数据结构

### 创意项目结构

```dart
{
  'id': 'workshop_timestamp',
  'title': '项目标题',
  'type': 'idea|design|prototype|artwork|writing|music|video|code',
  'description': '项目描述',
  'status': 'draft|in_progress|completed|published',
  'createdAt': '2025-06-26T10:30:00.000Z',
  'updatedAt': '2025-06-26T10:30:00.000Z',
  'metadata': {
    'tags': ['标签1', '标签2'],
    'priority': 'high|medium|low',
    // 其他自定义字段
  },
}
```

## UI配置系统

### CreativeTypeConfig

```dart
class CreativeTypeConfig {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
}

// 预定义配置
class CreativeTypeConfigs {
  static CreativeTypeConfig? getConfig(String type);
  static Map<String, CreativeTypeConfig> get all;
}
```

## 技术特性

- **事件驱动**: 基于 EventBus 的松耦合架构
- **状态管理**: 本地内存存储，支持实时更新
- **Material Design 3**: 现代化UI设计
- **类型安全**: 强类型的数据结构
- **动画支持**: 流畅的交互动画
- **可扩展**: 支持自定义元数据

## 依赖关系

- `flutter`: Flutter SDK
- `core_services`: 事件总线和模块接口

## 模块集成

```dart
// 在模块管理器中注册
moduleManager.registerModule(workshop);

// 监听状态变化
EventBus.instance.on<WorkshopStateChangedEvent>().listen((event) {
  print('创意工坊状态变化: ${event.changeType}');
});
```

## 注意事项

- 模块必须先初始化再启动
- 创意项目操作通过模块API进行
- UI组件需要传入已初始化的模块实例
- 数据暂存在内存中，重启后丢失
- 支持基础的项目CRUD操作

## 当前功能限制

⚠️ **重要提醒**: 本模块目前处于早期开发阶段，仅实现了基础功能。

**已实现功能**:
- 基础创意项目创建和删除
- 简单的项目列表展示  
- 8种创意类型定义（仅用于数据结构）

**计划实现功能**（未来版本）:
- 创意项目编辑和更新
- 项目状态管理和流转
- 多媒体创作工具集成
- 协作和分享功能
- 模板库和资源管理

## 快速开始

### 1. 模块初始化

```dart
import 'package:workshop/workshop.dart';
import 'package:core_services/core_services.dart';

void main() async {
  // 初始化核心服务
  final serviceLocator = ServiceLocator.instance;
  
  // 初始化工坊模块
  final workshopModule = WorkshopModule();
  await workshopModule.initialize();
  
  // 注册模块
  serviceLocator.registerModule(workshopModule);
}
```

### 2. 使用工坊组件

```dart
import 'package:workshop/workshop.dart';

class MyWorkshopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('创意工坊')),
      body: WorkshopWidget(),
    );
  }
}
```

## 总结

此包为PetApp项目的创意工坊模块早期版本，当前仅实现基础的创建和删除功能。完整的CRUD操作、高级功能和数据持久化将在后续版本中实现。

## 依赖关系

- `flutter`: Flutter SDK
- `core_services`: 事件总线和模块接口

## 许可证

本包作为 PetApp 项目的一部分，遵循项目整体许可协议。 