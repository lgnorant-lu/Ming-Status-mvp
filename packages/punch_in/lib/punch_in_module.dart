/*
---------------------------------------------------------------
File name:          punch_in_module.dart
Author:             Ignorant-lu
Date created:       2025/06/24
Last modified:      2025/06/26
Dart Version:       3.32.4
Description:        打卡模块 - 提供游戏化打卡签到功能，包含经验值系统和成就激励
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 模块修复 - 恢复完整的API文档规范实现;
    2025/06/25: Initial creation - 打卡模块基础实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:developer' as developer;
import 'package:core_services/core_services.dart';

/// 打卡事件基类
abstract class PunchInEvent {
  final DateTime timestamp;
  final String eventId;
  
  PunchInEvent({
    required this.eventId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 用户打卡事件
class UserPunchInEvent extends PunchInEvent {
  final int xpGained;                    // 获得的经验值
  final Map<String, dynamic>? additionalData;  // 附加数据
  
  UserPunchInEvent({
    required String eventId,
    required this.xpGained,
    this.additionalData,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 打卡数据更新事件
class PunchInDataUpdatedEvent extends PunchInEvent {
  final Map<String, dynamic> stats;     // 更新后的统计信息
  
  PunchInDataUpdatedEvent({
    required String eventId,
    required this.stats,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 打卡状态变化事件
class PunchInStateChangedEvent extends PunchInEvent {
  final String changeType;              // 变化类型（initialized/activated等）
  final Map<String, dynamic>? data;     // 状态变化相关数据
  
  PunchInStateChangedEvent({
    required String eventId,
    required this.changeType,
    this.data,
    DateTime? timestamp,
  }) : super(eventId: eventId, timestamp: timestamp);
}

/// 打卡模块 - 游戏化打卡系统
class PunchInModule implements PetModuleInterface {
  // === 模块基本信息 ===
  @override
  String get id => 'punch_in';
  
  @override
  String get name => '桌宠打卡';
  
  @override
  String get description => '游戏化打卡系统，提供经验值奖励、成就激励和打卡统计功能，让日常打卡变得有趣有动力。';
  
  @override
  String get version => '1.1.0';
  
  @override
  String get author => 'Ignorant-lu';
  
  @override
  List<String> get dependencies => [];
  
  @override
  Map<String, dynamic> get metadata => {
    'category': 'builtin',
    'features': ['gamification', 'xp_system', 'daily_limit', 'statistics'],
    'maxDailyPunches': 5,
    'baseXpReward': 10,
  };

  // === 状态管理 ===
  bool _isInitialized = false;
  bool _isActive = false;
  EventBus? _eventBus;

  @override
  bool get isInitialized => _isInitialized;
  
  @override
  bool get isActive => _isActive;

  // === 数据存储 ===
  int _currentXP = 0;
  final List<Map<String, dynamic>> _punchHistory = [];
  int _todayPunchCount = 0;

  // === 配置常量 ===
  static const int maxDailyPunches = 5;
  static const int baseXpReward = 10;

  // === 生命周期方法 ===
  
  @override
  Future<void> initialize(EventBus eventBus) async {
    developer.log('开始初始化打卡模块...', name: 'PunchInModule');
    
    try {
      _eventBus = eventBus;
      
      // 注册事件监听器
      _setupEventListeners();
      
      // 加载打卡数据
      _loadPunchData();
      
      _isInitialized = true;
      
      // 发布初始化完成事件
      _publishStateChangeEvent('initialized', {
        'currentXP': _currentXP,
        'todayPunchCount': _todayPunchCount,
        'totalPunches': _punchHistory.length,
      });
      
      developer.log('打卡模块初始化完成', name: 'PunchInModule');
    } catch (e) {
      developer.log('打卡模块初始化失败: $e', name: 'PunchInModule');
      rethrow;
    }
  }

  @override
  Future<void> boot() async {
    if (!_isInitialized) {
      throw StateError('模块未初始化，请先调用initialize()');
    }
    
    developer.log('启动打卡模块...', name: 'PunchInModule');
    
    // 检查今日打卡状态
    _checkTodayPunchStatus();
    
    _isActive = true;
    
    // 发布激活事件
    _publishStateChangeEvent('activated', {
      'canPunchToday': canPunchToday(),
      'remainingPunches': maxDailyPunches - _todayPunchCount,
    });
    
    developer.log('打卡模块已激活', name: 'PunchInModule');
  }

  @override
  void dispose() {
    developer.log('销毁打卡模块...', name: 'PunchInModule');
    
    _isActive = false;
    _isInitialized = false;
    _eventBus = null;
    
    developer.log('打卡模块已销毁', name: 'PunchInModule');
  }

  // === 核心业务方法 ===

  /// 执行打卡操作
  Future<bool> performPunchIn() async {
    developer.log('执行打卡操作...', name: 'PunchInModule');
    
    // 检查模块状态
    if (!_isInitialized || !_isActive) {
      developer.log('模块未准备就绪', name: 'PunchInModule');
      return false;
    }
    
    // 检查今日打卡限制
    if (!canPunchToday()) {
      developer.log('今日打卡次数已达上限', name: 'PunchInModule');
      return false;
    }
    
    try {
      // 计算经验值奖励
      final xpGained = calculateXPGain();
      
      // 更新状态
      _currentXP += xpGained;
      _todayPunchCount++;
      
      // 创建打卡记录
      final punchRecord = {
        'id': 'punch_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
        'xpGained': xpGained,
        'dailyCount': _todayPunchCount,
        'totalXP': _currentXP,
      };
      
      _punchHistory.add(punchRecord);
      
      // 发布用户打卡事件
      _publishUserPunchInEvent(xpGained, punchRecord);
      
      // 发布数据更新事件
      _publishDataUpdatedEvent();
      
      developer.log('打卡成功: +$xpGained XP, 总计: $_currentXP XP', name: 'PunchInModule');
      return true;
      
    } catch (e) {
      developer.log('打卡操作失败: $e', name: 'PunchInModule');
      return false;
    }
  }

  /// 检查今日是否还可以打卡
  bool canPunchToday() {
    return _todayPunchCount < maxDailyPunches;
  }

  // === 数据查询方法 ===

  /// 获取当前经验值
  int getCurrentXP() {
    if (!_isInitialized) {
      throw StateError('模块未初始化');
    }
    return _currentXP;
  }

  /// 获取今日打卡次数
  int getTodayPunchCount() {
    return _todayPunchCount;
  }

  /// 获取最近一次打卡时间
  DateTime? getLastPunchTime() {
    if (_punchHistory.isEmpty) return null;
    final lastRecord = _punchHistory.last;
    return DateTime.parse(lastRecord['timestamp'] as String);
  }

  /// 获取打卡历史记录
  List<Map<String, dynamic>> getPunchHistory({int? limit}) {
    final history = List<Map<String, dynamic>>.from(_punchHistory);
    // 按时间倒序排列
    history.sort((a, b) => DateTime.parse(b['timestamp'] as String)
        .compareTo(DateTime.parse(a['timestamp'] as String)));
    
    if (limit != null && limit > 0) {
      return history.take(limit).toList();
    }
    return history;
  }

  /// 获取完整统计信息
  Map<String, dynamic> getStatistics() {
    return {
      'currentXP': _currentXP,
      'todayPunchCount': _todayPunchCount,
      'maxDailyPunches': maxDailyPunches,
      'remainingPunches': maxDailyPunches - _todayPunchCount,
      'totalPunches': _punchHistory.length,
      'lastPunchTime': getLastPunchTime()?.toIso8601String(),
      'canPunchToday': canPunchToday(),
    };
  }

  // === 内部方法 ===

  /// 设置事件监听器
  void _setupEventListeners() {
    // 当前版本暂不监听外部事件
    developer.log('打卡事件监听器注册完成', name: 'PunchInModule');
  }

  /// 加载打卡数据
  void _loadPunchData() {
    // 加载示例数据（实际应用中应从持久化存储加载）
    _currentXP = 150;
    _todayPunchCount = 2;
    
    // 添加示例历史记录
    final now = DateTime.now();
    _punchHistory.addAll([
      {
        'id': 'punch_${now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch}',
        'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'xpGained': 10,
        'dailyCount': 1,
        'totalXP': 140,
      },
      {
        'id': 'punch_${now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch}',
        'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'xpGained': 12,
        'dailyCount': 2,
        'totalXP': 150,
      },
    ]);
    
    developer.log('打卡数据加载完成: XP=$_currentXP, 历史记录=${_punchHistory.length}条', name: 'PunchInModule');
  }

  /// 检查今日打卡状态
  void _checkTodayPunchStatus() {
    final now = DateTime.now();
    final lastPunch = getLastPunchTime();
    
    // 如果最后打卡不是今天，重置今日计数
    if (lastPunch == null || !_isSameDay(lastPunch, now)) {
      _todayPunchCount = 0;
      developer.log('今日打卡计数已重置', name: 'PunchInModule');
    }
  }

  /// 计算经验值奖励
  int calculateXPGain() {
    // 基础经验值
    int xp = baseXpReward;
    
    // 连续打卡奖励：每日第N次打卡额外获得 N * 2 XP
    if (_todayPunchCount > 0) {
      xp += (_todayPunchCount + 1) * 2;
    }
    
    return xp;
  }

  /// 检查是否为同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // === 事件发布方法 ===

  /// 发布用户打卡事件
  void _publishUserPunchInEvent(int xpGained, Map<String, dynamic> punchRecord) {
    try {
      final event = UserPunchInEvent(
        eventId: 'user_punch_in_${DateTime.now().millisecondsSinceEpoch}',
        xpGained: xpGained,
        additionalData: punchRecord,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布用户打卡事件失败: $e', name: 'PunchInModule');
    }
  }

  /// 发布数据更新事件
  void _publishDataUpdatedEvent() {
    try {
      final event = PunchInDataUpdatedEvent(
        eventId: 'data_updated_${DateTime.now().millisecondsSinceEpoch}',
        stats: getStatistics(),
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布数据更新事件失败: $e', name: 'PunchInModule');
    }
  }

  /// 发布状态变化事件
  void _publishStateChangeEvent(String changeType, Map<String, dynamic>? data) {
    try {
      final event = PunchInStateChangedEvent(
        eventId: 'state_change_${DateTime.now().millisecondsSinceEpoch}',
        changeType: changeType,
        data: data,
      );
      _eventBus?.fire(event);
    } catch (e) {
      developer.log('发布状态变化事件失败: $e', name: 'PunchInModule');
    }
  }
} 