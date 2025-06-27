/*
---------------------------------------------------------------
File name:          window_manager.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        WindowManager窗口管理器 - 管理桌面环境中的浮动窗口生命周期
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0b Step 7 - 创建基础结构;
    2025/06/27: Phase 2.0 Sprint 2.0b Step 9 - 实现完整窗口管理功能;
    2025/06/27: Phase 2.0 Sprint 2.0c Step 14 - 实现智能边界约束和吸附逻辑;
    2025/06/27: Phase 2.0 Sprint 2.0c Step 14 HOTFIX - 修复AppDock区域保护，解决窗口覆盖导致的交互阻塞问题;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'types/window_types.dart';
import 'floating_window.dart';
import 'utils/desktop_utils.dart';

/// 窗口性能配置文件 - 不同性能模式的配置 (Phase 2.3前瞻性接口)
enum WindowPerformanceProfile {
  /// 高性能模式 - 优先体验，适用于重要工作窗口
  highPerformance,
  /// 平衡模式 - 性能与资源使用平衡
  balanced,
  /// 节能模式 - 优先节省资源，适用于后台窗口
  powerSaver,
  /// 自适应模式 - 根据系统状态动态调整
  adaptive,
}

/// WindowManager - 窗口管理器
/// 
/// 负责管理桌面环境中所有浮动窗口的生命周期：
/// - 窗口创建、销毁、显示、隐藏
/// - 窗口状态管理（最小化、最大化、正常）
/// - 窗口拖拽和调整大小
/// - 窗口层级管理（Z-order）
class WindowManager extends ChangeNotifier {
  /// 当前活动的窗口列表（按Z-order排序，最后的在最上层）
  final List<String> _activeWindows = [];
  
  /// 窗口配置映射
  final Map<String, WindowConfig> _windowConfigs = {};
  
  /// 窗口几何信息映射
  final Map<String, WindowGeometry> _windowGeometries = {};
  
  /// 窗口状态映射
  final Map<String, WindowState> _windowStates = {};
  
  /// 当前焦点窗口
  String? _focusedWindow;

  /// 获取活动窗口列表（只读）
  List<String> get activeWindows => List.unmodifiable(_activeWindows);
  
  /// 获取窗口总数
  int get windowCount => _activeWindows.length;
  
  /// 获取当前焦点窗口
  String? get focusedWindow => _focusedWindow;
  
  /// 检查是否达到最大窗口数量限制
  bool get isAtMaxCapacity => windowCount >= DesktopUtils.maxConcurrentWindows;

  /// 创建新窗口
  Future<bool> createWindow(WindowConfig config) async {
    if (_activeWindows.contains(config.windowId)) {
      // 窗口已存在，将其置于顶层并聚焦
      bringToFront(config.windowId);
      return true;
    }
    
    if (isAtMaxCapacity) {
      return false; // 达到最大窗口数量限制
    }
    
    // 计算窗口初始位置（如果未指定）
    final initialPosition = config.initialPosition ?? _calculateNextWindowPosition();
    
    // 记录窗口信息
    _activeWindows.add(config.windowId);
    _windowConfigs[config.windowId] = config;
    _windowStates[config.windowId] = WindowState.normal;
    
    // 设置几何信息
    _windowGeometries[config.windowId] = WindowGeometry(
      position: initialPosition,
      size: config.initialSize,
    );
    
    // 设置为焦点窗口
    _focusedWindow = config.windowId;
    
    notifyListeners();
    return true;
  }

  /// 关闭窗口
  Future<bool> closeWindow(String windowId) async {
    if (!_activeWindows.contains(windowId)) {
      return false;
    }
    
    _activeWindows.remove(windowId);
    _windowConfigs.remove(windowId);
    _windowGeometries.remove(windowId);
    _windowStates.remove(windowId);
    
    // 如果关闭的是焦点窗口，将焦点转移到下一个窗口
    if (_focusedWindow == windowId) {
      _focusedWindow = _activeWindows.isNotEmpty ? _activeWindows.last : null;
    }
    
    notifyListeners();
    return true;
  }

  /// 将窗口置于顶层
  void bringToFront(String windowId) {
    if (_activeWindows.contains(windowId)) {
      _activeWindows.remove(windowId);
      _activeWindows.add(windowId);
      _focusedWindow = windowId;
      notifyListeners();
    }
  }

  /// 最小化窗口
  void minimizeWindow(String windowId) {
    if (_windowStates.containsKey(windowId)) {
      _windowStates[windowId] = WindowState.minimized;
      
      // 如果最小化的是焦点窗口，转移焦点
      if (_focusedWindow == windowId) {
        final visibleWindows = _activeWindows.where(
          (id) => _windowStates[id] != WindowState.minimized
        ).toList();
        _focusedWindow = visibleWindows.isNotEmpty ? visibleWindows.last : null;
      }
      
      notifyListeners();
    }
  }

  /// 最大化窗口
  void maximizeWindow(String windowId) {
    if (_windowStates.containsKey(windowId) && _windowGeometries.containsKey(windowId)) {
      final currentGeometry = _windowGeometries[windowId]!;
      
      // 保存当前几何信息以便恢复
      _windowGeometries['${windowId}_backup'] = currentGeometry;
      
      // 设置最大化状态和全屏几何信息
      _windowStates[windowId] = WindowState.maximized;
      _windowGeometries[windowId] = WindowGeometry(
        position: const Offset(0, 0), // 左上角
        size: getEffectiveScreenSize(), // 全屏尺寸
      );
      
      bringToFront(windowId);
    }
  }

  /// 恢复窗口到正常状态
  void restoreWindow(String windowId) {
    if (_windowStates.containsKey(windowId)) {
      _windowStates[windowId] = WindowState.normal;
      
      // 恢复之前保存的几何信息
      final backupGeometry = _windowGeometries['${windowId}_backup'];
      if (backupGeometry != null) {
        _windowGeometries[windowId] = backupGeometry;
        _windowGeometries.remove('${windowId}_backup');
      }
      
      bringToFront(windowId);
    }
  }

  /// 更新窗口位置（应用智能边界约束）
  void updateWindowPosition(String windowId, Offset position, {bool enableSnapping = true}) {
    final geometry = _windowGeometries[windowId];
    if (geometry != null) {
      // 应用智能边界约束
      final constrainedGeometry = applyIntelligentConstraints(
        position, 
        geometry.size, 
        enableSnapping: enableSnapping,
      );
      
      _windowGeometries[windowId] = constrainedGeometry;
      notifyListeners();
    }
  }

  /// 更新窗口大小（应用智能边界约束）
  void updateWindowSize(String windowId, Size size, {bool enableSnapping = false}) {
    final geometry = _windowGeometries[windowId];
    if (geometry != null) {
      // 应用智能边界约束（调整大小时通常不启用吸附）
      final constrainedGeometry = applyIntelligentConstraints(
        geometry.position, 
        size, 
        enableSnapping: enableSnapping,
      );
      
      _windowGeometries[windowId] = constrainedGeometry;
      notifyListeners();
    }
  }

  /// 同时更新窗口位置和大小（用于调整大小操作）
  void updateWindowGeometry(String windowId, Offset position, Size size, {bool enableSnapping = false}) {
    if (_windowGeometries.containsKey(windowId)) {
      // 应用智能边界约束
      final constrainedGeometry = applyIntelligentConstraints(
        position, 
        size, 
        enableSnapping: enableSnapping,
      );
      
      _windowGeometries[windowId] = constrainedGeometry;
      notifyListeners();
    }
  }

  /// 处理调整大小结束（可能同时影响位置和大小）
  void handleResizeEnd(String windowId) {
    final geometry = _windowGeometries[windowId];
    if (geometry != null) {
      // 应用智能边界约束但不启用吸附
      final constrainedGeometry = applyIntelligentConstraints(
        geometry.position, 
        geometry.size, 
        enableSnapping: false,
      );
      
      _windowGeometries[windowId] = constrainedGeometry;
      notifyListeners();
    }
  }

  /// 构建所有窗口的Widget列表
  List<Widget> buildWindows(BuildContext context) {
    return _activeWindows.map((windowId) {
      final config = _windowConfigs[windowId]!;
      final geometry = _windowGeometries[windowId]!;
      final state = _windowStates[windowId]!;
      
      return FloatingWindow(
        key: ValueKey(windowId),
        config: config,
        geometry: geometry,
        windowState: state,
        // 拖拽过程中：不启用吸附（性能优化）
        onPositionChanged: (position) => updateWindowPosition(windowId, position, enableSnapping: false),
        // 调整大小过程中：不启用吸附
        onSizeChanged: (size) => updateWindowSize(windowId, size, enableSnapping: false),
        // 拖拽结束时：启用智能吸附
        onPositionDragEnd: (position) => updateWindowPosition(windowId, position, enableSnapping: true),
        // 调整大小结束时：应用综合约束（位置+大小）
        onResizeEnd: () => handleResizeEnd(windowId),
        onClose: () => closeWindow(windowId),
        onMinimize: () => minimizeWindow(windowId),
        onMaximize: () {
          if (state == WindowState.maximized) {
            restoreWindow(windowId);
          } else {
            maximizeWindow(windowId);
          }
        },
        onDragStart: () => bringToFront(windowId),
      );
    }).toList();
  }

  /// 计算下一个窗口的默认位置（层叠效果）
  Offset _calculateNextWindowPosition() {
    const baseOffset = Offset(100, 100);
    const stepOffset = Offset(30, 30);
    
    final windowIndex = _activeWindows.length;
    return baseOffset + stepOffset * windowIndex.toDouble();
  }

  /// 获取窗口配置
  WindowConfig? getWindowConfig(String windowId) => _windowConfigs[windowId];

  /// 获取窗口几何信息
  WindowGeometry? getWindowGeometry(String windowId) => _windowGeometries[windowId];

  /// 获取窗口状态
  WindowState? getWindowState(String windowId) => _windowStates[windowId];

  /// 获取屏幕尺寸（用于最大化）
  Size _getScreenSize() {
    // 默认桌面屏幕尺寸，实际应用中可以通过MediaQuery获取
    // 这里使用常见的桌面尺寸作为默认值
    return const Size(1200, 800);
  }

  /// 设置屏幕尺寸（供外部设置真实屏幕尺寸）
  Size? _screenSize;
  void setScreenSize(Size size) {
    _screenSize = size;
  }
  
  /// 获取当前设置的屏幕尺寸
  Size getEffectiveScreenSize() {
    return _screenSize ?? _getScreenSize();
  }

  /// 约束窗口位置以保持在可用边界内
  /// 策略：保护AppDock交互区域，确保标题栏可见且可拖拽
  Offset constrainPosition(Offset position, Size windowSize) {
    final screenSize = getEffectiveScreenSize();
    
    // 标题栏高度（当前在AppDock保护策略中不需要，但保留用于其他约束逻辑）
    // final titleBarHeight = DesktopUtils.titleBarHeight;
    
    // AppDock高度，确保不覆盖AppDock交互区域
    final dockHeight = DesktopUtils.dockHeight;
    
    // 最小可见边距 - 保证用户能够抓住窗口边缘
    const minVisibleMargin = 50.0;
    
    // X轴约束：允许窗口大部分超出，但保留足够抓取的区域
    double constrainedX = position.dx;
    if (constrainedX > screenSize.width - minVisibleMargin) {
      constrainedX = screenSize.width - minVisibleMargin;
    } else if (constrainedX < -(windowSize.width - minVisibleMargin)) {
      constrainedX = -(windowSize.width - minVisibleMargin);
    }
    
    // Y轴约束：保护AppDock区域和标题栏可见性
    double constrainedY = position.dy;
    
    // 上边界：不允许标题栏超出屏幕顶部
    if (constrainedY < 0) {
      constrainedY = 0;
    }
    
    // 下边界：确保窗口不覆盖AppDock区域
    final maxBottomPosition = screenSize.height - dockHeight - windowSize.height;
    if (constrainedY > maxBottomPosition) {
      constrainedY = maxBottomPosition;
    }
    
    // 特殊情况：如果窗口太高导致无法同时满足上下约束，优先保护AppDock
    if (constrainedY < 0) {
      constrainedY = 0;
      // 此时窗口可能会覆盖AppDock，但这比标题栏不可见更好
      // 实际上这种情况应该在constrainSize中被处理
    }
    
    return Offset(constrainedX, constrainedY);
  }

  /// 约束窗口大小以保持在可用边界内
  /// 考虑屏幕大小、AppDock保护区域和最小窗口尺寸
  Size constrainSize(Size size, Offset position) {
    final screenSize = getEffectiveScreenSize();
    final dockHeight = DesktopUtils.dockHeight;
    
    // 可用屏幕高度（扣除AppDock区域）
    final availableHeight = screenSize.height - dockHeight;
    
    // 应用最小和最大尺寸约束
    double constrainedWidth = size.width.clamp(
      DesktopUtils.minWindowWidth, 
      screenSize.width * 0.95, // 最大不超过屏幕95%
    );
    
    double constrainedHeight = size.height.clamp(
      DesktopUtils.minWindowHeight,
      availableHeight * 0.95, // 最大不超过可用高度的95%
    );
    
    // 如果窗口在特定位置会超出屏幕，则调整大小
    if (position.dx + constrainedWidth > screenSize.width + 50) {
      constrainedWidth = (screenSize.width + 50 - position.dx).clamp(
        DesktopUtils.minWindowWidth, 
        constrainedWidth,
      );
    }
    
    // 检查是否会覆盖AppDock区域
    if (position.dy + constrainedHeight > availableHeight) {
      constrainedHeight = (availableHeight - position.dy).clamp(
        DesktopUtils.minWindowHeight,
        constrainedHeight,
      );
    }
    
    return Size(constrainedWidth, constrainedHeight);
  }

  /// 智能吸附逻辑 - 当窗口接近屏幕边缘时自动对齐（保护AppDock区域）
  Offset applySnapLogic(Offset position, Size windowSize) {
    final screenSize = getEffectiveScreenSize();
    final dockHeight = DesktopUtils.dockHeight;
    const snapThreshold = 15.0; // 吸附阈值（像素）
    
    // 可用屏幕高度（扣除AppDock区域）
    final availableHeight = screenSize.height - dockHeight;
    
    double snappedX = position.dx;
    double snappedY = position.dy;
    
    // X轴吸附
    if ((position.dx - 0).abs() <= snapThreshold) {
      snappedX = 0; // 吸附到左边缘
    } else if ((position.dx + windowSize.width - screenSize.width).abs() <= snapThreshold) {
      snappedX = screenSize.width - windowSize.width; // 吸附到右边缘
    }
    
    // Y轴吸附（保护AppDock区域）
    if ((position.dy - 0).abs() <= snapThreshold) {
      snappedY = 0; // 吸附到顶部边缘
    } else if ((position.dy + windowSize.height - availableHeight).abs() <= snapThreshold) {
      snappedY = availableHeight - windowSize.height; // 吸附到AppDock上方边缘
    }
    
    return Offset(snappedX, snappedY);
  }

  /// 应用智能边界约束（组合位置约束、大小约束和吸附逻辑）
  WindowGeometry applyIntelligentConstraints(Offset position, Size size, {bool enableSnapping = true}) {
    // 1. 先约束大小
    final constrainedSize = constrainSize(size, position);
    
    // 2. 约束位置
    var constrainedPosition = constrainPosition(position, constrainedSize);
    
    // 3. 应用智能吸附（可选）
    if (enableSnapping) {
      constrainedPosition = applySnapLogic(constrainedPosition, constrainedSize);
    }
    
    return WindowGeometry(
      position: constrainedPosition,
      size: constrainedSize,
    );
  }

  /// 清空所有窗口
  void closeAllWindows() {
    _activeWindows.clear();
    _windowConfigs.clear();
    _windowGeometries.clear();
    _windowStates.clear();
    _focusedWindow = null;
    notifyListeners();
  }

  // ========== 前瞻性接口 (Phase 2.3+扩展预留) ==========

  /// 自适应性能调度器接口 (Adaptive Performance Scheduler) - Phase 2.3目标
  /// 
  /// 为未来实现智能窗口性能调度功能预留接口
  /// 支持基于系统负载、硬件能力和用户行为的动态性能优化
  ///
  /// 预期功能:
  /// - 智能帧率调节（低负载时提升体验，高负载时保证稳定）
  /// - 基于使用模式的窗口资源分配
  /// - 自适应渲染质量调整
  /// - 内存使用优化和垃圾回收调度
  // DEBT-PERF-004: 窗口性能调度器接口预留 - Phase 2.3实现

  /// 性能调度器状态
  bool _performanceSchedulerEnabled = false;
  // TODO: Phase 2.3 - 实现全局性能配置文件应用逻辑
  // WindowPerformanceProfile _globalPerformanceProfile = WindowPerformanceProfile.balanced;
  final Map<String, WindowPerformanceProfile> _windowPerformanceProfiles = {};

  /// 启用/禁用性能调度器
  /// [enabled] - 是否启用性能调度器
  void setPerformanceSchedulerEnabled(bool enabled) {
    // TODO: Phase 2.3 - 实现性能调度器的启用/禁用逻辑
    _performanceSchedulerEnabled = enabled;
    
    // 启用时开始性能监控，禁用时恢复默认行为
    if (enabled) {
      _startPerformanceMonitoring();
    } else {
      _stopPerformanceMonitoring();
    }
  }

  /// 设置全局性能配置文件
  /// [profile] - 性能配置文件
  void setGlobalPerformanceProfile(WindowPerformanceProfile profile) {
    // TODO: Phase 2.3 - 应用全局性能配置
    // _globalPerformanceProfile = profile;
    
    // 将配置应用到所有没有特定配置的窗口
    for (final windowId in _activeWindows) {
      if (!_windowPerformanceProfiles.containsKey(windowId)) {
        _applyPerformanceProfile(windowId, profile);
      }
    }
  }

  /// 为特定窗口设置性能配置文件
  /// [windowId] - 窗口标识符
  /// [profile] - 性能配置文件
  void setWindowPerformanceProfile(String windowId, WindowPerformanceProfile profile) {
    // TODO: Phase 2.3 - 为特定窗口应用性能配置
    if (_activeWindows.contains(windowId)) {
      _windowPerformanceProfiles[windowId] = profile;
      _applyPerformanceProfile(windowId, profile);
    }
  }

  /// 获取窗口性能指标
  /// [windowId] - 窗口标识符
  /// 
  /// 返回窗口的实时性能数据
  Map<String, dynamic> getWindowPerformanceMetrics(String windowId) {
    // TODO: Phase 2.3 - 收集并返回窗口性能指标
    // 包括：渲染帧率、内存使用、CPU占用、GPU使用率等
    return {
      'windowId': windowId,
      'frameRate': 60.0, // 当前帧率
      'memoryUsage': 0, // 内存使用量(MB)
      'cpuUsage': 0.0, // CPU使用率(%)
      'gpuUsage': 0.0, // GPU使用率(%)
      'renderLatency': 0.0, // 渲染延迟(ms)
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// 获取系统整体性能状态
  /// 
  /// 返回当前系统的性能负载情况
  Map<String, dynamic> getSystemPerformanceStatus() {
    // TODO: Phase 2.3 - 收集系统整体性能数据
    // 用于智能调度决策
    return {
      'systemCpuUsage': 0.0, // 系统CPU使用率
      'systemMemoryUsage': 0.0, // 系统内存使用率
      'totalWindows': windowCount,
      'activeWindows': _activeWindows.where((id) => _windowStates[id] != WindowState.minimized).length,
      'performanceLevel': 'normal', // normal, stressed, critical
      'recommendedProfile': WindowPerformanceProfile.balanced.toString(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// 应用智能性能调优
  /// 
  /// 基于当前系统状态和使用模式自动优化所有窗口性能
  Future<void> applyIntelligentPerformanceTuning() async {
    // TODO: Phase 2.3 - 实现智能性能调优算法
    // 1. 分析系统当前负载
    // 2. 识别用户活跃窗口 vs 后台窗口
    // 3. 根据使用模式调整资源分配
    // 4. 优化帧率、渲染质量、内存使用
    
    if (!_performanceSchedulerEnabled) return;
    
    // TODO: Phase 2.3 - 实现基于系统状态的性能调优
    // final systemStatus = getSystemPerformanceStatus();
    // 根据系统状态应用不同的优化策略
    // 例如：高负载时降低后台窗口资源，低负载时提升体验
  }

  /// 预测性能瓶颈
  /// 
  /// 分析当前趋势，预测可能出现的性能问题
  List<Map<String, dynamic>> predictPerformanceBottlenecks() {
    // TODO: Phase 2.3 - 实现性能瓶颈预测
    // 基于历史数据和当前趋势预测问题
    return [
      // 示例预测结果格式
      // {
      //   'type': 'memory_pressure',
      //   'severity': 'medium',
      //   'estimatedTime': '5 minutes',
      //   'affectedWindows': ['window1', 'window2'],
      //   'recommendations': ['Close unused windows', 'Switch to power saver mode']
      // }
    ];
  }

  /// 性能调度器内部方法（预留）
  
  /// 开始性能监控
  void _startPerformanceMonitoring() {
    // TODO: Phase 2.3 - 启动性能数据收集
    // 设置定时器收集性能指标，监控帧率、内存使用等
  }

  /// 停止性能监控
  void _stopPerformanceMonitoring() {
    // TODO: Phase 2.3 - 停止性能数据收集
    // 清理定时器和监控资源
  }

  /// 应用性能配置文件到特定窗口
  /// [windowId] - 窗口标识符
  /// [profile] - 性能配置文件
  void _applyPerformanceProfile(String windowId, WindowPerformanceProfile profile) {
    // TODO: Phase 2.3 - 根据配置文件调整窗口性能设置
    // 例如：调整渲染帧率、内存分配、动画质量等
    switch (profile) {
      case WindowPerformanceProfile.highPerformance:
        // 高帧率、高质量渲染、更多内存分配
        break;
      case WindowPerformanceProfile.balanced:
        // 默认设置，平衡性能与资源
        break;
      case WindowPerformanceProfile.powerSaver:
        // 降低帧率、简化渲染、减少内存使用
        break;
      case WindowPerformanceProfile.adaptive:
        // 基于当前系统状态动态调整
        break;
    }
  }

  /// 与ModuleManager协作的性能优化接口
  /// 
  /// 为模块性能调优提供窗口层面的支持
  // DEBT-PERF-005: ModuleManager协作接口预留 - Phase 2.3实现
  
  /// 获取模块相关窗口的性能数据
  /// [moduleId] - 模块标识符
  /// 
  /// 返回该模块所有窗口的聚合性能数据
  Map<String, dynamic> getModuleWindowsPerformance(String moduleId) {
    // TODO: Phase 2.3 - 收集特定模块的所有窗口性能数据
    // 用于ModuleManager的性能优化决策
    return {
      'moduleId': moduleId,
      'associatedWindows': [], // 该模块创建的窗口列表
      'totalMemoryUsage': 0,
      'averageFrameRate': 60.0,
      'performanceScore': 100.0, // 0-100的性能评分
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// 应用模块级性能优化建议
  /// [moduleId] - 模块标识符
  /// [optimizationHints] - 来自ModuleManager的优化建议
  /// 
  /// 返回优化是否成功应用
  Future<bool> applyModulePerformanceOptimization(
    String moduleId,
    Map<String, dynamic> optimizationHints,
  ) async {
    // TODO: Phase 2.3 - 根据模块层面的优化建议调整窗口性能
    // 例如：限制模块窗口数量、调整渲染优先级等
    return false;
  }
} 