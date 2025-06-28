/*
---------------------------------------------------------------
File name:          punch_in_en.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        Punch In English translations - Phase 2.2 Sprint 2 distributed i18n system
---------------------------------------------------------------
*/

import 'package:core_services/core_services.dart';

/// Punch In English translation provider
class PunchInEnProvider extends BasePackageI18nProvider {
  PunchInEnProvider() : super('punch_in_en') {
    addTranslations(SupportedLocale.english, _enTranslations);
  }

  static const Map<String, String> _enTranslations = {
    // Module title
    'punch_in_title': 'Punch In',
    'module_name': 'Punch In',
    'module_description': 'Record your attendance time',
    
    // Basic operations
    'initializing': 'Initializing Punch In...',
    'punch_now': 'Punch Now',
    'punch_success': 'Punch successful',
    'punch_failed': 'Punch failed',
    'today_punch_in': 'Today\'s Punch In',
    'punch_in_stats': 'Punch In Statistics',
    
    // Status display
    'current_xp': 'Current XP',
    'level': 'Level',
    'total_punches': 'Total Punches',
    'remaining_today': 'Remaining Today',
    'daily_limit_reached': 'Daily limit reached',
    'last_punch_time': 'Last Punch Time',
    'punch_count': 'Punch Count',
    
    // Record list
    'recent_punches': 'Recent Punches',
    'no_punch_records': 'No punch records',
    'punch_history': 'Punch History',
    'view_all_records': 'View All Records',
    
    // XP system
    'punch_success_with_xp': 'Punch successful and gained XP',
    'xp_gained': 'XP Gained',
    'level_up': 'Level Up!',
    'next_level': 'Next Level',
    'xp_to_next_level': 'XP to Next Level',
    
    // Time display
    'morning': 'Morning',
    'afternoon': 'Afternoon',
    'evening': 'Evening',
    'now': 'Just now',
    'minutes_ago': '{minutes} minutes ago',
    'hours_ago': '{hours} hours ago',
    'days_ago': '{days} days ago',
    
    // Errors and status
    'network_error': 'Network error',
    'server_error': 'Server error',
    'unknown_error': 'Unknown error',
    'loading': 'Loading...',
    'refresh': 'Refresh',
    'retry': 'Retry',
    
    // Settings
    'settings': 'Settings',
    'daily_limit': 'Daily Limit',
    'punch_reminder': 'Punch Reminder',
    'sound_enabled': 'Sound Notification',
    'vibration_enabled': 'Vibration Notification',
    
    // Statistics
    'weekly_stats': 'Weekly Stats',
    'monthly_stats': 'Monthly Stats',
    'total_stats': 'Total Stats',
    'streak_days': 'Streak Days',
    'average_daily': 'Daily Average',
  };
} 