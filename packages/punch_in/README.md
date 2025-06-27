# Punch In Package

打卡模块包，提供基础的打卡签到功能。

## 概述

`punch_in` 包包含 `PunchInModule` 和 `PunchInWidget` 两个核心组件。`PunchInModule` 基于事件驱动架构，实现用户打卡签到、经验值管理和打卡记录追踪功能。`PunchInWidget` 提供Material Design 3风格的打卡界面，包含经验值显示、打卡按钮和历史记录等功能。

## 安装

```yaml
dependencies:
  punch_in:
    path: ../punch_in
```

## 核心组件

### PunchInModule

打卡业务模块，实现 `PetModuleInterface` 接口：

```dart
class PunchInModule implements PetModuleInterface {
  String get id => 'punch_in';
  String get name => '桌宠打卡';
  String get version => '1.1.0';
  String get description => '桌宠打卡签到系统 - 每日打卡获取经验值';
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

**核心属性**：
- 支持每日最多5次打卡
- 基础经验值10XP + 连续打卡奖励
- 连续打卡额外奖励机制

### PunchInWidget

打卡UI组件，基于 `StatefulWidget`：

```dart
class PunchInWidget extends StatefulWidget {
  final PunchInModule punchInModule;
  
  // 提供完整的打卡管理界面
}
```

**UI功能**：
- 经验值显示卡片
- 大型打卡按钮（支持动画效果）
- 打卡统计信息
- 最近打卡历史记录

## API参考

### 核心打卡方法

```dart
// 执行打卡操作
Future<bool> performPunchIn();

// 检查今日是否还能打卡
bool canPunchToday();

// 获取当前经验值
int getCurrentXP();

// 获取今日打卡次数
int getTodayPunchCount();

// 获取打卡历史记录
List<Map<String, dynamic>> getPunchHistory({int? limit});

// 获取统计信息
Map<String, int> getStatistics();
```

### 统计信息结构

```dart
{
  'currentXP': 150,
  'todayPunchCount': 3,
  'totalPunches': 45,
  'maxDailyPunches': 5,
  'canPunchToday': true,
  'remainingPunches': 2,
}
```

## 事件系统

模块通过 `EventBus` 处理以下事件：

### 打卡事件

```dart
// 用户打卡事件
class UserPunchInEvent extends PunchInEvent {
  final int xpGained;
  final int newTotalXP;
  final int todayPunchCount;
  final String eventId;
}

// 打卡数据更新事件
class PunchInDataUpdatedEvent extends PunchInEvent {
  final Map<String, int> stats;
  final String eventId;
}

// 打卡状态变化事件
class PunchInStateChangedEvent extends PunchInEvent {
  final String changeType; // 'initialized', 'activated', 'disposed'
  final Map<String, dynamic>? data;
  final String eventId;
}
```

## 使用方法

### 基础使用

```dart
import 'package:punch_in/punch_in.dart';

// 初始化模块
final punchIn = PunchInModule();
await punchIn.initialize(eventBus);
await punchIn.boot();

// 使用UI组件
PunchInWidget(
  punchInModule: punchIn,
)
```

### 打卡操作

```dart
// 检查是否可以打卡
if (punchIn.canPunchToday()) {
  // 执行打卡
  final success = await punchIn.performPunchIn();
  if (success) {
    print('打卡成功！');
  }
}

// 获取当前状态
final xp = punchIn.getCurrentXP();
final todayCount = punchIn.getTodayPunchCount();
print('当前经验值: $xp, 今日打卡: $todayCount');
```

### 数据查询

```dart
// 获取统计信息
final stats = punchIn.getStatistics();
print('总打卡次数: ${stats['totalPunches']}');
print('今日剩余次数: ${stats['remainingPunches']}');

// 获取打卡历史
final history = punchIn.getPunchHistory(limit: 10);
for (final record in history) {
  print('${record['timestamp']}: +${record['xpGained']} XP');
}
```

## UI组件特性

### 经验值卡片

显示当前经验值，支持动画效果：
- 当前总经验值
- 打卡成功时的缩放动画

### 打卡按钮

大型圆形打卡按钮：
- 支持脉冲动画（可打卡时）
- 显示剩余打卡次数
- 加载状态指示器
- 禁用状态（达到每日上限）

### 统计信息

双列统计卡片：
- 今日打卡进度（3/5）
- 累计打卡总数

### 历史记录

最近打卡记录列表：
- 时间格式化显示（刚刚、X分钟前、X小时前等）
- 经验值奖励显示
- 空状态提示

## 打卡规则

### 每日限制

- 每日最多打卡5次
- 超过限制后按钮自动禁用

### 经验值计算

```dart
// 基础经验值
int baseXP = 10;

// 连续打卡奖励（简化版）
int bonusXP = consecutiveDays > 0 ? consecutiveDays * 2 : 0;

// 总经验值
int totalXP = baseXP + bonusXP;
```

### 打卡记录结构

```dart
{
  'id': 'punch_timestamp',
  'timestamp': '2025-06-26T10:30:00.000Z',
  'xpGained': 12,
  'dailyCount': 1,
  'totalXPAfter': 162,
}
```

## 动画系统

### UI配置常量

```dart
class PunchInConfig {
  static const double iconSize = 32.0;
  static const double cardElevation = 2.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pulseAnimationDuration = Duration(milliseconds: 1000);
}
```

### 动画效果

- **脉冲动画**: 打卡按钮的呼吸效果
- **成功动画**: 经验值卡片的缩放反馈
- **加载动画**: 打卡过程中的圆形进度指示器

## 示例数据

模块初始化时会创建示例打卡记录：

```dart
// 初始化时加载的示例数据
_currentXP = 50;
_todayPunchCount = 2;
_totalPunches = 15;

// 示例历史记录
final sampleHistory = [
  {
    'id': 'punch_001',
    'timestamp': DateTime.now().subtract(Duration(hours: 2)),
    'xpGained': 10,
    'dailyCount': 2,
    'totalXPAfter': 50,
  },
  // ... 更多记录
];
```

## 技术特性

- **事件驱动**: 基于 EventBus 的松耦合架构
- **状态管理**: 本地状态管理，支持实时更新
- **Material Design 3**: 现代化UI设计风格
- **动画支持**: 流畅的交互动画和视觉反馈
- **时间格式化**: 智能的相对时间显示

## 依赖关系

- `flutter`: Flutter SDK
- `core_services`: 事件总线和模块接口

## 模块集成

```dart
// 在模块管理器中注册
moduleManager.registerModule(punchIn);

// 监听打卡事件
EventBus.instance.on<UserPunchInEvent>().listen((event) {
  print('用户打卡成功，获得 ${event.xpGained} 经验值');
});
```

## 注意事项

- 模块必须先初始化再使用
- 每日打卡限制为5次
- 经验值和历史记录暂存在内存中
- 打卡操作通过异步方法执行
- UI组件需要传入已初始化的模块实例