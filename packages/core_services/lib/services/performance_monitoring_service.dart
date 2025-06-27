/*
---------------------------------------------------------------
File name:          performance_monitoring_service.dart
Author:             Ig
Date created:       2025/06/26
Last modified:      2025/06/26
Dart Version:       3.32.4
Description:        性能监控服务 - 提供应用性能指标收集、分析和报告功能
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 重构 - 核心服务框架补强，创建性能监控服务;
---------------------------------------------------------------
*/

/// 性能指标类型
enum MetricType {
  /// 执行时间
  duration,
  /// 内存使用
  memory,
  /// 帧率
  fps,
  /// 网络请求时间
  networkLatency,
  /// 应用启动时间
  appLaunchTime,
  /// 自定义指标
  custom;

  String get displayName {
    switch (this) {
      case MetricType.duration:
        return 'DURATION';
      case MetricType.memory:
        return 'MEMORY';
      case MetricType.fps:
        return 'FPS';
      case MetricType.networkLatency:
        return 'NETWORK_LATENCY';
      case MetricType.appLaunchTime:
        return 'APP_LAUNCH_TIME';
      case MetricType.custom:
        return 'CUSTOM';
    }
  }
}

/// 性能指标数据类
class PerformanceMetric {
  /// 指标名称
  final String name;
  
  /// 指标类型
  final MetricType type;
  
  /// 指标值
  final double value;
  
  /// 指标单位
  final String unit;
  
  /// 时间戳
  final DateTime timestamp;
  
  /// 标签/分类
  final Map<String, String>? tags;
  
  /// 额外数据
  final Map<String, dynamic>? data;

  const PerformanceMetric({
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.tags,
    this.data,
  });

  /// 创建工厂方法
  factory PerformanceMetric.create({
    required String name,
    required MetricType type,
    required double value,
    required String unit,
    Map<String, String>? tags,
    Map<String, dynamic>? data,
  }) {
    return PerformanceMetric(
      name: name,
      type: type,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      tags: tags,
      data: data,
    );
  }

  /// 工厂方法 - 持续时间指标
  factory PerformanceMetric.duration({
    required String name,
    required Duration duration,
    Map<String, String>? tags,
    Map<String, dynamic>? data,
  }) {
    return PerformanceMetric.create(
      name: name,
      type: MetricType.duration,
      value: duration.inMicroseconds / 1000.0, // 转换为毫秒
      unit: 'ms',
      tags: tags,
      data: data,
    );
  }

  /// 工厂方法 - 内存使用指标
  factory PerformanceMetric.memory({
    required String name,
    required int bytes,
    Map<String, String>? tags,
    Map<String, dynamic>? data,
  }) {
    return PerformanceMetric.create(
      name: name,
      type: MetricType.memory,
      value: bytes / (1024 * 1024), // 转换为MB
      unit: 'MB',
      tags: tags,
      data: data,
    );
  }

  /// 工厂方法 - 帧率指标
  factory PerformanceMetric.fps({
    required String name,
    required double fps,
    Map<String, String>? tags,
    Map<String, dynamic>? data,
  }) {
    return PerformanceMetric.create(
      name: name,
      type: MetricType.fps,
      value: fps,
      unit: 'fps',
      tags: tags,
      data: data,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.displayName,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'PerformanceMetric($name: $value$unit @ ${timestamp.toIso8601String()})';
  }
}

/// 性能计时器
class PerformanceTimer {
  /// 计时器名称
  final String name;
  
  /// 开始时间
  final DateTime _startTime;
  
  /// 是否已停止
  bool _isStopped = false;
  
  /// 标签
  final Map<String, String>? tags;
  
  /// 额外数据
  final Map<String, dynamic>? data;

  PerformanceTimer._(this.name, this._startTime, {this.tags, this.data});

  /// 创建并开始计时器
  factory PerformanceTimer.start(String name, {Map<String, String>? tags, Map<String, dynamic>? data}) {
    return PerformanceTimer._(name, DateTime.now(), tags: tags, data: data);
  }

  /// 停止计时器并返回持续时间
  Duration stop() {
    if (_isStopped) {
      throw StateError('Timer already stopped');
    }
    
    _isStopped = true;
    return DateTime.now().difference(_startTime);
  }

  /// 停止计时器并创建性能指标
  PerformanceMetric stopAndCreateMetric() {
    final duration = stop();
    return PerformanceMetric.duration(
      name: name,
      duration: duration,
      tags: tags,
      data: data,
    );
  }

  /// 获取当前经过的时间（不停止计时器）
  Duration get elapsed => DateTime.now().difference(_startTime);

  /// 是否已停止
  bool get isStopped => _isStopped;
}

/// 性能统计信息
class PerformanceStats {
  /// 指标名称
  final String name;
  
  /// 样本数量
  final int count;
  
  /// 平均值
  final double average;
  
  /// 最小值
  final double min;
  
  /// 最大值
  final double max;
  
  /// 标准差
  final double standardDeviation;
  
  /// 50分位数
  final double p50;
  
  /// 90分位数
  final double p90;
  
  /// 95分位数
  final double p95;
  
  /// 99分位数
  final double p99;

  const PerformanceStats({
    required this.name,
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.standardDeviation,
    required this.p50,
    required this.p90,
    required this.p95,
    required this.p99,
  });

  /// 从数值列表计算统计信息
  factory PerformanceStats.fromValues(String name, List<double> values) {
    if (values.isEmpty) {
      return PerformanceStats(
        name: name,
        count: 0,
        average: 0,
        min: 0,
        max: 0,
        standardDeviation: 0,
        p50: 0,
        p90: 0,
        p95: 0,
        p99: 0,
      );
    }

    final sortedValues = List<double>.from(values)..sort();
    final count = values.length;
    final sum = values.reduce((a, b) => a + b);
    final average = sum / count;

    // 计算标准差
    final variance = values.map((v) => (v - average) * (v - average)).reduce((a, b) => a + b) / count;
    final standardDeviation = variance.isNaN ? 0.0 : variance.sqrt();

    return PerformanceStats(
      name: name,
      count: count,
      average: average,
      min: sortedValues.first,
      max: sortedValues.last,
      standardDeviation: standardDeviation,
      p50: _percentile(sortedValues, 50),
      p90: _percentile(sortedValues, 90),
      p95: _percentile(sortedValues, 95),
      p99: _percentile(sortedValues, 99),
    );
  }

  /// 计算百分位数
  static double _percentile(List<double> sortedValues, int percentile) {
    if (sortedValues.isEmpty) return 0.0;
    
    final index = (percentile / 100.0) * (sortedValues.length - 1);
    final lower = index.floor();
    final upper = index.ceil();
    
    if (lower == upper) {
      return sortedValues[lower];
    }
    
    return sortedValues[lower] + (sortedValues[upper] - sortedValues[lower]) * (index - lower);
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'average': average,
      'min': min,
      'max': max,
      'standardDeviation': standardDeviation,
      'p50': p50,
      'p90': p90,
      'p95': p95,
      'p99': p99,
    };
  }

  @override
  String toString() {
    return 'PerformanceStats($name: avg=${average.toStringAsFixed(2)}, p95=${p95.toStringAsFixed(2)}, count=$count)';
  }
}

/// 性能监控配置
class PerformanceMonitoringConfig {
  /// 是否启用
  final bool enabled;
  
  /// 指标缓存大小
  final int metricCacheSize;
  
  /// 自动报告间隔（毫秒）
  final int autoReportIntervalMs;
  
  /// 是否启用内存监控
  final bool enableMemoryMonitoring;
  
  /// 是否启用帧率监控
  final bool enableFpsMonitoring;
  
  /// 采样率（0.0-1.0）
  final double samplingRate;

  const PerformanceMonitoringConfig({
    this.enabled = true,
    this.metricCacheSize = 1000,
    this.autoReportIntervalMs = 60000, // 1分钟
    this.enableMemoryMonitoring = true,
    this.enableFpsMonitoring = true,
    this.samplingRate = 1.0,
  });
}

/// 性能监控服务接口
abstract class PerformanceMonitoringService {
  /// 配置服务
  void configure(PerformanceMonitoringConfig config);
  
  /// 开始计时
  PerformanceTimer startTimer(String name, {Map<String, String>? tags, Map<String, dynamic>? data});
  
  /// 记录指标
  void recordMetric(PerformanceMetric metric);
  
  /// 记录持续时间
  void recordDuration(String name, Duration duration, {Map<String, String>? tags, Map<String, dynamic>? data});
  
  /// 记录内存使用
  void recordMemoryUsage(String name, int bytes, {Map<String, String>? tags, Map<String, dynamic>? data});
  
  /// 记录帧率
  void recordFps(String name, double fps, {Map<String, String>? tags, Map<String, dynamic>? data});
  
  /// 记录自定义指标
  void recordCustomMetric(String name, double value, String unit, {Map<String, String>? tags, Map<String, dynamic>? data});
  
  /// 获取指标统计信息
  PerformanceStats? getStats(String name);
  
  /// 获取所有指标统计信息
  Map<String, PerformanceStats> getAllStats();
  
  /// 清理旧指标
  void clearOldMetrics({Duration? olderThan});
  
  /// 生成性能报告
  Map<String, dynamic> generateReport();
  
  /// 启动自动报告
  void startAutoReporting();
  
  /// 停止自动报告
  void stopAutoReporting();
  
  /// 关闭服务
  void close();
}

/// 基础性能监控服务实现
class BasicPerformanceMonitoringService implements PerformanceMonitoringService {
  /// 配置
  PerformanceMonitoringConfig _config = const PerformanceMonitoringConfig();
  
  /// 指标存储
  final Map<String, List<PerformanceMetric>> _metrics = {};
  
  /// 活跃计时器
  final Map<String, PerformanceTimer> _activeTimers = {};
  
  /// 自动报告定时器
  Timer? _autoReportTimer;
  
  /// 是否已关闭
  bool _isClosed = false;

  @override
  void configure(PerformanceMonitoringConfig config) {
    _config = config;
    
    if (config.enabled && config.autoReportIntervalMs > 0) {
      startAutoReporting();
    } else {
      stopAutoReporting();
    }
  }

  @override
  PerformanceTimer startTimer(String name, {Map<String, String>? tags, Map<String, dynamic>? data}) {
    if (!_config.enabled || _isClosed) {
      // 返回一个空的计时器
      return PerformanceTimer.start(name, tags: tags, data: data);
    }
    
    // 检查采样率
    if (_config.samplingRate < 1.0) {
      final random = DateTime.now().millisecond / 1000.0;
      if (random > _config.samplingRate) {
        return PerformanceTimer.start(name, tags: tags, data: data);
      }
    }
    
    final timer = PerformanceTimer.start(name, tags: tags, data: data);
    _activeTimers[name] = timer;
    return timer;
  }

  @override
  void recordMetric(PerformanceMetric metric) {
    if (!_config.enabled || _isClosed) return;
    
    _metrics.putIfAbsent(metric.name, () => <PerformanceMetric>[]).add(metric);
    
    // 限制缓存大小
    final metricList = _metrics[metric.name]!;
    if (metricList.length > _config.metricCacheSize) {
      metricList.removeAt(0);
    }
  }

  @override
  void recordDuration(String name, Duration duration, {Map<String, String>? tags, Map<String, dynamic>? data}) {
    final metric = PerformanceMetric.duration(
      name: name,
      duration: duration,
      tags: tags,
      data: data,
    );
    recordMetric(metric);
  }

  @override
  void recordMemoryUsage(String name, int bytes, {Map<String, String>? tags, Map<String, dynamic>? data}) {
    if (!_config.enableMemoryMonitoring) return;
    
    final metric = PerformanceMetric.memory(
      name: name,
      bytes: bytes,
      tags: tags,
      data: data,
    );
    recordMetric(metric);
  }

  @override
  void recordFps(String name, double fps, {Map<String, String>? tags, Map<String, dynamic>? data}) {
    if (!_config.enableFpsMonitoring) return;
    
    final metric = PerformanceMetric.fps(
      name: name,
      fps: fps,
      tags: tags,
      data: data,
    );
    recordMetric(metric);
  }

  @override
  void recordCustomMetric(String name, double value, String unit, {Map<String, String>? tags, Map<String, dynamic>? data}) {
    final metric = PerformanceMetric.create(
      name: name,
      type: MetricType.custom,
      value: value,
      unit: unit,
      tags: tags,
      data: data,
    );
    recordMetric(metric);
  }

  @override
  PerformanceStats? getStats(String name) {
    final metricList = _metrics[name];
    if (metricList == null || metricList.isEmpty) {
      return null;
    }
    
    final values = metricList.map((m) => m.value).toList();
    return PerformanceStats.fromValues(name, values);
  }

  @override
  Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};
    
    for (final entry in _metrics.entries) {
      if (entry.value.isNotEmpty) {
        final values = entry.value.map((m) => m.value).toList();
        stats[entry.key] = PerformanceStats.fromValues(entry.key, values);
      }
    }
    
    return stats;
  }

  @override
  void clearOldMetrics({Duration? olderThan}) {
    final cutoffTime = DateTime.now().subtract(olderThan ?? const Duration(hours: 1));
    
    for (final entry in _metrics.entries) {
      entry.value.removeWhere((metric) => metric.timestamp.isBefore(cutoffTime));
    }
    
    // 移除空的指标列表
    _metrics.removeWhere((key, value) => value.isEmpty);
  }

  @override
  Map<String, dynamic> generateReport() {
    final stats = getAllStats();
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'config': {
        'enabled': _config.enabled,
        'metricCacheSize': _config.metricCacheSize,
        'samplingRate': _config.samplingRate,
      },
      'summary': {
        'totalMetrics': _metrics.values.fold<int>(0, (sum, list) => sum + list.length),
        'uniqueMetricNames': _metrics.keys.length,
        'activeTimers': _activeTimers.length,
      },
      'stats': stats.map((key, value) => MapEntry(key, value.toJson())),
    };
    
    return report;
  }

  @override
  void startAutoReporting() {
    if (_autoReportTimer != null || !_config.enabled) return;
    
    _autoReportTimer = Timer.periodic(
      Duration(milliseconds: _config.autoReportIntervalMs),
      (timer) {
        final report = generateReport();
        print('[PERFORMANCE REPORT] ${report.toString()}');
        
        // 清理旧指标
        clearOldMetrics();
      },
    );
  }

  @override
  void stopAutoReporting() {
    _autoReportTimer?.cancel();
    _autoReportTimer = null;
  }

  @override
  void close() {
    if (_isClosed) return;
    
    _isClosed = true;
    stopAutoReporting();
    
    _metrics.clear();
    _activeTimers.clear();
  }
}

/// 扩展数学运算（为了避免依赖math库）
extension on double {
  double sqrt() {
    if (this < 0) return double.nan;
    if (this == 0) return 0;
    
    double x = this;
    double prev;
    
    // 牛顿法求平方根
    do {
      prev = x;
      x = (x + this / x) / 2;
    } while ((x - prev).abs() > 0.000001);
    
    return x;
  }
}

/// Timer类的简单实现（如果dart:async不可用）
class Timer {
  static Timer? periodic(Duration duration, void Function(Timer) callback) {
    // 这里需要实际的Timer实现
    // 在真实项目中应该使用dart:async的Timer
    // 这里只是接口示例
    return null;
  }
  
  void cancel() {
    // 取消定时器
  }
} 