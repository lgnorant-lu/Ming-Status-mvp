# ModuleManager API 文档

## 概述

ModuleManager是整个应用平台的核心模块管理服务，负责模块的注册、生命周期管理、依赖解析和向UI层提供模块清单。它是从Phase 0的基础验证架构向Phase 1混合架构演进的关键组件。

- **主要功能**: 模块注册/注销、生命周期管理、依赖解析、事件流管理、EventBus安全集成
- **设计模式**: 单例模式 + 观察者模式 + 工厂模式
- **依赖关系**: 依赖于EventBus、PetModuleInterface（支持安全的EventBus可选依赖）
- **位置**: `packages/core_services/lib/services/module_manager.dart`
- **测试兼容性**: 支持测试环境下的EventBus缺失情况，自动降级处理

## 核心类型定义

### ModuleLifecycleState 枚举
```dart
enum ModuleLifecycleState {
  registered,    // 已注册但未初始化
  initializing,  // 正在初始化
  active,        // 已初始化并可用
  disposing,     // 正在销毁
  disposed,      // 已销毁或出错
  error,         // 初始化失败
}
```

### ModuleMetadata 类
```dart
class ModuleMetadata {
  final String id;              // 模块唯一标识
  final String name;            // 模块名称
  final String description;     // 模块描述
  final String version;         // 版本号
  final String author;          // 作者
  final List<String> dependencies; // 依赖列表
  final Map<String, dynamic> configuration; // 配置信息
  final ModuleLifecycleState state; // 当前状态
  final DateTime registeredAt; // 注册时间
  final DateTime? initializedAt; // 初始化时间
  final String? errorMessage;  // 错误信息
}
```

## 主要接口

### 单例管理

#### `ModuleManager.instance`
- **描述**: 获取ModuleManager的单例实例
- **签名**: `static ModuleManager get instance`
- **返回值**: ModuleManager实例
- **示例**:
```dart
final moduleManager = ModuleManager.instance;
```

### 模块注册与管理

#### `registerModule`
- **描述**: 注册新模块到管理器
- **签名**: `Future<String> registerModule(PetModuleInterface moduleInstance, {ModuleMetadata? metadata})`
- **参数**:
  - `moduleInstance`: 模块实例，必须实现PetModuleInterface
  - `metadata`: 可选的模块元数据，不提供则自动创建
- **返回值**: 注册成功的模块ID
- **异常**: `ModuleManagerException` - 模块已存在或依赖验证失败
- **示例**:
```dart
final punchInModule = PunchInModule();
final moduleId = await moduleManager.registerModule(punchInModule);
```

#### `unregisterModule`
- **描述**: 注销指定模块
- **签名**: `Future<void> unregisterModule(String moduleId, {bool force = false})`
- **参数**:
  - `moduleId`: 要注销的模块ID
  - `force`: 是否强制注销（忽略依赖检查）
- **异常**: `ModuleManagerException` - 模块不存在或有依赖冲突
- **示例**:
```dart
await moduleManager.unregisterModule('punch_in', force: true);
```

### 模块生命周期管理

#### `initializeModule`
- **描述**: 初始化指定模块，自动处理依赖项的初始化顺序
- **签名**: `Future<void> initializeModule(String moduleId)`
- **参数**: `moduleId` - 要初始化的模块ID
- **异常**: `ModuleManagerException` - 模块不存在、依赖缺失或初始化失败
- **示例**:
```dart
await moduleManager.initializeModule('punch_in');
```

#### `disposeModule`
- **描述**: 销毁指定模块，自动处理依赖模块的销毁
- **签名**: `Future<void> disposeModule(String moduleId)`
- **参数**: `moduleId` - 要销毁的模块ID
- **示例**:
```dart
await moduleManager.disposeModule('punch_in');
```

#### `initializeAllModules`
- **描述**: 按依赖顺序初始化所有已注册的模块
- **签名**: `Future<void> initializeAllModules()`
- **示例**:
```dart
await moduleManager.initializeAllModules();
```

#### `disposeAllModules`
- **描述**: 按反向依赖顺序销毁所有模块
- **签名**: `Future<void> disposeAllModules()`
- **示例**:
```dart
await moduleManager.disposeAllModules();
```

### 查询与信息接口

#### `getAllModules`
- **描述**: 获取所有已注册模块的元数据
- **签名**: `List<ModuleMetadata> getAllModules()`
- **返回值**: 模块元数据列表
- **示例**:
```dart
final modules = moduleManager.getAllModules();
for (final metadata in modules) {
  print('模块: ${metadata.name}, 状态: ${metadata.state}');
}
```

#### `getActiveModules`
- **描述**: 获取活跃状态的模块列表
- **签名**: `List<ModuleMetadata> getActiveModules()`
- **返回值**: 活跃状态的模块元数据列表

#### `getModuleMetadata`
- **描述**: 获取特定模块的元数据
- **签名**: `ModuleMetadata? getModuleMetadata(String moduleId)`
- **参数**: `moduleId` - 模块ID
- **返回值**: 模块元数据或null（如果不存在）

#### `getModuleInstance`
- **描述**: 获取特定模块的实例
- **签名**: `PetModuleInterface? getModuleInstance(String moduleId)`
- **参数**: `moduleId` - 模块ID
- **返回值**: 模块实例或null（如果不存在）

#### `isModuleRegistered`
- **描述**: 检查模块是否已注册
- **签名**: `bool isModuleRegistered(String moduleId)`
- **参数**: `moduleId` - 模块ID
- **返回值**: 是否已注册

#### `isModuleActive`
- **描述**: 检查模块是否处于活跃状态
- **签名**: `bool isModuleActive(String moduleId)`
- **参数**: `moduleId` - 模块ID
- **返回值**: 是否处于活跃状态

#### `getStatistics`
- **描述**: 获取模块管理器统计信息
- **签名**: `Map<String, dynamic> getStatistics()`
- **返回值**: 包含模块数量、状态分布、管理器状态等统计信息
- **示例**:
```dart
final stats = moduleManager.getStatistics();
print('总模块数: ${stats['totalModules']}');
print('活跃模块数: ${stats['activeModules']}');
print('错误模块数: ${stats['errorModules']}');
```

## 事件系统

### 生命周期事件流

#### `lifecycleEvents`
- **描述**: 获取模块生命周期事件流
- **签名**: `Stream<ModuleLifecycleEvent> get lifecycleEvents`
- **返回值**: 生命周期事件流
- **示例**:
```dart
moduleManager.lifecycleEvents.listen((event) {
  switch (event.runtimeType) {
    case ModuleRegisteredEvent:
      print('模块 ${event.moduleId} 已注册');
      break;
    case ModuleInitializedEvent:
      print('模块 ${event.moduleId} 已初始化');
      break;
    case ModuleDisposedEvent:
      print('模块 ${event.moduleId} 已销毁');
      break;
    case ModuleErrorEvent:
      final errorEvent = event as ModuleErrorEvent;
      print('模块 ${event.moduleId} 错误: ${errorEvent.errorMessage}');
      break;
  }
});
```

#### `getModuleLifecycleEvents`
- **描述**: 获取特定模块的生命周期事件流
- **签名**: `Stream<ModuleLifecycleEvent> getModuleLifecycleEvents(String moduleId)`
- **参数**: `moduleId` - 模块ID
- **返回值**: 特定模块的生命周期事件流

### 事件类型

- **ModuleRegisteredEvent**: 模块注册事件
- **ModuleInitializedEvent**: 模块初始化完成事件
- **ModuleDisposedEvent**: 模块销毁事件
- **ModuleErrorEvent**: 模块错误事件

## 异常处理

### ModuleManagerException
```dart
class ModuleManagerException implements Exception {
  final String message;      // 错误消息
  final String? moduleId;    // 相关模块ID
  final dynamic originalError; // 原始错误
}
```

**常见异常情况**:
- 模块已存在
- 模块不存在
- 依赖模块缺失
- 循环依赖检测
- 模块初始化失败
- 模块销毁失败

### EventBus安全处理机制

ModuleManager现在包含了健壮的EventBus错误处理机制，确保在以下情况下仍能正常工作：

#### 测试环境兼容性
- **EventBus未注册**: 在单元测试环境中，如果EventBus未注册到GetIt容器，ModuleManager会自动降级
- **临时EventBus**: 如果模块初始化时EventBus不可用，会创建临时EventBus实例
- **调试日志**: 所有EventBus访问失败都会记录详细的调试信息

#### 自动降级处理
```dart
// 示例：安全的EventBus访问
try {
  EventBus.instance.fire(event);
} catch (e) {
  // 自动降级，记录日志但不影响核心功能
  developer.log('EventBus not available: $e', name: 'ModuleManager');
}
```

#### 影响的功能
- **事件发布**: 生命周期事件可能无法发布到全局EventBus，但内部流仍正常工作
- **模块初始化**: 使用临时EventBus确保模块正常初始化
- **状态同步**: 核心状态管理不受影响，仅外部事件通知可能受限

## 配置与性能

### 内部机制
- **依赖解析**: 使用拓扑排序算法确定模块初始化顺序
- **循环依赖检测**: 在注册时进行依赖图验证
- **事件驱动**: 与EventBus集成，支持模块间通信
- **线程安全**: 单例模式确保线程安全
- **内存管理**: 支持模块热重载和资源清理

### 性能特性
- **懒加载**: 模块按需初始化
- **批量操作**: 支持批量模块初始化
- **事件缓存**: 生命周期事件流支持广播
- **统计监控**: 提供详细的模块状态统计

## 使用最佳实践

1. **模块设计**: 模块应具有清晰的接口和最小依赖
2. **依赖管理**: 避免循环依赖，合理设计模块层次
3. **错误处理**: 监听错误事件，实现优雅降级
4. **生命周期**: 正确实现模块的初始化和销毁逻辑
5. **事件监听**: 使用生命周期事件进行UI状态更新

## 版本历史

- **v1.1.0** (2025-06-25): EventBus安全处理增强 - Step 22测试修复
  - 新增EventBus安全访问机制，支持测试环境下的EventBus缺失
  - 改进`_setupEventListeners`方法，添加try-catch错误处理
  - 增强`_publishLifecycleEvent`方法，支持EventBus不可用时的降级处理
  - 优化`initializeModule`方法，添加临时EventBus创建机制
  - 完善调试日志系统，提供详细的EventBus状态信息
  - 提高测试兼容性，确保单元测试环境下的稳定运行

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 基础模块注册和生命周期管理
  - 依赖解析和拓扑排序
  - EventBus集成
  - 统计信息和健康监测 