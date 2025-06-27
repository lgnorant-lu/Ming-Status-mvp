# NavigationService API 文档

## 概述

NavigationService是应用的核心导航管理服务，负责统一的路由状态管理、历史记录跟踪、模块间导航协调和事件驱动的导航架构。它为Phase 1混合架构提供了可靠的导航基础设施。

- **主要功能**: 路由状态管理、历史记录跟踪、事件驱动导航、Go Router集成、EventBus安全处理
- **设计模式**: 单例模式 + 观察者模式 + 事件驱动
- **依赖关系**: 依赖于go_router、EventBus、BaseItem（支持安全的EventBus可选依赖）
- **位置**: `packages/core_services/lib/services/navigation_service.dart`
- **测试兼容性**: 支持测试环境下的EventBus缺失情况，自动降级处理

## 核心类型定义

### NavigationHistoryItem 类
```dart
class NavigationHistoryItem {
  final String route;              // 路由路径
  final Map<String, String> params; // 路由参数
  final DateTime timestamp;        // 访问时间戳
  final String? moduleId;          // 模块ID
  final String? itemId;           // 项目ID
  final String? title;            // 页面标题
}
```

### NavigationState 类
```dart
class NavigationState {
  final String currentRoute;                    // 当前路由路径
  final Map<String, String> currentParams;     // 当前路由参数
  final List<NavigationHistoryItem> history;   // 导航历史
  final bool canGoBack;                        // 是否可以返回
  final bool canGoForward;                     // 是否可以前进
  final String? currentModuleId;               // 当前模块ID
  final String? currentItemId;                 // 当前项目ID
}
```

### NavigationResult 枚举
```dart
enum NavigationResult {
  success,         // 导航成功
  failed,          // 导航失败
  cancelled,       // 导航被取消
  routeNotFound,   // 路由不存在
  permissionDenied, // 权限拒绝
}
```

### NavigationResponse 类
```dart
class NavigationResponse {
  final NavigationResult result;      // 导航结果
  final String? errorMessage;        // 错误消息
  final Map<String, dynamic>? data;  // 附加数据
  
  bool get isSuccess => result == NavigationResult.success;
  bool get isFailure => result != NavigationResult.success;
}
```

## 主要接口

### 单例管理

#### `NavigationService.instance`
- **描述**: 获取NavigationService的单例实例
- **签名**: `static NavigationService get instance`
- **返回值**: NavigationService实例
- **示例**:
```dart
final navService = NavigationService.instance;
```

### 初始化与配置

#### `initialize`
- **描述**: 初始化导航服务
- **签名**: `Future<void> initialize(GoRouter router)`
- **参数**: `router` - Go Router实例
- **示例**:
```dart
await navService.initialize(AppRouter.router);
```

### 路由状态管理

#### `currentState`
- **描述**: 获取当前导航状态
- **签名**: `NavigationState get currentState`
- **返回值**: 当前导航状态
- **示例**:
```dart
final state = navService.currentState;
print('当前路由: ${state.currentRoute}');
```

#### `stateStream`
- **描述**: 获取导航状态变化流
- **签名**: `Stream<NavigationState> get stateStream`
- **返回值**: 导航状态流
- **示例**:
```dart
navService.stateStream.listen((state) {
  print('导航到: ${state.currentRoute}');
});
```

#### `eventStream`
- **描述**: 获取导航事件流
- **签名**: `Stream<NavigationEvent> get eventStream`
- **返回值**: 导航事件流

### 基础导航操作

#### `navigateTo`
- **描述**: 导航到指定路由
- **签名**: `Future<NavigationResponse> navigateTo(String route, {Map<String, String>? params, Object? extra, bool replace = false})`
- **参数**:
  - `route`: 目标路由路径
  - `params`: 路由参数
  - `extra`: 额外数据
  - `replace`: 是否替换当前路由
- **返回值**: NavigationResponse - 导航操作结果
- **示例**:
```dart
final response = await navService.navigateTo('/profile', 
  params: {'userId': '123'},
  replace: false
);
if (response.isSuccess) {
  print('导航成功');
}
```

#### `navigateToModule`
- **描述**: 导航到指定模块
- **签名**: `Future<NavigationResponse> navigateToModule(String moduleId, {Map<String, String>? params, bool replace = false})`
- **参数**:
  - `moduleId`: 模块ID
  - `params`: 传递参数
  - `replace`: 是否替换当前路由
- **返回值**: NavigationResponse - 导航结果
- **示例**:
```dart
await navService.navigateToModule('punch_in', 
  params: {'action': 'new'}
);
```

#### `navigateToItem`
- **描述**: 导航到特定项目
- **签名**: `Future<NavigationResponse> navigateToItem(String moduleId, String itemId, ItemType itemType, {Map<String, String>? params, bool replace = false})`
- **参数**:
  - `moduleId`: 模块ID
  - `itemId`: 项目ID
  - `itemType`: 项目类型
  - `params`: 额外参数
  - `replace`: 是否替换当前路由
- **示例**:
```dart
await navService.navigateToItem('notes', 'note_123', ItemType.note);
```

#### `goBack`
- **描述**: 返回上一页
- **签名**: `Future<NavigationResponse> goBack()`
- **返回值**: NavigationResponse - 返回操作结果
- **示例**:
```dart
if (navService.currentState.canGoBack) {
  await navService.goBack();
}
```

#### `goHome`
- **描述**: 导航到首页
- **签名**: `Future<NavigationResponse> goHome({bool replace = false})`
- **参数**: `replace` - 是否替换当前路由
- **示例**:
```dart
await navService.goHome(replace: true);
```

### 状态属性

#### `currentRoute`
- **描述**: 获取当前路由
- **签名**: `String get currentRoute`
- **返回值**: 当前路由路径

#### `currentParams`
- **描述**: 获取当前参数
- **签名**: `Map<String, String> get currentParams`
- **返回值**: 当前路由参数

#### `currentModuleId`
- **描述**: 获取当前模块ID
- **签名**: `String? get currentModuleId`
- **返回值**: 当前模块ID（如果有）

#### `currentItemId`
- **描述**: 获取当前项目ID
- **签名**: `String? get currentItemId`
- **返回值**: 当前项目ID（如果有）

## 事件系统

### 导航事件

NavigationService与EventBus深度集成，支持以下事件：

#### 监听的事件
- **NavigateToModuleEvent**: 模块导航请求
- **NavigateToItemEvent**: 项目导航请求
- **NavigateBackEvent**: 返回请求

#### 发布的事件
- **NavigationStateUpdatedEvent**: 导航状态变化

### 事件类型定义

```dart
// 导航到模块事件
class NavigateToModuleEvent extends NavigationEvent {
  final String moduleId;
  final Map<String, String> params;
}

// 导航到项目事件
class NavigateToItemEvent extends NavigationEvent {
  final String moduleId;
  final String itemId;
  final ItemType itemType;
  final Map<String, String> params;
}

// 返回上一页事件
class NavigateBackEvent extends NavigationEvent {
  // 时间戳由基类提供
}

// 导航状态更新事件
class NavigationStateUpdatedEvent extends NavigationEvent {
  final NavigationState state;
}
```

### 事件处理示例
```dart
// 监听导航请求
EventBus.instance.on<NavigateToModuleEvent>().listen((event) {
  navService.navigateToModule(event.moduleId, 
    params: event.params
  );
});

// 发布导航状态变化
EventBus.instance.fire(NavigationStateUpdatedEvent(
  state: currentState,
  timestamp: DateTime.now()
));
```

## Go Router 集成

### 路由变化监听

NavigationService与AppRouter的go_router配置完全兼容：

```dart
// 在路由变化时自动更新NavigationService状态
router.routerDelegate.addListener(_onRouteChanged);
```

### 路由构建助手

```dart
// 构建带参数的路径
String _buildPathWithParams(String route, Map<String, String> params) {
  // 处理路径参数替换
}

// 提取模块ID
String? _extractModuleId(String route) {
  // 从路由路径提取模块标识
}

// 获取模块路由
String _getModuleRoute(String moduleId) {
  // 根据模块ID获取对应路由
}

// 获取项目路由
String _getItemRoute(String moduleId, ItemType itemType) {
  // 根据模块和项目类型获取路由
}
```

## 异常处理

### NavigationServiceException
```dart
class NavigationServiceException implements Exception {
  final String message;        // 错误消息
  final String? route;         // 相关路由
  final dynamic originalError; // 原始错误
}
```

**常见异常情况**:
- 服务未初始化
- 路由不存在
- 导航被中断
- 参数验证失败

### EventBus安全处理机制

NavigationService现在包含了完善的EventBus错误处理机制，确保在各种环境下都能稳定运行：

#### 测试环境兼容性
- **EventBus未注册**: 在单元测试环境中，如果EventBus未注册到GetIt容器，导航服务会自动降级
- **事件监听失败**: EventBus监听器设置失败不会影响核心导航功能
- **事件发布失败**: 状态更新和导航事件发布失败会记录日志但不阻断操作

#### 自动降级处理
```dart
// 示例：安全的EventBus事件监听设置
try {
  EventBus.instance.on<NavigateToModuleEvent>().listen((event) {
    navigateToModule(event.moduleId, params: event.params);
  });
} catch (e) {
  // 自动降级，记录日志但不影响导航功能
  developer.log('EventBus not available during initialization: $e');
}

// 示例：安全的事件发布
try {
  EventBus.instance.fire(NavigationStateUpdatedEvent(
    state: currentState,
    timestamp: DateTime.now(),
  ));
} catch (e) {
  // 事件发布失败不影响状态更新
  developer.log('EventBus not available during state update: $e');
}
```

#### 影响的功能
- **事件监听**: 可能无法接收来自其他模块的导航请求，但直接API调用仍正常
- **状态同步**: 导航状态变化可能无法通知其他组件，但内部状态流仍工作
- **核心导航**: 所有基础导航功能（navigate、goBack等）不受影响

## 内部机制

### 历史管理
- **自动记录**: 导航操作自动添加到历史记录
- **容量限制**: 最大历史记录数量限制
- **状态同步**: 历史状态与Go Router同步

### 状态更新
- **路由监听**: 监听Go Router的路由变化
- **事件发布**: 状态变化自动发布事件
- **流式更新**: 支持状态流订阅

### 性能优化
- **懒加载**: 按需初始化组件
- **事件防抖**: 防止快速重复导航
- **内存管理**: 自动清理过期历史记录

## 使用最佳实践

1. **初始化**: 应用启动时初始化导航服务
2. **状态监听**: 使用stateStream监听导航变化
3. **事件驱动**: 使用事件系统实现模块间导航解耦
4. **错误处理**: 正确处理导航异常和失败情况
5. **历史管理**: 合理使用replace参数避免历史堆积

## 版本历史

- **v1.1.0** (2025-06-25): EventBus安全处理增强 - Step 22测试修复
  - 新增EventBus安全访问机制，支持测试环境下的EventBus缺失
  - 改进`_setupEventListeners`方法，添加try-catch错误处理
  - 增强`_publishStateUpdate`方法，支持EventBus不可用时的降级处理
  - 优化`_publishNavigationEvent`方法，确保事件发布失败不影响核心功能
  - 完善调试日志系统，提供详细的EventBus状态信息
  - 提高测试兼容性，确保单元测试环境下的稳定运行
  - 修复测试用例中的goBack操作验证逻辑

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 基础路由状态管理
  - Go Router集成
  - EventBus事件驱动导航
  - 历史记录管理
  - 模块导航支持 