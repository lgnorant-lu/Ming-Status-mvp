import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
  ];

  /// 应用标题
  ///
  /// In zh, this message translates to:
  /// **'Ming-桌宠助手'**
  String get appTitle;

  /// 欢迎信息
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用Ming-桌宠助手'**
  String get welcomeMessage;

  /// 事务中心模块名称
  ///
  /// In zh, this message translates to:
  /// **'事务中心'**
  String get notesHub;

  /// 创意工坊模块名称
  ///
  /// In zh, this message translates to:
  /// **'创意工坊'**
  String get workshop;

  /// 打卡模块名称
  ///
  /// In zh, this message translates to:
  /// **'打卡'**
  String get punchIn;

  /// 首页导航
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// 设置页面
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 保存按钮
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// 取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 删除按钮
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// 编辑按钮
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// 搜索功能
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// 活跃状态
  ///
  /// In zh, this message translates to:
  /// **'活跃'**
  String get active;

  /// 已完成状态
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get completed;

  /// 已归档状态
  ///
  /// In zh, this message translates to:
  /// **'已归档'**
  String get archived;

  /// 总计统计
  ///
  /// In zh, this message translates to:
  /// **'总计'**
  String get total;

  /// 笔记类型
  ///
  /// In zh, this message translates to:
  /// **'笔记'**
  String get note;

  /// 待办类型
  ///
  /// In zh, this message translates to:
  /// **'待办'**
  String get todo;

  /// 项目类型
  ///
  /// In zh, this message translates to:
  /// **'项目'**
  String get project;

  /// 提醒类型
  ///
  /// In zh, this message translates to:
  /// **'提醒'**
  String get reminder;

  /// 习惯类型
  ///
  /// In zh, this message translates to:
  /// **'习惯'**
  String get habit;

  /// 目标类型
  ///
  /// In zh, this message translates to:
  /// **'目标'**
  String get goal;

  /// 全部类型过滤器
  ///
  /// In zh, this message translates to:
  /// **'全部类型'**
  String get allTypes;

  /// 当前经验值标签
  ///
  /// In zh, this message translates to:
  /// **'当前经验值'**
  String get currentXP;

  /// 应用描述
  ///
  /// In zh, this message translates to:
  /// **'基于包驱动架构的模块化宠物管理应用'**
  String get appDescription;

  /// 模块状态标题
  ///
  /// In zh, this message translates to:
  /// **'模块状态'**
  String get moduleStatusTitle;

  /// 事务中心描述
  ///
  /// In zh, this message translates to:
  /// **'管理您的笔记和任务'**
  String get notesHubDescription;

  /// 创意工坊描述
  ///
  /// In zh, this message translates to:
  /// **'记录您的创意和灵感'**
  String get workshopDescription;

  /// 打卡中心描述
  ///
  /// In zh, this message translates to:
  /// **'记录您的考勤时间'**
  String get punchInDescription;

  /// 初始化信息
  ///
  /// In zh, this message translates to:
  /// **'正在初始化事务管理中心...'**
  String get initializing;

  /// 搜索框提示
  ///
  /// In zh, this message translates to:
  /// **'搜索事务...'**
  String get searchHint;

  /// 优先级 - 紧急
  ///
  /// In zh, this message translates to:
  /// **'紧急'**
  String get priorityUrgent;

  /// 优先级 - 高
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get priorityHigh;

  /// 优先级 - 中
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get priorityMedium;

  /// 优先级 - 低
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get priorityLow;

  /// 创建新项目按钮
  ///
  /// In zh, this message translates to:
  /// **'新建{itemType}'**
  String createNew(String itemType);

  /// 空状态信息
  ///
  /// In zh, this message translates to:
  /// **'暂无{itemType}'**
  String noItemsFound(String itemType);

  /// 创建提示
  ///
  /// In zh, this message translates to:
  /// **'点击 + 按钮创建{itemType}'**
  String createItemHint(String itemType);

  /// 标题字段
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get title;

  /// 内容字段
  ///
  /// In zh, this message translates to:
  /// **'内容'**
  String get content;

  /// 优先级字段
  ///
  /// In zh, this message translates to:
  /// **'优先级'**
  String get priority;

  /// 状态字段
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get status;

  /// 创建时间字段
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get createdAt;

  /// 删除确认标题
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// 删除确认信息
  ///
  /// In zh, this message translates to:
  /// **'确定要删除\"{itemName}\"吗？此操作无法撤销。'**
  String confirmDeleteMessage(String itemName);

  /// 项目删除成功信息
  ///
  /// In zh, this message translates to:
  /// **'项目已删除'**
  String get itemDeleted;

  /// 新项目创建成功信息
  ///
  /// In zh, this message translates to:
  /// **'已创建新的{itemType}'**
  String newItemCreated(String itemType);

  /// 创意工坊初始化信息
  ///
  /// In zh, this message translates to:
  /// **'正在初始化创意工坊...'**
  String get initializingWorkshop;

  /// 创意工坊空状态信息
  ///
  /// In zh, this message translates to:
  /// **'暂无创意项目'**
  String get noCreativeProjects;

  /// 创意工坊创建提示
  ///
  /// In zh, this message translates to:
  /// **'点击右下角按钮创建新的创意项目'**
  String get createNewCreativeProject;

  /// 默认新创意想法标题
  ///
  /// In zh, this message translates to:
  /// **'新创意想法'**
  String get newCreativeIdea;

  /// 默认新创意想法描述
  ///
  /// In zh, this message translates to:
  /// **'这是一个新的创意想法'**
  String get newCreativeDescription;

  /// 默认新创意想法内容
  ///
  /// In zh, this message translates to:
  /// **'详细的创意描述...'**
  String get detailedCreativeContent;

  /// 创意项目创建成功信息
  ///
  /// In zh, this message translates to:
  /// **'创意项目创建成功'**
  String get creativeProjectCreated;

  /// 编辑功能待办信息
  ///
  /// In zh, this message translates to:
  /// **'编辑功能待实现'**
  String get editFunctionTodo;

  /// 创意项目删除成功信息
  ///
  /// In zh, this message translates to:
  /// **'创意项目已删除'**
  String get creativeProjectDeleted;

  /// 打卡系统初始化信息
  ///
  /// In zh, this message translates to:
  /// **'正在初始化桌宠打卡系统...'**
  String get initializingPunchIn;

  /// 等级标签
  ///
  /// In zh, this message translates to:
  /// **'等级'**
  String get level;

  /// 今日打卡标题
  ///
  /// In zh, this message translates to:
  /// **'今日打卡'**
  String get todayPunchIn;

  /// 立即打卡按钮
  ///
  /// In zh, this message translates to:
  /// **'立即打卡'**
  String get punchNow;

  /// 每日限制达到信息
  ///
  /// In zh, this message translates to:
  /// **'今日打卡次数已达上限'**
  String get dailyLimitReached;

  /// 打卡统计标题
  ///
  /// In zh, this message translates to:
  /// **'打卡统计'**
  String get punchInStats;

  /// 总打卡次数统计
  ///
  /// In zh, this message translates to:
  /// **'总打卡次数'**
  String get totalPunches;

  /// 今日剩余次数
  ///
  /// In zh, this message translates to:
  /// **'今日剩余次数'**
  String get remainingToday;

  /// 最近打卡记录标题
  ///
  /// In zh, this message translates to:
  /// **'最近打卡记录'**
  String get recentPunches;

  /// 无打卡记录信息
  ///
  /// In zh, this message translates to:
  /// **'暂无打卡记录'**
  String get noPunchRecords;

  /// 打卡成功信息
  ///
  /// In zh, this message translates to:
  /// **'打卡成功！获得 {xp} 经验值'**
  String punchSuccessWithXP(int xp);

  /// 上次打卡时间
  ///
  /// In zh, this message translates to:
  /// **'上次打卡：{time}'**
  String lastPunchTime(String time);

  /// 打卡次数
  ///
  /// In zh, this message translates to:
  /// **'第 {count} 次打卡'**
  String punchCount(int count);

  /// 核心功能分组标题
  ///
  /// In zh, this message translates to:
  /// **'核心功能'**
  String get coreFeatures;

  /// 内置模块分组标题
  ///
  /// In zh, this message translates to:
  /// **'内置模块'**
  String get builtinModules;

  /// 扩展模块分组标题
  ///
  /// In zh, this message translates to:
  /// **'扩展模块'**
  String get extensionModules;

  /// 系统功能分组标题
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get system;

  /// 版本信息
  ///
  /// In zh, this message translates to:
  /// **'Phase 1 - v1.0.0'**
  String get versionInfo;

  /// 模块状态信息
  ///
  /// In zh, this message translates to:
  /// **'模块: {active}/{total} 活跃'**
  String moduleStatus(String active, String total);

  /// 模块管理功能
  ///
  /// In zh, this message translates to:
  /// **'模块管理'**
  String get moduleManagement;

  /// 版权信息
  ///
  /// In zh, this message translates to:
  /// **'© 2025 Pet Assistant\nPowered by Flutter'**
  String get copyrightInfo;

  /// 关于页面
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// 模块管理对话框标题
  ///
  /// In zh, this message translates to:
  /// **'模块管理'**
  String get moduleManagementDialog;

  /// 模块管理待办信息
  ///
  /// In zh, this message translates to:
  /// **'模块管理功能将在后续版本中实现'**
  String get moduleManagementTodo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
