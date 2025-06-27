/*
---------------------------------------------------------------
File name:          theme_service.dart
Author:             Ig
Date created:       2025/06/26
Last modified:      2025/06/26
Dart Version:       3.32.4
Description:        主题管理服务 - 提供主题热切换、用户自定义主题、主题持久化存储等功能
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 重构 - 主题系统拓展，创建完整的主题管理服务;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 主题模式枚举
enum AppThemeMode {
  /// 浅色主题
  light,
  /// 深色主题
  dark,
  /// 跟随系统
  system;

  /// 转换为Flutter的ThemeMode
  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// 从字符串解析
  static AppThemeMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }

  /// 显示名称
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return '浅色主题';
      case AppThemeMode.dark:
        return '深色主题';
      case AppThemeMode.system:
        return '跟随系统';
    }
  }
}

/// 主题配色方案类型
enum ColorSchemeType {
  /// Material Design默认紫色
  material,
  /// 蓝色系
  blue,
  /// 绿色系
  green,
  /// 橙色系
  orange,
  /// 红色系
  red,
  /// 粉色系
  pink,
  /// 青色系
  teal,
  /// 自定义
  custom;

  /// 获取种子颜色
  Color get seedColor {
    switch (this) {
      case ColorSchemeType.material:
        return const Color(0xFF6750A4);
      case ColorSchemeType.blue:
        return Colors.blue;
      case ColorSchemeType.green:
        return Colors.green;
      case ColorSchemeType.orange:
        return Colors.orange;
      case ColorSchemeType.red:
        return Colors.red;
      case ColorSchemeType.pink:
        return Colors.pink;
      case ColorSchemeType.teal:
        return Colors.teal;
      case ColorSchemeType.custom:
        return const Color(0xFF6750A4); // 默认值
    }
  }

  /// 显示名称
  String get displayName {
    switch (this) {
      case ColorSchemeType.material:
        return 'Material紫色';
      case ColorSchemeType.blue:
        return '蓝色';
      case ColorSchemeType.green:
        return '绿色';
      case ColorSchemeType.orange:
        return '橙色';
      case ColorSchemeType.red:
        return '红色';
      case ColorSchemeType.pink:
        return '粉色';
      case ColorSchemeType.teal:
        return '青色';
      case ColorSchemeType.custom:
        return '自定义';
    }
  }

  /// 从字符串解析
  static ColorSchemeType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'material':
        return ColorSchemeType.material;
      case 'blue':
        return ColorSchemeType.blue;
      case 'green':
        return ColorSchemeType.green;
      case 'orange':
        return ColorSchemeType.orange;
      case 'red':
        return ColorSchemeType.red;
      case 'pink':
        return ColorSchemeType.pink;
      case 'teal':
        return ColorSchemeType.teal;
      case 'custom':
        return ColorSchemeType.custom;
      default:
        return ColorSchemeType.material;
    }
  }
}

/// 字体样式类型
enum FontStyleType {
  /// 系统默认
  system,
  /// 苹方字体
  pingFang,
  /// 思源字体
  noto,
  /// 自定义
  custom;

  /// 获取字体族名
  String? get fontFamily {
    switch (this) {
      case FontStyleType.system:
        return null;
      case FontStyleType.pingFang:
        return 'PingFang SC';
      case FontStyleType.noto:
        return 'Noto Sans SC';
      case FontStyleType.custom:
        return null; // 需要用户指定
    }
  }

  /// 显示名称
  String get displayName {
    switch (this) {
      case FontStyleType.system:
        return '系统默认';
      case FontStyleType.pingFang:
        return '苹方字体';
      case FontStyleType.noto:
        return '思源字体';
      case FontStyleType.custom:
        return '自定义字体';
    }
  }

  /// 从字符串解析
  static FontStyleType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'system':
        return FontStyleType.system;
      case 'pingfang':
        return FontStyleType.pingFang;
      case 'noto':
        return FontStyleType.noto;
      case 'custom':
        return FontStyleType.custom;
      default:
        return FontStyleType.system;
    }
  }
}

/// 主题配置数据类
class ThemeConfig {
  final AppThemeMode themeMode;
  final ColorSchemeType colorSchemeType;
  final Color? customSeedColor;
  final FontStyleType fontStyleType;
  final String? customFontFamily;
  final bool useMaterial3;
  final double fontScale;
  final bool enableAnimations;
  final Duration animationDuration;

  const ThemeConfig({
    this.themeMode = AppThemeMode.system,
    this.colorSchemeType = ColorSchemeType.material,
    this.customSeedColor,
    this.fontStyleType = FontStyleType.system,
    this.customFontFamily,
    this.useMaterial3 = true,
    this.fontScale = 1.0,
    this.enableAnimations = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// 获取实际的种子颜色
  Color get effectiveSeedColor {
    return customSeedColor ?? colorSchemeType.seedColor;
  }

  /// 获取实际的字体族
  String? get effectiveFontFamily {
    return customFontFamily ?? fontStyleType.fontFamily;
  }

  /// 复制并修改
  ThemeConfig copyWith({
    AppThemeMode? themeMode,
    ColorSchemeType? colorSchemeType,
    Color? customSeedColor,
    FontStyleType? fontStyleType,
    String? customFontFamily,
    bool? useMaterial3,
    double? fontScale,
    bool? enableAnimations,
    Duration? animationDuration,
  }) {
    return ThemeConfig(
      themeMode: themeMode ?? this.themeMode,
      colorSchemeType: colorSchemeType ?? this.colorSchemeType,
      customSeedColor: customSeedColor ?? this.customSeedColor,
      fontStyleType: fontStyleType ?? this.fontStyleType,
      customFontFamily: customFontFamily ?? this.customFontFamily,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      fontScale: fontScale ?? this.fontScale,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'colorSchemeType': colorSchemeType.name,
      'customSeedColor': customSeedColor?.toARGB32().toRadixString(16).padLeft(8, '0').substring(2),
      'fontStyleType': fontStyleType.name,
      'customFontFamily': customFontFamily,
      'useMaterial3': useMaterial3,
      'fontScale': fontScale,
      'enableAnimations': enableAnimations,
      'animationDurationMs': animationDuration.inMilliseconds,
    };
  }

  /// 从JSON创建
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      themeMode: AppThemeMode.fromString(json['themeMode'] ?? 'system'),
      colorSchemeType: ColorSchemeType.fromString(json['colorSchemeType'] ?? 'material'),
      customSeedColor: json['customSeedColor'] != null ? Color(int.parse(json['customSeedColor'], radix: 16)) : null,
      fontStyleType: FontStyleType.fromString(json['fontStyleType'] ?? 'system'),
      customFontFamily: json['customFontFamily'],
      useMaterial3: json['useMaterial3'] ?? true,
      fontScale: (json['fontScale'] ?? 1.0).toDouble(),
      enableAnimations: json['enableAnimations'] ?? true,
      animationDuration: Duration(milliseconds: json['animationDurationMs'] ?? 300),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeConfig &&
        other.themeMode == themeMode &&
        other.colorSchemeType == colorSchemeType &&
        other.customSeedColor == customSeedColor &&
        other.fontStyleType == fontStyleType &&
        other.customFontFamily == customFontFamily &&
        other.useMaterial3 == useMaterial3 &&
        other.fontScale == fontScale &&
        other.enableAnimations == enableAnimations &&
        other.animationDuration == animationDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      colorSchemeType,
      customSeedColor,
      fontStyleType,
      customFontFamily,
      useMaterial3,
      fontScale,
      enableAnimations,
      animationDuration,
    );
  }
}

/// 主题存储接口
abstract class ThemeStorage {
  /// 保存主题配置
  Future<void> saveThemeConfig(ThemeConfig config);
  
  /// 加载主题配置
  Future<ThemeConfig?> loadThemeConfig();
  
  /// 删除主题配置
  Future<void> clearThemeConfig();
}

/// 简单内存存储实现（实际项目中可使用SharedPreferences）
class InMemoryThemeStorage implements ThemeStorage {
  ThemeConfig? _cachedConfig;

  @override
  Future<void> saveThemeConfig(ThemeConfig config) async {
    _cachedConfig = config;
    // 在实际项目中，这里应该持久化到本地存储
    // 例如：await prefs.setString('theme_config', jsonEncode(config.toJson()));
  }

  @override
  Future<ThemeConfig?> loadThemeConfig() async {
    // 在实际项目中，这里应该从本地存储读取
    // 例如：final json = prefs.getString('theme_config');
    return _cachedConfig;
  }

  @override
  Future<void> clearThemeConfig() async {
    _cachedConfig = null;
    // 在实际项目中，这里应该删除本地存储的数据
    // 例如：await prefs.remove('theme_config');
  }
}

/// 应用主题数据类（避免与Flutter的ThemeData冲突）
class AppThemeData {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeConfig config;

  const AppThemeData({
    required this.lightTheme,
    required this.darkTheme,
    required this.config,
  });
}

/// 主题服务接口
abstract class ThemeService {
  /// 当前主题配置
  ThemeConfig get currentConfig;
  
  /// 当前主题数据
  AppThemeData get currentTheme;
  
  /// 主题变化流
  Stream<ThemeConfig> get themeChanges;
  
  /// 初始化服务
  Future<void> initialize();
  
  /// 设置主题模式
  Future<void> setThemeMode(AppThemeMode mode);
  
  /// 设置颜色方案
  Future<void> setColorScheme(ColorSchemeType type, {Color? customColor});
  
  /// 设置字体样式
  Future<void> setFontStyle(FontStyleType type, {String? customFontFamily});
  
  /// 设置字体缩放
  Future<void> setFontScale(double scale);
  
  /// 设置动画开关
  Future<void> setAnimationsEnabled(bool enabled);
  
  /// 应用主题配置
  Future<void> applyThemeConfig(ThemeConfig config);
  
  /// 重置为默认主题
  Future<void> resetToDefault();
  
  /// 获取预设主题列表
  List<ColorSchemeType> getPresetColorSchemes();
  
  /// 获取预设字体列表
  List<FontStyleType> getPresetFontStyles();
  
  /// 判断当前是否为深色模式
  bool get isDarkMode;
  
  /// 关闭服务
  void dispose();
}

/// 基础主题服务实现
class BasicThemeService implements ThemeService {
  static BasicThemeService? _instance;
  static BasicThemeService get instance => _instance ??= BasicThemeService._();
  
  BasicThemeService._();

  /// 主题存储
  late ThemeStorage _storage;
  
  /// 当前配置
  ThemeConfig _currentConfig = const ThemeConfig();
  
  /// 当前主题数据
  late AppThemeData _currentTheme;
  
  /// 主题变化控制器
  final StreamController<ThemeConfig> _themeController = StreamController<ThemeConfig>.broadcast();
  
  /// 是否已初始化
  bool _isInitialized = false;

  @override
  ThemeConfig get currentConfig => _currentConfig;

  @override
  AppThemeData get currentTheme => _currentTheme;

  @override
  Stream<ThemeConfig> get themeChanges => _themeController.stream;

  @override
  Future<void> initialize({ThemeStorage? storage}) async {
    if (_isInitialized) return;
    
    _storage = storage ?? InMemoryThemeStorage();
    
    // 加载保存的主题配置
    final savedConfig = await _storage.loadThemeConfig();
    if (savedConfig != null) {
      _currentConfig = savedConfig;
    }
    
    // 生成主题数据
    _currentTheme = _buildThemeData(_currentConfig);
    
    _isInitialized = true;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    final newConfig = _currentConfig.copyWith(themeMode: mode);
    await applyThemeConfig(newConfig);
  }

  @override
  Future<void> setColorScheme(ColorSchemeType type, {Color? customColor}) async {
    final newConfig = _currentConfig.copyWith(
      colorSchemeType: type,
      customSeedColor: customColor,
    );
    await applyThemeConfig(newConfig);
  }

  @override
  Future<void> setFontStyle(FontStyleType type, {String? customFontFamily}) async {
    final newConfig = _currentConfig.copyWith(
      fontStyleType: type,
      customFontFamily: customFontFamily,
    );
    await applyThemeConfig(newConfig);
  }

  @override
  Future<void> setFontScale(double scale) async {
    final newConfig = _currentConfig.copyWith(fontScale: scale);
    await applyThemeConfig(newConfig);
  }

  @override
  Future<void> setAnimationsEnabled(bool enabled) async {
    final newConfig = _currentConfig.copyWith(enableAnimations: enabled);
    await applyThemeConfig(newConfig);
  }

  @override
  Future<void> applyThemeConfig(ThemeConfig config) async {
    _ensureInitialized();
    
    _currentConfig = config;
    _currentTheme = _buildThemeData(config);
    
    // 保存配置
    await _storage.saveThemeConfig(config);
    
    // 通知监听者
    _themeController.add(config);
  }

  @override
  Future<void> resetToDefault() async {
    await applyThemeConfig(const ThemeConfig());
  }

  @override
  List<ColorSchemeType> getPresetColorSchemes() {
    return ColorSchemeType.values;
  }

  @override
  List<FontStyleType> getPresetFontStyles() {
    return FontStyleType.values;
  }

  @override
  bool get isDarkMode {
    if (_currentConfig.themeMode == AppThemeMode.dark) {
      return true;
    } else if (_currentConfig.themeMode == AppThemeMode.light) {
      return false;
    } else {
      // 跟随系统
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  @override
  void dispose() {
    _themeController.close();
    _isInitialized = false;
  }

  /// 构建主题数据
  AppThemeData _buildThemeData(ThemeConfig config) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: config.effectiveSeedColor,
      brightness: Brightness.light,
    );
    
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: config.effectiveSeedColor,
      brightness: Brightness.dark,
    );

    return AppThemeData(
      lightTheme: _buildLightTheme(config, colorScheme),
      darkTheme: _buildDarkTheme(config, darkColorScheme),
      config: config,
    );
  }

  /// 构建浅色主题
  ThemeData _buildLightTheme(ThemeConfig config, ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: config.useMaterial3,
      fontFamily: config.effectiveFontFamily,
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18 * config.fontScale,
          fontWeight: FontWeight.w600,
          fontFamily: config.effectiveFontFamily,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surface,
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      // 动画设置
      pageTransitionsTheme: config.enableAnimations
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              },
            ),
    );
  }

  /// 构建深色主题
  ThemeData _buildDarkTheme(ThemeConfig config, ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: config.useMaterial3,
      fontFamily: config.effectiveFontFamily,
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18 * config.fontScale,
          fontWeight: FontWeight.w600,
          fontFamily: config.effectiveFontFamily,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surface,
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      // 动画设置
      pageTransitionsTheme: config.enableAnimations
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              },
            ),
    );
  }

  /// 确保已初始化
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('ThemeService not initialized. Call initialize() first.');
    }
  }
}

/// 主题管理Widget - 提供主题数据给子Widget
class ThemeProvider extends StatefulWidget {
  final Widget child;
  final ThemeService? themeService;

  const ThemeProvider({
    super.key,
    required this.child,
    this.themeService,
  });

  @override
  State<ThemeProvider> createState() => _ThemeProviderState();

  /// 获取主题服务
  static ThemeService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_InheritedThemeProvider>();
    return provider?.themeService ?? BasicThemeService.instance;
  }
}

class _ThemeProviderState extends State<ThemeProvider> {
  late ThemeService _themeService;
  late StreamSubscription<ThemeConfig> _themeSubscription;
  ThemeConfig _currentConfig = const ThemeConfig();

  @override
  void initState() {
    super.initState();
    _themeService = widget.themeService ?? BasicThemeService.instance;
    _currentConfig = _themeService.currentConfig;
    
    _themeSubscription = _themeService.themeChanges.listen((config) {
      if (mounted) {
        setState(() {
          _currentConfig = config;
        });
      }
    });
  }

  @override
  void dispose() {
    _themeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedThemeProvider(
      themeService: _themeService,
      config: _currentConfig,
      child: widget.child,
    );
  }
}

/// 继承Widget，用于传递主题数据
class _InheritedThemeProvider extends InheritedWidget {
  final ThemeService themeService;
  final ThemeConfig config;

  const _InheritedThemeProvider({
    required this.themeService,
    required this.config,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _InheritedThemeProvider oldWidget) {
    return config != oldWidget.config;
  }
} 