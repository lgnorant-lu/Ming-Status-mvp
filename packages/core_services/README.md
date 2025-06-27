# Core Services Package

PetApp核心服务框架包，提供依赖注入、事件总线、模块管理等基础服务架构。

## 概述

`core_services`包是PetApp架构的核心服务层，提供了应用的基础设施服务，包括依赖注入系统、事件总线、模块管理、日志记录、错误处理和性能监控等。这些服务为整个应用提供了统一的基础架构支持。

## 特性

- ✅ **依赖注入系统** - ServiceLocator模式的依赖管理
- ✅ **事件总线** - 松耦合的组件间通信
- ✅ **模块管理** - 动态模块加载和生命周期管理
- ✅ **日志服务** - 结构化日志记录和多输出器支持
- ✅ **错误处理** - 统一的错误处理和恢复机制
- ✅ **性能监控** - 应用性能指标收集和分析

## 安装

在你的`pubspec.yaml`中添加依赖：

```yaml
dependencies:
  core_services:
    path: ../core_services
```

## 核心服务

### 1. 依赖注入系统

使用ServiceLocator模式管理应用依赖。

```dart
import 'package:core_services/core_services.dart';

// 注册服务
ServiceLocator.registerSingleton<UserService>(BasicUserService());
ServiceLocator.registerFactory<HttpClient>(() => HttpClient());

// 使用服务
final userService = ServiceLocator.get<UserService>();
final httpClient = ServiceLocator.get<HttpClient>();

// 检查服务是否已注册
if (ServiceLocator.isRegistered<UserService>()) {
  // 服务已注册
}
```

#### ServiceLocator API

```dart
class ServiceLocator {
  // 注册单例服务
  static void registerSingleton<T>(T service);
  
  // 注册工厂服务
  static void registerFactory<T>(T Function() factory);
  
  // 获取服务实例
  static T get<T>();
  
  // 检查服务是否已注册
  static bool isRegistered<T>();
  
  // 移除服务
  static void unregister<T>();
  
  // 清空所有服务
  static void clear();
}
```

### 2. 事件总线

提供松耦合的组件间通信机制。

```dart
import 'package:core_services/core_services.dart';

// 定义事件
class UserLoginEvent extends AppEvent {
  final String userId;
  const UserLoginEvent(this.userId);
}

// 发送事件
EventBus.instance.fire(UserLoginEvent('user123'));

// 监听事件
EventBus.instance.on<UserLoginEvent>().listen((event) {
  print('用户登录: ${event.userId}');
});
```

#### EventBus API

```dart
class EventBus {
  // 获取单例实例
  static EventBus get instance;
  
  // 发送事件
  void fire(AppEvent event);
  
  // 监听事件
  Stream<T> on<T extends AppEvent>();
  
  // 销毁事件总线
  void destroy();
}
```

### 3. 模块管理

动态管理应用模块的加载和生命周期。

```dart
import 'package:core_services/core_services.dart';

// 实现模块接口
class MyModule implements ModuleInterface {
  @override
  String get name => 'my_module';
  
  @override
  String get version => '1.0.0';
  
  @override
  Future<void> initialize() async {
    // 模块初始化逻辑
  }
  
  @override
  Widget createWidget() {
    return MyModuleWidget();
  }
  
  @override
  void dispose() {
    // 清理资源
  }
}

// 注册模块
ModuleManager.instance.registerModule('my_module', MyModule());

// 获取所有模块
List<ModuleMetadata> modules = ModuleManager.instance.getAllModules();

// 监听模块生命周期事件
ModuleManager.instance.lifecycleEvents.listen((event) {
  print('模块状态变化: ${event.moduleId} -> ${event.newState}');
});
```

#### ModuleManager API

```dart
class ModuleManager {
  // 获取单例实例
  static ModuleManager get instance;
  
  // 注册模块
  void registerModule(String id, ModuleInterface module);
  
  // 获取模块
  ModuleInterface? getModule(String id);
  
  // 获取所有模块
  List<ModuleMetadata> getAllModules();
  
  // 生命周期事件流
  Stream<ModuleLifecycleEvent> get lifecycleEvents;
}
```

### 4. 日志服务

结构化的日志记录系统。

```dart
import 'package:core_services/core_services.dart';

// 获取日志服务
final logger = ServiceLocator.get<LoggingService>();

// 记录不同级别的日志
logger.debug('调试信息', tag: 'DEBUG');
logger.info('普通信息', tag: 'INFO');
logger.warning('警告信息', tag: 'WARN');
logger.error('错误信息', tag: 'ERROR', error: exception);
logger.fatal('严重错误', tag: 'FATAL', error: exception, stackTrace: stackTrace);

// 带额外数据的日志
logger.info('用户操作', tag: 'USER', data: {
  'userId': '123',
  'action': 'login',
  'timestamp': DateTime.now().toIso8601String(),
});

// 配置日志服务
logger.setMinLevel(LogLevel.info);
logger.addOutput(FileLogOutput(filePath: 'app.log'));
```

#### LoggingService API

```dart
abstract class LoggingService {
  // 设置最小日志级别
  void setMinLevel(LogLevel level);
  
  // 添加/移除输出器
  void addOutput(LogOutput output);
  void removeOutput(LogOutput output);
  
  // 记录日志
  void debug(String message, {String? tag, Map<String, dynamic>? data});
  void info(String message, {String? tag, Map<String, dynamic>? data});
  void warning(String message, {String? tag, Map<String, dynamic>? data});
  void error(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  void fatal(String message, {String? tag, Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  // 关闭服务
  void close();
}
```

### 5. 错误处理

统一的错误处理和恢复机制。

```dart
import 'package:core_services/core_services.dart';

// 获取错误处理服务
final errorService = ServiceLocator.get<ErrorHandlingService>();

// 处理不同类型的错误
await errorService.handleNetworkError('网络请求失败');
await errorService.handleBusinessError('业务逻辑错误');
await errorService.handleValidationError('输入验证失败', field: 'email');

// 自定义错误处理器
class CustomErrorHandler implements ErrorHandler {
  @override
  bool canHandle(AppException error) {
    return error.category == ErrorCategory.custom;
  }
  
  @override
  Future<bool> handle(AppException error) async {
    // 自定义处理逻辑
    return true;
  }
}

// 注册自定义错误处理器
errorService.registerHandler(CustomErrorHandler());
```

#### ErrorHandlingService API

```dart
abstract class ErrorHandlingService {
  // 注册组件
  void registerHandler(ErrorHandler handler);
  void registerReporter(ErrorReporter reporter);
  void registerRecoveryStrategy(ErrorRecoveryStrategy strategy);
  
  // 处理错误
  Future<bool> handleError(Object error, [StackTrace? stackTrace]);
  Future<bool> handleAppException(AppException error);
  
  // 便捷方法
  Future<bool> handleBusinessError(String message, {String? code, String? userMessage});
  Future<bool> handleNetworkError(String message, {Object? originalError, String? userMessage});
  Future<bool> handleValidationError(String message, {String? field, String? userMessage});
  
  // 错误恢复和上报
  Future<bool> attemptRecovery(AppException error);
  Future<void> reportError(AppException error);
}
```

### 6. 性能监控

应用性能指标收集和分析。

```dart
import 'package:core_services/core_services.dart';

// 获取性能监控服务
final perfService = ServiceLocator.get<PerformanceMonitoringService>();

// 使用计时器
final timer = perfService.startTimer('database_query');
// 执行业务逻辑
await doSomething();
final metric = timer.stopAndCreateMetric();

// 直接记录指标
perfService.recordDuration('api_call', Duration(milliseconds: 150));
perfService.recordMemoryUsage('heap_usage', 50 * 1024 * 1024); // 50MB
perfService.recordFps('ui_fps', 60.0);
perfService.recordCustomMetric('user_actions', 10, 'count');

// 获取统计信息
final stats = perfService.getStats('api_call');
print('API调用平均时间: ${stats?.average}ms');

// 生成性能报告
final report = perfService.generateReport();
```

#### PerformanceMonitoringService API

```dart
abstract class PerformanceMonitoringService {
  // 配置服务
  void configure(PerformanceMonitoringConfig config);
  
  // 计时器
  PerformanceTimer startTimer(String name, {Map<String, String>? tags});
  
  // 记录指标
  void recordDuration(String name, Duration duration);
  void recordMemoryUsage(String name, int bytes);
  void recordFps(String name, double fps);
  void recordCustomMetric(String name, double value, String unit);
  
  // 统计和报告
  PerformanceStats? getStats(String name);
  Map<String, PerformanceStats> getAllStats();
  Map<String, dynamic> generateReport();
  
  // 清理和控制
  void clearOldMetrics({Duration? olderThan});
  void startAutoReporting();
  void stopAutoReporting();
}
```

## 初始化

在应用启动时初始化核心服务：

```dart
import 'package:core_services/core_services.dart';

Future<void> initializeCoreServices() async {
  // 1. 注册基础服务
  ServiceLocator.registerSingleton<LoggingService>(
    BasicLoggingService(minLevel: LogLevel.info)
  );
  
  ServiceLocator.registerSingleton<ErrorHandlingService>(
    BasicErrorHandlingService()
  );
  
  ServiceLocator.registerSingleton<PerformanceMonitoringService>(
    BasicPerformanceMonitoringService()
  );
  
  // 2. 初始化性能监控
  final perfService = ServiceLocator.get<PerformanceMonitoringService>();
  await perfService.configure(PerformanceMonitoringConfig(
    enabled: true,
    autoReportIntervalMs: 60000, // 1分钟
  ));
  
  // 3. 启动自动报告
  perfService.startAutoReporting();
  
  print('核心服务初始化完成');
}
```

## 最佳实践

### 1. 服务注册

```dart
// ✅ 好的实践 - 在应用启动时注册所有服务
void setupServices() {
  ServiceLocator.registerSingleton<LoggingService>(BasicLoggingService());
  ServiceLocator.registerSingleton<ThemeService>(BasicThemeService());
  ServiceLocator.registerFactory<HttpClient>(() => HttpClient());
}

// ❌ 避免的做法 - 运行时动态注册关键服务
void someFunction() {
  ServiceLocator.registerSingleton<CriticalService>(CriticalService()); // 避免
}
```

### 2. 事件设计

```dart
// ✅ 好的实践 - 事件携带必要信息
class UserLoginEvent extends AppEvent {
  final String userId;
  final DateTime loginTime;
  final String source;
  
  const UserLoginEvent({
    required this.userId,
    required this.loginTime,
    required this.source,
  });
}

// ❌ 避免的做法 - 事件信息不足
class LoginEvent extends AppEvent {
  const LoginEvent(); // 缺少关键信息
}
```

### 3. 错误处理

```dart
// ✅ 好的实践 - 分类处理错误
try {
  await apiCall();
} on NetworkException catch (e) {
  await errorService.handleNetworkError(e.message, originalError: e);
} on ValidationException catch (e) {
  await errorService.handleValidationError(e.message, field: e.field);
} catch (e, stackTrace) {
  await errorService.handleError(e, stackTrace);
}

// ❌ 避免的做法 - 笼统处理错误
try {
  await apiCall();
} catch (e) {
  print('错误: $e'); // 缺少分类和恢复机制
}
```

### 4. 性能监控

```dart
// ✅ 好的实践 - 监控关键操作
Future<User> loadUser(String id) async {
  final timer = perfService.startTimer('load_user', tags: {'method': 'api'});
  try {
    final user = await userApi.getUser(id);
    timer.stopAndCreateMetric();
    return user;
  } catch (e) {
    timer.stopAndCreateMetric();
    rethrow;
  }
}

// ❌ 避免的做法 - 过度监控琐碎操作
String formatName(String name) {
  final timer = perfService.startTimer('format_name'); // 不必要
  final result = name.trim().toLowerCase();
  timer.stopAndCreateMetric();
  return result;
}
```

## 依赖关系

`core_services`包依赖：
- `app_config` - 配置管理

被以下包依赖：
- `app_routing`
- `ui_framework` 
- 所有业务模块包

## 变更历史

### v1.0.0 (2025-06-26)
- ✅ 初始版本发布
- ✅ ServiceLocator依赖注入系统
- ✅ EventBus事件总线
- ✅ ModuleManager模块管理
- ✅ LoggingService日志服务
- ✅ ErrorHandlingService错误处理
- ✅ PerformanceMonitoringService性能监控

## 许可证

本包遵循PetApp项目的许可证协议。

## 贡献

欢迎提交Issue和Pull Request来改进这个包。

## 支持

如有问题，请在项目仓库中提交Issue。 