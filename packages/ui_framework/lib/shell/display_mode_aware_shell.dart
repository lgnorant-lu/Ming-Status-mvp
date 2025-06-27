/*
---------------------------------------------------------------
File name:          display_mode_aware_shell.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        DisplayModeAwareShell - 根据DisplayModeService动态选择UI外壳的适配器
---------------------------------------------------------------
Change History:
    2025/06/28: Initial creation - Phase 2.1 三端UI框架的核心适配逻辑;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:core_services/core_services.dart';
import 'package:desktop_environment/desktop_environment.dart';
import 'package:ui_framework/ui_framework.dart';

/// DisplayModeAwareShell - 显示模式感知外壳适配器
/// 
/// 根据DisplayModeService的状态动态选择和切换UI外壳：
/// - Desktop模式 → SpatialOsShell（来自desktop_environment包）
/// - Mobile模式 → StandardAppShell（ui_framework包的现有实现）
/// - Web模式 → ResponsiveWebShell（新创建的Web端适配）
class DisplayModeAwareShell extends StatefulWidget {
  /// 本地化数据
  final MainShellLocalizations? localizations;
  
  /// 语言切换回调
  final Function(Locale)? onLocaleChanged;
  
  /// 注册的模块列表
  final List<ModuleInfo>? modules;

  const DisplayModeAwareShell({
    super.key,
    this.localizations,
    this.onLocaleChanged,
    this.modules,
  });

  @override
  State<DisplayModeAwareShell> createState() => _DisplayModeAwareShellState();
}

class _DisplayModeAwareShellState extends State<DisplayModeAwareShell> {
  late DisplayModeService _displayModeService;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化显示模式服务
    _displayModeService = displayModeService;
    
    // 确保服务已初始化
    _ensureServiceInitialized();
  }

  /// 确保DisplayModeService已初始化
  Future<void> _ensureServiceInitialized() async {
    if (!_displayModeService.isInitialized) {
      await _displayModeService.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果服务未初始化，显示加载界面
    if (!_displayModeService.isInitialized) {
      return const _LoadingShell();
    }
    
    // 监听显示模式变更
    return StreamBuilder<DisplayMode>(
      stream: _displayModeService.currentModeStream,
      initialData: _displayModeService.currentMode,
      builder: (context, snapshot) {
        final displayMode = snapshot.data ?? DisplayMode.mobile;
        
        return _buildShellForMode(displayMode);
      },
    );
  }

  /// 根据当前显示模式构建对应的Shell
  Widget _buildShellForMode(DisplayMode mode) {
    final modules = widget.modules ?? _getDefaultModules();
    
    switch (mode) {
      case DisplayMode.desktop:
        // 桌面模式 - 使用desktop_environment包中的SpatialOsShell
        return SpatialOsShell(
          localizations: widget.localizations,
          onLocaleChanged: widget.onLocaleChanged,
          modules: modules,
          windowManager: WindowManager(), // 创建WindowManager实例
        );
        
      case DisplayMode.mobile:
        // 移动模式 - 使用新的ModularMobileShell（真正的原生模块化应用）
        return ModularMobileShell(
          localizations: widget.localizations,
          onLocaleChanged: widget.onLocaleChanged,
          modules: modules,
        );
        
      case DisplayMode.web:
        // Web模式 - 使用ResponsiveWebShell
        return ResponsiveWebShell(
          localizations: widget.localizations,
          onLocaleChanged: widget.onLocaleChanged,
          modules: modules,
        );
    }
  }

  /// 获取默认模块列表（与AppShell.adaptive()保持一致）
  List<ModuleInfo> _getDefaultModules() {
    return [
      ModuleInfo(
        id: 'home',
        name: '首页',
        description: '应用主页和概览',
        icon: Icons.home,
        widgetBuilder: (context) => const _PlaceholderWidget(title: '首页'),
        order: 0,
      ),
      ModuleInfo(
        id: 'notes_hub',
        name: '事务中心',
        description: '管理您的笔记和任务',
        icon: Icons.note,
        widgetBuilder: (context) => const _PlaceholderWidget(title: '事务中心'),
        order: 1,
      ),
      ModuleInfo(
        id: 'workshop',
        name: '创意工坊',
        description: '记录您的创意和灵感',
        icon: Icons.build,
        widgetBuilder: (context) => const _PlaceholderWidget(title: '创意工坊'),
        order: 2,
      ),
      ModuleInfo(
        id: 'punch_in',
        name: '打卡',
        description: '记录您的考勤时间',
        icon: Icons.access_time,
        widgetBuilder: (context) => const _PlaceholderWidget(title: '打卡'),
        order: 3,
      ),
    ];
  }
}

/// 加载界面（服务初始化时显示）
class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '正在初始化三端UI框架...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Phase 2.1 - 显示模式服务启动中',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 临时占位符Widget（与AppShell保持一致）
class _PlaceholderWidget extends StatelessWidget {
  final String title;
  
  const _PlaceholderWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            '$title 模块',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Phase 2.1 Sprint - 三端UI框架\n模块占位符UI',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
} 