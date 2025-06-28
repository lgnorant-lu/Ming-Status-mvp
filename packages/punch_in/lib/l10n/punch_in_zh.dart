/*
---------------------------------------------------------------
File name:          punch_in_zh.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Punch In中文翻译 - Phase 2.2 Sprint 2 分布式i18n体系
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// Punch In中文翻译提供者
class PunchInZhProvider extends BasePackageI18nProvider {
  PunchInZhProvider() : super('punch_in_zh') {
    addTranslations(SupportedLocale.chinese, _zhTranslations);
  }

  static const Map<String, String> _zhTranslations = {
    // 模块标题
    'punch_in_title': '打卡',
    'module_name': '打卡',
    'module_description': '记录您的考勤时间',
    
    // 基本操作
    'initializing': '正在初始化打卡...',
    'punch_now': '立即打卡',
    'punch_success': '打卡成功',
    'punch_failed': '打卡失败',
    'today_punch_in': '今日打卡',
    'punch_in_stats': '打卡统计',
    
    // 状态显示
    'current_xp': '当前经验值',
    'level': '等级',
    'total_punches': '总打卡次数',
    'remaining_today': '今日剩余打卡次数',
    'daily_limit_reached': '今日打卡次数已达上限',
    'last_punch_time': '上次打卡时间',
    'punch_count': '打卡次数',
    
    // 记录列表
    'recent_punches': '最近打卡记录',
    'no_punch_records': '暂无打卡记录',
    'punch_history': '打卡历史',
    'view_all_records': '查看所有记录',
    
    // 经验值系统
    'punch_success_with_xp': '打卡成功并获得经验值',
    'xp_gained': '获得经验值',
    'level_up': '升级了！',
    'next_level': '下一等级',
    'xp_to_next_level': '距离下一等级',
    
    // 时间显示
    'morning': '上午',
    'afternoon': '下午',
    'evening': '晚上',
    'now': '刚刚',
    'minutes_ago': '{minutes}分钟前',
    'hours_ago': '{hours}小时前',
    'days_ago': '{days}天前',
    
    // 错误和状态
    'network_error': '网络错误',
    'server_error': '服务器错误',
    'unknown_error': '未知错误',
    'loading': '加载中...',
    'refresh': '刷新',
    'retry': '重试',
    
    // 设置
    'settings': '设置',
    'daily_limit': '每日限制',
    'punch_reminder': '打卡提醒',
    'sound_enabled': '声音提醒',
    'vibration_enabled': '震动提醒',
    
    // 统计
    'weekly_stats': '本周统计',
    'monthly_stats': '本月统计',
    'total_stats': '总计统计',
    'streak_days': '连续打卡天数',
    'average_daily': '日均打卡次数',
  };
} 