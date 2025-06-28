/*
---------------------------------------------------------------
File name:          punch_in_widget.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        游戏化打卡Widget - 提供经验值系统、打卡激励、成就展示的现代化打卡界面
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 模块修复 - 完全重写为游戏化打卡界面，匹配新的API设计;
    2025/06/25: Initial creation - 打卡Widget基础实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:core_services/core_services.dart';
import 'punch_in_module.dart';
import 'l10n/punch_in_l10n.dart';

/// 打卡模块本地化字符串类
class PunchInLocalizations {
  final String punchInTitle;
  final String initializing;
  final String currentXP;
  final String level;
  final String todayPunchIn;
  final String punchNow;
  final String dailyLimitReached;
  final String punchInStats;
  final String totalPunches;
  final String remainingToday;
  final String recentPunches;
  final String noPunchRecords;
  final String punchSuccessWithXP;
  final String lastPunchTime;
  final String punchCount;

  const PunchInLocalizations({
    required this.punchInTitle,
    required this.initializing,
    required this.currentXP,
    required this.level,
    required this.todayPunchIn,
    required this.punchNow,
    required this.dailyLimitReached,
    required this.punchInStats,
    required this.totalPunches,
    required this.remainingToday,
    required this.recentPunches,
    required this.noPunchRecords,
    required this.punchSuccessWithXP,
    required this.lastPunchTime,
    required this.punchCount,
  });
}

/// 游戏化打卡Widget
class PunchInWidget extends StatefulWidget {
  final PunchInLocalizations? localizations;
  
  const PunchInWidget({super.key, this.localizations});

  @override
  State<PunchInWidget> createState() => _PunchInWidgetState();
}

class _PunchInWidgetState extends State<PunchInWidget> 
    with TickerProviderStateMixin {
  late PunchInModule _module;
  late AnimationController _xpAnimationController;
  late Animation<double> _xpAnimation;
  bool _isInitialized = false;

  /// 便捷翻译方法 - Phase 2.2 Sprint 2 使用分布式i18n系统
  String _t(String key) {
    return PunchInL10n.t(key);
  }

  @override
  void initState() {
    super.initState();
    
    _xpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _xpAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _xpAnimationController, curve: Curves.easeInOut));

    _initializeModule();
  }

  Future<void> _initializeModule() async {
    try {
      _module = PunchInModule();
      
      // 注册EventBus并初始化模块
      EventBus.register();
      await _module.initialize(EventBus.instance);
      await _module.boot();
      
      setState(() {
        _isInitialized = true;
      });
      
      _xpAnimationController.forward();
    } catch (e) {
      debugPrint('初始化打卡模块失败: $e');
    }
  }

  @override
  void dispose() {
    _xpAnimationController.dispose();
    if (_isInitialized) {
      _module.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_t('initializing')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_t('punch_in_title')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF764ba2), Color(0xFF667eea)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        _xpAnimationController.reset();
        _xpAnimationController.forward();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildXPCard(),
            const SizedBox(height: 16),
            _buildPunchInCard(),
            const SizedBox(height: 16),
            _buildStatsCard(),
            const SizedBox(height: 16),
            _buildHistoryCard(),
          ],
        ),
      ),
    );
  }

  /// 经验值展示卡片
  Widget _buildXPCard() {
    final currentXP = _module.getCurrentXP();
    
    return AnimatedBuilder(
      animation: _xpAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 32),
                  Text(
                    _t('current_xp'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Transform.scale(
                scale: _xpAnimation.value,
                child: Text(
                  '${currentXP} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_t('level')} ${(currentXP / 100).floor() + 1}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 打卡操作卡片
  Widget _buildPunchInCard() {
    final canPunch = _module.canPunchToday();
    final todayCount = _module.getTodayPunchCount();
    final maxPunches = PunchInModule.maxDailyPunches;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app, size: 28, color: Color(0xFF667eea)),
                const SizedBox(width: 12),
                Text(
                  _t('today_punch_in'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: canPunch ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$todayCount/$maxPunches',
                    style: TextStyle(
                      color: canPunch ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 进度条
            LinearProgressIndicator(
              value: todayCount / maxPunches,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                canPunch ? const Color(0xFF667eea) : Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            
            // 打卡按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: canPunch ? _performPunchIn : null,
                icon: Icon(canPunch ? Icons.star : Icons.block),
                label: Text(
                  canPunch ? '${_t('punch_now')} (+${_getNextXPGain()} XP)' : _t('daily_limit_reached'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canPunch ? const Color(0xFF667eea) : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: canPunch ? 4 : 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 统计信息卡片
  Widget _buildStatsCard() {
    final stats = _module.getStatistics();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                Text(
                  _t('punch_in_stats'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    _t('total_punches'),
                    '${stats['totalPunches']}',
                    Icons.history,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    _t('remaining_today'),
                    '${stats['remainingPunches']}',
                    Icons.access_time,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (stats['lastPunchTime'] != null) ...[
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _t('last_punch_time').replaceFirst('{time}', _formatDateTime(DateTime.parse(stats['lastPunchTime']))),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 历史记录卡片
  Widget _buildHistoryCard() {
    final history = _module.getPunchHistory(limit: 5);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                Text(
                  _t('recent_punches'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    _t('no_punch_records'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...history.map((record) => _buildHistoryItem(record)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> record) {
    final timestamp = DateTime.parse(record['timestamp']);
    final xpGained = record['xpGained'] as int;
    final dailyCount = record['dailyCount'] as int;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF667eea),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateTime(timestamp),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _t('punch_count').replaceFirst('{count}', '$dailyCount'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$xpGained XP',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 执行打卡
  void _performPunchIn() {
    final xpGained = _getNextXPGain();
    _module.performPunchIn();
    
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_t('punch_success_with_xp').replaceFirst('{xp}', '$xpGained')),
      ),
    );
    
    _xpAnimationController.reset();
    _xpAnimationController.forward();
  }
  
  /// 获取下一次打卡可获得的经验值
  int _getNextXPGain() {
    return _module.calculateXPGain();
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
} 