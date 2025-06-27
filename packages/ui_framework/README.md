# UI Framework Package

现代化的 Flutter UI 框架包，提供主题系统、基础组件和应用外壳，支持热切换主题、国际化和响应式设计。

## 功能特性

- **主题系统**: 完整的主题管理，支持浅色/深色/跟随系统模式
- **热切换主题**: 运行时动态切换主题，无需重启应用
- **多彩色方案**: 内置8种精美配色方案和3种字体样式
- **用户自定义**: 支持用户自定义颜色、字体和字体缩放
- **主题持久化**: 自动保存和恢复用户主题偏好
- **应用外壳**: 统一的应用框架和导航组件
- **响应式设计**: 适配不同屏幕尺寸和设备类型
- **国际化支持**: 完整的多语言本地化支持

## 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  ui_framework:
    path: ../packages/ui_framework  # 相对于你的项目路径调整
```

## 快速开始

### 1. 基础应用设置

```dart
import 'package:ui_framework/ui_framework.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App(); // 使用 UI Framework 提供的 App 组件
  }
}
```

### 2. 主题系统使用

```dart
import 'package:ui_framework/ui_framework.dart';

// 初始化主题服务
final themeService = BasicThemeService();

// 应用主题提供者
ThemeProvider(
  themeService: themeService,
  child: MaterialApp(
    theme: context.watch<ThemeService>().currentTheme.lightTheme,
    darkTheme: context.watch<ThemeService>().currentTheme.darkTheme,
    home: MyHomePage(),
  ),
)
```

### 3. 主题切换

```dart
// 切换主题模式
themeService.setThemeMode(ThemeMode.dark);
themeService.setThemeMode(ThemeMode.light);
themeService.setThemeMode(ThemeMode.system);

// 切换配色方案
themeService.setColorScheme(ColorSchemes.ocean);
themeService.setColorScheme(ColorSchemes.forest);

// 设置字体样式
themeService.setFontStyle(FontStyles.modern);
```

## API 参考

### App 类

应用的根组件，提供完整的应用框架设置。

```dart
App({
  Key? key,
  String? title,
  Widget? home,
  List<LocalizationsDelegate<dynamic>>? localizationsDelegates,
})
```

### ThemeService 接口

主题管理的核心接口，定义了所有主题相关操作。

#### 属性

- `currentTheme: AppTheme` - 当前活跃的主题
- `themeMode: ThemeMode` - 当前主题模式
- `colorScheme: ColorSchemes` - 当前配色方案
- `fontStyle: FontStyles` - 当前字体样式

#### 方法

```dart
// 主题模式管理
Future<void> setThemeMode(ThemeMode mode)
Future<void> toggleThemeMode()

// 配色方案管理
Future<void> setColorScheme(ColorSchemes scheme)
List<ColorSchemes> getAvailableColorSchemes()

// 字体管理
Future<void> setFontStyle(FontStyles style)
Future<void> setFontScale(double scale)

// 自定义主题
Future<void> setCustomColors(Map<String, Color> colors)
Future<void> setCustomFont(String fontFamily)

// 动画控制
Future<void> setAnimationsEnabled(bool enabled)
```

### ThemeProvider Widget

主题数据的提供者组件，将主题服务注入到 Widget 树中。

```dart
ThemeProvider({
  required ThemeService themeService,
  required Widget child,
})
```

### MainShell 组件

应用的主外壳组件，提供统一的应用框架。

```dart
MainShell({
  Key? key,
  required Widget child,
  String? title,
})
```

### NavigationDrawer 组件

应用的侧边导航抽屉。

```dart
NavigationDrawer({
  Key? key,
  List<NavigationItem>? items,
  Function(String)? onItemTap,
})
```

### PageContainer 组件

页面容器组件，提供一致的页面布局。

```dart
PageContainer({
  Key? key,
  required Widget child,
  String? title,
  List<Widget>? actions,
})
```

## 主题系统详解

### 配色方案

内置8种配色方案：

| 方案名 | 特色 | 适用场景 |
|-------|------|----------|
| `blue` | 经典蓝色 | 通用商务应用 |
| `green` | 自然绿色 | 健康、环保主题 |
| `purple` | 优雅紫色 | 创意、艺术应用 |
| `orange` | 活力橙色 | 娱乐、社交应用 |
| `pink` | 温馨粉色 | 生活、购物应用 |
| `teal` | 清新青色 | 科技、工具应用 |
| `indigo` | 深邃靛蓝 | 专业、企业应用 |
| `red` | 热情红色 | 紧急、重要功能 |

### 字体样式

内置3种字体样式：

- **Default**: 系统默认字体，平衡易读性和美观性
- **Modern**: 现代简约字体，适合科技感应用  
- **Classic**: 经典衬线字体，适合阅读密集应用

### 自定义主题

```dart
// 自定义颜色
await themeService.setCustomColors({
  'primary': Colors.blue.shade600,
  'secondary': Colors.green.shade400,
  'background': Colors.grey.shade50,
});

// 自定义字体
await themeService.setCustomFont('Roboto');

// 字体缩放
await themeService.setFontScale(1.2); // 放大20%
```

## 响应式设计

UI Framework 内置响应式设计支持：

```dart
// 断点定义
class Breakpoints {
  static const mobile = 600.0;
  static const tablet = 1024.0;
  static const desktop = 1440.0;
}

// 响应式布局
Widget buildResponsiveLayout(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  
  if (screenWidth < Breakpoints.mobile) {
    return MobileLayout();
  } else if (screenWidth < Breakpoints.tablet) {
    return TabletLayout();
  } else {
    return DesktopLayout();
  }
}
```

## 最佳实践

### 1. 主题一致性

```dart
// 使用主题色彩
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)
```

### 2. 响应式组件

```dart
// 响应式间距
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  
  const ResponsivePadding({required this.child});
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 600 ? 16.0 : 32.0;
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}
```

### 3. 主题切换动画

```dart
// 平滑的主题切换
AnimatedTheme(
  duration: Duration(milliseconds: 300),
  data: currentTheme,
  child: MyWidget(),
)
```

## 依赖关系

### 直接依赖
- `flutter`: Flutter SDK
- `cupertino_icons`: ^1.0.8 - iOS 风格图标
- `core_services`: 核心服务包
- `app_config`: 应用配置包
- `app_routing`: 路由管理包

### 层次位置
```
app_config (基础配置)
    ↓
core_services (核心服务)
    ↓
app_routing (路由管理)
    ↓
ui_framework (UI框架) ← 当前包
    ↓
business_modules (业务模块)
```

## 性能优化

### 1. 主题缓存

主题数据会自动缓存，避免重复计算：

```dart
// 主题服务会自动缓存计算结果
final theme = themeService.currentTheme; // 从缓存获取
```

### 2. 延迟加载

非关键主题资源采用延迟加载：

```dart
// 自定义字体延迟加载
await themeService.loadCustomFont('CustomFont');
```

### 3. 内存管理

及时释放不需要的主题资源：

```dart
@override
void dispose() {
  themeService.dispose();
  super.dispose();
}
```

## 故障排除

### 常见问题

1. **主题切换不生效**
   ```
   检查: ThemeProvider 是否正确包装应用
   确认: MaterialApp 是否使用了主题数据
   ```

2. **自定义字体不显示**
   ```
   检查: 字体文件是否正确添加到 pubspec.yaml
   确认: 字体家族名称是否正确
   ```

3. **响应式布局异常**
   ```
   检查: MediaQuery 是否可用
   确认: 断点值是否合理
   ```

## 开发与测试

### 运行测试

```bash
cd packages/ui_framework
flutter test
```

### 主题测试

```dart
// 测试主题切换
testWidgets('Theme switching works correctly', (tester) async {
  final themeService = MockThemeService();
  
  await tester.pumpWidget(
    ThemeProvider(
      themeService: themeService,
      child: MaterialApp(home: Container()),
    ),
  );
  
  // 验证主题切换
  themeService.setThemeMode(ThemeMode.dark);
  await tester.pump();
  
  // 断言主题已更新
  expect(themeService.themeMode, ThemeMode.dark);
});
```

## 更新日志

### v1.0.0
- 初始版本发布
- 完整主题系统实现
- 应用外壳组件
- 响应式设计支持
- 8种内置配色方案
- 3种字体样式选择

## 许可证

本包作为 PetApp 项目的一部分，遵循项目整体许可协议。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个包。请确保：

1. 遵循项目编码规范
2. 添加适当的测试用例
3. 更新相关文档
4. 保持向后兼容性
5. 测试多种主题和设备

## 相关资源

- [Flutter 主题指南](https://docs.flutter.dev/cookbook/design/themes)
- [Material Design 规范](https://material.io/design)
- [响应式设计最佳实践](https://docs.flutter.dev/development/ui/layout/responsive)
- [PetApp 设计原则文档](../../docs/design_principles.md) 