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
import 'package:go_router/go_router.dart';
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
  
  // Phase 1.6残余已清理 - 现在完全使用UIL10n.t()分布式i18n系统

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
                tooltip: UIL10n.t('minimize_to_background'),
              ),
              
              // 关闭模块
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _closeModule(moduleInstance.moduleInfo.id),
                tooltip: UIL10n.t('close_module'),
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
            
            // 设置按钮
            IconButton(
              icon: const Icon(Icons.settings_outlined, size: 20),
              onPressed: () => context.go('/settings'),
              tooltip: UIL10n.t('settings'),
            ),
            
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
              tooltip: UIL10n.t('task_manager'),
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
              UIL10n.t('running_modules_count').replaceAll('{count}', '${_activeModules.length}'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Expanded(
              child: _activeModules.isEmpty
                  ? Center(
                      child: Text(
                        UIL10n.t('no_running_modules'),
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
                              isForeground ? UIL10n.t('running_foreground') : UIL10n.t('running_background'),
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
              tooltip: UIL10n.t('toggle_system_bar'),
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
            UIL10n.t('modular_mobile_platform'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            UIL10n.t('phase_description'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            UIL10n.t('tap_icon_to_launch'),
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
    
    // 检查模块是否有widgetBuilder
    if (module.widgetBuilder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${module.name} 模块暂未实现'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    final moduleInstance = _ModuleInstance(
      moduleInfo: module,
      widget: module.widgetBuilder!(context),
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
        content: Text(UIL10n.t('module_launched').replaceAll('{moduleName}', module.name)),
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
        content: Text(UIL10n.t('module_closed').replaceAll('{moduleName}', moduleInstance.moduleInfo.name)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 获取当前时间
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // Phase 1.6残余已清理 - 现在完全使用UIL10n.t()分布式i18n系统
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