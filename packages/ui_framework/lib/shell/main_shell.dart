/*
---------------------------------------------------------------
File name:          main_shell.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/27
Description:        主壳程序 - 提供应用主要布局结构，集成真实模块Widget，支持i18n参数传递
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 1.5 NavigationDrawer本地化 - 添加NavigationDrawer本地化支持;
    2025/06/26: Phase 1.5 i18n集成 - 修改为参数传递方式，避免包间耦合;
    2025/06/26: Phase 1.5 模块集成 - 替换占位符为真实模块Widget;
    2025/06/26: Phase 1.5 重构 - 简化实现，移除路由依赖;
    2025/06/25: Initial creation - 主壳程序布局实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:notes_hub/notes_hub.dart';
import 'package:workshop/workshop.dart';
import 'package:punch_in/punch_in.dart';
import 'package:ui_framework/shell/navigation_drawer.dart';
// import 'package:core_services/core_services.dart';

// BusinessModuleLocalizations is imported from notes_hub package

/// 本地化字符串数据类
class MainShellLocalizations {
  final String appTitle;
  final String home;
  final String notesHub;
  final String workshop;
  final String punchIn;
  final String settings;
  final String welcomeMessage;
  final String appDescription;
  final String moduleStatusTitle;
  final String notesHubDescription;
  final String workshopDescription;
  final String punchInDescription;
  
  // 业务模块本地化字段
  final String note;
  final String todo;
  final String project;
  final String reminder;
  final String habit;
  final String goal;
  final String allTypes;
  final String total;
  final String active;
  final String completed;
  final String archived;
  final String searchHint;
  final String initializing;
  final String priorityUrgent;
  final String priorityHigh;
  final String priorityMedium;
  final String priorityLow;
  final String createNew;
  final String noItemsFound;
  final String createItemHint;
  final String confirmDelete;
  final String confirmDeleteMessage;
  final String itemDeleted;
  final String newItemCreated;
  final String save;
  final String cancel;
  final String edit;
  final String delete;
  final String title;
  final String content;
  final String priority;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String dueDate;
  final String tags;
  final String close;
  final String createFailed;
  final String deleteSuccess;
  final String deleteFailed;
  final String itemNotFound;
  
  // 创意工坊本地化字段
  final String initializingWorkshop;
  final String noCreativeProjects;
  final String createNewCreativeProject;
  final String newCreativeIdea;
  final String newCreativeDescription;
  final String detailedCreativeContent;
  final String creativeProjectCreated;
  final String editFunctionTodo;
  final String creativeProjectDeleted;
  
  // 打卡模块本地化字段
  final String initializingPunchIn;
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
  
  // NavigationDrawer本地化字段
  final String coreFeatures;
  final String builtinModules;
  final String extensionModules;
  final String system;
  final String petAssistant;
  final String versionInfo;
  final String moduleStatus;
  final String moduleManagement;
  final String copyrightInfo;
  final String about;
  final String moduleManagementDialog;
  final String moduleManagementTodo;

  const MainShellLocalizations({
    required this.appTitle,
    required this.home,
    required this.notesHub,
    required this.workshop,
    required this.punchIn,
    required this.settings,
    required this.welcomeMessage,
    required this.appDescription,
    required this.moduleStatusTitle,
    required this.notesHubDescription,
    required this.workshopDescription,
    required this.punchInDescription,
    required this.note,
    required this.todo,
    required this.project,
    required this.reminder,
    required this.habit,
    required this.goal,
    required this.allTypes,
    required this.total,
    required this.active,
    required this.completed,
    required this.archived,
    required this.searchHint,
    required this.initializing,
    required this.priorityUrgent,
    required this.priorityHigh,
    required this.priorityMedium,
    required this.priorityLow,
    required this.createNew,
    required this.noItemsFound,
    required this.createItemHint,
    required this.confirmDelete,
    required this.confirmDeleteMessage,
    required this.itemDeleted,
    required this.newItemCreated,
    required this.save,
    required this.cancel,
    required this.edit,
    required this.delete,
    required this.title,
    required this.content,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.dueDate,
    required this.tags,
    required this.close,
    required this.createFailed,
    required this.deleteSuccess,
    required this.deleteFailed,
    required this.itemNotFound,
    required this.initializingWorkshop,
    required this.noCreativeProjects,
    required this.createNewCreativeProject,
    required this.newCreativeIdea,
    required this.newCreativeDescription,
    required this.detailedCreativeContent,
    required this.creativeProjectCreated,
    required this.editFunctionTodo,
    required this.creativeProjectDeleted,
    required this.initializingPunchIn,
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
    required this.coreFeatures,
    required this.builtinModules,
    required this.extensionModules,
    required this.system,
    required this.petAssistant,
    required this.versionInfo,
    required this.moduleStatus,
    required this.moduleManagement,
    required this.copyrightInfo,
    required this.about,
    required this.moduleManagementDialog,
    required this.moduleManagementTodo,
  });
}

/// 主壳程序 - 应用的主要布局结构
class MainShell extends StatefulWidget {
  final MainShellLocalizations? localizations;
  final Function(Locale)? onLocaleChanged;
  
  const MainShell({super.key, this.localizations, this.onLocaleChanged});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  
  // 默认中文本地化（回退方案）
  MainShellLocalizations get localizations => widget.localizations ?? const MainShellLocalizations(
    appTitle: '桌宠助手',
    home: '首页',
    notesHub: '事务中心',
    workshop: '创意工坊',
    punchIn: '打卡',
    settings: '设置',
    welcomeMessage: '欢迎使用桌宠助手',
    appDescription: '基于包驱动架构的模块化宠物管理应用',
    moduleStatusTitle: '模块状态',
    notesHubDescription: '管理您的笔记和任务',
    workshopDescription: '记录您的创意和灵感',
    punchInDescription: '记录您的考勤时间',
    note: '笔记',
    todo: '待办',
    project: '项目',
    reminder: '提醒',
    habit: '习惯',
    goal: '目标',
    allTypes: '全部类型',
    total: '总计',
    active: '活跃',
    completed: '已完成',
    archived: '已归档',
    searchHint: '搜索事务...',
    initializing: '正在初始化事务管理中心...',
    priorityUrgent: '紧急',
    priorityHigh: '高',
    priorityMedium: '中',
    priorityLow: '低',
    createNew: '新建{itemType}',
    noItemsFound: '暂无{itemType}',
    createItemHint: '点击 + 按钮创建{itemType}',
    confirmDelete: '确认删除',
    confirmDeleteMessage: '确定要删除"{itemName}"吗？此操作无法撤销。',
    itemDeleted: '项目已删除',
    newItemCreated: '已创建新的{itemType}',
    save: '保存',
    cancel: '取消',
    edit: '编辑',
    delete: '删除',
    title: '标题',
    content: '内容',
    priority: '优先级',
    status: '状态',
    createdAt: '创建时间',
    updatedAt: '更新时间',
    dueDate: '截止日期',
    tags: '标签',
    close: '关闭',
    createFailed: '创建失败',
    deleteSuccess: '事务删除成功',
    deleteFailed: '删除失败',
    itemNotFound: '事务不存在',
    initializingWorkshop: '正在初始化创意工坊...',
    noCreativeProjects: '暂无创意项目',
    createNewCreativeProject: '新建创意项目',
    newCreativeIdea: '新创意想法',
    newCreativeDescription: '描述创意想法',
    detailedCreativeContent: '创意详细内容',
    creativeProjectCreated: '创意项目已创建',
    editFunctionTodo: '编辑创意项目',
    creativeProjectDeleted: '创意项目已删除',
    initializingPunchIn: '正在初始化打卡...',
    currentXP: '当前经验值',
    level: '等级',
    todayPunchIn: '今日打卡',
    punchNow: '立即打卡',
    dailyLimitReached: '今日打卡次数已达上限',
    punchInStats: '打卡统计',
    totalPunches: '总打卡次数',
    remainingToday: '今日剩余打卡次数',
    recentPunches: '最近打卡记录',
    noPunchRecords: '暂无打卡记录',
    punchSuccessWithXP: '打卡成功并获得经验值',
    lastPunchTime: '上次打卡时间',
    punchCount: '打卡次数',
    coreFeatures: '核心功能',
    builtinModules: '内置模块',
    extensionModules: '扩展模块',
    system: '系统',
    petAssistant: '桌宠助手',
    versionInfo: 'Phase 1 - v1.0.0',
    moduleStatus: '模块: {active}/{total} 活跃',
    moduleManagement: '模块管理',
    copyrightInfo: '© 2025 桌宠助手\nPowered by Flutter',
    about: '关于',
    moduleManagementDialog: '模块管理',
    moduleManagementTodo: '模块管理功能将在后续版本中实现',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
      drawer: AdaptiveNavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // 关闭drawer
        },
        localizations: localizations,
        isDesktopMode: false, // drawer模式始终为移动端模式
        onLocaleChanged: widget.onLocaleChanged,
      ),
    );
  }

  Widget _buildBody() {
    // 创建业务模块本地化
    final businessModuleLocalizations = BusinessModuleLocalizations(
      notesHubTitle: localizations.notesHub,
      workshopTitle: localizations.workshop,
      punchInTitle: localizations.punchIn,
      note: localizations.note,
      todo: localizations.todo,
      project: localizations.project,
      reminder: localizations.reminder,
      habit: localizations.habit,
      goal: localizations.goal,
      allTypes: localizations.allTypes,
      total: localizations.total,
      active: localizations.active,
      completed: localizations.completed,
      archived: localizations.archived,
      searchHint: localizations.searchHint,
      initializing: localizations.initializing,
      priorityUrgent: localizations.priorityUrgent,
      priorityHigh: localizations.priorityHigh,
      priorityMedium: localizations.priorityMedium,
      priorityLow: localizations.priorityLow,
      createNew: localizations.createNew,
      noItemsFound: localizations.noItemsFound,
      createItemHint: localizations.createItemHint,
      confirmDelete: localizations.confirmDelete,
      confirmDeleteMessage: localizations.confirmDeleteMessage,
      itemDeleted: localizations.itemDeleted,
      newItemCreated: localizations.newItemCreated,
      save: localizations.save,
      cancel: localizations.cancel,
      edit: localizations.edit,
      delete: localizations.delete,
      title: localizations.title,
      content: localizations.content,
      priority: localizations.priority,
      status: localizations.status,
      createdAt: localizations.createdAt,
      updatedAt: localizations.updatedAt,
      dueDate: localizations.dueDate,
      tags: localizations.tags,
      close: localizations.close,
      createFailed: localizations.createFailed,
      deleteSuccess: localizations.deleteSuccess,
      deleteFailed: localizations.deleteFailed,
      itemNotFound: localizations.itemNotFound,
    );

    // 创建Workshop本地化
    final workshopLocalizations = WorkshopLocalizations(
      workshopTitle: localizations.workshop,
      initializing: localizations.initializingWorkshop,
      total: localizations.total,
      active: localizations.active,
      completed: localizations.completed,
      archived: localizations.archived,
      noCreativeProjects: localizations.noCreativeProjects,
      createNewCreativeProject: localizations.createNewCreativeProject,
      newCreativeIdea: localizations.newCreativeIdea,
      newCreativeDescription: localizations.newCreativeDescription,
      detailedCreativeContent: localizations.detailedCreativeContent,
      creativeProjectCreated: localizations.creativeProjectCreated,
      editFunctionTodo: localizations.editFunctionTodo,
      creativeProjectDeleted: localizations.creativeProjectDeleted,
      edit: localizations.edit,
      delete: localizations.delete,
    );

    // 创建PunchIn本地化
    final punchInLocalizations = PunchInLocalizations(
      punchInTitle: localizations.punchIn,
      initializing: localizations.initializingPunchIn,
      currentXP: localizations.currentXP,
      level: localizations.level,
      todayPunchIn: localizations.todayPunchIn,
      punchNow: localizations.punchNow,
      dailyLimitReached: localizations.dailyLimitReached,
      punchInStats: localizations.punchInStats,
      totalPunches: localizations.totalPunches,
      remainingToday: localizations.remainingToday,
      recentPunches: localizations.recentPunches,
      noPunchRecords: localizations.noPunchRecords,
      punchSuccessWithXP: localizations.punchSuccessWithXP,
      lastPunchTime: localizations.lastPunchTime,
      punchCount: localizations.punchCount,
    );

    switch (_selectedIndex) {
      case 0:
        return _HomePage(localizations: localizations);
      case 1:
        return NotesHubWidget(localizations: businessModuleLocalizations);
      case 2:
        return WorkshopWidget(localizations: workshopLocalizations);
      case 3:
        return PunchInWidget(localizations: punchInLocalizations);
      default:
        return _HomePage(localizations: localizations);
    }
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: localizations.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.note),
          label: localizations.notesHub,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.build),
          label: localizations.workshop,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.access_time),
          label: localizations.punchIn,
        ),
      ],
    );
  }


}

// 首页显示模块统计和快捷入口
class _HomePage extends StatelessWidget {
  final MainShellLocalizations localizations;
  
  const _HomePage({required this.localizations});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 欢迎卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.welcomeMessage,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.appDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 模块状态卡片
          Text(
            localizations.moduleStatusTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // 模块状态列表
          _buildModuleStatusCard(
            localizations.notesHub,
            Icons.note,
            Colors.blue,
            localizations.notesHubDescription,
          ),
          _buildModuleStatusCard(
            localizations.workshop,
            Icons.build,
            Colors.orange,
            localizations.workshopDescription,
          ),
          _buildModuleStatusCard(
            localizations.punchIn,
            Icons.access_time,
            Colors.green,
            localizations.punchInDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleStatusCard(
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
          onTap: () {
          // 可以添加导航到对应模块的逻辑
          },
      ),
    );
  }
} 