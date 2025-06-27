# App Routing Package

基于 GoRouter 的简单路由管理包，提供基础的声明式路由配置。

## 概述

`app_routing` 包使用 `go_router` 库为应用提供基础的路由功能。当前所有路由都指向占位符页面，等待后续集成实际组件。

## 安装

```yaml
dependencies:
  app_routing:
    path: ../app_routing
```

## 核心组件

### RoutePaths 路径常量

定义了应用的所有路由路径：

```dart
class RoutePaths {
  static const String home = '/';
  static const String punchIn = '/punch-in';
  static const String notesHub = '/notes-hub';
  static const String workshop = '/workshop';
  static const String settings = '/settings';
  static const String about = '/about';
  
  // 带参数的路由
  static const String moduleDetail = '/module/:moduleId';
  static const String itemDetail = '/item/:itemId';
}
```

### RouteParams 参数键名

定义了路由参数的键名常量：

```dart
class RouteParams {
  static const String moduleId = 'moduleId';
  static const String itemId = 'itemId';
  static const String returnPath = 'returnPath';
}
```

### AppRouter 主路由器

提供静态的 GoRouter 实例和导航工具方法：

```dart
class AppRouter {
  static GoRouter get router; // 路由器实例
  
  // 导航方法
  static void navigateTo(BuildContext context, String path, {Map<String, String>? queryParameters});
  static void pushTo(BuildContext context, String path, {Map<String, String>? queryParameters});
  static void goBack(BuildContext context);
}
```

## 路由配置

### 支持的路由

| 路径 | 名称 | 描述 |
|------|------|------|
| `/` | home | 主页占位符 |
| `/punch-in` | punch-in | 打卡模块占位符 |
| `/notes-hub` | notes-hub | 事务管理中心占位符 |
| `/workshop` | workshop | 创意工坊占位符 |
| `/settings` | settings | 设置页面占位符 |
| `/about` | about | 关于页面占位符 |
| `/module/:moduleId` | module-detail | 模块详情占位符 |
| `/item/:itemId` | item-detail | 条目详情占位符 |

### 错误处理

内置错误页面处理，显示"页面未找到"并提供返回首页的按钮。

### 占位符页面

所有路由当前都使用 `_buildPlaceholderPage` 方法生成占位符页面，包含：
- 工程图标
- 页面标题和描述  
- 返回和首页按钮

## 使用方法

### 基础集成

```dart
import 'package:app_routing/app_routing.dart';

// 在 MaterialApp.router 中使用
MaterialApp.router(
  routerConfig: AppRouter.router,
  // ...
)
```

### 导航操作

```dart
import 'package:app_routing/app_routing.dart';

// 使用 AppRouter 静态方法
AppRouter.navigateTo(context, RoutePaths.punchIn);
AppRouter.pushTo(context, RoutePaths.settings);
AppRouter.goBack(context);

// 或直接使用 GoRouter 标准方法
context.go(RoutePaths.home);
context.push(RoutePaths.about);
context.pop();
```

### 带参数的导航

```dart
// 导航到模块详情（路径参数）
context.go('/module/notes');

// 导航到条目详情（路径参数 + 查询参数）
AppRouter.navigateTo(
  context, 
  '/item/123',
  queryParameters: {'returnPath': '/notes'},
);

// 在路由处理器中获取参数
final moduleId = state.pathParameters[RouteParams.moduleId] ?? '';
final returnPath = state.uri.queryParameters[RouteParams.returnPath];
```

## 配置特性

- **初始路由**: 默认为 `/` 主页
- **调试日志**: 开发模式下启用路由调试
- **错误处理**: 自动显示错误页面
- **参数支持**: 支持路径参数和查询参数

## 技术特性

- **基于 GoRouter**: 使用现代声明式路由
- **类型安全**: 强类型的路径和参数常量
- **占位符页面**: 统一的占位符页面设计
- **错误处理**: 内置错误页面和导航恢复
- **参数传递**: 支持路径参数和查询参数

## 依赖关系

- `flutter`: Flutter SDK
- `go_router`: ^14.6.2 - 声明式路由库
- `app_config`: 应用配置包

## 注意事项

- 当前所有路由都指向占位符页面
- 需要后续集成实际的页面组件
- 错误处理会自动重定向到首页
- 支持基础的前进/后退导航

## 功能特性

- **声明式路由配置**: 基于 GoRouter 的现代路由解决方案
- **类型安全导航**: 强类型路由参数和路径
- **层次化路由**: 支持嵌套路由和子路由
- **路由守卫**: 内置权限检查和导航拦截
- **深度链接**: 完整的深度链接支持
- **路由状态管理**: 与应用状态集成的路由管理

## 快速开始

### 1. 基础用法

```dart
import 'package:app_routing/app_routing.dart';

// 获取路由配置
final router = AppRouter.router;

// 在 MaterialApp 中使用
MaterialApp.router(
  routerConfig: router,
  title: 'Pet App',
)
```

### 2. 导航操作

```dart
import 'package:app_routing/app_routing.dart';
import 'package:go_router/go_router.dart';

// 导航到指定路径
context.go('/notes');
context.go('/workshop');
context.go('/punch-in');

// 推送新路由
context.push('/settings');

// 替换当前路由
context.replace('/login');

// 返回上一页
context.pop();
```

## API 参考

### AppRouter 类

路由配置的核心类，提供应用的完整路由定义。

#### 静态属性

- `router: GoRouter` - 获取配置好的 GoRouter 实例

#### 静态方法

- `navigateTo(BuildContext context, String path, {Map<String, String>? queryParameters})` - 导航到指定路径
- `pushTo(BuildContext context, String path, {Map<String, String>? queryParameters})` - 推送新路由
- `goBack(BuildContext context)` - 返回上一页

#### 支持的路由

| 路径 | 组件 | 描述 |
|------|------|------|
| `/` | MainShell | 应用主框架 |
| `/notes` | NotesHub | 笔记中心模块 |
| `/workshop` | Workshop | 创意工坊模块 |
| `/punch-in` | PunchIn | 签到打卡模块 |

### 路由守卫

```dart
// 自定义路由守卫
GoRoute(
  path: '/protected',
  builder: (context, state) => ProtectedPage(),
  redirect: (context, state) {
    // 权限检查逻辑
    if (!userIsAuthenticated) {
      return '/login';
    }
    return null;
  },
)
```

### 路由参数

```dart
// 路径参数
GoRoute(
  path: '/notes/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return NoteDetailPage(noteId: id);
  },
)

// 查询参数
context.go('/notes?search=flutter');
final search = state.uri.queryParameters['search'];
```

## 最佳实践

### 1. 路由常量

建议定义路由路径常量：

```dart
class AppRoutes {
  static const home = '/';
  static const notes = '/notes';
  static const workshop = '/workshop';
  static const punchIn = '/punch-in';
}

// 使用
context.go(AppRoutes.notes);
```

### 2. 类型安全导航

使用扩展方法增强类型安全：

```dart
extension AppNavigation on BuildContext {
  void goToNotes() => go(AppRoutes.notes);
  void goToWorkshop() => go(AppRoutes.workshop);
  void goToPunchIn() => go(AppRoutes.punchIn);
}

// 使用
context.goToNotes();
```

### 3. 路由状态管理

```dart
// 监听路由变化
GoRouter.of(context).routerDelegate.addListener(() {
  final location = GoRouter.of(context).location;
  // 处理路由变化
});
```

### 4. 错误处理

```dart
// 自定义错误页面
GoRouter(
  errorBuilder: (context, state) => ErrorPage(
    error: state.error,
  ),
)
```

## 依赖关系

### 直接依赖
- `flutter`: Flutter SDK
- `go_router`: ^14.6.2 - 现代路由解决方案
- `app_config`: 应用配置包

### 层次位置
```
app_config (基础配置)
    ↓
app_routing (路由层)
    ↓
ui_framework (UI框架层)
    ↓
business_modules (业务模块层)
```

## 配置选项

### 路由配置

可以通过 `AppConfig` 自定义路由行为：

```dart
// 在应用启动时配置
AppConfig.configure(
  enableDeepLinks: true,
  defaultRoute: '/notes',
  debugRouting: false,
);
```

## 故障排除

### 常见问题

1. **路由未找到**
   ```
   错误: No route defined for /unknown
   解决: 确保路由已在 AppRouter 中正确定义
   ```

2. **深度链接不工作**
   ```
   检查: 平台特定的深度链接配置
   Android: android/app/src/main/AndroidManifest.xml
   iOS: ios/Runner/Info.plist
   ```

3. **路由参数类型错误**
   ```
   使用: state.pathParameters 获取字符串参数
   转换: int.parse(state.pathParameters['id']!)
   ```

## 开发与测试

### 运行测试

```bash
cd packages/app_routing
flutter test
```

### 路由调试

启用路由调试信息：

```dart
GoRouter.optionURLReflectsImperativeAPIs = true;
```

## 更新日志

### v1.0.0
- 初始版本发布
- 基础路由配置
- 支持主要业务模块路由
- 集成 GoRouter 14.6.2

## 许可证

本包作为 PetApp 项目的一部分，遵循项目整体许可协议。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个包。请确保：

1. 遵循项目编码规范
2. 添加适当的测试用例
3. 更新相关文档
4. 保持向后兼容性

## 相关资源

- [GoRouter 官方文档](https://pub.dev/packages/go_router)
- [Flutter 导航指南](https://docs.flutter.dev/development/ui/navigation)
- [PetApp 架构文档](../../docs/architecture.md) 