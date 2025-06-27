# AdaptiveNavigationDrawer API 文档

## 概述

AdaptiveNavigationDrawer是桌宠应用的核心导航组件，提供响应式自适应导航体验。它在桌面端显示为NavigationRail，在移动端显示为NavigationDrawer，支持动态模块集成、状态管理和主题切换。

- **主要功能**: 响应式导航、模块集成、状态显示、主题适配
- **设计模式**: 组合模式 + 观察者模式
- **响应式**: 桌面端NavigationRail + 移动端NavigationDrawer
- **位置**: `lib/ui/shell/navigation_drawer.dart`

## 核心组件定义

### AdaptiveNavigationDrawer 类
```dart
class AdaptiveNavigationDrawer extends StatefulWidget {
  const AdaptiveNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isDesktopMode = false,
    this.customModuleManager,
  });

  final int selectedIndex;                    // 当前选中的导航项索引
  final ValueChanged<int> onDestinationSelected; // 导航项选择回调
  final bool isDesktopMode;                   // 是否为桌面模式（影响显示样式）
  final ModuleManager? customModuleManager;   // 自定义模块管理器（可选，用于测试）
}
```

### StaticNavigationItem 配置类
```dart
class StaticNavigationItem {
  const StaticNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
    required this.category,
  });

  final IconData icon;                        // 未选中状态图标
  final IconData selectedIcon;                // 选中状态图标
  final String label;                         // 导航标签
  final String path;                          // 路由路径
  final NavigationCategory category;          // 导航分类
}
```

### NavigationCategory 枚举
```dart
enum NavigationCategory {
  core,        // 核心功能
  builtin,     // 内置模块
  extension,   // 扩展模块
  system,      // 系统功能
}
```

## 核心功能实现

### 响应式布局切换
```dart
@override
Widget build(BuildContext context) {
  if (widget.isDesktopMode) {
    return _buildNavigationRail(context);
  } else {
    return _buildNavigationDrawer(context);
  }
}

// 桌面端导航栏
Widget _buildNavigationRail(BuildContext context) {
  final allDestinations = _buildAllDestinations(context);
  
  return NavigationRail(
    selectedIndex: widget.selectedIndex,
    onDestinationSelected: widget.onDestinationSelected,
    labelType: NavigationRailLabelType.all,
    backgroundColor: Theme.of(context).colorScheme.surface,
    leading: /* 品牌展示区域 */,
    destinations: allDestinations,
    trailing: /* 系统功能区域 */,
  );
}

// 移动端抽屉导航
Widget _buildNavigationDrawer(BuildContext context) {
  return NavigationDrawer(
    selectedIndex: widget.selectedIndex,
    onDestinationSelected: widget.onDestinationSelected,
    children: [
      _buildDrawerHeader(context),
      _buildSectionHeader(context, '核心功能'),
      ..._buildCoreDestinations(context),
      _buildSectionHeader(context, '内置模块'),
      ..._buildBuiltinDestinations(context),
      if (_moduleMetadataList.isNotEmpty) ...[
        _buildSectionHeader(context, '扩展模块'),
        ..._buildDynamicDestinations(context),
      ],
      const Divider(),
      _buildSectionHeader(context, '系统'),
      ..._buildSystemDestinations(context),
      _buildDrawerFooter(context),
    ],
  );
}
```

### 静态导航项配置
```dart
static const List<StaticNavigationItem> _staticItems = [
  StaticNavigationItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: '主页',
    path: RoutePaths.home,
    category: NavigationCategory.core,
  ),
  StaticNavigationItem(
    icon: Icons.access_time_outlined,
    selectedIcon: Icons.access_time,
    label: '打卡',
    path: RoutePaths.punchIn,
    category: NavigationCategory.builtin,
  ),
  StaticNavigationItem(
    icon: Icons.note_outlined,
    selectedIcon: Icons.note,
    label: '事务中心',
    path: RoutePaths.notesHub,
    category: NavigationCategory.builtin,
  ),
  StaticNavigationItem(
    icon: Icons.build_outlined,
    selectedIcon: Icons.build,
    label: '创意工坊',
    path: RoutePaths.workshop,
    category: NavigationCategory.builtin,
  ),
];

static const List<StaticNavigationItem> _systemItems = [
  StaticNavigationItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: '设置',
    path: RoutePaths.settings,
    category: NavigationCategory.system,
  ),
  StaticNavigationItem(
    icon: Icons.info_outline,
    selectedIcon: Icons.info,
    label: '关于',
    path: RoutePaths.about,
    category: NavigationCategory.system,
  ),
];
```

### 动态模块集成
```dart
/// 加载动态模块列表
void _loadDynamicModules() {
  _moduleMetadataList = _moduleManager.getAllModules();
}

/// 处理模块生命周期事件
void _onModuleLifecycleEvent(ModuleLifecycleEvent event) {
  if (mounted) {
    setState(() {
      _loadDynamicModules();
    });
  }
}

/// 构建动态模块目标
List<Widget> _buildDynamicDestinations(BuildContext context) {
  return _moduleMetadataList.map((metadata) {
    return NavigationDrawerDestination(
      icon: const Icon(Icons.extension_outlined),
      selectedIcon: const Icon(Icons.extension),
      label: Row(
        children: [
          Expanded(child: Text(metadata.name)),
          _buildModuleStatusIcon(metadata),
        ],
      ),
    );
  }).toList();
}
```

### 模块状态指示器
```dart
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
```

### 抽屉头部设计
```dart
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
                    '桌宠助手',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Phase 1 - v1.0.0',
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
```

### 模块状态摘要
```dart
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
          '模块: $activeModules/$totalModules 活跃',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    ),
  );
}
```

### 导航项构建
```dart
/// 构建核心功能目标
List<Widget> _buildCoreDestinations(BuildContext context) {
  return _staticItems
      .where((item) => item.category == NavigationCategory.core)
      .map((item) => _buildNavigationDestination(context, item))
      .toList();
}

/// 构建内置模块目标
List<Widget> _buildBuiltinDestinations(BuildContext context) {
  return _staticItems
      .where((item) => item.category == NavigationCategory.builtin)
      .map((item) => _buildNavigationDestination(context, item))
      .toList();
}

/// 构建系统功能目标
List<Widget> _buildSystemDestinations(BuildContext context) {
  return _systemItems
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
```

### 桌面端导航栏
```dart
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

/// 构建导航栏尾部（系统功能）
Widget _buildRailTrailing(BuildContext context) {
  return Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 设置按钮
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.go(RoutePaths.settings),
          tooltip: '设置',
        ),
        
        // 关于按钮
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => context.go(RoutePaths.about),
          tooltip: '关于',
        ),
        
        const SizedBox(height: 16),
      ],
    ),
  );
}
```

### 抽屉底部
```dart
Widget _buildDrawerFooter(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        // 模块管理按钮
        ListTile(
          leading: const Icon(Icons.extension),
          title: const Text('模块管理'),
          dense: true,
          onTap: () => _showModuleManager(context),
        ),
        
        // 版权信息
        const SizedBox(height: 8),
        Text(
          '© 2025 桌宠助手\nPowered by Flutter',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

/// 显示模块管理器对话框
void _showModuleManager(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => _ModuleManagerDialog(),
  );
}
```

## 生命周期管理

### 初始化和事件监听
```dart
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
```

## 使用示例

### 基本用法
```dart
class MainShell extends StatefulWidget {
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    return Scaffold(
      body: Row(
        children: [
          // 导航组件
          AdaptiveNavigationDrawer(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _navigateToPage(index);
            },
            isDesktopMode: isDesktop,
          ),
          
          // 主内容区域
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      
      // 移动端抽屉
      drawer: !isDesktop ? AdaptiveNavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.of(context).pop(); // 关闭抽屉
          _navigateToPage(index);
        },
        isDesktopMode: false,
      ) : null,
    );
  }
  
  void _navigateToPage(int index) {
    // 根据索引导航到相应页面
    final routes = [
      RoutePaths.home,
      RoutePaths.punchIn,
      RoutePaths.notesHub,
      RoutePaths.workshop,
      RoutePaths.settings,
      RoutePaths.about,
    ];
    
    if (index < routes.length) {
      context.go(routes[index]);
    }
  }
}
```

### 自定义模块管理器
```dart
// 用于测试的自定义模块管理器
final customModuleManager = MockModuleManager();

AdaptiveNavigationDrawer(
  selectedIndex: 0,
  onDestinationSelected: (index) {
    // 处理导航
  },
  isDesktopMode: true,
  customModuleManager: customModuleManager,
)
```

## 配置与扩展

### 响应式断点
- **桌面模式**: 屏幕宽度 ≥ 1024px
- **移动模式**: 屏幕宽度 < 1024px

### 主题适配
- 自动适应Material Design 3主题色彩
- 支持浅色/深色主题切换
- 响应系统颜色变化

### 模块集成
- 自动监听ModuleManager生命周期事件
- 动态更新模块列表和状态
- 支持模块状态可视化指示

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 响应式桌面/移动端导航
  - 静态和动态模块集成
  - 模块状态指示和管理
  - Material Design 3主题适配 