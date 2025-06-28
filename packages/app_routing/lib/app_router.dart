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
import 'l10n/routing_l10n.dart';

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
        title: Text(RoutingL10n.t('page_not_found')),
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
              RoutingL10n.t('path_not_found').replaceFirst('{path}', state.uri.toString()),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: Text(RoutingL10n.t('return_home')),
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
          RoutingL10n.t('about_title'),
          RoutingL10n.t('about_app_version'),
        ),
      ),
    ],
  );

  /// 获取路由器实例
  static GoRouter get router => _router;
  
  /// 处理语言切换 - 集成LocaleService实现真正的国际化
  static void _handleLocaleChange(Locale locale) {
    // Phase 2.2 Sprint 2 - 集成LocaleService实现响应式语言切换
    try {
      // 导入core_services以使用localeService
      final supportedLocale = SupportedLocale.fromLocale(locale);
      // 注意：这里不直接调用switchToLocale，避免循环调用
      // 语言切换主要由LocaleService管理，这里只做日志记录
      debugPrint('🌐 AppRouter收到语言切换请求: ${locale.languageCode} -> ${supportedLocale.displayName}');
    } catch (e) {
      debugPrint('⚠️ AppRouter处理语言切换失败: $e');
    }
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

  /// 构建模块列表 - 集成真实的业务模块，使用分布式i18n
  static List<ModuleInfo> _buildModuleList() {
    return [
      ModuleInfo(
        id: 'home',
        name: RoutingL10n.t('home_nav'),
        description: RoutingL10n.t('home_description'),
        icon: Icons.home,
        widgetBuilder: (context) => _buildHomePage(context),
        order: 0,
      ),
      ModuleInfo(
        id: 'notes_hub',
        name: RoutingL10n.t('notes_hub_nav'),
        description: RoutingL10n.t('notes_hub_description'),
        icon: Icons.note,
        widgetBuilder: (context) => NotesHubWidget(
          localizations: _getNotesHubLocalizations(),
        ),
        order: 1,
      ),
      ModuleInfo(
        id: 'workshop',
        name: RoutingL10n.t('workshop_nav'),
        description: RoutingL10n.t('workshop_description'),
        icon: Icons.build,
        widgetBuilder: (context) => WorkshopWidget(
          localizations: _getWorkshopLocalizations(),
        ),
        order: 2,
      ),
      ModuleInfo(
        id: 'punch_in',
        name: RoutingL10n.t('punch_in_nav'),
        description: RoutingL10n.t('punch_in_description'),
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
                          RoutingL10n.t('welcome_message'),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    RoutingL10n.t('app_description'),
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
                        RoutingL10n.t('project_info'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    RoutingL10n.t('project_features'),
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
                              child: Text(RoutingL10n.t('switch_button')),
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
            RoutingL10n.t('module_status'),
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

  /// 获取默认本地化 - 使用分布式i18n系统
  static MainShellLocalizations _getDefaultLocalizations() {
    // Phase 2.2 Sprint 2: 使用分布式i18n系统替代硬编码
    return MainShellLocalizations(
      appTitle: RoutingL10n.t('app_title'),
      home: RoutingL10n.t('home_nav'),
      notesHub: RoutingL10n.t('notes_hub_nav'),
      workshop: RoutingL10n.t('workshop_nav'),
      punchIn: RoutingL10n.t('punch_in_nav'),
      settings: RoutingL10n.t('settings_title'),
      welcomeMessage: RoutingL10n.t('welcome_message'),
      appDescription: RoutingL10n.t('app_description'),
      moduleStatusTitle: RoutingL10n.t('module_status'),
      notesHubDescription: RoutingL10n.t('notes_hub_description'),
      workshopDescription: RoutingL10n.t('workshop_description'),
      punchInDescription: RoutingL10n.t('punch_in_description'),
      // 业务模块字段 - 将逐步使用业务包级i18n替代
      note: 'Note', todo: 'Task', project: 'Project', reminder: 'Reminder',
      habit: 'Habit', goal: 'Goal', allTypes: 'All Types', total: 'Total',
      active: 'Active', completed: 'Completed', archived: 'Archived',
      searchHint: 'Search...', initializing: 'Initializing...',
      priorityUrgent: 'Urgent', priorityHigh: 'High', priorityMedium: 'Medium', priorityLow: 'Low',
      createNew: 'Create new {itemType}', noItemsFound: 'No {itemType} found',
      createItemHint: 'Tap + button to create {itemType}', confirmDelete: 'Confirm Delete',
      confirmDeleteMessage: 'Are you sure you want to delete "{itemName}"? This action cannot be undone.',
      itemDeleted: 'Item deleted', newItemCreated: 'Created new {itemType}',
      save: 'Save', cancel: 'Cancel', edit: 'Edit', delete: 'Delete',
      title: 'Title', content: 'Content', priority: 'Priority', status: 'Status',
      createdAt: 'Created At', updatedAt: 'Updated At', dueDate: 'Due Date',
      tags: 'Tags', close: 'Close', createFailed: 'Create Failed',
      deleteSuccess: 'Delete Success', deleteFailed: 'Delete Failed', itemNotFound: 'Item Not Found',
      initializingWorkshop: 'Initializing Workshop...', noCreativeProjects: 'No Creative Projects',
      createNewCreativeProject: 'Create New Creative Project', newCreativeIdea: 'New Creative Idea',
      newCreativeDescription: 'Creative Description', detailedCreativeContent: 'Creative Content',
      creativeProjectCreated: 'Creative Project Created',
      creativeProjectDeleted: 'Creative Project Deleted', initializingPunchIn: 'Initializing Punch In...',
      currentXP: 'Current XP', level: 'Level', todayPunchIn: 'Today Punch In',
      punchNow: 'Punch Now', dailyLimitReached: 'Daily Limit Reached',
      punchInStats: 'Punch In Stats', totalPunches: 'Total Punches',
      remainingToday: 'Remaining Today', recentPunches: 'Recent Punches',
      noPunchRecords: 'No Punch Records', punchSuccessWithXP: 'Punch Success with XP',
      lastPunchTime: 'Last Punch Time', punchCount: 'Punch Count',
      coreFeatures: RoutingL10n.t('core_features'), builtinModules: RoutingL10n.t('builtin_modules'),
      extensionModules: RoutingL10n.t('extension_modules'), system: RoutingL10n.t('system'), 
      petAssistant: RoutingL10n.t('pet_assistant'), versionInfo: RoutingL10n.t('version_info'), 
      moduleStatus: RoutingL10n.t('module_active'), moduleManagement: RoutingL10n.t('module_management'), 
      copyrightInfo: RoutingL10n.t('copyright_info'), about: RoutingL10n.t('about_nav'), 
      moduleManagementDialog: RoutingL10n.t('module_management_dialog'),
      moduleManagementTodo: RoutingL10n.t('module_management_todo'),
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
                    child: Text(RoutingL10n.t('back_button')),
                  ),
                  ElevatedButton(
                    onPressed: () => navigateTo(context, RoutePaths.home),
                    child: Text(RoutingL10n.t('home_button')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建设置页面 - Phase 2.2C Step 8 完整实现
  static Widget _buildSettingsPage(BuildContext context) {
    return const SettingsPage();
  }
} 