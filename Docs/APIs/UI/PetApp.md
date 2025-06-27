# PetApp API 文档

## 概述

PetApp是桌宠应用的主应用框架组件，负责整个应用的初始化、主题管理、路由集成和基础的错误处理。它基于MaterialApp.router构建，提供简洁的应用生命周期管理和用户体验优化。

- **主要功能**: 应用初始化、主题管理、路由集成、基础错误处理
- **设计模式**: 工厂模式 + 包装器模式
- **核心组件**: MaterialApp.router + 主题系统 + 错误边界
- **位置**: `lib/ui/app.dart`

## 核心组件定义

### PetApp 主应用类
```dart
class PetApp extends StatelessWidget {
  static const String appTitle = '桌宠助手';
  static const String appVersion = '1.0.0-phase1';
  
  final bool debugMode;             // 是否启用调试模式
  final AppRouter? customRouter;    // 自定义路由器（可选，用于测试）

  const PetApp({
    super.key,
    this.debugMode = false,
    this.customRouter,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // === 基础配置 ===
      title: appTitle,
      debugShowCheckedModeBanner: debugMode,
      
      // === 路由配置 ===
      routerConfig: AppRouter.router,
      
      // === 主题配置 ===
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system, // 跟随系统主题
      
      // === 本地化配置 ===
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文简体
        Locale('en', 'US'), // 英文
      ],
      
      // === 全局配置 ===
      builder: (context, child) => _AppWrapper(child: child),
    );
  }
}
```

## 主题系统

### 浅色主题构建
```dart
ThemeData _buildLightTheme() {
  return ThemeData(
    // === 色彩方案 ===
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4), // Material Design 3 紫色
      brightness: Brightness.light,
    ),
    
    // === Material Design 版本 ===
    useMaterial3: true,
    
    // === 字体配置 ===
    fontFamily: 'PingFang SC', // iOS风格字体（Android会回退到系统字体）
    
    // === AppBar主题 ===
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    
    // === 卡片主题 ===
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    
    // === 输入框主题 ===
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    
    // === 按钮主题 ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    
    // === 浮动按钮主题 ===
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
    ),
  );
}
```

### 深色主题构建
```dart
ThemeData _buildDarkTheme() {
  return ThemeData(
    // === 色彩方案 ===
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
    
    // === Material Design 版本 ===
    useMaterial3: true,
    
    // === 字体配置 ===
    fontFamily: 'PingFang SC',
    
    // === AppBar主题 ===
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // === 卡片主题 ===
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    
    // === 输入框主题 ===
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    
    // === 按钮主题 ===
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    
    // === 浮动按钮主题 ===
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
    ),
  );
}
```

## 应用包装器组件

### _AppWrapper 全局包装器
```dart
class _AppWrapper extends StatelessWidget {
  final Widget? child;

  const _AppWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getSystemOverlayStyle(context),
      child: GestureDetector(
        // 点击空白区域收起键盘
        onTap: () => _dismissKeyboard(context),
        child: _ErrorBoundary(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  // 获取系统UI样式
  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }

  // 收起软键盘
  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
    }
  }
}
```

## 错误边界组件

### _ErrorBoundary 错误边界
```dart
class _ErrorBoundary extends StatefulWidget {
  final Widget child;

  const _ErrorBoundary({required this.child});

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    
    // 设置Flutter错误处理器
    FlutterError.onError = (FlutterErrorDetails details) {
      // 在调试模式下打印详细错误信息
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
      
      // 更新错误状态
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    // 如果有错误，显示错误页面
    if (_error != null) {
      return _buildErrorWidget(context);
    }
    
    return widget.child;
  }
}
```

### 错误页面构建
```dart
Widget _buildErrorWidget(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('应用错误'),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              '应用遇到了一个错误',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '我们正在努力修复这个问题。您可以尝试重启应用。',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _clearError,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
                if (kDebugMode)
                  OutlinedButton.icon(
                    onPressed: () => _showErrorDetails(context),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('详情'),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

### 错误处理方法
```dart
void _clearError() {
  setState(() {
    _error = null;
    _stackTrace = null;
  });
}

void _showErrorDetails(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('错误详情'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('错误类型: ${_error.runtimeType}'),
            const SizedBox(height: 8),
            Text('错误信息: ${_error.toString()}'),
            if (_stackTrace != null) ...[
              const SizedBox(height: 16),
              const Text('堆栈跟踪:'),
              const SizedBox(height: 8),
              Text(
                _stackTrace.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}
```

## 应用配置类

### AppConfig 全局配置
```dart
class AppConfig {
  /// 是否启用Material Design 3
  static const bool useMaterial3 = true;
  
  /// 默认动画时长
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  /// 默认页面切换动画时长
  static const Duration pageTransitionDuration = Duration(milliseconds: 200);
  
  /// 是否启用触觉反馈
  static const bool enableHapticFeedback = true;
  
  /// 是否启用声音反馈
  static const bool enableSoundFeedback = false;
  
  /// 最大并发网络请求数
  static const int maxConcurrentRequests = 3;
  
  /// 默认超时时长
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  /// 应用支持的平台特性
  static const Map<String, bool> platformFeatures = {
    'android_back_gesture': true,
    'ios_edge_swipe': true,
    'desktop_keyboard_shortcuts': true,
    'mobile_haptic_feedback': true,
  };
}
```

### DebugConfig 调试配置
```dart
class DebugConfig {
  /// 是否显示性能叠加层
  static const bool showPerformanceOverlay = false;
  
  /// 是否显示语义边界
  static const bool showSemanticsDebugger = false;
  
  /// 是否打印导航日志
  static const bool logNavigationEvents = true;
  
  /// 是否打印网络请求日志
  static const bool logNetworkRequests = true;
  
  /// 是否启用检查器
  static const bool enableInspector = true;
}
```

## 使用示例

### 基础使用
```dart
void main() {
  // 运行应用
  runApp(const PetApp());
}
```

### 调试模式使用
```dart
void main() {
  // 启用调试模式
  runApp(const PetApp(debugMode: true));
}
```

### 测试环境使用
```dart
void main() {
  // 使用自定义路由器进行测试
  final testRouter = MockAppRouter();
  
  runApp(PetApp(
    debugMode: true,
    customRouter: testRouter,
  ));
}
```

### 主题自定义
```dart
class CustomPetApp extends PetApp {
  const CustomPetApp({super.key});

  @override
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue, // 自定义主色调
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      // 其他自定义主题设置...
    );
  }
}
```

## 系统集成

### 系统UI配置
```dart
// 系统UI样式根据主题自动切换
SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.light
      ? SystemUiOverlayStyle.dark  // 浅色主题使用深色状态栏
      : SystemUiOverlayStyle.light; // 深色主题使用浅色状态栏
}
```

### 键盘管理
```dart
// 全局键盘收起功能
void _dismissKeyboard(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.unfocus();
  }
}
```

## 错误处理机制

### 全局错误捕获
- **Flutter框架错误**: 通过FlutterError.onError捕获
- **调试信息**: 调试模式下输出详细错误信息
- **用户友好界面**: 生产环境显示简洁的错误页面
- **错误恢复**: 提供重试机制

### 错误显示策略
- **生产环境**: 显示简洁的错误提示和重试按钮
- **调试环境**: 额外提供错误详情按钮
- **错误重置**: 用户可以重置错误状态继续使用

## 性能特性

### 主题优化
- **Material Design 3**: 使用最新的设计规范
- **自适应主题**: 支持浅色/深色主题自动切换
- **字体回退**: iOS风格字体，Android自动回退

### 动画配置
- **统一时长**: 所有动画使用一致的时长设置
- **性能友好**: 简洁的动画效果，不影响性能

### 路由集成
- **Go Router**: 深度集成声明式路由
- **状态管理**: 路由状态与应用状态同步

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 基础应用框架搭建
  - Material Design 3主题系统
  - Go Router路由集成
  - 基础错误边界处理
  - 系统UI适配
  - 键盘管理功能 