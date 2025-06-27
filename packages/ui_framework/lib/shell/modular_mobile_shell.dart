/*
---------------------------------------------------------------
File name:          modular_mobile_shell.dart
Author:             Ignorant-lu
Date created:       2025/06/28
Last modified:      2025/06/28
Dart Version:       3.32.4
Description:        ModularMobileShell - 真正的移动端模块化应用外壳，每个模块都是独立的应用实例
---------------------------------------------------------------
Change History:
    2025/06/28: Initial creation - Phase 2.1 基于desktop_environment的模块化理念重新设计移动端;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:ui_framework/ui_framework.dart';

/// ModularMobileShell - 真正的移动端模块化外壳
/// 
/// 核心理念：每个模块 = 一个包 = 一个应用
/// 借鉴desktop_environment的模块化特性，适配移动端：
/// - 模块以全屏卡片形式独立运行
/// - 模块之间完全解耦，各自管理状态
/// - 系统级的模块切换器和任务管理
/// - 真正的"原生模块化应用"体验
class ModularMobileShell extends AppShell {
  const ModularMobileShell({
    super.key,
    super.localizations,
    super.onLocaleChanged,
    required super.modules,
  }) : super(shellType: ShellType.standard); // 基于standard但完全重新设计

  @override
  State<ModularMobileShell> createState() => _ModularMobileShellState();
}

class _ModularMobileShellState extends State<ModularMobileShell> with TickerProviderStateMixin {
  /// 当前活跃的模块实例
  final Map<String, _ModuleInstance> _activeModules = {};
  
  /// 当前前台模块ID
  String? _foregroundModuleId;
  
  /// 模块切换动画控制器
  late AnimationController _moduleTransitionController;
  
  /// 任务管理器可见性
  bool _isTaskManagerVisible = false;
  
  /// 系统状态栏可见性
  bool _isSystemBarVisible = true;
  
  // 默认中文本地化（回退方案）
  MainShellLocalizations get localizations => widget.localizations ?? _getDefaultLocalizations();

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _moduleTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 自动启动首页模块
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchModule('home');
    });
  }

  @override
  void dispose() {
    _moduleTransitionController.dispose();
    // 清理所有模块实例
    for (final instance in _activeModules.values) {
      instance.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // 主要模块区域
          _buildModuleArea(),
          
          // 系统状态栏
          if (_isSystemBarVisible) _buildSystemBar(),
          
          // 任务管理器
          if (_isTaskManagerVisible) _buildTaskManager(),
          
          // 模块启动器（类似AppDock但适配移动端）
          _buildModuleLauncher(),
        ],
      ),
    );
  }

  /// 构建模块区域
  Widget _buildModuleArea() {
    if (_foregroundModuleId == null || !_activeModules.containsKey(_foregroundModuleId)) {
      return _buildEmptyState();
    }
    
    final foregroundModule = _activeModules[_foregroundModuleId]!;
    
    return AnimatedBuilder(
      animation: _moduleTransitionController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(
            top: _isSystemBarVisible ? 60 : 0,
            bottom: 80, // 为模块启动器预留空间
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 模块头部
                  _buildModuleHeader(foregroundModule),
                  
                  // 模块内容
                  Expanded(
                    child: foregroundModule.widget,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建模块头部
  Widget _buildModuleHeader(_ModuleInstance moduleInstance) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // 模块图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              moduleInstance.moduleInfo.icon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 模块标题和描述
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  moduleInstance.moduleInfo.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  moduleInstance.moduleInfo.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 模块控制按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 最小化到后台
              IconButton(
                icon: const Icon(Icons.minimize),
                onPressed: () => _minimizeModule(moduleInstance.moduleInfo.id),
                tooltip: '最小化到后台',
              ),
              
              // 关闭模块
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _closeModule(moduleInstance.moduleInfo.id),
                tooltip: '关闭模块',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建系统状态栏
  Widget _buildSystemBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            // 时间显示
            Text(
              _getCurrentTime(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const Spacer(),
            
            // 系统状态
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.apps,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_activeModules.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 任务管理器按钮
            IconButton(
              icon: Icon(
                _isTaskManagerVisible ? Icons.close : Icons.view_carousel,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isTaskManagerVisible = !_isTaskManagerVisible;
                });
              },
              tooltip: '任务管理器',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建任务管理器
  Widget _buildTaskManager() {
    return Positioned(
      top: 70,
      left: 16,
      right: 16,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '运行中的模块 (${_activeModules.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Expanded(
              child: _activeModules.isEmpty
                  ? Center(
                      child: Text(
                        '没有运行中的模块',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _activeModules.length,
                      itemBuilder: (context, index) {
                        final moduleId = _activeModules.keys.elementAt(index);
                        final module = _activeModules[moduleId]!;
                        final isForeground = moduleId == _foregroundModuleId;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isForeground 
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                module.moduleInfo.icon,
                                color: isForeground
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                            title: Text(module.moduleInfo.name),
                            subtitle: Text(
                              isForeground ? '前台运行' : '后台运行',
                              style: TextStyle(
                                color: isForeground 
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => _closeModule(moduleId),
                            ),
                            onTap: () {
                              _switchToModule(moduleId);
                              setState(() {
                                _isTaskManagerVisible = false;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建模块启动器
  Widget _buildModuleLauncher() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            // 模块图标列表
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.modules.map((module) {
                    final isActive = _activeModules.containsKey(module.id);
                    final isForeground = module.id == _foregroundModuleId;
                    
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _handleModuleTap(module.id),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isForeground
                              ? Theme.of(context).colorScheme.primary
                              : isActive
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: isActive
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                module.icon,
                                color: isForeground
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : isActive
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                module.name,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isForeground
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : isActive
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // 系统按钮
            IconButton(
              icon: Icon(
                _isSystemBarVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                setState(() {
                  _isSystemBarVisible = !_isSystemBarVisible;
                });
              },
              tooltip: '切换系统栏',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apps,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            '模块化移动平台',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Phase 2.1 - 每个模块都是独立应用',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '点击底部图标启动模块',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // 模块管理方法
  
  /// 处理模块点击
  void _handleModuleTap(String moduleId) {
    if (_activeModules.containsKey(moduleId)) {
      // 模块已运行，切换到前台
      _switchToModule(moduleId);
    } else {
      // 启动新模块
      _launchModule(moduleId);
    }
  }

  /// 启动模块
  void _launchModule(String moduleId) {
    final module = widget.modules.firstWhere(
      (m) => m.id == moduleId,
      orElse: () => throw Exception('Module not found: $moduleId'),
    );
    
    final moduleInstance = _ModuleInstance(
      moduleInfo: module,
      widget: module.widgetBuilder(context),
      launchedAt: DateTime.now(),
    );
    
    setState(() {
      _activeModules[moduleId] = moduleInstance;
      _foregroundModuleId = moduleId;
    });
    
    // 动画效果
    _moduleTransitionController.forward(from: 0);
    
    // 显示启动提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已启动 ${module.name} 模块'),
        duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// 切换到指定模块
  void _switchToModule(String moduleId) {
    if (!_activeModules.containsKey(moduleId)) return;
    
    setState(() {
      _foregroundModuleId = moduleId;
    });
    
    _moduleTransitionController.forward(from: 0);
  }

  /// 最小化模块
  void _minimizeModule(String moduleId) {
    if (_foregroundModuleId == moduleId) {
      setState(() {
        _foregroundModuleId = null;
      });
    }
  }

  /// 关闭模块
  void _closeModule(String moduleId) {
    if (!_activeModules.containsKey(moduleId)) return;
    
    final moduleInstance = _activeModules[moduleId]!;
    moduleInstance.dispose();
    
    setState(() {
      _activeModules.remove(moduleId);
      if (_foregroundModuleId == moduleId) {
        // 如果关闭的是前台模块，切换到最近使用的模块
        if (_activeModules.isNotEmpty) {
          _foregroundModuleId = _activeModules.keys.last;
        } else {
          _foregroundModuleId = null;
        }
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已关闭 ${moduleInstance.moduleInfo.name} 模块'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 获取当前时间
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// 获取默认本地化（与ResponsiveWebShell一致）
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
      // 其他字段省略...
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
      versionInfo: 'Phase 2.1 - 模块化移动端',
      moduleStatus: '模块: {active}/{total} 活跃',
      moduleManagement: '模块管理',
      copyrightInfo: '© 2025 桌宠AI助理平台\nPowered by Flutter Mobile',
      about: '关于',
      moduleManagementDialog: '模块管理',
      moduleManagementTodo: '模块管理功能将在Phase 2.1中实现',
    );
  }
}

/// 模块实例类
/// 每个模块都有独立的实例，管理自己的状态和生命周期
class _ModuleInstance {
  final ModuleInfo moduleInfo;
  final Widget widget;
  final DateTime launchedAt;
  
  _ModuleInstance({
    required this.moduleInfo,
    required this.widget,
    required this.launchedAt,
  });
  
  /// 清理模块资源
  void dispose() {
    // 在这里可以添加模块清理逻辑
    // 如取消订阅、释放资源等
  }
} 