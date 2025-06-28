/*
---------------------------------------------------------------
File name:          main.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/27
Dart Version:       3.32.4
Description:        应用启动器 - Phase 2.0双端自适应UI框架，基于StandardAppShell和AppRouter
---------------------------------------------------------------
Change History:
    2025/06/27: Phase 2.0 Sprint 2.0a - 集成StandardAppShell和AppRouter，实现双端自适应UI框架;
    2025/06/26: Phase 1.5 i18n集成 - 添加MaterialApp和国际化配置;
    2025/06/26: Phase 1.5 模块集成 - 添加模块管理器和EventBus初始化;
    2025/06/26: Phase 1.5 重构 - 简化启动流程，移除复杂的服务注册;
    2025/06/25: Step 20 重构 - 企业级应用启动器实现;
    2025/06/25: Step 18后期修复 - 简化架构修复;
    2025/06/25: Step 18初始版本 - 基础应用入口点;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_routing/app_routing.dart';
import 'package:core_services/core_services.dart';
import 'package:core_services/database/database.dart' as db;
import 'package:ui_framework/ui_framework.dart';
import 'package:notes_hub/notes_hub.dart';
import 'package:workshop/workshop.dart';
import 'package:punch_in/punch_in.dart';

// 导入生成的本地化文件
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 基础系统配置
    await _configureSystemSettings();
    
    // 初始化核心服务
    await _initializeCoreServices();
    
    // 初始化模块
    await _initializeModules();
    
    // 启动应用 - 使用新的双端自适应架构
    runApp(const PetAppMain());
  } catch (e, stackTrace) {
    // 处理启动错误
    if (kDebugMode) {
      print('应用启动失败: $e');
      print(stackTrace);
    }
    
    // 运行错误恢复应用
    runApp(ErrorRecoveryApp(error: e.toString()));
  }
}

/// 主应用程序 - Phase 2.0双端自适应UI框架
class PetAppMain extends StatefulWidget {
  const PetAppMain({super.key});

  @override
  State<PetAppMain> createState() => _PetAppMainState();
}

class _PetAppMainState extends State<PetAppMain> with WidgetsBindingObserver {
  Locale? _currentLocale;
  StreamSubscription<SupportedLocale>? _localeSubscription;
  StreamSubscription<ThemeConfig>? _themeSubscription;
  ThemeConfig _currentThemeConfig = const ThemeConfig();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocaleListener();
    _initializeThemeListener();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localeSubscription?.cancel();
    _themeSubscription?.cancel();
    // 清理服务资源
    displayModeService.dispose();
    localeService.dispose();
    super.dispose();
  }
  
  /// 初始化语言监听器 - Phase 2.2 Sprint 2
  void _initializeLocaleListener() {
    try {
      // 设置初始语言
      _currentLocale = localeService.currentFlutterLocale;
      
      // 监听语言变化
      _localeSubscription = localeService.localeStream.listen((supportedLocale) {
        if (mounted) {
          setState(() {
            _currentLocale = supportedLocale.locale;
          });
          if (kDebugMode) {
            print('🌐 MaterialApp语言已更新: ${supportedLocale.displayName}');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 语言监听器初始化失败: $e');
      }
      // 使用默认语言
      _currentLocale = const Locale('zh', 'CN');
    }
  }
  
  /// 初始化主题监听器 - Phase 2.2C 设置页面主题集成
  void _initializeThemeListener() {
    try {
      final themeService = BasicThemeService.instance;
      
      // 设置初始主题配置
      _currentThemeConfig = themeService.currentConfig;
      
      // 监听主题变化
      _themeSubscription = themeService.themeChanges.listen((themeConfig) {
        if (mounted) {
          setState(() {
            _currentThemeConfig = themeConfig;
          });
          if (kDebugMode) {
            print('🎨 MaterialApp主题已更新: ${themeConfig.colorSchemeType.displayName} (${themeConfig.themeMode.displayName})');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 主题监听器初始化失败: $e');
      }
      // 使用默认主题配置
      _currentThemeConfig = const ThemeConfig();
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 应用生命周期变化处理
    if (state == AppLifecycleState.detached) {
      displayModeService.dispose();
      localeService.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取ThemeService并构建主题数据
    final themeService = BasicThemeService.instance;
    final appThemeData = themeService.currentTheme;
    
    return MaterialApp.router(
      title: '桌宠AI助理平台',
      
      // 国际化配置
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // 支持的语言环境
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文（中国）
        Locale('en', 'US'), // 英文（美国）
      ],
      
      // 当前语言环境
      locale: _currentLocale,
      
      // 主题配置 - 使用ThemeService提供的动态主题
      theme: appThemeData.lightTheme,
      darkTheme: appThemeData.darkTheme,
      themeMode: _currentThemeConfig.themeMode.flutterThemeMode,
      
      // 使用新的AppRouter - 支持双端自适应外壳
      routerConfig: AppRouter.router,
      
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 配置系统设置
Future<void> _configureSystemSettings() async {
  // 设置首选方向 - 移动端竖屏，桌面端自适应
  if (!kIsWeb && (
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS
  )) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  if (kDebugMode) {
    print('✅ 系统配置完成 - Phase 2.0双端自适应');
    print('📱 当前平台: ${_getPlatformInfo()}');
  }
}

/// 获取平台信息
String _getPlatformInfo() {
  if (kIsWeb) return 'Web (标准模式)';
  
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'Android (沉浸式标准应用)';
    case TargetPlatform.iOS:
      return 'iOS (沉浸式标准应用)';
    case TargetPlatform.windows:
      return 'Windows (空间化OS模式 - Phase 2.0b)';
    case TargetPlatform.macOS:
      return 'macOS (空间化OS模式 - Phase 2.0b)';
    case TargetPlatform.linux:
      return 'Linux (空间化OS模式 - Phase 2.0b)';
    default:
      return '未知平台';
  }
}

/// 自动检测并设置正确的显示模式 - Phase 2.1 BugFix
Future<void> _autoDetectAndSetDisplayMode() async {
  try {
    DisplayMode targetMode;
    String reason;
    
    // 根据平台特征进行智能检测
    if (kIsWeb) {
      // Web平台：使用Web模式
      targetMode = DisplayMode.web;
      reason = 'Auto-detected: Web platform';
    } else {
      // 原生平台：根据设备类型选择
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
          // 移动平台：使用移动模式
          targetMode = DisplayMode.mobile;
          reason = 'Auto-detected: Mobile platform (${defaultTargetPlatform.name})';
          break;
        case TargetPlatform.windows:
        case TargetPlatform.macOS:
        case TargetPlatform.linux:
          // 桌面平台：使用桌面模式
          targetMode = DisplayMode.desktop;
          reason = 'Auto-detected: Desktop platform (${defaultTargetPlatform.name})';
          break;
        default:
          // 未知平台：使用移动模式作为默认
          targetMode = DisplayMode.mobile;
          reason = 'Auto-detected: Unknown platform, fallback to mobile';
      }
    }
    
    // 只有当当前模式与目标模式不同时才切换
    if (displayModeService.currentMode != targetMode) {
      await displayModeService.switchToMode(targetMode, reason: reason);
      if (kDebugMode) {
        print('🔄 自动切换显示模式: ${displayModeService.currentMode.displayName} ($reason)');
      }
    } else {
      if (kDebugMode) {
        print('✅ 显示模式已正确: ${displayModeService.currentMode.displayName}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ 自动显示模式检测失败: $e');
    }
    // 发生错误时，确保至少有一个可用的模式
    if (displayModeService.currentMode != DisplayMode.mobile) {
      await displayModeService.switchToMode(DisplayMode.mobile, reason: 'Error fallback');
    }
  }
}

/// 初始化核心服务
Future<void> _initializeCoreServices() async {
  try {
    // 创建并注册EventBus（避免循环依赖）
    final eventBus = EventBus();
    ServiceLocator.instance.registerSingleton<EventBus>(eventBus);
    
    // Phase 2.2B Sprint 2: 初始化Drift数据库和Repository
    await _initializeDatabaseServices();
    
    // 初始化DisplayModeService - Phase 2.1三端UI框架核心服务
    displayModeService = DisplayModeService();
    await displayModeService.initialize();
    
    // Phase 2.1 BugFix: 根据实际平台自动设置正确的显示模式
    await _autoDetectAndSetDisplayMode();
    
    // 初始化LocaleService - Phase 2.2 Sprint 2国际化系统
    localeService = LocaleService();
    await localeService.initialize();
    
    // 初始化ThemeService - Phase 2.2C设置页面需要
    final themeService = BasicThemeService.instance;
    await themeService.initialize();
    
    // 初始化I18nService - Phase 2.2 Sprint 2分布式国际化系统
    await _initializeDistributedI18n();
    
    if (kDebugMode) {
      print('✅ 核心服务初始化完成 - EventBus已注册');
      print('✅ 数据库服务初始化完成 - DriftPersistenceRepository已注册');
      print('✅ DisplayModeService初始化完成 - 当前模式: ${displayModeService.currentMode.displayName}');
      print('✅ LocaleService初始化完成 - 当前语言: ${localeService.currentLocale.displayName}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ 核心服务初始化失败: $e');
    }
    rethrow;
  }
}

/// 初始化数据库服务 - Phase 2.2B Sprint 2 (带Web平台降级支持)
Future<void> _initializeDatabaseServices() async {
  try {
    IPersistenceRepository repository;
    
    if (kIsWeb) {
      // Web平台：使用InMemoryRepository降级方案
      repository = InMemoryRepository();
      if (kDebugMode) {
        print('🌐 Web平台检测 - 使用InMemoryRepository降级方案');
        print('⚠️ 注意: Web平台数据存储为内存模式，刷新页面将丢失数据');
      }
    } else {
      // 原生平台：使用DriftPersistenceRepository
      try {
        // 创建AppDatabase实例
        final database = db.AppDatabase();
        
        // 注册AppDatabase实例到ServiceLocator
        ServiceLocator.instance.registerSingleton<db.AppDatabase>(database);
        
        // 创建DriftPersistenceRepository实例
        repository = DriftPersistenceRepository(database);
        
        // 验证健康检查
        final healthCheck = await repository.healthCheck();
        if (!healthCheck.isSuccess || healthCheck.data?['healthy'] != true) {
          throw Exception('数据库健康检查失败: ${healthCheck.errorMessage}');
        }
        
        if (kDebugMode) {
          print('✅ Drift数据库初始化成功 (原生平台)');
          final stats = await repository.getStatistics();
          if (stats.isSuccess) {
            print('📈 Repository统计: ${stats.data}');
          }
        }
      } catch (e) {
        // 原生平台Drift失败时也降级到InMemoryRepository
        if (kDebugMode) {
          print('⚠️ Drift数据库初始化失败，降级到InMemoryRepository: $e');
        }
        repository = InMemoryRepository();
      }
    }
    
    // 注册Repository作为IPersistenceRepository的实现
    ServiceLocator.instance.registerSingleton<IPersistenceRepository>(repository);
    
    // Phase 2.2B Sprint 2: 测试Repository依赖注入
    await _testRepositoryInjection();
    
    if (kDebugMode) {
      print('✅ 数据库服务初始化完成 - Repository类型: ${repository.runtimeType}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ 数据库服务初始化完全失败: $e');
    }
    rethrow;
  }
}

/// 测试Repository依赖注入 - Phase 2.2B Sprint 2验证
Future<void> _testRepositoryInjection() async {
  try {
    // 验证是否能从ServiceLocator获取Repository
    final isRegistered = ServiceLocator.instance.isRegistered<IPersistenceRepository>();
    if (!isRegistered) {
      throw Exception('IPersistenceRepository未注册到ServiceLocator');
    }
    
    // 获取Repository实例
    final repository = ServiceLocator.instance.get<IPersistenceRepository>();
    
    // 测试基本操作
    final stats = await repository.getStatistics();
    if (!stats.isSuccess) {
      throw Exception('Repository统计功能测试失败: ${stats.errorMessage}');
    }
    
    final count = await repository.count();
    if (!count.isSuccess) {
      throw Exception('Repository计数功能测试失败: ${count.errorMessage}');
    }
    
    if (kDebugMode) {
      print('✅ Repository依赖注入测试通过');
      print('🎯 Repository类型: ${repository.runtimeType}');
      print('📊 当前数据项数量: ${count.data}');
    }
    
  } catch (e) {
    if (kDebugMode) {
      print('❌ Repository依赖注入测试失败: $e');
    }
    throw Exception('Repository依赖注入验证失败: $e');
  }
}

/// 初始化所有模块
Future<void> _initializeModules() async {
  try {
    final moduleManager = ModuleManager.instance;
    // EventBus从ServiceLocator获取，模块管理器会自动使用
    
    // 注册业务模块
    await moduleManager.registerModule(NotesHubModule());
    await moduleManager.registerModule(WorkshopModule());
    await moduleManager.registerModule(PunchInModule());
    
    // 初始化所有模块
    await moduleManager.initializeAllModules();
    
    if (kDebugMode) {
      print('✅ 所有模块初始化完成 - Phase 2.0模块集成');
      final activeModules = moduleManager.getActiveModules();
      print('📦 已加载模块: ${activeModules.map((m) => m.id).toList()}');
      print('🎯 模块总数: ${activeModules.length}/3 活跃');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ 模块初始化失败: $e');
    }
    rethrow;
  }
}

/// 初始化分布式国际化系统 - Phase 2.2 Sprint 2
Future<void> _initializeDistributedI18n() async {
  try {
    final i18nService = I18nService.instance;
    
    // 注册各包的i18n提供者 - 按依赖顺序注册
    
    // 初始化I18nService本身（传入LocaleService）
    await i18nService.initialize(localeService);
    
    // 1. 注册UI框架包的i18n提供者
    UIFrameworkL10n.register();
    
    // 2. 注册路由包的i18n提供者  
    AppRoutingL10n.register();
    
    // 3. 注册核心服务包（如果需要）
    // i18nService.registerPackageProvider('core_services', CoreServicesL10n());
    
    // 4. 注册业务模块包的i18n提供者
    for (final provider in NotesHubL10n.getAllProviders()) {
      i18nService.registerProvider(provider);
    }
    for (final provider in WorkshopL10n.getAllProviders()) {
      i18nService.registerProvider(provider);
    }
    for (final provider in PunchInL10n.getAllProviders()) {
      i18nService.registerProvider(provider);
    }
    
    if (kDebugMode) {
      print('✅ 分布式I18n系统初始化完成 - Phase 2.2 Sprint 2');
      print('📦 已注册包级i18n提供者: ui_framework, app_routing, notes_hub, workshop, punch_in');
      
      // 验证翻译完整性
      final debugInfo = i18nService.getDebugInfo();
      print('🌐 I18n调试信息: ${debugInfo.length} 项');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ 分布式I18n系统初始化失败: $e');
    }
    rethrow;
  }
}

/// 错误恢复应用
class ErrorRecoveryApp extends StatelessWidget {
  final String error;
  
  const ErrorRecoveryApp({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '桌宠AI助理平台 - 启动错误',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 20),
                Text(
                  '桌宠AI助理平台启动失败',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Phase 2.0 Sprint 2.0a\n双端自适应UI框架',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // 重启应用
                    SystemNavigator.pop();
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('重启应用'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 