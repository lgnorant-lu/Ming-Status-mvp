/*
---------------------------------------------------------------
File name:          spatial_os_shell.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        SpatialOsShell空间化OS外壳 - 实现桌面"空间化OS"模式的主要外壳组件
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0b Step 7 - 创建基础结构，Step 8将实现具体功能;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:ui_framework/ui_framework.dart';
import 'window_manager.dart';
import 'app_dock.dart';
import 'performance_monitor_panel.dart';
import 'dev_panel.dart';
import 'types/window_types.dart';

/// SpatialOsShell - 空间化操作系统外壳
/// 
/// 为桌面平台提供类似操作系统的工作环境：
/// - 桌面背景和壁纸系统
/// - 应用程序坞(AppDock)
/// - 窗口管理器集成(WindowManager)
/// - 拖放支持和快捷键系统
class SpatialOsShell extends AppShell {
  /// 窗口管理器实例
  final WindowManager windowManager;
  
  const SpatialOsShell({
    super.key,
    super.localizations,
    super.onLocaleChanged,
    required super.modules,
    required this.windowManager,
  }) : super(shellType: ShellType.spatial);

  @override
  State<SpatialOsShell> createState() => _SpatialOsShellState();
}

class _SpatialOsShellState extends State<SpatialOsShell> {
  /// 性能监控面板可见性状态
  bool _isPerformanceMonitorVisible = false;
  
  /// 开发者工具面板可见性状态
  bool _isDevPanelVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 设置WindowManager的屏幕尺寸
    final screenSize = MediaQuery.of(context).size;
    widget.windowManager.setScreenSize(screenSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 桌面背景层
          _buildDesktopBackground(),
          
          // 窗口管理层 - WindowManager负责管理所有浮动窗口
          _buildWindowLayer(),
          
          // 最小化窗口任务栏 - 固定在底部上方
          _buildTaskBar(),
          
          // 应用程序坞层 - 固定在底部
          _buildAppDock(),
          
          // 性能监控面板 - 浮动在右上角
          PerformanceMonitorPanel(
            windowManager: widget.windowManager,
            isVisible: _isPerformanceMonitorVisible,
            onToggleVisibility: () {
              setState(() {
                _isPerformanceMonitorVisible = !_isPerformanceMonitorVisible;
              });
            },
          ),
          
          // 开发者工具面板 - DevPanel MVP (Sprint 2.0d Step 19)
          if (_isDevPanelVisible)
            Positioned(
              top: 60,
              right: 20,
              child: DevPanel(
                windowManager: widget.windowManager,
                onClose: () {
                  setState(() {
                    _isDevPanelVisible = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 构建桌面背景
  Widget _buildDesktopBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.desktop_windows,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              '桌宠AI助理平台',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phase 2.0 Sprint 2.0b - 空间化OS模式',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建窗口管理层
  Widget _buildWindowLayer() {
    return AnimatedBuilder(
      animation: widget.windowManager,
      builder: (context, child) {
        // 获取所有窗口Widget
        final windows = widget.windowManager.buildWindows(context);
        
        return Stack(
          children: [
            // 窗口管理器状态显示（调试信息）
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WindowManager Status',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        // 开发者工具面板切换按钮 (Step 19)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isDevPanelVisible = !_isDevPanelVisible;
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.developer_mode,
                              size: 16,
                              color: _isDevPanelVisible 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        
                        // 性能监控切换按钮
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isPerformanceMonitorVisible = !_isPerformanceMonitorVisible;
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              _isPerformanceMonitorVisible ? Icons.monitor_outlined : Icons.monitor,
                              size: 16,
                              color: _isPerformanceMonitorVisible 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '活跃窗口: ${widget.windowManager.windowCount}/10\n'
                      '焦点窗口: ${widget.windowManager.focusedWindow ?? "无"}\n'
                      'Step 17: 数据监控面板 ${_isPerformanceMonitorVisible ? "✅" : "📱"}\n'
                      'Step 19: DevPanel开发者工具 ${_isDevPanelVisible ? "✅" : "📱"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 所有浮动窗口
            ...windows,
          ],
        );
      },
    );
  }

  /// 构建最小化窗口任务栏
  Widget _buildTaskBar() {
    return AnimatedBuilder(
      animation: widget.windowManager,
      builder: (context, child) {
        // 获取所有最小化的窗口
        final minimizedWindows = widget.windowManager.activeWindows
            .where((windowId) => 
                widget.windowManager.getWindowState(windowId) == WindowState.minimized)
            .toList();
        
        if (minimizedWindows.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          left: 20,
          right: 20,
          bottom: 80, // 在AppDock上方
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 任务栏标签
                Text(
                  '最小化窗口:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                
                // 最小化窗口按钮列表
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: minimizedWindows.length,
                    itemBuilder: (context, index) {
                      final windowId = minimizedWindows[index];
                      final config = widget.windowManager.getWindowConfig(windowId);
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            // 恢复最小化的窗口
                            widget.windowManager.restoreWindow(windowId);
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.window,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  config?.title ?? windowId,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建应用程序坞
  Widget _buildAppDock() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AppDock(
        modules: widget.modules,
        onModuleTap: _handleModuleTap,
      ),
    );
  }

  /// 处理模块点击事件
  void _handleModuleTap(String moduleId) {
    // 查找对应的模块信息
    final module = widget.modules.firstWhere(
      (m) => m.id == moduleId,
      orElse: () => throw Exception('Module not found: $moduleId'),
    );
    
    // 创建窗口配置
    final windowConfig = WindowConfig(
      windowId: 'window_$moduleId',
      title: module.name,
      content: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 模块头部信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    module.icon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          module.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 模块实际内容
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: module.widgetBuilder(context),
                ),
              ),
            ),
          ],
        ),
      ),
      initialSize: _getModuleWindowSize(moduleId),
      resizable: true,
      draggable: true,
      closable: true,
      minimizable: true,
      maximizable: true,
    );
    
    // 使用WindowManager创建窗口
    widget.windowManager.createWindow(windowConfig).then((success) {
      if (success) {
        // 窗口创建成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已启动 ${module.name} 模块窗口'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        // 窗口创建失败（可能已存在或达到限制）
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${module.name} 窗口已存在或已达到窗口数量限制'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
  }
  
  /// 根据模块ID获取推荐的窗口大小
  Size _getModuleWindowSize(String moduleId) {
    switch (moduleId) {
      case 'home':
        return const Size(500, 400);
      case 'notes_hub':
        return const Size(600, 500);
      case 'workshop':
        return const Size(550, 450);
      case 'punch_in':
        return const Size(400, 350);
      default:
        return const Size(450, 400);
    }
  }
} 