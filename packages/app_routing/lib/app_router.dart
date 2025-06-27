/*
---------------------------------------------------------------
File name:          app_router.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/28
Description:        应用路由配置 - 基于go_router的声明式路由管理，支持三端自适应UI框架动态切换
---------------------------------------------------------------
Change History:
    2025/06/28: Phase 2.1 Step 6 - 重构为DisplayModeAwareShell，实现基于DisplayModeService的三端动态切换逻辑;
    2025/06/27: Phase 2.0 Sprint 2.0a - 集成StandardAppShell，支持平台自动检测和双端外壳切换;
    2025/06/26: Phase 1.5 重构 - 移除重复定义，导入route_definitions;
    2025/06/25: Initial creation for Phase 1 routing foundation;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_framework/ui_framework.dart';
import 'package:core_services/core_services.dart';
import 'package:notes_hub/notes_hub.dart';
import 'package:workshop/workshop.dart';
import 'package:punch_in/punch_in.dart';
import 'route_definitions.dart';

/// 应用路由配置类
/// 
/// Phase 2.1 更新：集成DisplayModeAwareShell，支持三端UI外壳动态切换：
/// - Desktop模式：SpatialOsShell (桌面空间化OS)
/// - Mobile模式：ModularMobileShell (真正的原生模块化应用)
/// - Web模式：ResponsiveWebShell (响应式Web应用)
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true, // 开发模式下启用路由调试日志
    
    // 错误页面处理
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '路径未找到: ${state.uri}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
    
    routes: [
      // 主框架路由 - 使用三端自适应外壳
      ShellRoute(
        builder: (context, state, child) {
          return DisplayModeAwareShell(
            localizations: _getDefaultLocalizations(),
            onLocaleChanged: _handleLocaleChange,
            modules: _buildModuleList(),
          );
        },
        routes: [
          // 主页路由 - 应用概览和模块状态
          GoRoute(
            path: RoutePaths.home,
            name: 'home',
            builder: (context, state) => _buildHomePage(context),
          ),
          
          // 事务管理中心路由
          GoRoute(
            path: RoutePaths.notesHub,
            name: 'notes-hub',
            builder: (context, state) => NotesHubWidget(
              localizations: _getNotesHubLocalizations(),
            ),
          ),
          
          // 创意工坊路由
          GoRoute(
            path: RoutePaths.workshop,
            name: 'workshop',
            builder: (context, state) => WorkshopWidget(
              localizations: _getWorkshopLocalizations(),
            ),
          ),
          
          // 打卡模块路由
          GoRoute(
            path: RoutePaths.punchIn,
            name: 'punch-in',
            builder: (context, state) => PunchInWidget(
              localizations: _getPunchInLocalizations(),
            ),
          ),
        ],
      ),
      
      // 独立页面路由（不在主框架内）
      
      // 设置页面路由 - Phase 2.1将集成DisplayMode切换功能
      GoRoute(
        path: RoutePaths.settings,
        name: 'settings',
        builder: (context, state) => _buildSettingsPage(context),
      ),
      
      // 关于页面路由
      GoRoute(
        path: RoutePaths.about,
        name: 'about',
        builder: (context, state) => _buildPlaceholderPage(
          context,
          '关于',
          '桌宠AI助理平台 v2.1.0\nPhase 2.1 三端自适应UI框架',
        ),
      ),
    ],
  );

  /// 获取路由器实例
  static GoRouter get router => _router;
  
  /// 处理语言切换 - 未来可与国际化系统集成
  static void _handleLocaleChange(Locale locale) {
    // TODO: Phase 2.2 - 集成真正的国际化系统
    // 目前暂时处理为空，未来可以更新所有本地化字符串
    debugPrint('Locale changed to: ${locale.languageCode}');
  }
  
  /// 导航到指定路径
  static void navigateTo(BuildContext context, String path, {Map<String, String>? queryParameters}) {
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final uri = Uri(path: path, queryParameters: queryParameters);
      context.go(uri.toString());
    } else {
      context.go(path);
    }
  }
  
  /// 导航到指定路径（新页面入栈）
  static void pushTo(BuildContext context, String path, {Map<String, String>? queryParameters}) {
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final uri = Uri(path: path, queryParameters: queryParameters);
      context.push(uri.toString());
    } else {
      context.push(path);
    }
  }
  
  /// 返回上一页
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // 如果无法返回，则导航到首页
      context.go(RoutePaths.home);
    }
  }

  /// 构建模块列表 - 集成真实的业务模块
  static List<ModuleInfo> _buildModuleList() {
    return [
      ModuleInfo(
        id: 'home',
        name: '首页',
        description: '应用概览和模块状态',
        icon: Icons.home,
        widgetBuilder: (context) => _buildHomePage(context),
        order: 0,
      ),
      ModuleInfo(
        id: 'notes_hub',
        name: '事务中心',
        description: '管理您的笔记和任务',
        icon: Icons.note,
        widgetBuilder: (context) => NotesHubWidget(
          localizations: _getNotesHubLocalizations(),
        ),
        order: 1,
      ),
      ModuleInfo(
        id: 'workshop',
        name: '创意工坊',
        description: '记录您的创意和灵感',
        icon: Icons.build,
        widgetBuilder: (context) => WorkshopWidget(
          localizations: _getWorkshopLocalizations(),
        ),
        order: 2,
      ),
      ModuleInfo(
        id: 'punch_in',
        name: '打卡',
        description: '记录您的考勤时间',
        icon: Icons.access_time,
        widgetBuilder: (context) => PunchInWidget(
          localizations: _getPunchInLocalizations(),
        ),
        order: 3,
      ),
    ];
  }

  /// 构建主页Widget
  static Widget _buildHomePage(BuildContext context) {
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
                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '欢迎使用桌宠AI助理平台',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '基于"桌宠-总线"插件式架构的智能助理平台',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Phase 2.1 三端架构状态卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Phase 2.1 三端自适应架构',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✅ ModularMobileShell (真正模块化移动端) 已实现\n✅ DisplayModeAwareShell (三端智能适配) 已集成\n✅ DisplayModeService (动态切换服务) 已启用',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  
                  // DisplayModeService实时状态
                  StreamBuilder<DisplayMode>(
                    stream: displayModeService.currentModeStream,
                    initialData: displayModeService.currentMode,
                    builder: (context, snapshot) {
                      final currentMode = snapshot.data ?? DisplayMode.mobile;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phonelink_setup,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '当前显示模式: ${currentMode.displayName}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    currentMode.description,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => navigateTo(context, RoutePaths.settings),
                              child: const Text('切换'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 模块状态
          Text(
            '模块状态',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._buildModuleStatusCards(context),
        ],
      ),
    );
  }

  /// 构建模块状态卡片
  static List<Widget> _buildModuleStatusCards(BuildContext context) {
    final modules = _buildModuleList();
    return modules.map((module) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(module.icon),
        title: Text(module.name),
        subtitle: Text(module.description),
        trailing: Icon(
          module.isActive ? Icons.check_circle : Icons.radio_button_unchecked,
          color: module.isActive 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    )).toList();
  }

  /// 获取默认本地化
  static MainShellLocalizations _getDefaultLocalizations() {
    // 这里返回一个简化的本地化对象，实际应该从国际化系统获取
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
      // 简化的字段，使用默认值
      note: '笔记', todo: '待办', project: '项目', reminder: '提醒',
      habit: '习惯', goal: '目标', allTypes: '全部类型', total: '总计',
      active: '活跃', completed: '已完成', archived: '已归档',
      searchHint: '搜索事务...', initializing: '正在初始化...',
      priorityUrgent: '紧急', priorityHigh: '高', priorityMedium: '中', priorityLow: '低',
      createNew: '新建{itemType}', noItemsFound: '暂无{itemType}',
      createItemHint: '点击 + 按钮创建{itemType}', confirmDelete: '确认删除',
      confirmDeleteMessage: '确定要删除"{itemName}"吗？此操作无法撤销。',
      itemDeleted: '项目已删除', newItemCreated: '已创建新的{itemType}',
      save: '保存', cancel: '取消', edit: '编辑', delete: '删除',
      title: '标题', content: '内容', priority: '优先级', status: '状态',
      createdAt: '创建时间', updatedAt: '更新时间', dueDate: '截止日期',
      tags: '标签', close: '关闭', createFailed: '创建失败',
      deleteSuccess: '删除成功', deleteFailed: '删除失败', itemNotFound: '项目不存在',
      initializingWorkshop: '正在初始化创意工坊...', noCreativeProjects: '暂无创意项目',
      createNewCreativeProject: '新建创意项目', newCreativeIdea: '新创意想法',
      newCreativeDescription: '描述创意想法', detailedCreativeContent: '创意详细内容',
      creativeProjectCreated: '创意项目已创建', editFunctionTodo: '编辑功能待实现',
      creativeProjectDeleted: '创意项目已删除', initializingPunchIn: '正在初始化打卡...',
      currentXP: '当前经验值', level: '等级', todayPunchIn: '今日打卡',
      punchNow: '立即打卡', dailyLimitReached: '今日打卡次数已达上限',
      punchInStats: '打卡统计', totalPunches: '总打卡次数',
      remainingToday: '今日剩余打卡次数', recentPunches: '最近打卡记录',
      noPunchRecords: '暂无打卡记录', punchSuccessWithXP: '打卡成功并获得经验值',
      lastPunchTime: '上次打卡时间', punchCount: '打卡次数',
      coreFeatures: '核心功能', builtinModules: '内置模块',
      extensionModules: '扩展模块', system: '系统', petAssistant: '桌宠助手',
      versionInfo: 'Phase 2.0 - v2.0.0', moduleStatus: '模块: {active}/{total} 活跃',
      moduleManagement: '模块管理', copyrightInfo: '© 2025 桌宠AI助理平台\nPowered by Flutter',
      about: '关于', moduleManagementDialog: '模块管理',
      moduleManagementTodo: '模块管理功能将在Phase 2.1中实现',
    );
  }

  /// 获取NotesHub本地化
  static BusinessModuleLocalizations _getNotesHubLocalizations() {
    final shell = _getDefaultLocalizations();
    return BusinessModuleLocalizations(
      notesHubTitle: shell.notesHub,
      workshopTitle: shell.workshop,
      punchInTitle: shell.punchIn,
      note: shell.note, todo: shell.todo, project: shell.project,
      reminder: shell.reminder, habit: shell.habit, goal: shell.goal,
      allTypes: shell.allTypes, total: shell.total, active: shell.active,
      completed: shell.completed, archived: shell.archived,
      searchHint: shell.searchHint, initializing: shell.initializing,
      priorityUrgent: shell.priorityUrgent, priorityHigh: shell.priorityHigh,
      priorityMedium: shell.priorityMedium, priorityLow: shell.priorityLow,
      createNew: shell.createNew, noItemsFound: shell.noItemsFound,
      createItemHint: shell.createItemHint, confirmDelete: shell.confirmDelete,
      confirmDeleteMessage: shell.confirmDeleteMessage, itemDeleted: shell.itemDeleted,
      newItemCreated: shell.newItemCreated, save: shell.save, cancel: shell.cancel,
      edit: shell.edit, delete: shell.delete, title: shell.title,
      content: shell.content, priority: shell.priority, status: shell.status,
      createdAt: shell.createdAt, updatedAt: shell.updatedAt, dueDate: shell.dueDate,
      tags: shell.tags, close: shell.close, createFailed: shell.createFailed,
      deleteSuccess: shell.deleteSuccess, deleteFailed: shell.deleteFailed,
      itemNotFound: shell.itemNotFound,
    );
  }

  /// 获取Workshop本地化
  static WorkshopLocalizations _getWorkshopLocalizations() {
    final shell = _getDefaultLocalizations();
    return WorkshopLocalizations(
      workshopTitle: shell.workshop, initializing: shell.initializingWorkshop,
      total: shell.total, active: shell.active, completed: shell.completed,
      archived: shell.archived, noCreativeProjects: shell.noCreativeProjects,
      createNewCreativeProject: shell.createNewCreativeProject,
      newCreativeIdea: shell.newCreativeIdea, newCreativeDescription: shell.newCreativeDescription,
      detailedCreativeContent: shell.detailedCreativeContent,
      creativeProjectCreated: shell.creativeProjectCreated,
      editFunctionTodo: shell.editFunctionTodo,
      creativeProjectDeleted: shell.creativeProjectDeleted,
      edit: shell.edit, delete: shell.delete,
    );
  }

  /// 获取PunchIn本地化
  static PunchInLocalizations _getPunchInLocalizations() {
    final shell = _getDefaultLocalizations();
    return PunchInLocalizations(
      punchInTitle: shell.punchIn, initializing: shell.initializingPunchIn,
      currentXP: shell.currentXP, level: shell.level, todayPunchIn: shell.todayPunchIn,
      punchNow: shell.punchNow, dailyLimitReached: shell.dailyLimitReached,
      punchInStats: shell.punchInStats, totalPunches: shell.totalPunches,
      remainingToday: shell.remainingToday, recentPunches: shell.recentPunches,
      noPunchRecords: shell.noPunchRecords, punchSuccessWithXP: shell.punchSuccessWithXP,
      lastPunchTime: shell.lastPunchTime, punchCount: shell.punchCount,
    );
  }

  /// 构建占位符页面的辅助方法
  static Widget _buildPlaceholderPage(BuildContext context, String title, String description) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => goBack(context),
                    child: const Text('返回'),
                  ),
                  ElevatedButton(
                    onPressed: () => navigateTo(context, RoutePaths.home),
                    child: const Text('首页'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建设置页面 - Phase 2.1 集成DisplayMode切换功能
  static Widget _buildSettingsPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase 2.1 显示模式切换区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.display_settings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '显示模式',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // DisplayModeService集成
                    StreamBuilder<DisplayMode>(
                      stream: displayModeService.currentModeStream,
                      initialData: displayModeService.currentMode,
                      builder: (context, snapshot) {
                        final currentMode = snapshot.data ?? DisplayMode.mobile;
                        
                        return Column(
                          children: [
                            Text(
                              '当前模式: ${currentMode.displayName}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentMode.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // 模式切换按钮
                            Wrap(
                              spacing: 8,
                              children: DisplayMode.values.map((mode) {
                                final isSelected = mode == currentMode;
                                return FilterChip(
                                  selected: isSelected,
                                  label: Text(mode.displayName),
                                  onSelected: (selected) {
                                    if (selected && mode != currentMode) {
                                      displayModeService.switchToMode(mode);
                                    }
                                  },
                                  backgroundColor: isSelected 
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : null,
                                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                  checkmarkColor: Theme.of(context).colorScheme.primary,
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // 快速切换按钮
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => displayModeService.switchToNextMode(),
                                icon: const Icon(Icons.swap_horiz),
                                label: const Text('切换到下一种模式'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 其他设置选项占位符
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '应用设置',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '主题设置、通知偏好、数据同步等功能\n将在后续版本中实现',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 返回按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => goBack(context),
                  child: const Text('返回'),
                ),
                ElevatedButton(
                  onPressed: () => navigateTo(context, RoutePaths.home),
                  child: const Text('首页'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 