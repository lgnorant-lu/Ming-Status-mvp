/*
---------------------------------------------------------------
File name:          navigation_drawer.dart
Author:             Ignorant-lu
Date created:       2025/06/24
Last modified:      2025/06/26
Dart Version:       3.32.4
Description:        自适应导航抽屉 - 根据ModuleManager动态生成模块菜单，支持响应式布局和国际化
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 重构 - 解决RoutePaths命名冲突，明确使用app_routing包;
    2025/06/25: Phase 1.5 重构 - 导入路径修正;
    2025/06/24: Initial creation - Phase 1导航组件实现;
---------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_routing/route_definitions.dart' as routes;
import 'package:core_services/core_services.dart';
import 'package:ui_framework/shell/main_shell.dart';

/// 自适应导航抽屉 - Phase 1平台骨架的核心导航组件
/// 
/// 提供完整的导航功能，包含静态导航项和动态模块菜单。
/// 根据ModuleManager动态生成模块菜单，支持模块生命周期状态显示。
class AdaptiveNavigationDrawer extends StatefulWidget {
  /// 当前选中的导航项索引
  final int selectedIndex;
  
  /// 导航项选择回调
  final ValueChanged<int> onDestinationSelected;
  
  /// 是否为桌面模式（影响显示样式）
  final bool isDesktopMode;
  
  /// 自定义模块管理器（可选，用于测试）
  final ModuleManager? customModuleManager;
  
  /// 本地化字符串
  final MainShellLocalizations localizations;
  
  /// 语言切换回调
  final Function(Locale)? onLocaleChanged;

  const AdaptiveNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.localizations,
    this.isDesktopMode = false,
    this.customModuleManager,
    this.onLocaleChanged,
  });

  @override
  State<AdaptiveNavigationDrawer> createState() => _AdaptiveNavigationDrawerState();
}

class _AdaptiveNavigationDrawerState extends State<AdaptiveNavigationDrawer> {
  /// 模块管理器实例
  late ModuleManager _moduleManager;
  
  /// 模块元数据列表
  List<ModuleMetadata> _moduleMetadataList = [];

  /// 静态导航项配置
  List<StaticNavigationItem> _getStaticItems(BuildContext context) {
    return [
      StaticNavigationItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: widget.localizations.home,
        path: routes.RoutePaths.home,
        category: NavigationCategory.core,
      ),
      StaticNavigationItem(
        icon: Icons.access_time_outlined,
        selectedIcon: Icons.access_time,
        label: widget.localizations.punchIn,
        path: routes.RoutePaths.punchIn,
        category: NavigationCategory.builtin,
      ),
      StaticNavigationItem(
        icon: Icons.note_outlined,
        selectedIcon: Icons.note,
        label: widget.localizations.notesHub,
        path: routes.RoutePaths.notesHub,
        category: NavigationCategory.builtin,
      ),
      StaticNavigationItem(
        icon: Icons.build_outlined,
        selectedIcon: Icons.build,
        label: widget.localizations.workshop,
        path: routes.RoutePaths.workshop,
        category: NavigationCategory.builtin,
      ),
    ];
  }

  /// 系统导航项配置
  List<StaticNavigationItem> _getSystemItems(BuildContext context) {
    return [
      StaticNavigationItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: widget.localizations.settings,
        path: routes.RoutePaths.settings,
        category: NavigationCategory.system,
      ),
      StaticNavigationItem(
        icon: Icons.info_outline,
        selectedIcon: Icons.info,
        label: widget.localizations.about,
        path: routes.RoutePaths.about,
        category: NavigationCategory.system,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    
    // 初始化模块管理器
    _moduleManager = widget.customModuleManager ?? ModuleManager.instance;
    
    // 监听模块生命周期事件
    _moduleManager.lifecycleEvents.listen(_onModuleLifecycleEvent);
    
    // 加载动态模块
    _loadDynamicModules();
  }

  @override
  void dispose() {
    // 清理资源
    super.dispose();
  }

  /// 处理模块生命周期事件
  void _onModuleLifecycleEvent(ModuleLifecycleEvent event) {
    if (mounted) {
      setState(() {
        _loadDynamicModules();
      });
    }
  }

  /// 加载动态模块列表
  void _loadDynamicModules() {
    _moduleMetadataList = _moduleManager.getAllModules();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDesktopMode) {
      return _buildNavigationRail(context);
    } else {
      return _buildNavigationDrawer(context);
    }
  }

  /// 构建桌面端导航栏
  Widget _buildNavigationRail(BuildContext context) {
    final allDestinations = _buildAllDestinations(context);
    
    return NavigationRail(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: Theme.of(context).colorScheme.surface,
      
      // 头部菜单按钮
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            // 应用图标
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.pets,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            // 模块状态指示器
            _buildModuleStatusIndicator(context),
          ],
        ),
      ),
      
      // 导航目标
      destinations: allDestinations,
      
      // 尾部系统功能
      trailing: _buildRailTrailing(context),
    );
  }

  /// 构建移动端导航抽屉
  Widget _buildNavigationDrawer(context) {
    return NavigationDrawer(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onDestinationSelected,
      children: [
        // 抽屉头部
        _buildDrawerHeader(context),
        
        // 核心功能区
        _buildSectionHeader(context, widget.localizations.coreFeatures),
        ..._buildCoreDestinations(context),
        
        // 内置模块区
        _buildSectionHeader(context, widget.localizations.builtinModules),
        ..._buildBuiltinDestinations(context),
        
        // 动态模块区（如果有）
        if (_moduleMetadataList.isNotEmpty) ...[
          _buildSectionHeader(context, widget.localizations.extensionModules),
          ..._buildDynamicDestinations(context),
        ],
        
        // 分隔线
        const Divider(),
        
        // 系统功能区
        _buildSectionHeader(context, widget.localizations.system),
        ..._buildSystemDestinations(context),
        
        // 底部信息
        _buildDrawerFooter(context),
      ],
    );
  }

  /// 构建抽屉头部
  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 应用图标和标题
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Icon(
                  Icons.pets,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.localizations.petAssistant,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.localizations.versionInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 模块状态摘要
          _buildModuleStatusSummary(context),
        ],
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建所有导航目标（用于NavigationRail）
  List<NavigationRailDestination> _buildAllDestinations(BuildContext context) {
    final List<NavigationRailDestination> destinations = [];
    final staticItems = _getStaticItems(context);
    final systemItems = _getSystemItems(context);
    
    // 添加静态项目
    for (final item in staticItems) {
      destinations.add(NavigationRailDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon),
        label: Text(item.label),
      ));
    }
    
    // 添加动态模块
    for (final metadata in _moduleMetadataList) {
      destinations.add(NavigationRailDestination(
        icon: const Icon(Icons.extension_outlined),
        selectedIcon: const Icon(Icons.extension),
        label: Text(metadata.name),
      ));
    }
    
    // 添加系统项目
    for (final item in systemItems) {
      destinations.add(NavigationRailDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon),
        label: Text(item.label),
      ));
    }
    
    return destinations;
  }

  /// 构建核心功能目标
  List<Widget> _buildCoreDestinations(BuildContext context) {
    final staticItems = _getStaticItems(context);
    return staticItems
        .where((item) => item.category == NavigationCategory.core)
        .map((item) => _buildNavigationDestination(context, item))
        .toList();
  }

  /// 构建内置模块目标
  List<Widget> _buildBuiltinDestinations(BuildContext context) {
    final staticItems = _getStaticItems(context);
    return staticItems
        .where((item) => item.category == NavigationCategory.builtin)
        .map((item) => _buildNavigationDestination(context, item))
        .toList();
  }

  /// 构建动态模块目标
  List<Widget> _buildDynamicDestinations(BuildContext context) {
    return _moduleMetadataList.map((metadata) {
      return NavigationDrawerDestination(
        icon: const Icon(Icons.extension_outlined),
        selectedIcon: const Icon(Icons.extension),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(metadata.name)),
            const SizedBox(width: 8),
            _buildModuleStatusIcon(metadata),
          ],
        ),
      );
    }).toList();
  }

  /// 构建系统功能目标
  List<Widget> _buildSystemDestinations(BuildContext context) {
    final systemItems = _getSystemItems(context);
    return systemItems
        .map((item) => _buildNavigationDestination(context, item))
        .toList();
  }

  /// 构建导航目标（静态项目）
  Widget _buildNavigationDestination(BuildContext context, StaticNavigationItem item) {
    return NavigationDrawerDestination(
      icon: Icon(item.icon),
      selectedIcon: Icon(item.selectedIcon),
      label: Text(item.label),
    );
  }

  /// 构建模块状态指示器（NavigationRail用）
  Widget _buildModuleStatusIndicator(BuildContext context) {
    final activeCount = _moduleMetadataList
        .where((metadata) => metadata.state == ModuleLifecycleState.active)
        .length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: activeCount > 0 
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$activeCount',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: activeCount > 0
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 构建模块状态摘要
  Widget _buildModuleStatusSummary(BuildContext context) {
    final totalModules = _moduleMetadataList.length;
    final activeModules = _moduleMetadataList
        .where((metadata) => metadata.state == ModuleLifecycleState.active)
        .length;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.widgets,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            widget.localizations.moduleStatus.replaceAll('{active}', activeModules.toString()).replaceAll('{total}', totalModules.toString()),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建模块状态图标
  Widget _buildModuleStatusIcon(ModuleMetadata metadata) {
    final isActive = metadata.state == ModuleLifecycleState.active;
    
    return Icon(
      isActive ? Icons.check_circle : Icons.radio_button_unchecked,
      size: 16,
      color: isActive 
          ? Colors.green 
          : Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  /// 构建导航栏尾部（系统功能）
  Widget _buildRailTrailing(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(routes.RoutePaths.settings),
            tooltip: widget.localizations.settings,
          ),
          
          // 关于按钮
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.go(routes.RoutePaths.about),
            tooltip: widget.localizations.about,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建抽屉底部
  Widget _buildDrawerFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 语言切换按钮
          if (widget.onLocaleChanged != null)
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('语言/Language'),
              dense: true,
              onTap: () => _showLanguageDialog(context),
            ),
            
          // 模块管理按钮
          ListTile(
            leading: const Icon(Icons.extension),
            title: Text(widget.localizations.moduleManagement),
            dense: true,
            onTap: () => _showModuleManager(context),
          ),
          
          // 版权信息
          const SizedBox(height: 8),
          Text(
            widget.localizations.copyrightInfo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示模块管理器
  void _showModuleManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.localizations.moduleManagementDialog),
        content: Text(widget.localizations.moduleManagementTodo),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.localizations.close),
          ),
        ],
      ),
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择语言 / Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇨🇳'),
                title: const Text('中文'),
                onTap: () {
                  widget.onLocaleChanged?.call(const Locale('zh', 'CN'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Text('🇺🇸'),
                title: const Text('English'),
                onTap: () {
                  widget.onLocaleChanged?.call(const Locale('en', 'US'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消 / Cancel'),
            ),
          ],
        );
      },
    );
  }
}

/// 静态导航项配置
class StaticNavigationItem {
  /// 默认图标
  final IconData icon;
  
  /// 选中时的图标
  final IconData selectedIcon;
  
  /// 标签文本
  final String label;
  
  /// 对应的路由路径
  final String path;
  
  /// 导航类别
  final NavigationCategory category;

  const StaticNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
    required this.category,
  });
}

/// 导航类别枚举
enum NavigationCategory {
  /// 核心功能
  core,
  
  /// 内置模块
  builtin,
  
  /// 动态模块
  dynamic,
  
  /// 系统功能
  system,
}

/// 模块管理器对话框
class _ModuleManagerDialog extends StatefulWidget {
  final ModuleManager moduleManager;

  const _ModuleManagerDialog({
    required this.moduleManager,
  });

  @override
  State<_ModuleManagerDialog> createState() => _ModuleManagerDialogState();
}

class _ModuleManagerDialogState extends State<_ModuleManagerDialog> {
  @override
  Widget build(BuildContext context) {
    final modules = widget.moduleManager.getAllModules();
    
    return AlertDialog(
      title: const Text('模块管理器'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: modules.isEmpty
            ? _buildEmptyState(context)
            : _buildModuleList(context, modules),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        ElevatedButton(
          onPressed: () => _refreshModules(),
          child: const Text('刷新'),
        ),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.extension_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无扩展模块',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '扩展模块将在后续版本中支持',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建模块列表
  Widget _buildModuleList(BuildContext context, List<ModuleMetadata> modules) {
    return ListView.builder(
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final metadata = modules[index];
        final isActive = metadata.state == ModuleLifecycleState.active;
        
        return ListTile(
          leading: const Icon(Icons.extension),
          title: Text(metadata.name),
          subtitle: Text(
            '${metadata.description}\n'
            '版本: ${metadata.version} | 作者: ${metadata.author}',
          ),
          trailing: Switch(
            value: isActive,
            onChanged: (value) => _toggleModule(metadata, value),
          ),
          isThreeLine: true,
        );
      },
    );
  }

  /// 切换模块状态
  void _toggleModule(ModuleMetadata metadata, bool enable) {
    setState(() {
      if (enable) {
        widget.moduleManager.initializeModule(metadata.id);
      } else {
        widget.moduleManager.disposeModule(metadata.id);
      }
    });
  }

  /// 刷新模块列表
  void _refreshModules() {
    setState(() {
      // 刷新模块状态
    });
  }
} 