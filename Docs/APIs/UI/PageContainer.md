# PageContainer API 文档

## 概述

`PageContainer` 是一个高度灵活的页面容器组件，为模块视图提供统一的容器管理、页面切换动画、错误边界保护和状态管理功能。

**文件位置**: `lib/ui/shell/page_container.dart`
**创建日期**: 2025-06-25
**版本**: 1.0.0

## 核心类型定义

### PageTransitionType 枚举

页面切换动画类型枚举：

```dart
enum PageTransitionType {
  fade,                // 淡入淡出
  slideFromRight,      // 从右侧滑入
  slideFromLeft,       // 从左侧滑入
  slideFromBottom,     // 从下方滑入
  scale,              // 缩放效果
  none,               // 无动画
}
```

### PageState 枚举

页面状态枚举：

```dart
enum PageState {
  loading,            // 加载中
  content,            // 内容已加载
  error,              // 错误状态
  empty,              // 空状态
}
```

### PageContainerConfig 配置类

页面容器配置类，控制容器行为和外观：

```dart
class PageContainerConfig {
  const PageContainerConfig({
    this.transitionType = PageTransitionType.fade,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.enableErrorBoundary = true,
    this.enableLoading = true,
    this.enableRefresh = true,
    this.maxRetryCount = 3,
    this.backgroundColor,
    this.loadingWidget,
    this.errorWidget,
  });

  final PageTransitionType transitionType;  // 页面切换动画类型
  final Duration transitionDuration;        // 动画持续时间
  final bool enableErrorBoundary;           // 是否启用错误边界
  final bool enableLoading;                 // 是否启用加载状态
  final bool enableRefresh;                 // 是否启用下拉刷新
  final int maxRetryCount;                  // 最大重试次数
  final Color? backgroundColor;             // 背景颜色
  final Widget? loadingWidget;              // 自定义加载widget
  final Widget? errorWidget;                // 自定义错误widget
}
```

## 主要组件

### PageContainer

主要的页面容器组件：

```dart
class PageContainer extends StatefulWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.config = const PageContainerConfig(),
    this.title,
    this.onRefresh,
    this.onRetry,
    this.initialState = PageState.content,
    this.errorMessage,
    this.isEmpty = false,
    this.emptyMessage = '暂无内容',
    this.emptyIcon = Icons.inbox_outlined,
    this.heroTag,
  });

  final Widget child;                       // 页面内容widget
  final PageContainerConfig config;         // 页面容器配置
  final String? title;                      // 页面标题
  final Future<void> Function()? onRefresh; // 下拉刷新回调
  final VoidCallback? onRetry;              // 重试回调
  final PageState initialState;             // 初始页面状态
  final String? errorMessage;               // 错误消息
  final bool isEmpty;                       // 是否为空状态
  final String emptyMessage;                // 空状态消息
  final IconData emptyIcon;                 // 空状态图标
  final String? heroTag;                    // Hero动画标签
}
```

#### 核心方法

**状态管理方法**:
```dart
// 更新页面状态
void updateState(PageState newState, {String? errorMessage})

// 重试操作
void _handleRetry()

// 下拉刷新处理
Future<void> _handleRefresh()
```

**构建方法**:
```dart
// 构建主要内容
Widget _buildMainContent()

// 构建加载状态内容
Widget _buildLoadingContent()

// 构建错误状态内容
Widget _buildErrorContent()

// 构建空状态内容
Widget _buildEmptyContent()

// 应用页面切换动画
Widget _applyTransition(Widget child)
```

### PageContainerFactory 工厂类

提供便捷的页面容器创建方法：

```dart
class PageContainerFactory {
  // 创建标准页面容器
  static PageContainer createStandard({
    required Widget child,
    String? title,
    Future<void> Function()? onRefresh,
    VoidCallback? onRetry,
  })

  // 创建快速页面容器（无动画）
  static PageContainer createQuick({
    required Widget child,
    String? title,
  })

  // 创建模块页面容器
  static PageContainer createModule({
    required Widget child,
    required String moduleName,
    Future<void> Function()? onRefresh,
    VoidCallback? onRetry,
    PageTransitionType transitionType = PageTransitionType.slideFromRight,
  })
}
```

### PageContainerController 扩展

提供外部状态控制能力：

```dart
extension PageContainerController on PageContainer {
  void showLoading()           // 显示加载状态
  void showContent()           // 显示内容
  void showError(String message) // 显示错误
  void showEmpty()             // 显示空状态
}
```

## 错误处理组件

### _ErrorBoundary

内部错误边界组件，捕获并处理渲染错误：

```dart
class _ErrorBoundary extends StatefulWidget {
  const _ErrorBoundary({
    required this.child,
    required this.onError,
  });

  final Widget child;
  final Function(Object error) onError;
}
```

### ErrorWidgetWrapper

错误Widget包装器，提供渲染错误的兜底处理：

```dart
class ErrorWidgetWrapper extends StatelessWidget {
  const ErrorWidgetWrapper({
    super.key,
    required this.child,
    required this.onError,
  });

  final Widget child;
  final Function(Object error) onError;
}
```

## 功能特性

### 页面切换动画系统

- **6种动画类型**: 淡入淡出、滑动（右/左/下）、缩放、无动画
- **自定义动画时长**: 通过 `transitionDuration` 配置
- **多动画控制器**: 独立的过渡和加载动画控制器
- **流畅动画曲线**: 使用 `Curves.easeInOut`、`Curves.easeOutCubic`、`Curves.elasticOut`

### 状态管理系统

- **4种页面状态**: 加载、内容、错误、空状态
- **状态自动切换**: 根据操作结果自动更新状态
- **状态持久化**: 在组件生命周期内保持状态
- **状态回调**: 支持状态变化监听

### 错误处理机制

- **双层错误边界**: `_ErrorBoundary` + `ErrorWidgetWrapper`
- **智能重试机制**: 最大重试次数限制
- **用户友好错误提示**: 自定义错误消息和操作按钮
- **错误恢复**: 支持错误状态恢复到正常状态

### 交互功能

- **下拉刷新**: 集成 `RefreshIndicator`
- **Hero动画**: 支持页面间平滑过渡
- **手势处理**: 支持返回手势和刷新手势
- **键盘适配**: 自动处理键盘弹出影响

## 使用示例

### 基础用法

```dart
PageContainer(
  child: MyContentWidget(),
  onRefresh: () async {
    // 刷新逻辑
    await fetchData();
  },
  onRetry: () {
    // 重试逻辑
    loadData();
  },
)
```

### 使用工厂方法创建

```dart
// 标准页面容器
final standardContainer = PageContainerFactory.createStandard(
  child: MyWidget(),
  title: '我的页面',
  onRefresh: refreshData,
  onRetry: retryLoad,
);

// 模块页面容器
final moduleContainer = PageContainerFactory.createModule(
  child: ModuleWidget(),
  moduleName: '事务中心',
  transitionType: PageTransitionType.slideFromRight,
  onRefresh: refreshModuleData,
);

// 快速页面容器（无动画）
final quickContainer = PageContainerFactory.createQuick(
  child: SimpleWidget(),
  title: '设置页面',
);
```

### 自定义配置

```dart
PageContainer(
  config: PageContainerConfig(
    transitionType: PageTransitionType.scale,
    transitionDuration: Duration(milliseconds: 500),
    enableErrorBoundary: true,
    enableRefresh: true,
    maxRetryCount: 5,
    backgroundColor: Colors.grey[50],
    loadingWidget: CustomLoadingWidget(),
    errorWidget: CustomErrorWidget(),
  ),
  child: MyContentWidget(),
  initialState: PageState.loading,
  heroTag: 'page_hero',
)
```

### 外部状态控制

```dart
final containerKey = GlobalKey<PageContainerState>();

// 创建带Key的容器
final container = PageContainer(
  key: containerKey,
  child: MyWidget(),
);

// 外部控制状态
void showLoading() {
  container.showLoading();
}

void showError(String message) {
  container.showError(message);
}
```

### 错误状态处理

```dart
PageContainer(
  child: MyContentWidget(),
  initialState: PageState.content,
  errorMessage: '加载失败，请重试',
  onRetry: () {
    // 重试逻辑
    print('重试加载数据');
    loadData();
  },
  config: PageContainerConfig(
    maxRetryCount: 3,
    enableErrorBoundary: true,
  ),
)
```

### 空状态自定义

```dart
PageContainer(
  child: ContentWidget(),
  isEmpty: dataList.isEmpty,
  emptyMessage: '暂无数据',
  emptyIcon: Icons.inbox_outlined,
  onRefresh: () async {
    await loadData();
  },
)
```

## 性能优化

### 动画优化

- **动画控制器生命周期管理**: 自动释放动画资源
- **条件动画**: 根据配置选择性启用动画
- **硬件加速**: 使用GPU加速的动画效果

### 内存管理

- **懒加载**: 状态Widget按需创建
- **资源清理**: 自动清理动画控制器和监听器
- **状态优化**: 避免不必要的状态重建

### 渲染优化

- **Widget复用**: 相同状态下复用Widget实例
- **局部重建**: 最小化受影响的Widget范围
- **异步操作**: 避免阻塞UI线程

## 最佳实践

### 配置建议

1. **根据使用场景选择动画类型**:
   - 主页导航: `PageTransitionType.fade`
   - 模块切换: `PageTransitionType.slideFromRight`
   - 弹出页面: `PageTransitionType.scale`

2. **合理设置重试次数**:
   - 网络请求: 3-5次
   - 本地操作: 1-2次
   - 重要操作: 5-10次

3. **性能优化配置**:
   - 简单页面: 禁用不必要的功能
   - 复杂页面: 启用完整功能
   - 低端设备: 减少动画效果

### 错误处理建议

1. **错误信息用户友好化**:
   - 避免技术术语
   - 提供明确的解决建议
   - 支持多语言

2. **错误恢复策略**:
   - 自动重试机制
   - 降级显示方案
   - 手动恢复选项

3. **错误监控和上报**:
   - 记录错误详情
   - 上报崩溃信息
   - 分析错误趋势

### 性能建议

1. **合理使用Hero动画**:
   - 避免过多并发Hero动画
   - 确保heroTag唯一性
   - 控制动画复杂度

2. **状态管理优化**:
   - 避免频繁状态切换
   - 合并连续状态更新
   - 使用防抖机制

3. **内存使用监控**:
   - 监控动画内存占用
   - 及时释放无用资源
   - 避免内存泄漏

## 注意事项

### 限制说明

1. **动画性能**: 复杂页面的动画可能影响性能
2. **状态一致性**: 外部状态控制需要确保状态同步
3. **错误边界范围**: 仅能捕获渲染时错误，不能捕获异步错误

### 兼容性

- **Flutter版本**: 要求 Flutter 3.0+
- **Dart版本**: 要求 Dart 3.0+
- **平台支持**: Android、iOS、Web、Desktop

### 依赖要求

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.8.1
```

## 版本历史

- **v1.0.0** (2025-06-25): 初始版本
  - 实现基础页面容器功能
  - 支持6种页面切换动画
  - 完整的状态管理系统
  - 双层错误边界保护
  - 工厂方法和扩展支持 