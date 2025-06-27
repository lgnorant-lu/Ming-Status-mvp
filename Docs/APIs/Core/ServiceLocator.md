# ServiceLocator API 文档

## 概述

ServiceLocator是Phase 1的企业级依赖注入服务定位器，负责统一的服务生命周期管理和依赖注入配置。基于GetIt包构建，为整个应用程序提供类型安全的服务注册、解析和状态管理。

- **主要功能**: 服务注册和解析、生命周期管理、状态跟踪、依赖注入配置
- **设计模式**: 单例模式 + 服务定位模式 + 工厂模式 + 状态管理模式
- **依赖关系**: 依赖于GetIt、被所有核心服务使用
- **位置**: `packages/core_services/lib/di/service_locator.dart`

## 核心枚举定义

### ServicePriority 服务优先级
定义服务注册的优先级顺序，确保依赖关系的正确初始化。

```dart
enum ServicePriority {
  core(1),        // 核心基础设施服务 (EventBus, 配置等)
  foundation(2),  // 基础服务层 (Repository, Network, Security等)
  application(3), // 应用服务层 (Navigation, ModuleManager等)
  modules(4),     // 业务模块层 (各种业务模块)
  presentation(5) // UI和表现层服务
}
```

**优先级说明**:
- **core**: EventBus、配置服务等基础设施
- **foundation**: 数据层、网络层、安全层服务
- **application**: 导航、模块管理等应用层服务
- **modules**: 具体业务模块 (PunchIn、NotesHub、Workshop)
- **presentation**: UI组件和表现层服务

### ServiceLifecycle 服务生命周期
定义服务的生命周期管理策略。

```dart
enum ServiceLifecycle {
  singleton,     // 单例模式 - 全局唯一实例
  lazySingleton, // 懒加载单例 - 首次使用时创建
  factory,       // 工厂模式 - 每次调用创建新实例
  scoped,        // 作用域单例 - 在特定作用域内唯一
}
```

### ServiceStatus 服务状态
跟踪服务的当前状态。

```dart
enum ServiceStatus {
  unregistered,  // 未注册状态
  registered,    // 已注册但未初始化
  initializing,  // 正在初始化
  ready,         // 已初始化并可用
  disposed,      // 已销毁
  error,         // 错误状态
}
```

---

## 核心类定义

### ServiceConfig<T> 服务配置元数据
包含服务注册的详细配置信息。

```dart
class ServiceConfig<T extends Object> {
  final Type serviceType;           // 服务类型
  final Type implementationType;    // 服务实现类型
  final ServiceLifecycle lifecycle; // 服务生命周期
  final ServicePriority priority;   // 注册优先级
  final T Function()? factoryFunc;  // 服务工厂函数
  final Future<T> Function()? asyncFactoryFunc; // 异步工厂函数
  final List<Type> dependencies;    // 服务依赖列表
  final bool isRequired;            // 是否必需服务
  final String description;         // 服务描述
  final bool isInterface;           // 是否为接口注册
}
```

**配置示例**:
```dart
ServiceConfig<EventBus>(
  serviceType: EventBus,
  implementationType: EventBus,
  lifecycle: ServiceLifecycle.singleton,
  priority: ServicePriority.core,
  factoryFunc: () => EventBus.instance,
  description: 'EventBus事件总线系统 - 全局事件通信',
  isRequired: true,
)
```

### ServiceLocatorException 异常处理
处理依赖注入过程中的各种异常情况。

```dart
class ServiceLocatorException implements Exception {
  final String message;      // 异常消息
  final Type? serviceType;   // 相关服务类型
  final String? operation;   // 操作名称
  final dynamic cause;       // 异常原因
}
```

### ServiceStatusInfo 服务状态信息
包含服务的详细状态信息。

```dart
class ServiceStatusInfo {
  final Type serviceType;              // 服务类型
  final ServiceStatus status;          // 当前状态
  final DateTime lastUpdated;          // 最后更新时间
  final String? errorMessage;          // 错误消息
  final Map<String, dynamic> metadata; // 元数据
}
```

---

## ServiceLocator 主类详解

### 基础属性和方法

```dart
class ServiceLocator {
  // 单例实例
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;

  // GetIt实例访问
  static GetIt get instance => _getIt;

  // 状态查询
  bool get isInitialized => _isInitialized;
  bool get debugMode => _debugMode;
  void setDebugMode(bool enabled);
}
```

### 核心服务管理方法

#### 获取服务实例
```dart
T get<T extends Object>({String? instanceName})
```

**功能**: 类型安全地获取已注册的服务实例
**参数**: 
- `T`: 服务类型
- `instanceName`: 可选的实例名称

**异常**: 
- `ServiceLocatorException`: 服务未注册或获取失败

**使用示例**:
```dart
// 获取EventBus实例
final eventBus = serviceLocator.get<EventBus>();

// 获取指定名称的实例
final customService = serviceLocator.get<MyService>(instanceName: 'custom');
```

#### 检查服务注册状态
```dart
bool isRegistered<T extends Object>({String? instanceName})
```

**功能**: 检查指定类型的服务是否已注册
**返回**: 如果服务已注册返回true，否则返回false

#### 重置服务定位器
```dart
Future<void> reset()
```

**功能**: 重置所有服务注册，清理状态信息
**用途**: 主要用于测试环境或应用重启

### 状态管理方法

#### 获取服务状态
```dart
ServiceStatusInfo? getServiceStatus(Type serviceType)
Map<Type, ServiceStatusInfo> getAllServiceStatus()
```

**功能**: 查询单个或所有服务的状态信息
**返回**: 服务状态详细信息

#### 调试和日志
```dart
void setDebugMode(bool enabled)
void _logDebug(String message)
```

**功能**: 启用调试模式，输出详细的注册和状态变化日志

---

## 使用示例

### 基础服务获取
```dart
import 'package:pet_app/core/di/service_locator.dart';

// 使用全局serviceLocator实例
final eventBus = serviceLocator.get<EventBus>();

// 或使用便捷函数
final moduleManager = getService<ModuleManager>();

// 检查服务可用性
if (isServiceAvailable<NavigationService>()) {
  final nav = getService<NavigationService>();
  // 使用导航服务
}
```

### 调试模式使用
```dart
void main() async {
  // 启用调试模式
  serviceLocator.setDebugMode(true);
  
  // 执行服务操作会输出详细日志
  final eventBus = serviceLocator.get<EventBus>();
  
  // 查看所有服务状态
  final statuses = serviceLocator.getAllServiceStatus();
  for (final status in statuses.values) {
    print('Service: ${status.serviceType}, Status: ${status.status}');
  }
}
```

### 错误处理
```dart
try {
  final service = serviceLocator.get<MyService>();
  // 使用服务
} on ServiceLocatorException catch (e) {
  print('Failed to get service: ${e.message}');
  if (e.serviceType != null) {
    print('Service type: ${e.serviceType}');
  }
  if (e.operation != null) {
    print('Operation: ${e.operation}');
  }
}
```

---

## 全局便捷函数

### getService<T>
```dart
T getService<T extends Object>({String? instanceName})
```

**功能**: 全局便捷的服务获取函数
**等价于**: `serviceLocator.get<T>(instanceName: instanceName)`

### isServiceAvailable<T>
```dart
bool isServiceAvailable<T extends Object>({String? instanceName})
```

**功能**: 全局便捷的服务可用性检查函数
**等价于**: `serviceLocator.isRegistered<T>(instanceName: instanceName)`

---

## 架构设计原则

### 依赖分离
- 接口与实现分离：支持接口注册，便于测试和替换
- 类型安全：编译时检查依赖关系
- 优先级管理：确保依赖服务先于使用者注册

### 生命周期管理
- **singleton**: 适用于无状态或全局共享的服务
- **lazySingleton**: 适用于初始化成本高但不总是需要的服务
- **factory**: 适用于有状态且需要独立实例的服务
- **scoped**: 适用于特定作用域内的服务

### 错误处理策略
- 区分必需和可选服务
- 详细的异常信息包含操作上下文
- 状态跟踪便于问题诊断

---

## 性能考虑

### 初始化性能
- 优先级驱动的注册顺序减少依赖等待
- 懒加载策略延迟非关键服务的创建
- 状态缓存避免重复查询

### 运行时性能
- GetIt的高效服务查找
- 类型缓存减少反射开销
- 最小化状态更新频率

### 内存管理
- 单例模式减少内存占用
- 及时清理销毁的服务状态
- 避免循环引用

---

## 扩展指南

### 添加新服务类型
```dart
// 1. 定义服务配置
final customConfig = ServiceConfig<MyCustomService>(
  serviceType: MyCustomService,
  implementationType: MyCustomServiceImpl,
  lifecycle: ServiceLifecycle.singleton,
  priority: ServicePriority.application,
  factoryFunc: () => MyCustomServiceImpl(),
  dependencies: [EventBus, ApiClient],
  description: '自定义业务服务',
  isRequired: false,
);

// 2. 注册服务 (通过扩展初始化逻辑)
// 或运行时注册
serviceLocator.registerService<MyCustomService>(
  MyCustomServiceImpl(),
  lifecycle: ServiceLifecycle.singleton,
);
```

### 自定义作用域管理
```dart
// 为特定功能创建作用域服务
class FeatureScopeManager {
  final ServiceLocator _locator = ServiceLocator();
  
  void enterScope() {
    // 注册作用域内的服务
  }
  
  void exitScope() {
    // 清理作用域服务
  }
}
```

---

## 最佳实践

### 服务设计
1. **单一职责**: 每个服务应有明确的职责边界
2. **接口优先**: 定义清晰的接口契约
3. **依赖最小化**: 减少不必要的服务依赖
4. **状态无关**: 服务应尽可能无状态或状态自包含

### 依赖管理
1. **分层依赖**: 遵循架构分层，避免循环依赖
2. **可选依赖**: 区分必需和可选依赖
3. **延迟初始化**: 使用懒加载策略优化启动性能
4. **接口隔离**: 通过接口隔离具体实现

### 测试策略
1. **Mock服务**: 为测试注册Mock实现
2. **隔离测试**: 每个测试使用独立的服务定位器
3. **状态验证**: 验证服务状态变化的正确性
4. **异常测试**: 测试各种异常场景的处理

---

## 故障排除

### 常见问题

**问题1**: `ServiceLocatorException: Service not registered`
```
原因: 尝试获取未注册的服务
解决方案:
- 确保服务已正确注册
- 检查服务类型是否匹配
- 验证instanceName是否正确
```

**问题2**: 服务依赖循环
```
原因: 服务间存在循环依赖关系
解决方案:
- 重新设计服务架构，打破循环
- 使用事件总线解耦服务间通信
- 考虑合并相关功能到同一服务
```

**问题3**: 初始化失败
```
原因: 服务初始化过程中出现异常
解决方案:
- 启用调试模式查看详细日志
- 检查服务依赖是否满足
- 验证工厂函数的正确性
```

### 调试技巧
```dart
// 启用详细日志
serviceLocator.setDebugMode(true);

// 检查服务状态
final status = serviceLocator.getServiceStatus(MyService);
print('Service status: ${status?.status}');
print('Last updated: ${status?.lastUpdated}');
print('Error: ${status?.errorMessage}');

// 验证依赖图
final graph = serviceLocator.getServiceDependencyGraph();
print('Dependency graph: $graph');

// 获取统计信息
final stats = serviceLocator.getStatistics();
print('Total services: ${stats['totalServices']}');
print('Status breakdown: ${stats['statusBreakdown']}');
```

---

## 依赖关系

### 外部依赖
- `package:get_it/get_it.dart`: 核心依赖注入框架

### 内部依赖
- 当前版本暂时移除了具体服务的导入以避免循环依赖
- 在实际初始化实现中会按需导入相关服务

### 潜在服务依赖
- EventBus: 事件通信系统
- ModuleManager: 模块管理服务
- NavigationService: 导航服务
- 各种Repository: 数据持久化服务
- 安全服务: 认证和加密服务
- 网络服务: API客户端
- 业务模块: PunchIn、NotesHub、Workshop

---

## 版本历史

### v1.0.0 (Step 19 初始版本)
- **核心架构**: 基于GetIt的企业级依赖注入系统
- **类型安全**: 完整的泛型支持和编译时检查
- **状态管理**: 详细的服务状态跟踪和生命周期管理
- **优先级系统**: 5级优先级确保正确的初始化顺序
- **异常处理**: 完善的异常体系和错误信息
- **调试支持**: 详细的调试日志和状态查询
- **便捷函数**: 全局服务获取和可用性检查函数
- **扩展性设计**: 支持运行时服务注册和自定义配置

### 下一步计划
- 完整的服务配置实现
- 自动化依赖验证
- 性能监控和统计
- 配置文件驱动的服务注册 