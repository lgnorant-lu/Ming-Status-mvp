# MainShell API 文档

## 概述

MainShell是桌宠应用的主布局壳组件，提供基础的应用框架容器和响应式导航体验。它基于Scaffold + NavigationDrawer构建，支持桌面端和移动端的自适应布局，集成页面切换动画和基础的全局功能。

- **主要功能**: 响应式布局、导航管理、页面容器、切换动画
- **设计模式**: 容器模式 + 适配器模式 + 状态管理模式
- **响应式设计**: 桌面端NavigationRail + 移动端NavigationDrawer/NavigationBar
- **位置**: `lib/ui/shell/main_shell.dart`

## 核心组件定义

### MainShell 主布局类
```dart
class MainShell extends StatefulWidget {
  final Widget child;                   // 要显示的子页面内容
  final GoRouterState? routerState;     // 当前路由状态（可选）

  const MainShell({
    super.key,
    required this.child,
    this.routerState,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _pageAnimationController;
  late Animation<double> _pageAnimation;
  int _selectedIndex = 0;
}
```

### NavigationItem 导航配置
```dart
class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;          // 默认图标
  final IconData selectedIcon;  // 选中状态图标
  final String label;           // 标签文本
  final String path;            // 路由路径
}
```

## 导航配置

### 静态导航项定义
```dart
static const List<NavigationItem> _navigationItems = [
  NavigationItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: '主页',
    path: RoutePaths.home,
  ),
  NavigationItem(
    icon: Icons.access_time_outlined,
    selectedIcon: Icons.access_time,
    label: '打卡',
    path: RoutePaths.punchIn,
  ),
  NavigationItem(
    icon: Icons.note_outlined,
    selectedIcon: Icons.note,
    label: '事务中心',
    path: RoutePaths.notesHub,
  ),
  NavigationItem(
    icon: Icons.build_outlined,
    selectedIcon: Icons.build,
    label: '创意工坊',
    path: RoutePaths.workshop,
  ),
  NavigationItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: '设置',
    path: RoutePaths.settings,
  ),
];
```

## 响应式布局实现

### 布局断点检测
```dart
bool _isDesktopScreen(BuildContext context) {
  return MediaQuery.of(context).size.width >= 1024;
}
```

### 主要布局方法

#### `build` 主构建方法
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
    
    // === 应用栏配置 ===
    appBar: _buildAppBar(context),
    
    // === 导航抽屉配置 ===
    drawer: _buildNavigationDrawer(context),
    
    // === 主内容区域 ===
    body: _buildMainContent(context),
    
    // === 底部导航栏（移动端） ===
    bottomNavigationBar: _buildBottomNavigationBar(context),
    
    // === 浮动按钮（可选） ===
    floatingActionButton: _buildFloatingActionButton(context),
    
    // === 悬浮按钮位置 ===
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}
```

### AppBar构建

#### `_buildAppBar` 应用栏构建
```dart
PreferredSizeWidget _buildAppBar(BuildContext context) {
  final isDesktop = _isDesktopScreen(context);
  
  return AppBar(
    title: Text(_getCurrentPageTitle()),
    
    // 桌面端隐藏菜单按钮（因为有持久性抽屉）
    automaticallyImplyLeading: !isDesktop,
    
    // 操作按钮
    actions: [
      // 通知按钮
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () => _showNotifications(context),
        tooltip: '通知',
      ),
      
      // 搜索按钮
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => _showSearch(context),
        tooltip: '搜索',
      ),
      
      // 更多操作
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: _handleMenuAction,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'refresh',
            child: ListTile(
              leading: Icon(Icons.refresh),
              title: Text('刷新'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'about',
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('关于'),
              dense: true,
            ),
          ),
        ],
      ),
    ],
  );
}
```

### 导航抽屉

#### `_buildNavigationDrawer` 导航抽屉构建
```dart
Widget? _buildNavigationDrawer(BuildContext context) {
  final isDesktop = _isDesktopScreen(context);
  
  // 桌面端使用持久性导航栏，移动端使用抽屉
  if (isDesktop) {
    return null; // 桌面端不显示抽屉，使用底部的持久导航
  }
  
  return NavigationDrawer(
    selectedIndex: _selectedIndex,
    onDestinationSelected: _onNavigationItemSelected,
    children: [
      // 抽屉头部
      _buildDrawerHeader(context),
      
      // 导航项目
      ..._navigationItems.map((item) {
        return NavigationDrawerDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: Text(item.label),
        );
      }),
      
      // 分隔线
      const Divider(),
      
      // 关于页面链接
      NavigationDrawerDestination(
        icon: const Icon(Icons.info_outline),
        label: const Text('关于'),
      ),
    ],
  );
}
```

#### `_buildDrawerHeader` 抽屉头部构建
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
        // 应用图标
        CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(
            Icons.pets,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 应用标题
        Text(
          '桌宠助手',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // 版本信息
        Text(
          'Phase 1 - v1.0.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    ),
  );
}
```

### 主内容区域

#### `_buildMainContent` 主内容构建
```dart
Widget _buildMainContent(BuildContext context) {
  final isDesktop = _isDesktopScreen(context);
  
  // 桌面端布局：侧边导航 + 内容区域
  if (isDesktop) {
    return Row(
      children: [
        // 左侧持久导航栏
        _buildPersistentNavigation(context),
        
        // 右侧内容区域
        Expanded(
          child: _buildContentArea(context),
        ),
      ],
    );
  }
  
  // 移动端布局：全屏内容区域
  return _buildContentArea(context);
}
```

#### `_buildPersistentNavigation` 持久导航栏（桌面端）
```dart
Widget _buildPersistentNavigation(BuildContext context) {
  return NavigationRail(
    selectedIndex: _selectedIndex,
    onDestinationSelected: _onNavigationItemSelected,
    labelType: NavigationRailLabelType.all,
    backgroundColor: Theme.of(context).colorScheme.surface,
    
    // 导航项目
    destinations: _navigationItems.map((item) {
      return NavigationRailDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon),
        label: Text(item.label),
      );
    }).toList(),
    
    // 头部和尾部
    leading: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FloatingActionButton.small(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        child: const Icon(Icons.menu),
      ),
    ),
    
    trailing: Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.go(RoutePaths.about),
            tooltip: '关于',
          ),
        ),
      ),
    ),
  );
}
```

#### `_buildContentArea` 内容区域构建
```dart
Widget _buildContentArea(BuildContext context) {
  return FadeTransition(
    opacity: _pageAnimation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(_pageAnimation),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(0), // 内容由子页面自己控制边距
        child: widget.child,
      ),
    ),
  );
}
```

### 底部导航栏

#### `_buildBottomNavigationBar` 底部导航栏（移动端）
```dart
Widget? _buildBottomNavigationBar(BuildContext context) {
  final isDesktop = _isDesktopScreen(context);
  
  // 桌面端不显示底部导航栏
  if (isDesktop) {
    return null;
  }
  
  // 移动端显示底部导航栏
  return NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: _onNavigationItemSelected,
    destinations: _navigationItems.take(4).map((item) { // 只显示前4个主要功能
      return NavigationDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.selectedIcon),
        label: item.label,
      );
    }).toList(),
  );
}
```

## 页面切换动画

### 动画初始化
```dart
@override
void initState() {
  super.initState();
  
  // 初始化页面切换动画
  _pageAnimationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  _pageAnimation = CurvedAnimation(
    parent: _pageAnimationController,
    curve: Curves.easeInOut,
  );
  
  // 开始页面动画
  _pageAnimationController.forward();
  
  // 更新选中状态
  _updateSelectedIndex();
}
```

### 动画更新
```dart
@override
void didUpdateWidget(MainShell oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // 如果路由状态发生变化，更新选中索引
  if (widget.routerState?.uri != oldWidget.routerState?.uri) {
    _updateSelectedIndex();
    _pageAnimationController.reset();
    _pageAnimationController.forward();
  }
}
```

## 浮动操作按钮

### 上下文相关FAB
```dart
Widget? _buildFloatingActionButton(BuildContext context) {
  // 根据当前页面决定是否显示浮动按钮
  switch (_selectedIndex) {
    case 1: // 打卡页面
      return FloatingActionButton(
        onPressed: () => _quickPunchIn(context),
        tooltip: '快速打卡',
        child: const Icon(Icons.add),
      );
    case 2: // 事务中心
      return FloatingActionButton(
        onPressed: () => _quickAddNote(context),
        tooltip: '快速添加',
        child: const Icon(Icons.add),
      );
    case 3: // 创意工坊
      return FloatingActionButton(
        onPressed: () => _quickAddIdea(context),
        tooltip: '记录灵感',
        child: const Icon(Icons.lightbulb),
      );
    default:
      return null;
  }
}
```

## 导航处理

### 导航项选择处理
```dart
void _onNavigationItemSelected(int index) {
  if (index < _navigationItems.length) {
    final targetPath = _navigationItems[index].path;
    context.go(targetPath);
  } else if (index == _navigationItems.length) {
    // 关于页面（在抽屉中的额外项目）
    context.go(RoutePaths.about);
  }
}
```

### 选中状态更新
```dart
void _updateSelectedIndex() {
  final currentPath = widget.routerState?.uri.path ?? RoutePaths.home;
  
  for (int i = 0; i < _navigationItems.length; i++) {
    if (_navigationItems[i].path == currentPath) {
      if (_selectedIndex != i) {
        setState(() {
          _selectedIndex = i;
        });
      }
      break;
    }
  }
}
```

### 页面标题获取
```dart
String _getCurrentPageTitle() {
  if (_selectedIndex < _navigationItems.length) {
    return _navigationItems[_selectedIndex].label;
  }
  return '桌宠助手';
}
```

## 交互功能

### 通知显示（占位符实现）
```dart
void _showNotifications(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('通知功能将在后续版本中实现'),
      duration: Duration(seconds: 2),
    ),
  );
}
```

### 搜索功能（占位符实现）
```dart
void _showSearch(BuildContext context) {
  showSearch(
    context: context,
    delegate: _AppSearchDelegate(),
  );
}

class _AppSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(
      child: Text('搜索功能将在后续版本中实现'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('输入关键词进行搜索...'),
    );
  }
}
```

### 菜单操作处理
```dart
void _handleMenuAction(String action) {
  switch (action) {
    case 'refresh':
      // 刷新当前页面
      _pageAnimationController.reset();
      _pageAnimationController.forward();
      break;
    case 'about':
      context.go(RoutePaths.about);
      break;
  }
}
```

### 快速操作（占位符实现）
```dart
void _quickPunchIn(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('快速打卡功能将在打卡模块中实现'),
      duration: Duration(seconds: 2),
    ),
  );
}

void _quickAddNote(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('快速添加功能将在事务中心中实现'),
      duration: Duration(seconds: 2),
    ),
  );
}

void _quickAddIdea(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('记录灵感功能将在创意工坊中实现'),
      duration: Duration(seconds: 2),
    ),
  );
}
```

## 生命周期管理

### 初始化
```dart
@override
void initState() {
  super.initState();
  
  // 初始化页面切换动画
  _pageAnimationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  _pageAnimation = CurvedAnimation(
    parent: _pageAnimationController,
    curve: Curves.easeInOut,
  );
  
  // 开始页面动画
  _pageAnimationController.forward();
  
  // 更新选中状态
  _updateSelectedIndex();
}
```

### 资源清理
```dart
@override
void dispose() {
  _pageAnimationController.dispose();
  super.dispose();
}
```

## 使用示例

### 基础使用
```dart
// 在App Router中使用
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(
        child: child,
        routerState: state,
      ),
      routes: [
        GoRoute(
          path: RoutePaths.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: RoutePaths.punchIn,
          builder: (context, state) => const PunchInPage(),
        ),
        // ... 其他路由
      ],
    ),
  ],
);
```

### 自定义配置
```dart
// 使用自定义路由状态
MainShell(
  child: currentPage,
  routerState: customRouterState,
)
```

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 基础响应式布局支持
  - NavigationDrawer和NavigationRail集成
  - 简单的页面切换动画
  - Go Router状态集成
  - 占位符功能实现 