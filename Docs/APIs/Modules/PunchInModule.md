# PunchInModule API 文档

## 概述

**PunchInModule** 是桌宠应用的打卡模块，专注于用户打卡签到功能，提供经验值管理、打卡记录追踪和成就激励功能。该模块重构后实现了完整的事件驱动架构，支持日常打卡限制、经验值奖励系统、历史记录管理等核心功能，为用户提供激励性的签到体验。

**主要功能**: 用户打卡签到、经验值管理、历史记录追踪、统计信息、成就激励  
**设计模式**: Event-Driven Architecture、Module Pattern、Observer Pattern  
**核心技术**: Dart/Flutter、EventBus、内存数据管理、状态管理  
**文件位置**: `packages/punch_in/lib/punch_in_module.dart`

## 包化架构导入

### 基础导入
```dart
// 导入打卡模块包
import 'package:punch_in/punch_in.dart';

// 或导入具体模块文件
import 'package:punch_in/punch_in_module.dart';
import 'package:punch_in/punch_in_widget.dart';
```

### 核心服务依赖
```dart
// 核心服务包（提供EventBus、PetModuleInterface等）
import 'package:core_services/core_services.dart';

// 在主应用中集成
import 'package:punch_in/punch_in.dart';
import 'package:core_services/core_services.dart';
```

## 核心事件类型定义

### 抽象基类 - PunchInEvent

打卡事件系统的基础抽象类，定义了所有打卡相关事件的通用属性。

```dart
abstract class PunchInEvent {
  final DateTime timestamp;
  final String eventId;
  
  PunchInEvent({
    required this.eventId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
```

**核心属性**:
- `timestamp`: 事件发生时间戳
- `eventId`: 事件唯一标识符

### 具体事件类

#### UserPunchInEvent - 用户打卡事件
```dart
class UserPunchInEvent extends PunchInEvent {
  final int xpGained;                    // 获得的经验值
  final Map<String, dynamic>? additionalData;  // 附加数据
}
```

**使用场景**: 用户执行打卡操作时发布，携带经验值奖励和打卡记录信息。

#### PunchInDataUpdatedEvent - 打卡数据更新事件
```dart
class PunchInDataUpdatedEvent extends PunchInEvent {
  final Map<String, dynamic> stats;     // 更新后的统计信息
}
```

**使用场景**: 打卡数据发生变化时发布，提供最新的统计信息供UI更新。

#### PunchInStateChangedEvent - 打卡状态变化事件
```dart
class PunchInStateChangedEvent extends PunchInEvent {
  final String changeType;              // 变化类型（initialized/activated等）
  final Map<String, dynamic>? data;     // 状态变化相关数据
}
```

**使用场景**: 模块生命周期状态变化时发布，如初始化完成、模块激活等。

## 主模块类 - PunchInModule

### 模块属性
```dart
String get id => 'punch_in';           // 模块唯一标识
String get name => '桌宠打卡';         // 模块显示名称
String get description;                // 模块功能描述
String get version => '1.1.0';        // 模块版本
String get author;                     // 模块作者
bool get isInitialized;                // 是否已初始化
bool get isActive;                     // 是否已激活
List<String> get dependencies => [];   // 依赖模块列表
Map<String, dynamic> get metadata;    // 模块元数据
```

### 生命周期方法

#### initialize(EventBus eventBus)
```dart
Future<void> initialize(EventBus eventBus) async
```
**功能**: 初始化打卡模块，注册事件监听器，加载打卡数据  
**参数**: `eventBus` - 事件总线实例  
**抛出**: 初始化失败时抛出异常  
**事件**: 发布 `PunchInStateChangedEvent(changeType: 'initialized')`

#### boot()
```dart
Future<void> boot() async
```
**功能**: 启动打卡模块，检查今日打卡状态，激活模块  
**前置条件**: 模块必须已初始化  
**抛出**: `StateError` - 模块未初始化时  
**事件**: 发布 `PunchInStateChangedEvent(changeType: 'activated')`

#### dispose()
```dart
void dispose()
```
**功能**: 销毁打卡模块，取消事件监听，清理资源  
**说明**: 安全销毁，不会抛出异常

### 核心业务方法

#### performPunchIn()
```dart
Future<bool> performPunchIn() async
```
**功能**: 执行打卡操作，更新经验值，记录历史  
**返回**: `bool` - 打卡是否成功  
**业务逻辑**:
- 检查模块状态和今日打卡限制
- 计算经验值奖励（基础10XP + 连续打卡奖励）
- 更新内部状态和历史记录
- 发布 `UserPunchInEvent` 和 `PunchInDataUpdatedEvent`

#### canPunchToday()
```dart
bool canPunchToday()
```
**功能**: 检查今日是否还可以打卡  
**返回**: `bool` - true表示可以打卡  
**规则**: 每日最多打卡5次

### 数据查询方法

#### getCurrentXP()
```dart
int getCurrentXP()
```
**功能**: 获取当前经验值总数  
**返回**: `int` - 当前经验值  
**异常**: `StateError` - 模块未初始化时

#### getTodayPunchCount()
```dart
int getTodayPunchCount()
```
**功能**: 获取今日已打卡次数  
**返回**: `int` - 今日打卡次数  
**说明**: 跨天自动重置

#### getLastPunchTime()
```dart
DateTime? getLastPunchTime()
```
**功能**: 获取最近一次打卡时间  
**返回**: `DateTime?` - 最近打卡时间，未打卡时为null

#### getPunchHistory({int? limit})
```dart
List<Map<String, dynamic>> getPunchHistory({int? limit})
```
**功能**: 获取打卡历史记录  
**参数**: `limit` - 限制返回数量，null表示返回全部  
**返回**: 按时间倒序排列的打卡记录列表  
**记录格式**:
```dart
{
  'id': 'punch_1640995200000',        // 打卡记录唯一ID
  'timestamp': '2021-12-31T16:00:00Z', // ISO 8601时间戳
  'xpGained': 10,                     // 本次获得经验值
  'dailyCount': 1,                    // 当日第几次打卡
  'totalXP': 160,                     // 打卡后总经验值
}
```

#### getStatistics()
```dart
Map<String, dynamic> getStatistics()
```
**功能**: 获取完整统计信息  
**返回**: 包含所有统计数据的Map  
**统计信息格式**:
```dart
{
  'currentXP': 150,                   // 当前总经验值
  'todayPunchCount': 2,               // 今日打卡次数
  'maxDailyPunches': 5,               // 每日最大打卡次数
  'remainingPunches': 3,              // 今日剩余打卡次数
  'totalPunches': 25,                 // 累计打卡总次数
  'lastPunchTime': '2021-12-31T16:00:00Z', // 最近打卡时间
  'canPunchToday': true,              // 今日是否还可打卡
}
```

## 打卡数据结构

### 打卡记录标准结构
每个打卡记录包含以下标准字段：
- **id**: 唯一标识符，格式为 `punch_[timestamp]`
- **timestamp**: ISO 8601格式的时间戳
- **xpGained**: 本次打卡获得的经验值
- **dailyCount**: 当日累计打卡次数
- **totalXP**: 打卡后的总经验值

### 经验值计算规则
- **基础经验值**: 每次打卡获得10XP
- **连续打卡奖励**: 每日第N次打卡额外获得 `N * 2` XP
- **示例**: 第1次打卡获得10XP，第2次打卡获得14XP，第3次打卡获得16XP

## 事件系统集成

### 事件监听
```dart
// 监听所有打卡事件
EventBus.instance.on<PunchInEvent>().listen((event) {
  if (event is UserPunchInEvent) {
    print('用户打卡成功，获得 ${event.xpGained} XP');
  }
});

// 监听特定事件类型
EventBus.instance.on<UserPunchInEvent>().listen((event) {
  // 处理用户打卡事件
});
```

### 事件发布
模块会在以下场景自动发布事件：
- **初始化完成**: `PunchInStateChangedEvent(changeType: 'initialized')`
- **模块激活**: `PunchInStateChangedEvent(changeType: 'activated')`
- **用户打卡**: `UserPunchInEvent` + `PunchInDataUpdatedEvent`

## 使用示例

### 基础使用
```dart
// 在主应用中集成打卡模块
import 'package:punch_in/punch_in.dart';
import 'package:core_services/core_services.dart';

// 获取打卡模块实例
final punchInModule = PunchInModule();

// 初始化模块
await punchInModule.initialize(EventBus.instance);
await punchInModule.boot();

// 检查是否可以打卡
if (punchInModule.canPunchToday()) {
  // 执行打卡
  final success = await punchInModule.performPunchIn();
  if (success) {
    print('打卡成功！当前XP: ${punchInModule.getCurrentXP()}');
  }
}

// 获取统计信息
final stats = punchInModule.getStatistics();
print('今日打卡: ${stats['todayPunchCount']}/${stats['maxDailyPunches']}');

// 获取历史记录
final history = punchInModule.getPunchHistory(limit: 10);
for (final record in history) {
  print('${record['timestamp']}: +${record['xpGained']} XP');
}
```

### 事件监听集成
```dart
// 监听打卡事件更新UI
EventBus.instance.on<UserPunchInEvent>().listen((event) {
  showSnackBar('打卡成功！获得 ${event.xpGained} XP');
  updateXPDisplay();
});

EventBus.instance.on<PunchInDataUpdatedEvent>().listen((event) {
  updateStatistics(event.stats);
});
```

## 最佳实践

### 模块初始化
- 确保在使用任何业务方法前完成 `initialize()` 和 `boot()`
- 在应用关闭时调用 `dispose()` 清理资源

### 数据持久化集成
```dart
// 在实际应用中，应集成持久化存储
class PersistentPunchInModule extends PunchInModule {
  @override
  void _loadPunchData() {
    // 从SharedPreferences或数据库加载数据
    _currentXP = prefs.getInt('punch_in_xp') ?? 0;
    // ... 加载其他数据
  }
  
  @override
  Future<bool> performPunchIn() async {
    final success = await super.performPunchIn();
    if (success) {
      // 保存到持久化存储
      await prefs.setInt('punch_in_xp', _currentXP);
    }
    return success;
  }
}
```

### 错误处理
```dart
try {
  await punchInModule.performPunchIn();
} catch (e) {
  if (e is StateError) {
    // 模块状态错误
    print('模块未正确初始化');
  } else {
    // 其他错误
    print('打卡操作失败: $e');
  }
}
```

### 状态检查
```dart
// 在执行操作前检查模块状态
if (!punchInModule.isInitialized || !punchInModule.isActive) {
  throw StateError('打卡模块未准备就绪');
}
```

## 性能考虑

### 内存管理
- 历史记录存储在内存中，长期使用时建议定期清理旧记录
- 建议保留最近30天的记录，其余数据移至持久化存储

### 事件频率
- 打卡操作频率受每日限制（5次）控制，不会产生过多事件
- 建议在UI中对用户操作进行防重复点击处理

### 数据同步
- 当前版本使用内存存储，重启后数据会丢失
- 生产环境中应集成数据库或SharedPreferences

## 扩展性

### 自定义经验值规则
```dart
class CustomPunchInModule extends PunchInModule {
  @override
  int _calculateXPGain() {
    // 自定义经验值计算逻辑
    return isWeekend() ? 20 : 10; // 周末双倍经验
  }
}
```

### 成就系统集成
```dart
// 监听打卡事件触发成就检查
EventBus.instance.on<UserPunchInEvent>().listen((event) {
  achievementSystem.checkPunchInAchievements(
    totalPunches: punchInModule.getStatistics()['totalPunches'],
    consecutiveDays: calculateConsecutiveDays(),
  );
});
```

### 多用户支持
```dart
class MultiUserPunchInModule extends PunchInModule {
  final String userId;
  
  MultiUserPunchInModule(this.userId);
  
  @override
  String get id => 'punch_in_$userId';
  
  // 实现用户隔离的数据存储
}
```

## 故障排除

### 常见问题

**Q: 打卡失败，提示"模块未正确初始化"**  
A: 确保在调用 `performPunchIn()` 前已完成 `initialize()` 和 `boot()`

**Q: 今日打卡次数计算不正确**  
A: 检查系统时间是否正确，模块依赖系统时间判断日期切换

**Q: 经验值没有正确累加**  
A: 检查 `performPunchIn()` 返回值，只有返回 `true` 时经验值才会增加

**Q: 历史记录为空**  
A: 确认是否成功执行过打卡操作，且模块状态正常

### 调试日志
模块内置调试日志输出，可通过控制台查看详细执行信息：
```
[PunchInModule] 开始初始化打卡模块...
[PunchInModule] 打卡事件监听器注册完成
[PunchInModule] 打卡数据加载完成: XP=150, 历史记录=2条
[PunchInModule] 打卡模块初始化完成
```

## 注意事项

### 并发安全
- 当前实现未考虑并发安全，多线程环境下需要额外的同步机制
- 建议在主线程中执行所有打卡操作

### 数据持久性
- 当前版本数据存储在内存中，应用重启后会丢失
- 生产环境中必须集成持久化存储方案

### 时区处理
- 日期判断基于本地系统时间
- 跨时区使用时需要考虑时区转换问题

## 版本历史

### v1.1.0 (2025-06-25) - Step 18重构版本
- **重构**: 升级为事件驱动架构，符合Phase 1模块管理规范
- **新增**: 完整的PetModuleInterface接口实现
- **新增**: 3种事件类型（UserPunchInEvent/PunchInDataUpdatedEvent/PunchInStateChangedEvent）
- **新增**: 完整的模块生命周期管理（initialize/boot/dispose）
- **新增**: 丰富的数据查询API和统计信息
- **新增**: 经验值奖励系统和连续打卡奖励
- **新增**: 每日打卡限制（5次）和状态检查
- **新增**: 示例数据和调试日志系统
- **改进**: Material Design 3风格的用户界面
- **改进**: 移除对旧PetCore的依赖

### v1.0.0 (2025-06-24) - 初始版本
- **基础**: 简单的打卡功能实现
- **基础**: 基于PetCore的状态管理
- **基础**: 基础的UI组件和EventBus集成 