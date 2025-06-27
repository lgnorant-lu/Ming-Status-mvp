# MainApp API 文档

## 概述

MainApp是整个应用的入口点和启动器，负责企业级应用初始化流程的完整管理。它集成ServiceLocator依赖注入系统，提供6阶段启动流程，确保所有服务和模块的正确初始化。

- **主要功能**: 应用启动流程管理、服务注册、模块加载、错误处理、性能监控
- **设计模式**: 工厂模式 + 建造者模式 + 观察者模式
- **依赖关系**: 依赖于ServiceLocator、AppConfig、所有核心服务
- **位置**: `lib/main.dart`

## 核心类型定义

### AppStartupPhase 枚举
```dart
enum AppStartupPhase {
  initializing,           // 初始化阶段 - Flutter绑定和基础设置
  registeringServices,    // 服务注册阶段 - 注册所有核心服务到ServiceLocator
  initializingServices,   // 服务初始化阶段 - 初始化已注册的服务
  loadingModules,         // 模块加载阶段 - 加载和初始化业务模块
  configuringRoutes,      // 路由配置阶段 - 配置应用路由系统
  startingUI,             // UI启动阶段 - 启动用户界面
  completed,              // 完成阶段 - 应用启动完成
  error,                  // 错误阶段 - 启动过程中发生错误
}
```

### AppStartupConfig 类

### AppStartupConfig
企业级应用启动配置类：

```dart
class AppStartupConfig {
  final bool enableDebugMode;                    // 是否启用调试模式
  final bool enablePerformanceMonitoring;       // 是否启用性能监控
  final int startupTimeoutMs;                    // 启动超时时间（毫秒）
  final bool skipAutoModuleLoading;             // 是否跳过模块自动加载
  final void Function(Object, StackTrace)? errorHandler;    // 自定义错误处理器
  final void Function(AppStartupPhase, String)? phaseCallback; // 启动阶段回调
}
```

**默认配置**:
- `enableDebugMode`: `kDebugMode`
- `enablePerformanceMonitoring`: `false`
- `startupTimeoutMs`: `10000`
- `skipAutoModuleLoading`: `false`

### AppStartupException
启动异常处理类：

```dart
class AppStartupException implements Exception {
  final String message;           // 异常消息
  final AppStartupPhase phase;    // 发生异常的阶段
  final dynamic cause;            // 原始异常原因
}
```

### AppBootstrap 类
```dart
class AppBootstrap {
  static AppStartupPhase currentPhase;           // 当前启动阶段
  static int startupDurationMs;                  // 启动耗时（毫秒）
  static Map<AppStartupPhase, DateTime> phaseTimestamps; // 各阶段时间戳
}
```

### AppStartupException 类
```dart
class AppStartupException implements Exception {
  final String message;           // 异常消息
  final AppStartupPhase phase;    // 发生异常的阶段
  final dynamic cause;            // 原始异常原因
}
```

## 主要接口

### 应用启动管理

#### `AppBootstrap.bootstrap`
- **描述**: 执行完整的6阶段企业级应用启动流程
- **签名**: `static Future<void> bootstrap({AppStartupConfig? config})`
- **参数**: `config` - 可选的启动配置，不提供则使用默认配置
- **异常**: `AppStartupException` - 启动过程中发生错误
- **示例**:
```dart
final config = AppStartupConfig(
  enableDebugMode: true,
  enablePerformanceMonitoring: true,
);
await AppBootstrap.bootstrap(config: config);
```

**启动阶段流程**:
1. **基础初始化** - Flutter绑定、系统UI设置、设备方向配置
2. **服务注册** - 注册所有核心服务到ServiceLocator
3. **服务初始化** - 验证关键服务可用性
4. **模块加载** - 加载和初始化业务模块
5. **路由配置** - 配置应用路由系统
6. **UI启动准备** - 预热关键UI组件

- **描述**: 应用程序主入口点，实现企业级启动流程
- **签名**: `Future<void> main() async`
- **功能**: 配置启动参数，执行bootstrap流程，启动PetApp
- **示例**:
```dart
Future<void> main() async {
  final config = AppStartupConfig(
    enableDebugMode: kDebugMode,
    enablePerformanceMonitoring: true,
    phaseCallback: (phase, message) => debugPrint('[Startup] $phase: $message'),
    errorHandler: (error, stackTrace) => debugPrint('[Startup Error] $error'),
  );

  try {
    await AppBootstrap.bootstrap(config: config);
    runApp(PetApp(debugMode: config.enableDebugMode));
  } catch (e, stackTrace) {
    // 启动失败处理 - 显示错误界面或fallback应用
  }
}
```

## 异常处理

### AppStartupException
```dart
class AppStartupException implements Exception {
  final String message;      // 错误消息
  final AppStartupPhase phase; // 异常阶段
  final dynamic cause;       // 原始异常原因
}
```

**常见异常情况**:
- 服务注册失败
- 模块初始化失败
- 路由配置错误
- UI启动失败
- 启动超时

## 配置与性能

### 内部机制
- **阶段管理**: 使用状态机管理6个启动阶段的转换
- **依赖注入**: 与ServiceLocator集成，统一服务管理
- **错误隔离**: 单个模块失败不影响整体启动流程
- **性能监控**: 详细的阶段时间戳和耗时跟踪

### 性能特性
- **分层初始化**: 按优先级和依赖关系初始化服务
- **懒加载支持**: 非关键服务可延迟初始化
- **内存优化**: 避免重复注册和资源浪费
- **并发处理**: 支持并行初始化无依赖的服务

## 使用最佳实践

1. **配置管理**: 根据环境配置不同的启动参数
2. **错误处理**: 实现完整的启动失败处理和用户反馈
3. **性能监控**: 监控启动时间，优化缓慢的初始化步骤
4. **日志记录**: 保留详细的启动日志用于问题诊断
5. **测试支持**: 提供测试模式配置，跳过非必要初始化

## 版本历史

### v2.0.0 (2025/06/25) - Step 20企业级重构
- **企业级启动器**: 引入6阶段启动流程管理
- **配置系统**: AppStartupConfig和AppStartupException
- **ServiceLocator集成**: 统一的依赖注入管理
- **性能监控**: 详细的阶段时间戳和启动耗时跟踪
- **错误处理**: 完整的异常处理和fallback机制

### v1.1.0 (2025/06/25) - Step 18后期修复
- **架构简化**: 移除PetCore依赖，采用直接模块管理
- **接口优化**: 简化服务初始化流程
- **构造函数修复**: 统一参数传递方式

### v1.0.0 (2025/06/25) - Step 18初始版本
- **基础功能**: 简单的main()函数和MyApp类
- **初步服务**: 基础的服务初始化和模块加载 