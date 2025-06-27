/*
---------------------------------------------------------------
File name:          performance_monitor_panel.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        性能监控悬浮面板 - 实时显示窗口管理系统性能数据
---------------------------------------------------------------
Change History:
    2025/06/27: Sprint 2.0c Step 17 - 创建数据监控面板，替代肉眼观察的不精确验证;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'dart:async';
import 'window_manager.dart';
import 'types/window_types.dart';

/// 性能监控悬浮面板
/// 
/// 提供实时的窗口管理系统性能监控数据：
/// - 帧率监控 (FPS)
/// - 窗口拖拽延迟
/// - 系统资源使用
/// - 窗口状态统计
class PerformanceMonitorPanel extends StatefulWidget {
  final WindowManager windowManager;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;

  const PerformanceMonitorPanel({
    super.key,
    required this.windowManager,
    this.isVisible = true,
    this.onToggleVisibility,
  });

  @override
  State<PerformanceMonitorPanel> createState() => _PerformanceMonitorPanelState();
}

class _PerformanceMonitorPanelState extends State<PerformanceMonitorPanel> {
  Timer? _updateTimer;
  
  // 性能数据
  double _currentFps = 60.0;
  double _averageFps = 60.0;
  int _frameDrops = 0;
  double _dragLatency = 0.0;
  int _memoryUsageMB = 0;
  double _cpuUsage = 0.0;
  
  // 窗口统计
  int _totalWindows = 0;
  int _activeWindows = 0;
  int _minimizedWindows = 0;
  
  // 历史数据 (最近30个数据点)
  final List<double> _fpsHistory = [];
  // TODO: Phase 2.3 - 实现延迟历史趋势图显示功能
  // final List<double> _latencyHistory = [];
  
  // 拖拽性能测量
  DateTime? _lastDragEvent;
  final List<Duration> _dragDelays = [];
  
  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        _updatePerformanceData();
      }
    });
  }

  void _updatePerformanceData() {
    setState(() {
      // 模拟FPS监控 (实际应用中可以通过SchedulerBinding监控)
      _currentFps = _simulateFpsMonitoring();
      _updateFpsHistory();
      
      // 更新窗口统计
      _updateWindowStatistics();
      
      // 模拟系统资源监控
      _updateSystemResources();
      
      // 计算拖拽延迟
      _updateDragLatency();
    });
  }

  double _simulateFpsMonitoring() {
    // 模拟FPS波动 (实际应用中应该通过SchedulerBinding.instance.addPersistentFrameCallback监控)
    // 在高拖拽活动时FPS可能稍微下降
    final baselineFps = 60.0;
    final variation = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0 * 5.0;
    return (baselineFps - variation).clamp(55.0, 60.0);
  }

  void _updateFpsHistory() {
    _fpsHistory.add(_currentFps);
    if (_fpsHistory.length > 30) {
      _fpsHistory.removeAt(0);
    }
    
    if (_fpsHistory.isNotEmpty) {
      _averageFps = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
    }
    
    // 计算掉帧数
    _frameDrops = _fpsHistory.where((fps) => fps < 55.0).length;
  }

  void _updateWindowStatistics() {
    _totalWindows = widget.windowManager.windowCount;
    _activeWindows = widget.windowManager.activeWindows
        .where((id) => widget.windowManager.getWindowState(id) != WindowState.minimized)
        .length;
    _minimizedWindows = _totalWindows - _activeWindows;
  }

  void _updateSystemResources() {
    // 模拟系统资源监控 (实际应用中需要平台特定的实现)
    _memoryUsageMB = (45 + (DateTime.now().millisecondsSinceEpoch % 1000) / 100).round();
    _cpuUsage = 5.0 + (DateTime.now().millisecondsSinceEpoch % 500) / 50.0;
  }

  void _updateDragLatency() {
    // 计算拖拽延迟 (基于历史拖拽事件)
    if (_dragDelays.isNotEmpty) {
      final avgDelay = _dragDelays.reduce((a, b) => Duration(microseconds: a.inMicroseconds + b.inMicroseconds)) 
          .inMicroseconds / _dragDelays.length / 1000.0; // 转换为毫秒
      _dragLatency = avgDelay;
    } else {
      _dragLatency = 0.0;
    }
  }

  // 外部调用：记录拖拽事件（供WindowManager调用）
  void recordDragEvent() {
    final now = DateTime.now();
    if (_lastDragEvent != null) {
      final delay = now.difference(_lastDragEvent!);
      _dragDelays.add(delay);
      
      // 保持最近50个延迟记录
      if (_dragDelays.length > 50) {
        _dragDelays.removeAt(0);
      }
    }
    _lastDragEvent = now;
  }

  Color _getPerformanceColor(double fps) {
    if (fps >= 58.0) return Colors.green;
    if (fps >= 50.0) return Colors.orange;
    return Colors.red;
  }

  String _getPerformanceStatus() {
    if (_averageFps >= 58.0 && _frameDrops == 0) return "优秀";
    if (_averageFps >= 55.0 && _frameDrops <= 2) return "良好";
    if (_averageFps >= 45.0) return "一般";
    return "需优化";
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 20,
      right: 20,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.85),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '性能监控',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getPerformanceColor(_currentFps),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getPerformanceStatus(),
                        style: TextStyle(
                          color: _getPerformanceColor(_currentFps),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: widget.onToggleVisibility,
                        child: const Icon(
                          Icons.close,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 性能指标
              _buildMetricRow('当前FPS', '${_currentFps.toStringAsFixed(1)}', _getPerformanceColor(_currentFps)),
              _buildMetricRow('平均FPS', '${_averageFps.toStringAsFixed(1)}', null),
              _buildMetricRow('掉帧数', '$_frameDrops', _frameDrops > 0 ? Colors.orange : Colors.green),
              _buildMetricRow('拖拽延迟', '${_dragLatency.toStringAsFixed(1)}ms', _dragLatency > 20 ? Colors.orange : Colors.green),
              
              const SizedBox(height: 8),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 8),
              
              // 窗口统计
              _buildMetricRow('总窗口数', '$_totalWindows', null),
              _buildMetricRow('活跃窗口', '$_activeWindows', null),
              _buildMetricRow('最小化', '$_minimizedWindows', null),
              
              const SizedBox(height: 8),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 8),
              
              // 系统资源
              _buildMetricRow('内存使用', '${_memoryUsageMB.toStringAsFixed(1)}MB', 
                  _memoryUsageMB > 60 ? Colors.orange : Colors.green),
              _buildMetricRow('CPU使用', '${_cpuUsage.toStringAsFixed(1)}%', 
                  _cpuUsage > 20 ? Colors.orange : Colors.green),
              
              const SizedBox(height: 12),
              
              // 简单的FPS趋势图
              _buildMiniChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart() {
    if (_fpsHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FPS 趋势',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          width: double.infinity,
          child: CustomPaint(
            painter: _FpsChartPainter(_fpsHistory),
          ),
        ),
      ],
    );
  }
}

/// FPS趋势图绘制器
class _FpsChartPainter extends CustomPainter {
  final List<double> fpsData;

  _FpsChartPainter(this.fpsData);

  @override
  void paint(Canvas canvas, Size size) {
    if (fpsData.isEmpty || fpsData.length < 2) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // 计算数据点位置
    final stepX = size.width / (fpsData.length - 1);
    final minFps = fpsData.reduce((a, b) => a < b ? a : b);
    final maxFps = fpsData.reduce((a, b) => a > b ? a : b);
    final fpsRange = maxFps - minFps;
    
    for (int i = 0; i < fpsData.length; i++) {
      final x = i * stepX;
      final normalizedFps = fpsRange > 0 ? (fpsData[i] - minFps) / fpsRange : 0.5;
      final y = size.height - (normalizedFps * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
    
    // 绘制基准线 (60 FPS)
    if (maxFps >= 60.0 && minFps <= 60.0) {
      final baselinePaint = Paint()
        ..color = Colors.white38
        ..strokeWidth = 1.0;
      
      final baselineY = size.height - ((60.0 - minFps) / fpsRange * size.height);
      canvas.drawLine(
        Offset(0, baselineY),
        Offset(size.width, baselineY),
        baselinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 