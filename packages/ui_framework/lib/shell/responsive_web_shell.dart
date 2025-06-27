/*
---------------------------------------------------------------
File name:          responsive_web_shell.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        ResponsiveWebShell - 基于AppShell的Web端响应式外壳
---------------------------------------------------------------
Change History:
    2025/06/28: Initial creation - Phase 2.1 三端UI框架，基于现有AppShell架构;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:ui_framework/ui_framework.dart';

/// ResponsiveWebShell - Web端响应式外壳
/// 
/// 基于AppShell架构，专为Web端设计的响应式外壳：
/// - 自适应屏幕尺寸（桌面/平板/移动）
/// - Web端专用导航模式（侧边栏、面包屑）
/// - 与现有MainShell和NavigationDrawer兼容
class ResponsiveWebShell extends AppShell {
  const ResponsiveWebShell({
    super.key,
    super.localizations,
    super.onLocaleChanged,
    required super.modules,
  }) : super(shellType: ShellType.standard); // 基于standard但有Web适配

  @override
  State<ResponsiveWebShell> createState() => _ResponsiveWebShellState();
}

class _ResponsiveWebShellState extends State<ResponsiveWebShell> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  
  // 默认中文本地化（回退方案）
  MainShellLocalizations get localizations => widget.localizations ?? _getDefaultLocalizations();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = _getBreakpoint(constraints.maxWidth);
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Row(
            children: [
              // 侧边导航栏（桌面和平板）
              if (breakpoint != ScreenSize.mobile || _isSidebarExpanded)
                _buildSidebar(breakpoint),
              
              // 主内容区域
              Expanded(
                child: Column(
                  children: [
                    // 顶部导航栏
                    _buildTopBar(breakpoint),
                    
                    // 面包屑导航
                    _buildBreadcrumbs(),
                    
                    // 主体内容
                    Expanded(
                      child: _buildMainContent(breakpoint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 移动端抽屉
          drawer: breakpoint == ScreenSize.mobile ? _buildMobileDrawer() : null,
        );
      },
    );
  }

  /// 构建侧边导航栏
  Widget _buildSidebar(ScreenSize breakpoint) {
    final isCollapsed = breakpoint == ScreenSize.tablet || 
                       (breakpoint == ScreenSize.desktop && !_isSidebarExpanded);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 72 : 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // 顶部标题区域
          _buildSidebarHeader(isCollapsed),
          
          // 导航菜单
          Expanded(
            child: _buildSidebarMenu(isCollapsed),
          ),
          
          // 底部操作区域
          _buildSidebarFooter(isCollapsed),
        ],
      ),
    );
  }

  /// 构建侧边栏头部
  Widget _buildSidebarHeader(bool isCollapsed) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 应用图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.pets,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
          
          // 应用标题
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations.appTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Web端',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建侧边栏菜单
  Widget _buildSidebarMenu(bool isCollapsed) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: widget.modules.length,
      itemBuilder: (context, index) {
        final module = widget.modules[index];
        final isSelected = _selectedIndex == index;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: isSelected 
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _selectModule(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      module.icon,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          module.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSecondaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建侧边栏底部
  Widget _buildSidebarFooter(bool isCollapsed) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 折叠/展开按钮
          if (!isCollapsed)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _toggleSidebar,
                icon: const Icon(Icons.menu_open),
                label: const Text('折叠侧栏'),
              ),
            )
          else
            IconButton(
              onPressed: _toggleSidebar,
              icon: const Icon(Icons.menu),
              tooltip: '展开侧栏',
            ),
          
          const SizedBox(height: 8),
          
          // 设置按钮
          if (!isCollapsed)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _showSettings,
                icon: const Icon(Icons.settings),
                label: Text(localizations.settings),
              ),
            )
          else
            IconButton(
              onPressed: _showSettings,
              icon: const Icon(Icons.settings),
              tooltip: localizations.settings,
            ),
        ],
      ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildTopBar(ScreenSize breakpoint) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // 移动端菜单按钮
          if (breakpoint == ScreenSize.mobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          
          // 页面标题
          Expanded(
            child: Text(
              _getPageTitle(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // 搜索框（桌面端）
          if (breakpoint == ScreenSize.desktop)
            SizedBox(
              width: 300,
              child: SearchBar(
                hintText: '搜索...',
                leading: const Icon(Icons.search),
                onTap: _showSearch,
              ),
            ),
          
          const SizedBox(width: 16),
          
          // 语言切换按钮
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageDialog,
            tooltip: '切换语言',
          ),
          
          // 用户菜单
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            onSelected: _handleUserMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('个人资料'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('设置'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('关于'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建面包屑导航
  Widget _buildBreadcrumbs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.home,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            localizations.home,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            _getPageTitle(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(ScreenSize breakpoint) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _getCurrentModuleWidget(),
    );
  }

  /// 构建移动端抽屉
  Widget _buildMobileDrawer() {
    return AdaptiveNavigationDrawer(
      localizations: localizations,
      onLocaleChanged: widget.onLocaleChanged,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        _selectModule(index);
        Navigator.pop(context);
      },
      isDesktopMode: false,
    );
  }

  /// 获取当前模块Widget
  Widget _getCurrentModuleWidget() {
    if (_selectedIndex >= 0 && _selectedIndex < widget.modules.length) {
      return widget.modules[_selectedIndex].widgetBuilder(context);
    }
    return const Center(child: Text('模块未找到'));
  }

  /// 获取页面标题
  String _getPageTitle() {
    if (_selectedIndex >= 0 && _selectedIndex < widget.modules.length) {
      return widget.modules[_selectedIndex].name;
    }
    return localizations.appTitle;
  }

  /// 获取屏幕断点
  ScreenSize _getBreakpoint(double width) {
    if (width >= 1200) return ScreenSize.desktop;
    if (width >= 768) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  // 事件处理方法
  void _selectModule(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  void _showSearch() {
    // TODO: 实现搜索功能
  }

  void _showSettings() {
    // TODO: 实现设置页面
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('中文'),
              onTap: () {
                widget.onLocaleChanged?.call(const Locale('zh'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                widget.onLocaleChanged?.call(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserMenuSelection(String value) {
    switch (value) {
      case 'profile':
        // TODO: 导航到个人资料
        break;
      case 'settings':
        _showSettings();
        break;
      case 'about':
        // TODO: 显示关于对话框
        break;
    }
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
      versionInfo: 'Phase 2.1 - Web模式',
      moduleStatus: '模块: {active}/{total} 活跃',
      moduleManagement: '模块管理',
      copyrightInfo: '© 2025 桌宠AI助理平台\nPowered by Flutter Web',
      about: '关于',
      moduleManagementDialog: '模块管理',
      moduleManagementTodo: '模块管理功能将在Phase 2.1中实现',
    );
  }
}

/// 屏幕尺寸枚举
enum ScreenSize {
  mobile,
  tablet,
  desktop,
} 