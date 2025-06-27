# PetApp Phase 1.5 设计原则与最佳实践

## 文档信息
- **版本**: Phase 1.5
- **创建日期**: 2025-06-26
- **最后更新**: 2025-06-26
- **作者**: Ig
- **状态**: 完成

## 概述

本文档总结了PetApp在Phase 1.5架构重构过程中沉淀的设计原则、最佳实践和编码规范，为后续开发提供指导和约束。

## 核心设计原则

### 1. 模块化优先原则

**原则**: 每个功能模块应该是独立、可替换的组件。

**实践指导**:
```dart
// ✅ 好的实践 - 清晰的模块接口
abstract class ModuleInterface {
  String get name;
  String get version;
  List<String> get dependencies;
  
  Future<void> initialize();
  Widget createWidget();
  void dispose();
}

// ❌ 避免的做法 - 模块间直接依赖
class NotesModule {
  // 错误：直接依赖其他模块的具体实现
  final WorkshopModule workshop; // 避免
}
```

**关键要点**:
- 模块间通过接口通信，不直接依赖具体实现
- 每个模块都有清晰的生命周期管理
- 模块应该能够独立开发、测试和部署
- 使用事件总线进行模块间松耦合通信

### 2. 依赖倒置原则

**原则**: 高层模块不应该依赖低层模块，两者都应该依赖于抽象。

**实践指导**:
```dart
// ✅ 好的实践 - 依赖抽象接口
class UserService {
  final LoggingService _logger;
  final StorageService _storage;
  
  UserService(this._logger, this._storage);
}

// ❌ 避免的做法 - 依赖具体实现
class UserService {
  final ConsoleLogger _logger = ConsoleLogger(); // 避免
  final FileStorage _storage = FileStorage();    // 避免
}
```

**依赖注入最佳实践**:
```dart
// 服务注册 - 在应用启动时
void setupServices() {
  ServiceLocator.registerSingleton<LoggingService>(BasicLoggingService());
  ServiceLocator.registerSingleton<StorageService>(LocalStorageService());
  ServiceLocator.registerSingleton<ThemeService>(BasicThemeService());
}

// 服务使用 - 在业务逻辑中
class BusinessLogic {
  late final LoggingService _logger;
  
  BusinessLogic() {
    _logger = ServiceLocator.get<LoggingService>();
  }
}
```

### 3. 单一职责原则

**原则**: 每个类、函数或模块应该只有一个引起它变化的原因。

**实践指导**:
```dart
// ✅ 好的实践 - 职责分离
class ThemeConfig {
  // 只负责主题数据
  final AppThemeMode themeMode;
  final ColorSchemeType colorSchemeType;
  // ...
}

class ThemeService {
  // 只负责主题业务逻辑
  Future<void> setThemeMode(AppThemeMode mode);
  Stream<ThemeConfig> get themeChanges;
}

class ThemeStorage {
  // 只负责主题数据持久化
  Future<void> saveThemeConfig(ThemeConfig config);
  Future<ThemeConfig?> loadThemeConfig();
}

// ❌ 避免的做法 - 职责混合
class ThemeManager {
  // 错误：混合了数据、逻辑和存储职责
  AppThemeMode themeMode;
  Future<void> setThemeMode(AppThemeMode mode) {
    // 直接操作文件系统
    File('theme.json').writeAsString(json.encode({}));
  }
}
```

### 4. 开闭原则

**原则**: 软件实体应该对扩展开放，对修改关闭。

**实践指导**:
```dart
// ✅ 好的实践 - 可扩展的错误处理系统
abstract class ErrorHandler {
  bool canHandle(AppException error);
  Future<bool> handle(AppException error);
}

class ErrorHandlingService {
  final List<ErrorHandler> _handlers = [];
  
  void registerHandler(ErrorHandler handler) {
    _handlers.add(handler); // 扩展：添加新的处理器
  }
  
  Future<bool> handleError(AppException error) {
    // 不需要修改现有代码，通过扩展支持新的错误类型
    for (final handler in _handlers) {
      if (handler.canHandle(error)) {
        return handler.handle(error);
      }
    }
    return false;
  }
}

// 扩展新的错误处理器
class NetworkErrorHandler implements ErrorHandler {
  @override
  bool canHandle(AppException error) => error.category == ErrorCategory.network;
  
  @override
  Future<bool> handle(AppException error) async {
    // 处理网络错误的具体逻辑
  }
}
```

### 5. 里氏替换原则

**原则**: 子类型必须能够替换它们的基类型。

**实践指导**:
```dart
// ✅ 好的实践 - 正确的继承关系
abstract class StorageService {
  Future<String?> getValue(String key);
  Future<void> setValue(String key, String value);
}

class LocalStorageService implements StorageService {
  @override
  Future<String?> getValue(String key) async {
    // 本地存储实现
  }
  
  @override
  Future<void> setValue(String key, String value) async {
    // 本地存储实现
  }
}

class CloudStorageService implements StorageService {
  @override
  Future<String?> getValue(String key) async {
    // 云存储实现
  }
  
  @override
  Future<void> setValue(String key, String value) async {
    // 云存储实现
  }
}

// 客户端代码可以无缝切换实现
StorageService storage = LocalStorageService();
storage = CloudStorageService(); // 完全兼容
```

## 架构设计最佳实践

### 1. 包设计原则

**分层架构**:
```
应用层 (Apps)     ← 业务应用
    ↓
业务层 (Modules)  ← 业务模块
    ↓
框架层 (Framework) ← UI框架、路由
    ↓
服务层 (Services) ← 核心服务
    ↓
配置层 (Config)   ← 基础配置
```

**包命名规范**:
- 使用小写字母和下划线
- 名称应该清晰表达包的职责
- 避免缩写，使用完整单词

**依赖管理**:
```yaml
# ✅ 好的实践 - 清晰的依赖声明
dependencies:
  flutter:
    sdk: flutter
  # 本地包依赖
  core_services:
    path: ../core_services
  # 第三方包依赖（固定版本）
  dio: ^5.3.2

# ❌ 避免的做法 - 模糊的版本范围
dependencies:
  some_package: any  # 避免使用any
  other_package: "*" # 避免使用通配符
```

### 2. 状态管理原则

**响应式数据流**:
```dart
// ✅ 好的实践 - 使用Stream进行状态管理
class ThemeService {
  final StreamController<ThemeConfig> _configController = 
      StreamController<ThemeConfig>.broadcast();
  
  Stream<ThemeConfig> get themeChanges => _configController.stream;
  
  void _notifyChange(ThemeConfig config) {
    _configController.add(config);
  }
}

// UI组件监听状态变化
class ThemeAwareWidget extends StatefulWidget {
  @override
  State<ThemeAwareWidget> createState() => _ThemeAwareWidgetState();
}

class _ThemeAwareWidgetState extends State<ThemeAwareWidget> {
  late StreamSubscription<ThemeConfig> _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = ThemeService.instance.themeChanges.listen((config) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

**状态不可变性**:
```dart
// ✅ 好的实践 - 不可变数据类
class ThemeConfig {
  final AppThemeMode themeMode;
  final ColorSchemeType colorSchemeType;
  
  const ThemeConfig({
    required this.themeMode,
    required this.colorSchemeType,
  });
  
  // 通过复制创建新状态
  ThemeConfig copyWith({
    AppThemeMode? themeMode,
    ColorSchemeType? colorSchemeType,
  }) {
    return ThemeConfig(
      themeMode: themeMode ?? this.themeMode,
      colorSchemeType: colorSchemeType ?? this.colorSchemeType,
    );
  }
}

// ❌ 避免的做法 - 可变状态
class ThemeConfig {
  AppThemeMode themeMode;    // 避免
  ColorSchemeType colorSchemeType; // 避免
}
```

### 3. 错误处理原则

**分层错误处理**:
```dart
// 1. 定义错误类型层次
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final ErrorSeverity severity;
  final ErrorCategory category;
  
  const AppException({
    required this.message,
    this.code,
    this.severity = ErrorSeverity.medium,
    this.category = ErrorCategory.unknown,
  });
}

// 2. 具体错误类型
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
  }) : super(
    severity: ErrorSeverity.medium,
    category: ErrorCategory.network,
  );
}

// 3. 错误处理策略
class NetworkErrorHandler implements ErrorHandler {
  @override
  bool canHandle(AppException error) {
    return error is NetworkException;
  }
  
  @override
  Future<bool> handle(AppException error) async {
    // 1. 记录错误
    logger.error('Network error: ${error.message}');
    
    // 2. 尝试恢复
    if (error.code == 'TIMEOUT') {
      return await _retryRequest();
    }
    
    // 3. 用户友好提示
    _showUserFriendlyMessage(error);
    return true;
  }
}
```

**全局错误边界**:
```dart
// 应用级错误捕获
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(Object error, StackTrace stackTrace)? onError;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  
  @override
  void initState() {
    super.initState();
    
    // 捕获Flutter框架错误
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
      });
      widget.onError?.call(details.exception, details.stack ?? StackTrace.current);
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }
    return widget.child;
  }
}
```

## 编码规范与约定

### 1. 命名规范

**类命名**:
```dart
// ✅ 好的实践
class UserService { }          // 服务类
class ThemeConfig { }          // 数据类
class LoginPage extends StatefulWidget { } // 页面组件
class CustomButton extends StatelessWidget { } // 自定义组件

// ❌ 避免的做法
class userservice { }          // 避免小写
class ThemeConfigData { }      // 避免冗余后缀
class LoginPageWidget { }      // 避免冗余后缀
```

**变量命名**:
```dart
// ✅ 好的实践 - 有意义的名称
final themeService = ServiceLocator.get<ThemeService>();
final userPreferences = await loadUserPreferences();
const maxRetryCount = 3;

// ❌ 避免的做法 - 无意义的名称
final ts = ServiceLocator.get<ThemeService>(); // 避免缩写
final data = await loadUserPreferences();      // 避免泛指
const MAX_RETRY_COUNT = 3;                     // 避免全大写
```

**文件命名**:
```dart
// ✅ 好的实践
theme_service.dart
user_preferences.dart
error_handling_service.dart

// ❌ 避免的做法
ThemeService.dart        // 避免大写开头
theme-service.dart       // 避免连字符
themeservice.dart        // 避免无分隔符
```

### 2. 代码组织

**文件结构**:
```dart
/*
---------------------------------------------------------------
File name:          theme_service.dart
Author:             Development Team
Date created:       2025-06-26
Last modified:      2025-06-26
Description:        主题管理服务实现
---------------------------------------------------------------
*/

// 1. 导入 - 按以下顺序
import 'dart:async';                    // Dart核心库
import 'dart:io';

import 'package:flutter/material.dart'; // Flutter库
import 'package:flutter/services.dart';

import 'package:third_party/third_party.dart'; // 第三方包

import '../core/base_service.dart';     // 相对导入
import '../models/theme_config.dart';

// 2. 常量定义
const Duration _defaultAnimationDuration = Duration(milliseconds: 300);

// 3. 枚举定义
enum ThemeMode { light, dark, system }

// 4. 数据类定义
class ThemeConfig {
  // ...
}

// 5. 接口定义
abstract class ThemeService {
  // ...
}

// 6. 实现类
class BasicThemeService implements ThemeService {
  // ...
}

// 7. 私有类/函数
class _InternalHelper {
  // ...
}
```

**类内结构**:
```dart
class MyService {
  // 1. 静态成员
  static const String version = '1.0.0';
  static MyService? _instance;
  
  // 2. 实例字段
  final String _id;
  late final StreamController<String> _controller;
  
  // 3. 构造函数
  MyService(this._id);
  
  // 4. getter/setter
  String get id => _id;
  
  // 5. 公共方法
  Future<void> initialize() async {
    // ...
  }
  
  void dispose() {
    // ...
  }
  
  // 6. 私有方法
  void _internalMethod() {
    // ...
  }
}
```

### 3. 注释与文档

**类和方法注释**:
```dart
/// 主题管理服务
/// 
/// 提供应用主题的配置、切换和持久化功能。支持浅色/深色主题切换，
/// 多种配色方案，以及用户自定义主题设置。
/// 
/// 使用示例：
/// ```dart
/// final themeService = BasicThemeService();
/// await themeService.initialize();
/// await themeService.setThemeMode(AppThemeMode.dark);
/// ```
abstract class ThemeService {
  /// 设置主题模式
  /// 
  /// [mode] 主题模式，支持浅色、深色或跟随系统
  /// 
  /// 抛出 [StateError] 如果服务未初始化
  Future<void> setThemeMode(AppThemeMode mode);
  
  /// 获取当前主题配置
  /// 
  /// 返回当前生效的主题配置信息
  ThemeConfig get currentConfig;
}

// ✅ 好的注释 - 解释为什么
// 使用延迟初始化避免循环依赖
late final ThemeService _themeService;

// ❌ 避免的注释 - 重复代码信息
// 设置主题模式为深色
await themeService.setThemeMode(AppThemeMode.dark);
```

**TODO和FIXME**:
```dart
// TODO: 实现主题预览功能
// FIXME: 修复主题切换时的闪烁问题
// NOTE: 这里使用了特殊的处理方式以兼容老版本
// HACK: 临时解决方案，等待上游修复
```

## 性能优化最佳实践

### 1. Widget优化

**避免不必要的重建**:
```dart
// ✅ 好的实践 - 使用const构造函数
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Static content'),  // const会被缓存
        SizedBox(height: 16),
      ],
    );
  }
}

// ✅ 好的实践 - 提取静态部分
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // 静态内容提取为字段
  static const Widget _staticHeader = Text('Header');
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _staticHeader,  // 不会重建
        Text('Dynamic: ${DateTime.now()}'),  // 只有这部分重建
      ],
    );
  }
}
```

**合理使用Builder**:
```dart
// ✅ 好的实践 - 局部重建
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar(title: Text('Title')), // 静态内容
      body: Builder(
        builder: (context) {
          // 只有这部分会因为_isLoading变化而重建
          if (_isLoading) {
            return const CircularProgressIndicator();
          }
          return const ContentWidget();
        },
      ),
    );
  }
}
```

### 2. 内存管理

**资源清理**:
```dart
class MyService {
  StreamController<String>? _controller;
  Timer? _timer;
  
  void initialize() {
    _controller = StreamController<String>.broadcast();
    _timer = Timer.periodic(Duration(seconds: 1), _onTimer);
  }
  
  void dispose() {
    // ✅ 好的实践 - 及时清理资源
    _controller?.close();
    _controller = null;
    
    _timer?.cancel();
    _timer = null;
  }
  
  void _onTimer(Timer timer) {
    // ...
  }
}
```

**避免内存泄漏**:
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<String> _subscription;
  
  @override
  void initState() {
    super.initState();
    
    // ✅ 好的实践 - 记录订阅以便清理
    _subscription = someStream.listen(_handleData);
  }
  
  @override
  void dispose() {
    // ✅ 必须取消订阅
    _subscription.cancel();
    super.dispose();
  }
  
  void _handleData(String data) {
    if (mounted) {  // ✅ 检查mounted状态
      setState(() {
        // 更新状态
      });
    }
  }
}
```

## 测试原则与实践

### 1. 单元测试

**测试结构**:
```dart
// test/services/theme_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:my_app/services/theme_service.dart';

void main() {
  group('ThemeService', () {
    late ThemeService themeService;
    late MockThemeStorage mockStorage;
    
    setUp(() {
      mockStorage = MockThemeStorage();
      themeService = BasicThemeService(storage: mockStorage);
    });
    
    tearDown(() {
      themeService.dispose();
    });
    
    group('setThemeMode', () {
      test('should update theme mode and notify listeners', () async {
        // Arrange
        const expectedMode = AppThemeMode.dark;
        
        // Act
        await themeService.setThemeMode(expectedMode);
        
        // Assert
        expect(themeService.currentConfig.themeMode, equals(expectedMode));
        verify(mockStorage.saveThemeConfig(any)).called(1);
      });
      
      test('should throw StateError when not initialized', () {
        // Arrange
        final uninitializedService = BasicThemeService();
        
        // Act & Assert
        expect(
          () => uninitializedService.setThemeMode(AppThemeMode.dark),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
```

**测试原则**:
- 每个测试方法只测试一个场景
- 使用AAA模式：Arrange（准备）、Act（执行）、Assert（断言）
- 测试名称应该清楚描述测试场景
- 使用Mock对象隔离外部依赖

### 2. Widget测试

```dart
// test/widgets/theme_settings_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/widgets/theme_settings.dart';

void main() {
  group('ThemeSettings Widget', () {
    testWidgets('should display all theme options', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSettings(),
        ),
      );
      
      // Act
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('浅色主题'), findsOneWidget);
      expect(find.text('深色主题'), findsOneWidget);
      expect(find.text('跟随系统'), findsOneWidget);
    });
    
    testWidgets('should change theme when option is selected', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: ThemeSettings()),
      );
      
      // Act
      await tester.tap(find.text('深色主题'));
      await tester.pumpAndSettle();
      
      // Assert
      // 验证主题确实发生了变化
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.dark));
    });
  });
}
```

## 国际化最佳实践

### 1. 资源文件管理

**文件组织**:
```
lib/l10n/
├── app_zh.arb          # 中文（简体）
├── app_zh_TW.arb       # 中文（繁体）
├── app_en.arb          # 英文
├── app_ja.arb          # 日文
└── app_ko.arb          # 韩文
```

**ARB文件格式**:
```json
{
  "@@locale": "zh",
  "appTitle": "宠物助手",
  "@appTitle": {
    "description": "应用程序的标题"
  },
  "welcomeUser": "欢迎, {username}!",
  "@welcomeUser": {
    "description": "欢迎用户的消息",
    "placeholders": {
      "username": {
        "type": "String",
        "example": "张三"
      }
    }
  },
  "itemCount": "{count, plural, =0{没有项目} =1{1个项目} other{{count}个项目}}",
  "@itemCount": {
    "description": "项目数量",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "5"
      }
    }
  }
}
```

### 2. 代码中的使用

```dart
// ✅ 好的实践 - 正确使用本地化
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Text(localizations.appTitle),
        Text(localizations.welcomeUser('张三')),
        Text(localizations.itemCount(5)),
      ],
    );
  }
}

// ❌ 避免的做法 - 硬编码字符串
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('宠物助手'),           // 避免硬编码
        Text('欢迎, 张三!'),        // 避免硬编码
        Text('5个项目'),           // 避免硬编码
      ],
    );
  }
}
```

## 总结

以上设计原则和最佳实践构成了PetApp Phase 1.5的技术基石。遵循这些原则可以确保：

1. **代码质量**: 清晰、可维护、可测试的代码
2. **架构稳定**: 模块化、松耦合、高内聚的架构
3. **开发效率**: 标准化的开发流程和规范
4. **用户体验**: 性能优化和国际化支持
5. **团队协作**: 统一的编码标准和文档规范

这些原则将指导PetApp的后续开发，确保项目的长期成功和可持续发展。 