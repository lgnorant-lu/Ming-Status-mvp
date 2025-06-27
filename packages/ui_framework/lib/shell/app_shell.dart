/*
---------------------------------------------------------------
File name:          app_shell.dart
Author:             Ignorant-lu  
Date created:       2025/06/27
Last modified:      2025/06/27
Description:        AppShell抽象基类 - 定义双端外壳的统一接口，支持"空间化OS"和"沉浸式标准应用"模式
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0a - 创建AppShell抽象接口，为双端自适应UI框架奠定基础;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:desktop_environment/desktop_environment.dart';
import 'main_shell.dart';

/// 外壳类型枚举
enum ShellType {
  /// 移动端"沉浸式标准应用"模式
  standard,
  /// PC端"空间化OS"模式  
  spatial,
}

/// 模块信息类
class ModuleInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Widget Function(BuildContext context) widgetBuilder;
  final bool isActive;
  final int order;

  const ModuleInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.widgetBuilder,
    this.isActive = true,
    this.order = 0,
  });
}

/// AppShell抽象基类
/// 
/// 定义双端外壳的统一接口，支持：
/// - Platform自动检测和外壳选择
/// - 模块注册和管理
/// - 本地化支持
/// - 主题切换
abstract class AppShell extends StatefulWidget {
  /// 本地化数据
  final MainShellLocalizations? localizations;
  
  /// 语言切换回调
  final Function(Locale)? onLocaleChanged;
  
  /// 注册的模块列表
  final List<ModuleInfo> modules;
  
  /// 外壳类型
  final ShellType shellType;

  const AppShell({
    super.key,
    this.localizations,
    this.onLocaleChanged,
    required this.modules,
    required this.shellType,
  });

  /// 工厂构造函数：根据平台自动选择外壳类型
  static AppShell adaptive({
    Key? key,
    MainShellLocalizations? localizations,
    Function(Locale)? onLocaleChanged,
    List<ModuleInfo>? modules,
  }) {
    final defaultModules = modules ?? _getDefaultModules();
    
    // 平台检测逻辑
    if (kIsWeb) {
      // Web端临时使用空间化OS模式体验 (Phase 2.0b Demo)
      return SpatialOsShell(
        key: key,
        localizations: localizations,
        onLocaleChanged: onLocaleChanged,
        modules: defaultModules,
        windowManager: WindowManager(), // 临时为Web提供WindowManager体验
      );
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
               defaultTargetPlatform == TargetPlatform.macOS ||
               defaultTargetPlatform == TargetPlatform.linux) {
      // 桌面端使用空间化OS模式（Phase 2.0b实现）
      return SpatialOsShell(
        key: key,
        localizations: localizations,
        onLocaleChanged: onLocaleChanged,
        modules: defaultModules,
        windowManager: WindowManager(), // Phase 2.0b创建WindowManager实例
      );
    } else {
      // 移动端使用标准模式
      return StandardAppShell(
        key: key,
        localizations: localizations,
        onLocaleChanged: onLocaleChanged,
        modules: defaultModules,
      );
    }
  }

  /// 获取默认模块列表
  static List<ModuleInfo> _getDefaultModules() {
    return [
      ModuleInfo(
        id: 'home',
        name: '首页',
        description: '应用主页和概览',
        icon: Icons.home,
        widgetBuilder: (context) => const _PlaceholderWidget(title: '首页'),
        order: 0,
      ),
      ModuleInfo(
        id: 'notes_hub',
        name: '事务中心',
        description: '管理您的笔记和任务',
        icon: Icons.note,
        widgetBuilder: (context) => const _PlaceholderWidget(title: '事务中心'),
        order: 1,
      ),
      ModuleInfo(
        id: 'workshop',
        name: '创意工坊',
        description: '记录您的创意和灵感',
        icon: Icons.build,
        widgetBuilder: (context) => const _PlaceholderWidget(title: '创意工坊'),
        order: 2,
      ),
      ModuleInfo(
        id: 'punch_in',
        name: '打卡',
        description: '记录您的考勤时间',
        icon: Icons.access_time,
        widgetBuilder: (context) => const _PlaceholderWidget(title: '打卡'),
        order: 3,
      ),
    ];
  }
}

/// 临时占位符Widget
class _PlaceholderWidget extends StatelessWidget {
  final String title;
  
  const _PlaceholderWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '$title 模块',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Phase 2.0 Sprint 2.0a\n模块占位符UI',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 标准应用外壳 - 移动端"沉浸式标准应用"模式
class StandardAppShell extends AppShell {
  const StandardAppShell({
    super.key,
    super.localizations,
    super.onLocaleChanged,
    required super.modules,
  }) : super(shellType: ShellType.standard);

  @override
  State<StandardAppShell> createState() => _StandardAppShellState();
}

class _StandardAppShellState extends State<StandardAppShell> {
  int _selectedIndex = 0;
  
  // 默认中文本地化（回退方案）
  MainShellLocalizations get localizations => widget.localizations ?? _getDefaultLocalizations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
      drawer: _buildNavigationDrawer(),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex >= 0 && _selectedIndex < widget.modules.length) {
      final module = widget.modules[_selectedIndex];
      return module.widgetBuilder(context);
    }
    return const Center(
      child: Text('模块未找到'),
    );
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
      items: widget.modules.map((module) => BottomNavigationBarItem(
        icon: Icon(module.icon),
        label: module.name,
      )).toList(),
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Phase 2.0 Sprint 2.0a\n双端自适应UI框架',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          ...widget.modules.asMap().entries.map((entry) {
            final index = entry.key;
            final module = entry.value;
            return ListTile(
              leading: Icon(module.icon),
              title: Text(module.name),
              subtitle: Text(module.description),
              selected: _selectedIndex == index,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                Navigator.pop(context);
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(localizations.settings),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到设置页面
            },
          ),
        ],
      ),
    );
  }

  /// 获取默认本地化
  static MainShellLocalizations _getDefaultLocalizations() {
    return const MainShellLocalizations(
      appTitle: '桌宠AI助理平台',
      home: '首页',
      notesHub: '事务中心',
      workshop: '创意工坊',
      punchIn: '打卡',
      settings: '设置',
      welcomeMessage: '欢迎使用桌宠AI助理平台',
      appDescription: '基于"桌宠-总线"插件式架构的智能助理平台',
      moduleStatusTitle: '模块状态',
      notesHubDescription: '管理您的笔记和任务',
      workshopDescription: '记录您的创意和灵感',
      punchInDescription: '记录您的考勤时间',
      // 其他字段使用默认值...
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
      initializing: '正在初始化...',
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
      deleteSuccess: '删除成功',
      deleteFailed: '删除失败',
      itemNotFound: '项目不存在',
      initializingWorkshop: '正在初始化创意工坊...',
      noCreativeProjects: '暂无创意项目',
      createNewCreativeProject: '新建创意项目',
      newCreativeIdea: '新创意想法',
      newCreativeDescription: '描述创意想法',
      detailedCreativeContent: '创意详细内容',
      creativeProjectCreated: '创意项目已创建',
      editFunctionTodo: '编辑功能待实现',
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
      versionInfo: 'Phase 2.0 - v2.0.0',
      moduleStatus: '模块: {active}/{total} 活跃',
      moduleManagement: '模块管理',
      copyrightInfo: '© 2025 桌宠AI助理平台\nPowered by Flutter',
      about: '关于',
      moduleManagementDialog: '模块管理',
      moduleManagementTodo: '模块管理功能将在Phase 2.1中实现',
    );
  }
} 