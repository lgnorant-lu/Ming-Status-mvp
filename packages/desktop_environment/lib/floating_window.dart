/*
---------------------------------------------------------------
File name:          floating_window.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        FloatingWindow浮动窗口组件 - 可拖拽、可调整大小的窗口容器
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0b Step 7 - 创建基础结构，Step 9将实现具体功能;
    2025/06/27: Phase 2.0 Sprint 2.0c Step 13 - 实现边缘缩放功能，完善窗口调整大小逻辑;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'types/window_types.dart';
import 'utils/desktop_utils.dart';

/// FloatingWindow - 浮动窗口组件
/// 
/// 提供可拖拽、可调整大小的窗口容器：
/// - 窗口标题栏和控制按钮
/// - 拖拽移动功能
/// - 调整大小功能
/// - 窗口装饰和阴影
/// - 内容区域Widget嵌入
class FloatingWindow extends StatefulWidget {
  /// 窗口配置
  final WindowConfig config;
  
  /// 窗口几何信息
  final WindowGeometry geometry;
  
  /// 窗口状态
  final WindowState windowState;
  
  /// 位置变化回调（拖拽过程中）
  final Function(Offset position)? onPositionChanged;
  
  /// 大小变化回调（调整大小过程中）
  final Function(Size size)? onSizeChanged;
  
  /// 位置拖拽结束回调（启用智能吸附）
  final Function(Offset position)? onPositionDragEnd;
  
  /// 调整大小操作结束回调（处理位置和大小的综合约束）
  final VoidCallback? onResizeEnd;
  
  /// 关闭按钮回调
  final VoidCallback? onClose;
  
  /// 最小化按钮回调
  final VoidCallback? onMinimize;
  
  /// 最大化按钮回调
  final VoidCallback? onMaximize;
  
  /// 拖拽开始回调
  final VoidCallback? onDragStart;
  
  /// 拖拽结束回调
  final VoidCallback? onDragEnd;

  const FloatingWindow({
    super.key,
    required this.config,
    required this.geometry,
    required this.windowState,
    this.onPositionChanged,
    this.onSizeChanged,
    this.onPositionDragEnd,
    this.onResizeEnd,
    this.onClose,
    this.onMinimize,
    this.onMaximize,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  State<FloatingWindow> createState() => _FloatingWindowState();
}

/// 调整大小方向枚举
enum ResizeDirection {
  none,
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

class _FloatingWindowState extends State<FloatingWindow> {
  late Offset _currentPosition;
  late Size _currentSize;
  bool _isDragging = false;
  bool _isResizing = false;
  ResizeDirection _resizeDirection = ResizeDirection.none;
  Offset? _dragStartPosition;
  Offset? _dragStartOffset;
  Size? _resizeStartSize;
  Offset? _resizeStartPosition;
  
  // 性能优化：节流拖拽更新
  DateTime? _lastDragUpdate;
  
  // 边缘检测阈值
  static const double _resizeEdgeThreshold = 8.0;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.geometry.position;
    _currentSize = widget.geometry.size;
  }

  @override
  void didUpdateWidget(FloatingWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.geometry != widget.geometry) {
      _currentPosition = widget.geometry.position;
      _currentSize = widget.geometry.size;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 窗口根据状态调整显示
    if (widget.windowState == WindowState.minimized) {
      return const SizedBox.shrink(); // 最小化时不显示
    }
    
    return Positioned(
      left: _currentPosition.dx,
      top: _currentPosition.dy,
      child: MouseRegion(
        cursor: _getCursor(),
        onHover: _handleMouseHover,
        child: GestureDetector(
          onPanStart: _handleDragStart,
          onPanUpdate: _handleDragUpdate,
          onPanEnd: _handleDragEnd,
          child: Container(
            width: _currentSize.width,
            height: _currentSize.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (_isDragging || _isResizing)
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: (_isDragging || _isResizing) ? 2.0 : DesktopUtils.windowBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: (_isDragging || _isResizing) ? 0.3 : 0.2),
                  blurRadius: (_isDragging || _isResizing) ? 16.0 : DesktopUtils.windowShadowBlur,
                  offset: (_isDragging || _isResizing) ? const Offset(0, 8) : const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 主窗口内容
                Column(
                  children: [
                    // 窗口标题栏 - 拖拽区域
                    _buildTitleBar(),
                    
                    // 窗口内容区域
                    _buildContentArea(),
                  ],
                ),
                
                // 调整大小手柄 (仅在可调整大小时显示)
                if (widget.config.resizable && widget.windowState != WindowState.maximized)
                  ..._buildResizeHandles(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建窗口标题栏
  Widget _buildTitleBar() {
    return Container(
      height: DesktopUtils.titleBarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          // 窗口标题
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.config.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // 控制按钮组
          _buildControlButtons(),
        ],
      ),
    );
  }

  /// 构建控制按钮组
  Widget _buildControlButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 最小化按钮
        if (widget.config.minimizable)
          _buildControlButton(
            icon: Icons.minimize,
            onTap: widget.onMinimize,
            tooltip: '最小化',
          ),
        
        // 最大化按钮  
        if (widget.config.maximizable)
          _buildControlButton(
            icon: widget.windowState == WindowState.maximized 
                ? Icons.fullscreen_exit 
                : Icons.fullscreen,
            onTap: widget.onMaximize,
            tooltip: widget.windowState == WindowState.maximized ? '还原' : '最大化',
          ),
        
        // 关闭按钮
        if (widget.config.closable)
          _buildControlButton(
            icon: Icons.close,
            onTap: widget.onClose,
            tooltip: '关闭',
            isCloseButton: true,
          ),
      ],
    );
  }

  /// 构建单个控制按钮
  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onTap,
    required String tooltip,
    bool isCloseButton = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isCloseButton 
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// 构建窗口内容区域
  Widget _buildContentArea() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // 窗口功能状态信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'FloatingWindow - Sprint 2.0c',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Window ID: ${widget.config.windowId}\n✅ 拖拽移动 ✅ 边缘缩放 ✅ 最小化/最大化 ✅ 智能边界约束 ✅ AppDock保护',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 实际内容（临时被占位符包装）
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
                  child: widget.config.content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理拖拽开始
  void _handleDragStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    final direction = _getResizeDirection(localPosition);
    
    if (direction != ResizeDirection.none && widget.config.resizable) {
      // 开始调整大小
      setState(() {
        _isResizing = true;
        _resizeDirection = direction;
        _dragStartPosition = details.globalPosition;
        _resizeStartSize = _currentSize;
        _resizeStartPosition = _currentPosition;
      });
    } else {
      // 开始拖拽移动
      setState(() {
        _isDragging = true;
        _dragStartPosition = details.globalPosition;
        _dragStartOffset = _currentPosition;
      });
    }
    
    widget.onDragStart?.call();
  }

  /// 处理拖拽更新 - 性能优化版本
  void _handleDragUpdate(DragUpdateDetails details) {
    // 节流拖拽更新以保持≥60fps性能
    final now = DateTime.now();
    if (_lastDragUpdate != null && 
        now.difference(_lastDragUpdate!) < DesktopUtils.dragUpdateThrottle) {
      return;
    }
    _lastDragUpdate = now;

    if (_isResizing) {
      _handleResize(details);
    } else if (_isDragging) {
      _handleDrag(details);
    }
  }

  /// 处理窗口拖拽移动
  void _handleDrag(DragUpdateDetails details) {
    final dragDelta = details.globalPosition - _dragStartPosition!;
    final newPosition = _dragStartOffset! + dragDelta;
    
    setState(() {
      _currentPosition = newPosition;
    });
    
    // 通知父组件位置变化
    widget.onPositionChanged?.call(_currentPosition);
  }

  /// 处理窗口调整大小
  void _handleResize(DragUpdateDetails details) {
    final dragDelta = details.globalPosition - _dragStartPosition!;
    var newSize = _resizeStartSize!;
    var newPosition = _resizeStartPosition!;

    switch (_resizeDirection) {
      case ResizeDirection.right:
        newSize = Size(
          (_resizeStartSize!.width + dragDelta.dx).clamp(DesktopUtils.minWindowWidth, double.infinity),
          newSize.height,
        );
        break;
      case ResizeDirection.bottom:
        newSize = Size(
          newSize.width,
          (_resizeStartSize!.height + dragDelta.dy).clamp(DesktopUtils.minWindowHeight, double.infinity),
        );
        break;
      case ResizeDirection.left:
        final newWidth = (_resizeStartSize!.width - dragDelta.dx).clamp(DesktopUtils.minWindowWidth, double.infinity);
        final widthDelta = newWidth - _resizeStartSize!.width;
        newSize = Size(newWidth, newSize.height);
        newPosition = Offset(_resizeStartPosition!.dx - widthDelta, newPosition.dy);
        break;
      case ResizeDirection.top:
        final newHeight = (_resizeStartSize!.height - dragDelta.dy).clamp(DesktopUtils.minWindowHeight, double.infinity);
        final heightDelta = newHeight - _resizeStartSize!.height;
        newSize = Size(newSize.width, newHeight);
        newPosition = Offset(newPosition.dx, _resizeStartPosition!.dy - heightDelta);
        break;
      case ResizeDirection.bottomRight:
        newSize = Size(
          (_resizeStartSize!.width + dragDelta.dx).clamp(DesktopUtils.minWindowWidth, double.infinity),
          (_resizeStartSize!.height + dragDelta.dy).clamp(DesktopUtils.minWindowHeight, double.infinity),
        );
        break;
      case ResizeDirection.bottomLeft:
        final newWidth = (_resizeStartSize!.width - dragDelta.dx).clamp(DesktopUtils.minWindowWidth, double.infinity);
        final widthDelta = newWidth - _resizeStartSize!.width;
        newSize = Size(
          newWidth,
          (_resizeStartSize!.height + dragDelta.dy).clamp(DesktopUtils.minWindowHeight, double.infinity),
        );
        newPosition = Offset(_resizeStartPosition!.dx - widthDelta, newPosition.dy);
        break;
      case ResizeDirection.topRight:
        final newHeight = (_resizeStartSize!.height - dragDelta.dy).clamp(DesktopUtils.minWindowHeight, double.infinity);
        final heightDelta = newHeight - _resizeStartSize!.height;
        newSize = Size(
          (_resizeStartSize!.width + dragDelta.dx).clamp(DesktopUtils.minWindowWidth, double.infinity),
          newHeight,
        );
        newPosition = Offset(newPosition.dx, _resizeStartPosition!.dy - heightDelta);
        break;
      case ResizeDirection.topLeft:
        final newWidth = (_resizeStartSize!.width - dragDelta.dx).clamp(DesktopUtils.minWindowWidth, double.infinity);
        final newHeight = (_resizeStartSize!.height - dragDelta.dy).clamp(DesktopUtils.minWindowHeight, double.infinity);
        final widthDelta = newWidth - _resizeStartSize!.width;
        final heightDelta = newHeight - _resizeStartSize!.height;
        newSize = Size(newWidth, newHeight);
        newPosition = Offset(
          _resizeStartPosition!.dx - widthDelta,
          _resizeStartPosition!.dy - heightDelta,
        );
        break;
      default:
        break;
    }

    setState(() {
      _currentSize = newSize;
      _currentPosition = newPosition;
    });

    // 通知父组件大小和位置变化
    widget.onSizeChanged?.call(_currentSize);
    widget.onPositionChanged?.call(_currentPosition);
  }

  /// 处理拖拽结束
  void _handleDragEnd(DragEndDetails details) {
    final wasDragging = _isDragging;
    final wasResizing = _isResizing;
    
    setState(() {
      _isDragging = false;
      _isResizing = false;
      _resizeDirection = ResizeDirection.none;
      _dragStartPosition = null;
      _dragStartOffset = null;
      _resizeStartSize = null;
      _resizeStartPosition = null;
    });
    
    widget.onDragEnd?.call();
    
    // 根据操作类型调用相应的结束回调
    if (wasDragging) {
      // 拖拽移动结束 - 启用智能吸附
      widget.onPositionDragEnd?.call(_currentPosition);
    } else if (wasResizing) {
      // 调整大小结束 - 应用综合约束（位置+大小）
      widget.onResizeEnd?.call();
    }
  }

  /// 鼠标悬停处理 - 用于边缘检测
  void _handleMouseHover(PointerEvent event) {
    if (_isDragging || _isResizing || widget.windowState == WindowState.maximized) return;
    
    final localPosition = event.localPosition;
    final newDirection = _getResizeDirection(localPosition);
    
    if (newDirection != _resizeDirection) {
      setState(() {
        _resizeDirection = newDirection;
      });
    }
  }

  /// 获取鼠标光标样式
  MouseCursor _getCursor() {
    switch (_resizeDirection) {
      case ResizeDirection.topLeft:
      case ResizeDirection.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeDirection.top:
      case ResizeDirection.bottom:
        return SystemMouseCursors.resizeUpDown;
      case ResizeDirection.topRight:
      case ResizeDirection.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case ResizeDirection.left:
      case ResizeDirection.right:
        return SystemMouseCursors.resizeLeftRight;
      default:
        return SystemMouseCursors.basic;
    }
  }

  /// 根据鼠标位置确定调整大小方向
  ResizeDirection _getResizeDirection(Offset localPosition) {
    if (!widget.config.resizable) return ResizeDirection.none;
    
    final width = _currentSize.width;
    final height = _currentSize.height;
    final threshold = _resizeEdgeThreshold;
    
    // 角落区域检测
    if (localPosition.dx <= threshold && localPosition.dy <= threshold) {
      return ResizeDirection.topLeft;
    } else if (localPosition.dx >= width - threshold && localPosition.dy <= threshold) {
      return ResizeDirection.topRight;
    } else if (localPosition.dx >= width - threshold && localPosition.dy >= height - threshold) {
      return ResizeDirection.bottomRight;
    } else if (localPosition.dx <= threshold && localPosition.dy >= height - threshold) {
      return ResizeDirection.bottomLeft;
    }
    
    // 边缘区域检测
    if (localPosition.dy <= threshold) {
      return ResizeDirection.top;
    } else if (localPosition.dx >= width - threshold) {
      return ResizeDirection.right;
    } else if (localPosition.dy >= height - threshold) {
      return ResizeDirection.bottom;
    } else if (localPosition.dx <= threshold) {
      return ResizeDirection.left;
    }
    
    return ResizeDirection.none;
  }

  /// 构建调整大小手柄
  List<Widget> _buildResizeHandles() {
    return [
      // 顶部边缘
      _buildResizeHandle(ResizeDirection.top, 
        left: _resizeEdgeThreshold, 
        right: _resizeEdgeThreshold, 
        top: 0, 
        height: _resizeEdgeThreshold
      ),
      // 右边缘
      _buildResizeHandle(ResizeDirection.right, 
        right: 0, 
        top: _resizeEdgeThreshold, 
        bottom: _resizeEdgeThreshold, 
        width: _resizeEdgeThreshold
      ),
      // 底部边缘
      _buildResizeHandle(ResizeDirection.bottom, 
        left: _resizeEdgeThreshold, 
        right: _resizeEdgeThreshold, 
        bottom: 0, 
        height: _resizeEdgeThreshold
      ),
      // 左边缘
      _buildResizeHandle(ResizeDirection.left, 
        left: 0, 
        top: _resizeEdgeThreshold, 
        bottom: _resizeEdgeThreshold, 
        width: _resizeEdgeThreshold
      ),
      
      // 角落手柄 - 更大的可点击区域
      _buildResizeHandle(ResizeDirection.topLeft, 
        left: 0, 
        top: 0, 
        width: _resizeEdgeThreshold * 2, 
        height: _resizeEdgeThreshold * 2
      ),
      _buildResizeHandle(ResizeDirection.topRight, 
        right: 0, 
        top: 0, 
        width: _resizeEdgeThreshold * 2, 
        height: _resizeEdgeThreshold * 2
      ),
      _buildResizeHandle(ResizeDirection.bottomRight, 
        right: 0, 
        bottom: 0, 
        width: _resizeEdgeThreshold * 2, 
        height: _resizeEdgeThreshold * 2
      ),
      _buildResizeHandle(ResizeDirection.bottomLeft, 
        left: 0, 
        bottom: 0, 
        width: _resizeEdgeThreshold * 2, 
        height: _resizeEdgeThreshold * 2
      ),
    ];
  }

  /// 构建单个调整大小手柄
  Widget _buildResizeHandle(
    ResizeDirection direction, {
    double? left,
    double? right,
    double? top,
    double? bottom,
    double? width,
    double? height,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      width: width,
      height: height,
      child: Container(
        // 调试时可以设置颜色查看手柄位置
        // color: Colors.red.withValues(alpha: 0.3),
      ),
    );
  }
} 