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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_routing/app_routing.dart';
import 'package:core_services/core_services.dart';
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
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 清理DisplayModeService资源
    displayModeService.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 应用生命周期变化处理
    if (state == AppLifecycleState.detached) {
      displayModeService.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      
      // 主题配置 - Material Design 3
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      
      // 深色主题配置
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      
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

/// 初始化核心服务
Future<void> _initializeCoreServices() async {
  try {
    // 创建并注册EventBus（避免循环依赖）
    final eventBus = EventBus();
    ServiceLocator.instance.registerSingleton<EventBus>(eventBus);
    
    // 初始化DisplayModeService - Phase 2.1三端UI框架核心服务
    displayModeService = DisplayModeService();
    await displayModeService.initialize();
    
    if (kDebugMode) {
      print('✅ 核心服务初始化完成 - EventBus已注册');
      print('✅ DisplayModeService初始化完成 - 当前模式: ${displayModeService.currentMode.displayName}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ 核心服务初始化失败: $e');
    }
    rethrow;
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