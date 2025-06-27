/*
---------------------------------------------------------------
File name:          dev_panel.dart
Author:             Ignorant-lu
Date created:       2025/01/27
Last modified:      2025/01/27
Description:        开发者工具面板 - 实时显示FloatingWindow状态信息
---------------------------------------------------------------
Change History:
    2025/01/27: Initial creation for Sprint 2.0d Step 19;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'window_manager.dart';
import 'types/window_types.dart';

/// 窗口信息类 - 用于DevPanel显示
class WindowInfo {
  final String id;
  final String title;
  final Offset position;
  final Size size;
  final int zIndex;
  final bool isMaximized;
  final bool isMinimized;

  const WindowInfo({
    required this.id,
    required this.title,
    required this.position,
    required this.size,
    required this.zIndex,
    required this.isMaximized,
    required this.isMinimized,
  });
}

/// 开发者工具面板 - MVP版本
/// 
/// 提供实时的FloatingWindow状态监控，包括：
/// - 窗口位置、大小信息
/// - Z-index层级显示
/// - 窗口状态(最小化/最大化)统计
/// - 开发调试辅助功能
class DevPanel extends StatefulWidget {
  final WindowManager windowManager;
  final VoidCallback? onClose;

  const DevPanel({
    super.key,
    required this.windowManager,
    this.onClose,
  });

  @override
  State<DevPanel> createState() => _DevPanelState();
}

class _DevPanelState extends State<DevPanel> {
  late Timer _refreshTimer;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    // 200ms高频刷新以实时显示窗口状态变化
    _refreshTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  /// 获取活跃窗口信息列表
  List<WindowInfo> _getActiveWindowInfos() {
    final activeWindowIds = widget.windowManager.activeWindows;
    final windowInfos = <WindowInfo>[];
    
    for (int i = 0; i < activeWindowIds.length; i++) {
      final windowId = activeWindowIds[i];
      final config = widget.windowManager.getWindowConfig(windowId);
      final geometry = widget.windowManager.getWindowGeometry(windowId);
      final state = widget.windowManager.getWindowState(windowId);
      
      if (config != null && geometry != null && state != null) {
        windowInfos.add(WindowInfo(
          id: windowId,
          title: config.title,
          position: geometry.position,
          size: geometry.size,
          zIndex: i, // Z-index基于在activeWindows列表中的位置
          isMaximized: state == WindowState.maximized,
          isMinimized: state == WindowState.minimized,
        ));
      }
    }
    
    return windowInfos;
  }

  /// 获取最小化窗口数量
  int _getMinimizedWindowCount() {
    final activeWindowIds = widget.windowManager.activeWindows;
    int count = 0;
    
    for (final windowId in activeWindowIds) {
      final state = widget.windowManager.getWindowState(windowId);
      if (state == WindowState.minimized) {
        count++;
      }
    }
    
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _isCollapsed ? 60 : 320,
      height: _isCollapsed ? 40 : 400,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isCollapsed ? _buildCollapsedView() : _buildExpandedView(),
    );
  }

  Widget _buildCollapsedView() {
    final windowCount = widget.windowManager.windowCount;
    
    return InkWell(
      onTap: () => setState(() => _isCollapsed = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.developer_mode,
              color: Colors.blue,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$windowCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    final activeWindows = _getActiveWindowInfos();
    final minimizedCount = _getMinimizedWindowCount();
    final activeCount = activeWindows.where((w) => !w.isMinimized).length;
    
    return Column(
      children: [
        _buildHeader(),
        _buildStatistics(activeCount, minimizedCount),
        Expanded(
          child: _buildWindowList(activeWindows),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.developer_mode,
            color: Colors.blue,
            size: 16,
          ),
          const SizedBox(width: 6),
          const Text(
            'DevPanel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => setState(() => _isCollapsed = true),
            child: const Icon(
              Icons.remove,
              color: Colors.white70,
              size: 16,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: widget.onClose,
            child: const Icon(
              Icons.close,
              color: Colors.white70,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(int activeCount, int minimizedCount) {
    final totalWindows = widget.windowManager.windowCount;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _buildStatItem('活跃', activeCount, Colors.green),
          const SizedBox(width: 16),
          _buildStatItem('最小化', minimizedCount, Colors.orange),
          const Spacer(),
          Text(
            'Total: $totalWindows',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildWindowList(List<WindowInfo> windows) {
    if (windows.isEmpty) {
      return const Center(
        child: Text(
          '无活跃窗口',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: windows.length,
      itemBuilder: (context, index) {
        final window = windows[index];
        return _buildWindowItem(window, index);
      },
    );
  }

  Widget _buildWindowItem(WindowInfo window, int index) {
    final position = window.position;
    final size = window.size;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: window.isMaximized 
              ? Colors.blue.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getWindowStatusColor(window),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  window.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Z:${window.zIndex}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Pos',
                  '(${position.dx.toInt()}, ${position.dy.toInt()})',
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Size',
                  '${size.width.toInt()}×${size.height.toInt()}',
                ),
              ),
            ],
          ),
          if (window.isMaximized) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.fullscreen,
                  color: Colors.blue,
                  size: 10,
                ),
                const SizedBox(width: 4),
                const Text(
                  '最大化',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Color _getWindowStatusColor(WindowInfo window) {
    if (window.isMaximized) return Colors.blue;
    return Colors.green;
  }
} 