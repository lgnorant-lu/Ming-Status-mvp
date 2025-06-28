// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ming-Pet Assistant';

  @override
  String get welcomeMessage => 'Welcome to Ming-Pet Assistant';

  @override
  String get notesHub => 'Notes Hub';

  @override
  String get workshop => 'Creative Workshop';

  @override
  String get punchIn => 'Punch In';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Completed';

  @override
  String get archived => 'Archived';

  @override
  String get total => 'Total';

  @override
  String get note => 'Note';

  @override
  String get todo => 'Task';

  @override
  String get project => 'Project';

  @override
  String get reminder => 'Reminder';

  @override
  String get habit => 'Habit';

  @override
  String get goal => 'Goal';

  @override
  String get allTypes => 'All Types';

  @override
  String get currentXP => 'Current XP';

  @override
  String get appDescription =>
      'Package-driven modular pet management application';

  @override
  String get moduleStatusTitle => 'Module Status';

  @override
  String get notesHubDescription => 'Manage your notes and tasks';

  @override
  String get workshopDescription => 'Record your creativity and inspiration';

  @override
  String get punchInDescription => 'Record your attendance time';

  @override
  String get initializing => 'Initializing task management center...';

  @override
  String get searchHint => 'Search tasks...';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String createNew(String itemType) {
    return 'Create new $itemType';
  }

  @override
  String noItemsFound(String itemType) {
    return 'No $itemType found';
  }

  @override
  String createItemHint(String itemType) {
    return 'Tap + button to create $itemType';
  }

  @override
  String get title => 'Title';

  @override
  String get content => 'Content';

  @override
  String get priority => 'Priority';

  @override
  String get status => 'Status';

  @override
  String get createdAt => 'Created At';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteMessage(String itemName) {
    return 'Are you sure you want to delete \"$itemName\"? This action cannot be undone.';
  }

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String newItemCreated(String itemType) {
    return 'Created new $itemType';
  }

  @override
  String get initializingWorkshop => 'Initializing Creative Workshop...';

  @override
  String get noCreativeProjects => 'No creative projects';

  @override
  String get createNewCreativeProject =>
      'Tap the bottom right button to create a new creative project';

  @override
  String get newCreativeIdea => 'New Creative Idea';

  @override
  String get newCreativeDescription => 'This is a new creative idea';

  @override
  String get detailedCreativeContent => 'Detailed creative description...';

  @override
  String get creativeProjectCreated => 'Creative project created successfully';

  @override
  String get creativeProjectDeleted => 'Creative project deleted';

  @override
  String get initializingPunchIn =>
      'Initializing desktop pet punch-in system...';

  @override
  String get level => 'Level';

  @override
  String get todayPunchIn => 'Today\'s Punch In';

  @override
  String get punchNow => 'Punch Now';

  @override
  String get dailyLimitReached => 'Daily punch-in limit reached';

  @override
  String get punchInStats => 'Punch In Statistics';

  @override
  String get totalPunches => 'Total Punches';

  @override
  String get remainingToday => 'Remaining Today';

  @override
  String get recentPunches => 'Recent Punches';

  @override
  String get noPunchRecords => 'No punch records';

  @override
  String punchSuccessWithXP(int xp) {
    return 'Punch successful! Gained $xp XP';
  }

  @override
  String lastPunchTime(String time) {
    return 'Last punch: $time';
  }

  @override
  String punchCount(int count) {
    return 'Punch #$count';
  }

  @override
  String get coreFeatures => 'Core Features';

  @override
  String get builtinModules => 'Built-in Modules';

  @override
  String get extensionModules => 'Extension Modules';

  @override
  String get system => 'System';

  @override
  String get versionInfo => 'Phase 1 - v1.0.0';

  @override
  String moduleStatus(String active, String total) {
    return 'Modules: $active/$total active';
  }

  @override
  String get moduleManagement => 'Module Management';

  @override
  String get copyrightInfo => '© 2025 Pet Assistant\nPowered by Flutter';

  @override
  String get about => 'About';

  @override
  String get moduleManagementDialog => 'Module Management';

  @override
  String get moduleManagementTodo =>
      'Module management features will be implemented in future versions';
}
