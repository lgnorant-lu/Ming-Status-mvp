# AppRouter API 文档

## 概述

AppRouter是桌宠应用的核心路由管理组件，基于go_router构建声明式路由系统。它提供基础的页面导航、参数传递、错误处理和占位符页面支持，为整个应用的导航体验提供统一的管理接口。

- **主要功能**: 声明式路由、参数传递、错误处理、占位符页面
- **设计模式**: 静态工厂模式
- **核心技术**: go_router + 自定义路由配置
- **位置**: `packages/app_routing/lib/app_router.dart`

## 核心类定义

### RoutePaths 路由路径常量
```dart
class RoutePaths {
  static const String home = '/';
  static const String punchIn = '/punch-in';
  static const String notesHub = '/notes-hub';
  static const String workshop = '/workshop';
  static const String settings = '/settings';
  static const String about = '/about';
  
  // 模块详情页面（支持参数传递）
  static const String moduleDetail = '/module/:moduleId';
  static const String itemDetail = '/item/:itemId';
}
```

### RouteParams 路由参数管理
```dart
class RouteParams {
  static const String moduleId = 'moduleId';
  static const String itemId = 'itemId';
  static const String returnPath = 'returnPath';
}
```

### AppRouter 核心路由器类
```dart
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => /* 错误页面 */,
    routes: [/* 路由定义 */],
  );

  /// 获取路由器实例
  static GoRouter get router => _router;
  
  /// 导航到指定路径
  static void navigateTo(BuildContext context, String path, {Map<String, String>? queryParameters});
  
  /// 导航到指定路径（新页面入栈）
  static void pushTo(BuildContext context, String path, {Map<String, String>? queryParameters});
  
  /// 返回上一页
  static void goBack(BuildContext context);
}
```

## 主要路由配置

### 核心路由
```dart
routes: [
  // 主页路由
  GoRoute(
    path: RoutePaths.home,
    name: 'home',
    builder: (context, state) => _buildPlaceholderPage(context, '主页', '应用主框架将在此处显示'),
  ),
  
  // 打卡模块路由
  GoRoute(
    path: RoutePaths.punchIn,
    name: 'punch-in',
    builder: (context, state) => _buildPlaceholderPage(context, '打卡模块', '重构后的打卡模块将在此处显示'),
  ),
  
  // 事务管理中心路由
  GoRoute(
    path: RoutePaths.notesHub,
    name: 'notes-hub',
    builder: (context, state) => _buildPlaceholderPage(context, '事务管理中心', '笔记、待办事项和任务管理功能'),
  ),
  
  // 创意工坊路由
  GoRoute(
    path: RoutePaths.workshop,
    name: 'workshop',
    builder: (context, state) => _buildPlaceholderPage(context, '创意工坊', '创意记录、灵感管理和项目孵化功能'),
  ),
  
  // 设置页面路由
  GoRoute(
    path: RoutePaths.settings,
    name: 'settings',
    builder: (context, state) => _buildPlaceholderPage(context, '设置', '应用配置、主题设置和偏好管理'),
  ),
  
  // 关于页面路由
  GoRoute(
    path: RoutePaths.about,
    name: 'about',
    builder: (context, state) => _buildPlaceholderPage(context, '关于', '应用信息、版本号和开发者信息'),
  ),
]
```

### 参数化路由
```dart
// 模块详情页面路由（支持参数传递）
GoRoute(
  path: RoutePaths.moduleDetail,
  name: 'module-detail',
  builder: (context, state) {
    final moduleId = state.pathParameters[RouteParams.moduleId] ?? '';
    final returnPath = state.uri.queryParameters[RouteParams.returnPath];
    
    return _buildPlaceholderPage(
      context,
      '模块详情',
      '模块ID: $moduleId\n返回路径: ${returnPath ?? "未指定"}',
    );
  },
),

// 条目详情页面路由（支持参数传递）
GoRoute(
  path: RoutePaths.itemDetail,
  name: 'item-detail',
  builder: (context, state) {
    final itemId = state.pathParameters[RouteParams.itemId] ?? '';
    final returnPath = state.uri.queryParameters[RouteParams.returnPath];
    
    return _buildPlaceholderPage(
      context,
      '条目详情',
      '条目ID: $itemId\n返回路径: ${returnPath ?? "未指定"}',
    );
  },
),
```

## 错误处理

### 统一错误页面
```dart
errorBuilder: (context, state) => Scaffold(
  appBar: AppBar(
    title: const Text('页面未找到'),
  ),
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text('路径未找到: ${state.uri}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.go(RoutePaths.home),
          child: const Text('返回首页'),
        ),
      ],
    ),
  ),
),
```

## 导航方法

### 基础导航
```dart
/// 导航到指定路径
static void navigateTo(BuildContext context, String path, {Map<String, String>? queryParameters}) {
  if (queryParameters != null && queryParameters.isNotEmpty) {
    final uri = Uri(path: path, queryParameters: queryParameters);
    context.go(uri.toString());
  } else {
    context.go(path);
  }
}

/// 导航到指定路径（新页面入栈）
static void pushTo(BuildContext context, String path, {Map<String, String>? queryParameters}) {
  if (queryParameters != null && queryParameters.isNotEmpty) {
    final uri = Uri(path: path, queryParameters: queryParameters);
    context.push(uri.toString());
  } else {
    context.push(path);
  }
}

/// 返回上一页
static void goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    // 如果无法返回，则导航到首页
    context.go(RoutePaths.home);
  }
}
```

## 占位符页面

### 统一占位符构建
```dart
/// 构建占位符页面的辅助方法
static Widget _buildPlaceholderPage(BuildContext context, String title, String description) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => goBack(context),
                  child: const Text('返回'),
                ),
                ElevatedButton(
                  onPressed: () => navigateTo(context, RoutePaths.home),
                  child: const Text('首页'),
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

## 使用示例

### 基础导航
```dart
// 导航到主页
AppRouter.navigateTo(context, RoutePaths.home);

// 导航到打卡页面
AppRouter.navigateTo(context, RoutePaths.punchIn);

// 导航到模块详情（带参数）
AppRouter.navigateTo(
  context, 
  RoutePaths.moduleDetail.replaceAll(':moduleId', 'punch_in'),
  queryParameters: {'returnPath': '/home'},
);

// 返回上一页
AppRouter.goBack(context);
```

### 路由参数处理
```dart
// 在页面中获取路径参数
final moduleId = GoRouterState.of(context).pathParameters[RouteParams.moduleId];

// 获取查询参数
final returnPath = GoRouterState.of(context).uri.queryParameters[RouteParams.returnPath];
```

## 配置说明

### 路由器配置
- **initialLocation**: 默认启动路径为主页 (`/`)
- **debugLogDiagnostics**: 开发模式下启用路由调试日志
- **errorBuilder**: 统一的404错误页面处理
- **routes**: 声明式路由定义列表

### 扩展性设计
- 占位符页面为Phase 1平台骨架提供基础导航框架
- 支持参数传递和查询参数
- 为后续UI组件集成预留接口
- 统一的导航方法封装，便于全局导航行为管理

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 基础路由配置和导航方法
  - 参数传递和错误处理
  - 占位符页面系统
  - go_router集成 