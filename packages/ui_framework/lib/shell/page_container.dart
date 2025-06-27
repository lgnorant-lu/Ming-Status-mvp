/*
---------------------------------------------------------------
File name:          page_container.dart
Author:             Ignorant-lu  
Date created:       2025/06/25
Last modified:      2025/06/25
Dart Version:       3.32.4
Description:        页面容器组件 - 为模块视图提供统一容器、页面切换动画和错误边界
---------------------------------------------------------------
Change History:
    2025/06/25: Initial creation;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 页面切换动画类型
enum PageTransitionType {
  /// 淡入淡出
  fade,
  /// 从右侧滑入
  slideFromRight,
  /// 从左侧滑入
  slideFromLeft,
  /// 从下方滑入
  slideFromBottom,
  /// 缩放效果
  scale,
  /// 无动画
  none,
}

/// 页面容器配置
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

  /// 页面切换动画类型
  final PageTransitionType transitionType;
  
  /// 动画持续时间
  final Duration transitionDuration;
  
  /// 是否启用错误边界
  final bool enableErrorBoundary;
  
  /// 是否启用加载状态
  final bool enableLoading;
  
  /// 是否启用下拉刷新
  final bool enableRefresh;
  
  /// 最大重试次数
  final int maxRetryCount;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 自定义加载widget
  final Widget? loadingWidget;
  
  /// 自定义错误widget
  final Widget? errorWidget;
}

/// 页面状态
enum PageState {
  /// 加载中
  loading,
  /// 内容已加载
  content,
  /// 错误状态
  error,
  /// 空状态
  empty,
}

/// 页面容器 - 为模块视图提供统一的容器和管理功能
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

  /// 页面内容widget
  final Widget child;
  
  /// 页面容器配置
  final PageContainerConfig config;
  
  /// 页面标题
  final String? title;
  
  /// 下拉刷新回调
  final Future<void> Function()? onRefresh;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  /// 初始页面状态
  final PageState initialState;
  
  /// 错误消息
  final String? errorMessage;
  
  /// 是否为空状态
  final bool isEmpty;
  
  /// 空状态消息
  final String emptyMessage;
  
  /// 空状态图标
  final IconData emptyIcon;
  
  /// Hero动画标签
  final String? heroTag;

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer>
    with TickerProviderStateMixin {
  late PageState _currentState;
  String? _currentError;
  int _retryCount = 0;
  
  late AnimationController _transitionController;
  late AnimationController _loadingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
    _currentError = widget.errorMessage;
    
    _setupAnimations();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    // 页面切换动画控制器
    _transitionController = AnimationController(
      duration: widget.config.transitionDuration,
      vsync: this,
    );
    
    // 加载动画控制器
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 淡入淡出动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    // 滑动动画
    _slideAnimation = Tween<Offset>(
      begin: _getSlideOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    ));

    // 缩放动画
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.elasticOut,
    ));

    // 加载动画（旋转）
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_loadingController);

    // 启动动画
    _transitionController.forward();
    if (_currentState == PageState.loading) {
      _loadingController.repeat();
    }
  }

  Offset _getSlideOffset() {
    switch (widget.config.transitionType) {
      case PageTransitionType.slideFromRight:
        return const Offset(1.0, 0.0);
      case PageTransitionType.slideFromLeft:
        return const Offset(-1.0, 0.0);
      case PageTransitionType.slideFromBottom:
        return const Offset(0.0, 1.0);
      default:
        return Offset.zero;
    }
  }

  /// 更新页面状态
  void updateState(PageState newState, {String? errorMessage}) {
    if (mounted && _currentState != newState) {
      setState(() {
        _currentState = newState;
        _currentError = errorMessage;
        
        if (newState == PageState.loading) {
          _loadingController.repeat();
        } else {
          _loadingController.stop();
        }
      });
    }
  }

  /// 重试操作
  void _handleRetry() {
    if (_retryCount < widget.config.maxRetryCount) {
      _retryCount++;
      updateState(PageState.loading);
      widget.onRetry?.call();
    } else {
      _showMaxRetryReachedMessage();
    }
  }

  void _showMaxRetryReachedMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已达到最大重试次数，请稍后再试'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 下拉刷新处理
  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      _retryCount = 0; // 重置重试计数
      updateState(PageState.loading);
      try {
        await widget.onRefresh!();
        updateState(PageState.content);
      } catch (e) {
        updateState(PageState.error, errorMessage: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.config.backgroundColor ?? 
             Theme.of(context).scaffoldBackgroundColor,
      child: widget.config.enableErrorBoundary
          ? _ErrorBoundary(
              child: _buildContent(),
              onError: (error) => updateState(
                PageState.error,
                errorMessage: error.toString(),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    Widget content = _buildStateContent();
    
    // 应用页面切换动画
    content = _applyTransition(content);
    
    // 添加Hero动画（如果指定了heroTag）
    if (widget.heroTag != null) {
      content = Hero(
        tag: widget.heroTag!,
        child: content,
      );
    }
    
    return content;
  }

  Widget _buildStateContent() {
    switch (_currentState) {
      case PageState.loading:
        return _buildLoadingContent();
      case PageState.error:
        return _buildErrorContent();
      case PageState.empty:
        return _buildEmptyContent();
      case PageState.content:
        return _buildMainContent();
    }
  }

  Widget _buildMainContent() {
    Widget content = widget.child;
    
    // 添加下拉刷新功能
    if (widget.config.enableRefresh && widget.onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: _handleRefresh,
        child: content,
      );
    }
    
    return content;
  }

  Widget _buildLoadingContent() {
    if (widget.config.loadingWidget != null) {
      return Center(child: widget.config.loadingWidget!);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _loadingAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _loadingAnimation.value * 2 * 3.14159,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            '加载中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    if (widget.config.errorWidget != null) {
      return Center(child: widget.config.errorWidget!);
    }
    
    return Center(
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
            const SizedBox(height: 16),
            Text(
              '出现错误',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _currentError ?? '未知错误',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _retryCount < widget.config.maxRetryCount
                      ? _handleRetry
                      : null,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    '重试 ($_retryCount/${widget.config.maxRetryCount})',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.emptyIcon,
            size: 64,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          if (widget.onRefresh != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _applyTransition(Widget child) {
    switch (widget.config.transitionType) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        );
      case PageTransitionType.slideFromRight:
      case PageTransitionType.slideFromLeft:
      case PageTransitionType.slideFromBottom:
        return SlideTransition(
          position: _slideAnimation,
          child: child,
        );
      case PageTransitionType.scale:
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      case PageTransitionType.none:
        return child;
    }
  }
}

/// 错误边界组件
class _ErrorBoundary extends StatefulWidget {
  const _ErrorBoundary({
    required this.child,
    required this.onError,
  });

  final Widget child;
  final Function(Object error) onError;

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'UI组件发生错误',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    return ErrorWidgetWrapper(
      onError: (error) {
        setState(() {
          _error = error;
        });
        widget.onError(error);
      },
      child: widget.child,
    );
  }
}

/// 错误Widget包装器
class ErrorWidgetWrapper extends StatelessWidget {
  const ErrorWidgetWrapper({
    super.key,
    required this.child,
    required this.onError,
  });

  final Widget child;
  final Function(Object error) onError;

  @override
  Widget build(BuildContext context) {
    try {
      return child;
    } catch (error) {
      onError(error);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text('渲染错误'),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
  }
}

/// 页面容器工厂类
class PageContainerFactory {
  /// 创建标准页面容器
  static PageContainer createStandard({
    required Widget child,
    String? title,
    Future<void> Function()? onRefresh,
    VoidCallback? onRetry,
  }) {
    return PageContainer(
      config: const PageContainerConfig(
        transitionType: PageTransitionType.fade,
        enableErrorBoundary: true,
        enableLoading: true,
        enableRefresh: true,
      ),
      title: title,
      onRefresh: onRefresh,
      onRetry: onRetry,
      child: child,
    );
  }

  /// 创建快速页面容器（无动画）
  static PageContainer createQuick({
    required Widget child,
    String? title,
  }) {
    return PageContainer(
      config: const PageContainerConfig(
        transitionType: PageTransitionType.none,
        enableErrorBoundary: false,
        enableLoading: false,
        enableRefresh: false,
      ),
      title: title,
      child: child,
    );
  }

  /// 创建模块页面容器
  static PageContainer createModule({
    required Widget child,
    required String moduleName,
    Future<void> Function()? onRefresh,
    VoidCallback? onRetry,
    PageTransitionType transitionType = PageTransitionType.slideFromRight,
  }) {
    return PageContainer(
      config: PageContainerConfig(
        transitionType: transitionType,
        enableErrorBoundary: true,
        enableLoading: true,
        enableRefresh: true,
        maxRetryCount: 5,
      ),
      title: moduleName,
      onRefresh: onRefresh,
      onRetry: onRetry,
      heroTag: 'module_$moduleName',
      child: child,
    );
  }
}

/// PageContainer状态管理扩展
extension PageContainerController on PageContainer {
  /// 显示加载状态
  void showLoading() {
    final state = key as GlobalKey<_PageContainerState>?;
    state?.currentState?.updateState(PageState.loading);
  }

  /// 显示内容
  void showContent() {
    final state = key as GlobalKey<_PageContainerState>?;
    state?.currentState?.updateState(PageState.content);
  }

  /// 显示错误
  void showError(String message) {
    final state = key as GlobalKey<_PageContainerState>?;
    state?.currentState?.updateState(PageState.error, errorMessage: message);
  }

  /// 显示空状态
  void showEmpty() {
    final state = key as GlobalKey<_PageContainerState>?;
    state?.currentState?.updateState(PageState.empty);
  }
} 