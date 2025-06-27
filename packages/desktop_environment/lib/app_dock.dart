/*
---------------------------------------------------------------
File name:          app_dock.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        AppDock应用程序坞 - 显示模块图标并处理启动事件
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0b Step 7 - 创建基础结构，Step 8将实现具体功能;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:ui_framework/ui_framework.dart';
import 'utils/desktop_utils.dart';

/// AppDock - 应用程序坞
/// 
/// 显示已注册模块的图标列表，类似于macOS的Dock或Windows的任务栏：
/// - 显示模块图标和名称
/// - 处理模块启动事件
/// - 提供视觉反馈和状态指示
/// - 支持动态添加/移除模块
class AppDock extends StatefulWidget {
  /// 注册的模块列表
  final List<ModuleInfo> modules;
  
  /// 模块点击回调
  final Function(String moduleId) onModuleTap;
  
  /// 是否自动隐藏
  final bool autoHide;

  const AppDock({
    super.key,
    required this.modules,
    required this.onModuleTap,
    this.autoHide = false,
  });

  @override
  State<AppDock> createState() => _AppDockState();
}

class _AppDockState extends State<AppDock> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesktopUtils.windowAnimationDuration,
      height: widget.autoHide && !_isHovered 
          ? DesktopUtils.dockHeight * 0.3 
          : DesktopUtils.dockHeight,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phase 2.0 状态指示器
              _buildPhaseIndicator(),
              
              const SizedBox(width: 16),
              
              // 模块图标列表
              ...widget.modules.map((module) => _buildDockItem(module)),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建Phase 2.0状态指示器
  Widget _buildPhaseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Phase 2.0b',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建程序坞项目
  Widget _buildDockItem(ModuleInfo module) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesktopUtils.dockItemSpacing / 2),
      child: Tooltip(
        message: module.description,
        child: InkWell(
          onTap: () => widget.onModuleTap(module.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: DesktopUtils.dockItemSize,
            height: DesktopUtils.dockItemSize,
            decoration: BoxDecoration(
              color: module.isActive 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: module.isActive 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  module.icon,
                  size: 24,
                  color: module.isActive 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 2),
                Text(
                  module.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 8,
                    color: module.isActive 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 