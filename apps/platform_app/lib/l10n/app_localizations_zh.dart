// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Ming-桌宠助手';

  @override
  String get welcomeMessage => '欢迎使用Ming-桌宠助手';

  @override
  String get notesHub => '事务中心';

  @override
  String get workshop => '创意工坊';

  @override
  String get punchIn => '打卡';

  @override
  String get home => '首页';

  @override
  String get settings => '设置';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get search => '搜索';

  @override
  String get active => '活跃';

  @override
  String get completed => '已完成';

  @override
  String get archived => '已归档';

  @override
  String get total => '总计';

  @override
  String get note => '笔记';

  @override
  String get todo => '待办';

  @override
  String get project => '项目';

  @override
  String get reminder => '提醒';

  @override
  String get habit => '习惯';

  @override
  String get goal => '目标';

  @override
  String get allTypes => '全部类型';

  @override
  String get currentXP => '当前经验值';

  @override
  String get appDescription => '基于包驱动架构的模块化宠物管理应用';

  @override
  String get moduleStatusTitle => '模块状态';

  @override
  String get notesHubDescription => '管理您的笔记和任务';

  @override
  String get workshopDescription => '记录您的创意和灵感';

  @override
  String get punchInDescription => '记录您的考勤时间';

  @override
  String get initializing => '正在初始化事务管理中心...';

  @override
  String get searchHint => '搜索事务...';

  @override
  String get priorityUrgent => '紧急';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityLow => '低';

  @override
  String createNew(String itemType) {
    return '新建$itemType';
  }

  @override
  String noItemsFound(String itemType) {
    return '暂无$itemType';
  }

  @override
  String createItemHint(String itemType) {
    return '点击 + 按钮创建$itemType';
  }

  @override
  String get title => '标题';

  @override
  String get content => '内容';

  @override
  String get priority => '优先级';

  @override
  String get status => '状态';

  @override
  String get createdAt => '创建时间';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteMessage(String itemName) {
    return '确定要删除\"$itemName\"吗？此操作无法撤销。';
  }

  @override
  String get itemDeleted => '项目已删除';

  @override
  String newItemCreated(String itemType) {
    return '已创建新的$itemType';
  }

  @override
  String get initializingWorkshop => '正在初始化创意工坊...';

  @override
  String get noCreativeProjects => '暂无创意项目';

  @override
  String get createNewCreativeProject => '点击右下角按钮创建新的创意项目';

  @override
  String get newCreativeIdea => '新创意想法';

  @override
  String get newCreativeDescription => '这是一个新的创意想法';

  @override
  String get detailedCreativeContent => '详细的创意描述...';

  @override
  String get creativeProjectCreated => '创意项目创建成功';

  @override
  String get creativeProjectDeleted => '创意项目已删除';

  @override
  String get initializingPunchIn => '正在初始化桌宠打卡系统...';

  @override
  String get level => '等级';

  @override
  String get todayPunchIn => '今日打卡';

  @override
  String get punchNow => '立即打卡';

  @override
  String get dailyLimitReached => '今日打卡次数已达上限';

  @override
  String get punchInStats => '打卡统计';

  @override
  String get totalPunches => '总打卡次数';

  @override
  String get remainingToday => '今日剩余次数';

  @override
  String get recentPunches => '最近打卡记录';

  @override
  String get noPunchRecords => '暂无打卡记录';

  @override
  String punchSuccessWithXP(int xp) {
    return '打卡成功！获得 $xp 经验值';
  }

  @override
  String lastPunchTime(String time) {
    return '上次打卡：$time';
  }

  @override
  String punchCount(int count) {
    return '第 $count 次打卡';
  }

  @override
  String get coreFeatures => '核心功能';

  @override
  String get builtinModules => '内置模块';

  @override
  String get extensionModules => '扩展模块';

  @override
  String get system => '系统';

  @override
  String get versionInfo => 'Phase 1 - v1.0.0';

  @override
  String moduleStatus(String active, String total) {
    return '模块: $active/$total 活跃';
  }

  @override
  String get moduleManagement => '模块管理';

  @override
  String get copyrightInfo => '© 2025 Pet Assistant\nPowered by Flutter';

  @override
  String get about => '关于';

  @override
  String get moduleManagementDialog => '模块管理';

  @override
  String get moduleManagementTodo => '模块管理功能将在后续版本中实现';
}
