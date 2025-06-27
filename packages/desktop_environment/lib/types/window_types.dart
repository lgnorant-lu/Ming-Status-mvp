/*
---------------------------------------------------------------
File name:          window_types.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        窗口系统类型定义 - 定义桌面环境中的基本数据结构和枚举
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0b Step 7 - 创建基础类型定义;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';

/// 窗口状态枚举
enum WindowState {
  /// 正常状态
  normal,
  /// 最小化
  minimized,
  /// 最大化
  maximized,
  /// 隐藏
  hidden,
}

/// 窗口位置和尺寸信息
class WindowGeometry {
  final Offset position;
  final Size size;
  final bool isDragging;
  final bool isResizing;

  const WindowGeometry({
    required this.position,
    required this.size,
    this.isDragging = false,
    this.isResizing = false,
  });

  WindowGeometry copyWith({
    Offset? position,
    Size? size,
    bool? isDragging,
    bool? isResizing,
  }) {
    return WindowGeometry(
      position: position ?? this.position,
      size: size ?? this.size,
      isDragging: isDragging ?? this.isDragging,
      isResizing: isResizing ?? this.isResizing,
    );
  }
}

/// 窗口配置信息
class WindowConfig {
  final String windowId;
  final String title;
  final Widget content;
  final Size initialSize;
  final Offset? initialPosition;
  final bool resizable;
  final bool draggable;
  final bool closable;
  final bool minimizable;
  final bool maximizable;

  const WindowConfig({
    required this.windowId,
    required this.title,
    required this.content,
    this.initialSize = const Size(400, 300),
    this.initialPosition,
    this.resizable = true,
    this.draggable = true,
    this.closable = true,
    this.minimizable = true,
    this.maximizable = true,
  });
}

/// 应用程序坞项目信息
class DockItem {
  final String moduleId;
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;
  final int order;

  const DockItem({
    required this.moduleId,
    required this.title,
    required this.icon,
    this.onTap,
    this.isActive = true,
    this.order = 0,
  });
} 