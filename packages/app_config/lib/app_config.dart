/// App Configuration Package
/// 
/// 管理应用的各种配置参数
library app_config;

/*
---------------------------------------------------------------
File name:          app_config.dart
Author:             AI Assistant  
Date created:       2025/06/25
Last modified:      2025/06/25
Dart Version:       3.32.4
Description:        企业级应用配置管理系统 - 环境配置、特性开关、常量管理
---------------------------------------------------------------
Change History:
    2025/06/25: Step 21 - 配置管理系统初始创建
---------------------------------------------------------------
*/

import 'dart:io';

// ========================================
// Step 21: 企业级应用配置管理系统
// ========================================

/// 应用环境枚举
/// 定义应用运行的不同环境类型
enum AppEnvironment {
  development('dev', 'Development'),
  testing('test', 'Testing'),
  staging('staging', 'Staging'),
  production('prod', 'Production');

  const AppEnvironment(this.code, this.displayName);

  /// 环境代码（用于配置文件和标识）
  final String code;
  
  /// 环境显示名称（用于UI显示）
  final String displayName;

  /// 是否为开发环境
  bool get isDevelopment => this == AppEnvironment.development;
  
  /// 是否为测试环境
  bool get isTesting => this == AppEnvironment.testing;
  
  /// 是否为预发环境
  bool get isStaging => this == AppEnvironment.staging;
  
  /// 是否为生产环境
  bool get isProduction => this == AppEnvironment.production;
  
  /// 是否为调试环境（开发和测试）
  bool get isDebugEnvironment => isDevelopment || isTesting;
  
  /// 是否为发布环境（预发和生产）
  bool get isReleaseEnvironment => isStaging || isProduction;

  /// 从字符串解析环境
  static AppEnvironment fromString(String value) {
    return AppEnvironment.values.firstWhere(
      (env) => env.code == value.toLowerCase() || env.name == value.toLowerCase(),
      orElse: () => AppEnvironment.development,
    );
  }
}

/// 日志级别枚举
enum LogLevel {
  verbose(0, 'VERBOSE'),
  debug(1, 'DEBUG'),
  info(2, 'INFO'),
  warning(3, 'WARNING'),
  error(4, 'ERROR'),
  wtf(5, 'WTF'); // What a Terrible Failure

  const LogLevel(this.value, this.name);

  /// 日志级别数值
  final int value;
  
  /// 日志级别名称
  final String name;

  /// 是否允许输出指定级别的日志
  bool allows(LogLevel level) => level.value >= value;
}

/// 特性开关配置类
/// 管理应用的功能特性启用/禁用状态
class FeatureFlags {
  const FeatureFlags({
    this.enableNotesHub = true,
    this.enableWorkshop = true,
    this.enablePunchIn = true,
    this.enableAdvancedLogging = false,
    this.enableCrashReporting = false,
    this.enableAnalytics = false,
    this.enablePerformanceMonitoring = false,
    this.enableExperimentalFeatures = false,
    this.enableBetaFeatures = false,
    this.enableOfflineMode = false,
    this.enableCloudSync = false,
    this.enableNotifications = true,
    this.enableAnimations = true,
    this.enableDarkMode = true,
    this.enableAccessibility = true,
  });

  // ========================================
  // 模块特性开关
  // ========================================
  
  /// 启用事务中心模块
  final bool enableNotesHub;
  
  /// 启用创意工坊模块
  final bool enableWorkshop;
  
  /// 启用打卡模块
  final bool enablePunchIn;

  // ========================================
  // 系统特性开关
  // ========================================
  
  /// 启用高级日志记录
  final bool enableAdvancedLogging;
  
  /// 启用崩溃报告
  final bool enableCrashReporting;
  
  /// 启用数据分析
  final bool enableAnalytics;
  
  /// 启用性能监控
  final bool enablePerformanceMonitoring;

  // ========================================
  // 实验性特性开关
  // ========================================
  
  /// 启用实验性功能
  final bool enableExperimentalFeatures;
  
  /// 启用Beta功能
  final bool enableBetaFeatures;

  // ========================================
  // 业务特性开关
  // ========================================
  
  /// 启用离线模式
  final bool enableOfflineMode;
  
  /// 启用云同步
  final bool enableCloudSync;
  
  /// 启用通知
  final bool enableNotifications;

  // ========================================
  // UI特性开关
  // ========================================
  
  /// 启用动画效果
  final bool enableAnimations;
  
  /// 启用深色模式
  final bool enableDarkMode;
  
  /// 启用无障碍功能
  final bool enableAccessibility;

  /// 获取所有启用的特性列表
  List<String> get enabledFeatures {
    final enabled = <String>[];
    if (enableNotesHub) enabled.add('NotesHub');
    if (enableWorkshop) enabled.add('Workshop');
    if (enablePunchIn) enabled.add('PunchIn');
    if (enableAdvancedLogging) enabled.add('AdvancedLogging');
    if (enableCrashReporting) enabled.add('CrashReporting');
    if (enableAnalytics) enabled.add('Analytics');
    if (enablePerformanceMonitoring) enabled.add('PerformanceMonitoring');
    if (enableExperimentalFeatures) enabled.add('ExperimentalFeatures');
    if (enableBetaFeatures) enabled.add('BetaFeatures');
    if (enableOfflineMode) enabled.add('OfflineMode');
    if (enableCloudSync) enabled.add('CloudSync');
    if (enableNotifications) enabled.add('Notifications');
    if (enableAnimations) enabled.add('Animations');
    if (enableDarkMode) enabled.add('DarkMode');
    if (enableAccessibility) enabled.add('Accessibility');
    return enabled;
  }

  /// 复制并修改特性开关
  FeatureFlags copyWith({
    bool? enableNotesHub,
    bool? enableWorkshop,
    bool? enablePunchIn,
    bool? enableAdvancedLogging,
    bool? enableCrashReporting,
    bool? enableAnalytics,
    bool? enablePerformanceMonitoring,
    bool? enableExperimentalFeatures,
    bool? enableBetaFeatures,
    bool? enableOfflineMode,
    bool? enableCloudSync,
    bool? enableNotifications,
    bool? enableAnimations,
    bool? enableDarkMode,
    bool? enableAccessibility,
  }) {
    return FeatureFlags(
      enableNotesHub: enableNotesHub ?? this.enableNotesHub,
      enableWorkshop: enableWorkshop ?? this.enableWorkshop,
      enablePunchIn: enablePunchIn ?? this.enablePunchIn,
      enableAdvancedLogging: enableAdvancedLogging ?? this.enableAdvancedLogging,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enablePerformanceMonitoring: enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
      enableExperimentalFeatures: enableExperimentalFeatures ?? this.enableExperimentalFeatures,
      enableBetaFeatures: enableBetaFeatures ?? this.enableBetaFeatures,
      enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      enableCloudSync: enableCloudSync ?? this.enableCloudSync,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableDarkMode: enableDarkMode ?? this.enableDarkMode,
      enableAccessibility: enableAccessibility ?? this.enableAccessibility,
    );
  }
}

/// 应用配置常量类
/// 定义应用中使用的各种常量值
class AppConstants {
  const AppConstants._();

  // ========================================
  // 应用基本信息
  // ========================================
  
  static const String appName = '桌宠助手';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription = '智能桌面宠物助手 - 提升工作效率的贴心伙伴';
  
  // ========================================
  // 网络配置
  // ========================================
  
  static const String baseApiUrl = 'https://api.pet-app.com';
  static const String wsBaseUrl = 'wss://ws.pet-app.com';
  static const int connectTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒
  static const int sendTimeout = 30000; // 30秒
  
  // ========================================
  // 存储配置
  // ========================================
  
  static const String databaseName = 'pet_app.db';
  static const int databaseVersion = 1;
  static const String prefsKey = 'pet_app_prefs';
  static const String cacheDir = 'cache';
  static const String documentsDir = 'documents';
  
  // ========================================
  // UI配置
  // ========================================
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration splashScreenDuration = Duration(seconds: 2);
  
  // ========================================
  // 性能配置
  // ========================================
  
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxImageCacheSize = 50 * 1024 * 1024; // 50MB
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // ========================================
  // 日志配置
  // ========================================
  
  static const int maxLogFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxLogFiles = 5;
  static const String logFilePrefix = 'pet_app_';
  static const String logFileExtension = '.log';
  
  // ========================================
  // 安全配置
  // ========================================
  
  static const String encryptionKeyAlias = 'pet_app_encryption_key';
  static const int sessionTimeout = 24 * 60 * 60 * 1000; // 24小时
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
}

/// 环境特定配置类
/// 根据不同环境提供不同的配置值
class EnvironmentConfig {
  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.logLevel,
    required this.enableDebugMode,
    required this.enablePerformanceOverlay,
    required this.enableInspector,
    required this.databaseName,
    this.customFeatureFlags,
  });

  /// 当前环境
  final AppEnvironment environment;
  
  /// API基础URL
  final String apiBaseUrl;
  
  /// WebSocket基础URL
  final String wsBaseUrl;
  
  /// 日志级别
  final LogLevel logLevel;
  
  /// 启用调试模式
  final bool enableDebugMode;
  
  /// 启用性能覆盖层
  final bool enablePerformanceOverlay;
  
  /// 启用Flutter Inspector
  final bool enableInspector;
  
  /// 数据库名称
  final String databaseName;
  
  /// 自定义特性开关（覆盖默认值）
  final FeatureFlags? customFeatureFlags;

  /// 获取有效的特性开关配置
  FeatureFlags get effectiveFeatureFlags {
    final defaultFlags = _getDefaultFeatureFlags();
    return customFeatureFlags ?? defaultFlags;
  }

  /// 根据环境获取默认特性开关
  FeatureFlags _getDefaultFeatureFlags() {
    switch (environment) {
      case AppEnvironment.development:
        return const FeatureFlags(
          enableAdvancedLogging: true,
          enableExperimentalFeatures: true,
          enableBetaFeatures: true,
          enablePerformanceMonitoring: true,
        );
      case AppEnvironment.testing:
        return const FeatureFlags(
          enableAdvancedLogging: true,
          enableCrashReporting: true,
          enablePerformanceMonitoring: true,
        );
      case AppEnvironment.staging:
        return const FeatureFlags(
          enableCrashReporting: true,
          enableAnalytics: true,
          enablePerformanceMonitoring: true,
          enableBetaFeatures: true,
        );
      case AppEnvironment.production:
        return const FeatureFlags(
          enableCrashReporting: true,
          enableAnalytics: true,
          enableCloudSync: true,
        );
    }
  }
}

/// 主应用配置类
/// 统一管理所有配置信息的中心类
class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.environmentConfig,
    required this.featureFlags,
    required this.constants,
  });

  /// 当前环境
  final AppEnvironment environment;
  
  /// 环境特定配置
  final EnvironmentConfig environmentConfig;
  
  /// 特性开关配置
  final FeatureFlags featureFlags;
  
  /// 应用常量
  final AppConstants constants;

  // ========================================
  // 单例模式实现
  // ========================================
  
  static AppConfig? _instance;
  
  /// 获取当前配置实例
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError('AppConfig has not been initialized. Call AppConfig.initialize() first.');
    }
    return _instance!;
  }

  /// 检查配置是否已初始化
  static bool get isInitialized => _instance != null;

  // ========================================
  // 配置初始化
  // ========================================
  
  /// 初始化应用配置
  static Future<void> initialize({
    AppEnvironment? environment,
    EnvironmentConfig? customEnvironmentConfig,
    FeatureFlags? customFeatureFlags,
  }) async {
    // 确定当前环境
    final currentEnvironment = environment ?? _detectEnvironment();
    
    // 创建环境配置
    final envConfig = customEnvironmentConfig ?? _createEnvironmentConfig(currentEnvironment);
    
    // 创建最终特性开关配置
    final finalFeatureFlags = customFeatureFlags ?? envConfig.effectiveFeatureFlags;
    
    // 创建配置实例
    _instance = AppConfig._(
      environment: currentEnvironment,
      environmentConfig: envConfig,
      featureFlags: finalFeatureFlags,
      constants: const AppConstants._(),
    );

    // 执行环境特定的初始化
    await _performEnvironmentSpecificInitialization();
    
    _logDebug('AppConfig initialized for environment: ${currentEnvironment.displayName}');
    _logDebug('Enabled features: ${finalFeatureFlags.enabledFeatures.join(', ')}');
  }

  /// 重置配置（主要用于测试）
  static void reset() {
    _instance = null;
  }

  // ========================================
  // 环境检测
  // ========================================
  
  /// 自动检测当前环境
  static AppEnvironment _detectEnvironment() {
    // 1. 从环境变量检测
    final envVar = Platform.environment['FLUTTER_ENV'];
    if (envVar != null) {
      return AppEnvironment.fromString(envVar);
    }
    
    // 2. 从编译时常量检测
    const environmentFromBuild = String.fromEnvironment('ENVIRONMENT');
    if (environmentFromBuild.isNotEmpty) {
      return AppEnvironment.fromString(environmentFromBuild);
    }
    
    // 3. 根据调试模式判断
    bool isDebugMode = false;
    assert(() {
      isDebugMode = true;
      return true;
    }());
    
    return isDebugMode ? AppEnvironment.development : AppEnvironment.production;
  }

  /// 创建环境特定配置
  static EnvironmentConfig _createEnvironmentConfig(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.development:
        return const EnvironmentConfig(
          environment: AppEnvironment.development,
          apiBaseUrl: 'http://localhost:3000/api',
          wsBaseUrl: 'ws://localhost:3000/ws',
          logLevel: LogLevel.debug,
          enableDebugMode: true,
          enablePerformanceOverlay: true,
          enableInspector: true,
          databaseName: 'pet_app_dev.db',
        );
      case AppEnvironment.testing:
        return const EnvironmentConfig(
          environment: AppEnvironment.testing,
          apiBaseUrl: 'https://api-test.pet-app.com',
          wsBaseUrl: 'wss://ws-test.pet-app.com',
          logLevel: LogLevel.info,
          enableDebugMode: true,
          enablePerformanceOverlay: false,
          enableInspector: true,
          databaseName: 'pet_app_test.db',
        );
      case AppEnvironment.staging:
        return const EnvironmentConfig(
          environment: AppEnvironment.staging,
          apiBaseUrl: 'https://api-staging.pet-app.com',
          wsBaseUrl: 'wss://ws-staging.pet-app.com',
          logLevel: LogLevel.info,
          enableDebugMode: false,
          enablePerformanceOverlay: false,
          enableInspector: false,
          databaseName: 'pet_app_staging.db',
        );
      case AppEnvironment.production:
        return const EnvironmentConfig(
          environment: AppEnvironment.production,
          apiBaseUrl: 'https://api.pet-app.com',
          wsBaseUrl: 'wss://ws.pet-app.com',
          logLevel: LogLevel.warning,
          enableDebugMode: false,
          enablePerformanceOverlay: false,
          enableInspector: false,
          databaseName: 'pet_app.db',
        );
    }
  }

  /// 执行环境特定的初始化
  static Future<void> _performEnvironmentSpecificInitialization() async {
    final config = _instance!;
    
    // 根据环境进行特定初始化
    switch (config.environment) {
      case AppEnvironment.development:
        // 开发环境：启用详细日志、性能监控等
        _logDebug('Development environment initialized');
        break;
      case AppEnvironment.testing:
        // 测试环境：配置测试相关设置
        _logDebug('Testing environment initialized');
        break;
      case AppEnvironment.staging:
        // 预发环境：配置预发相关设置
        _logDebug('Staging environment initialized');
        break;
      case AppEnvironment.production:
        // 生产环境：配置生产相关设置
        _logDebug('Production environment initialized');
        break;
    }
  }

  // ========================================
  // 便捷访问方法
  // ========================================
  
  /// 检查特性是否启用
  bool isFeatureEnabled(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'noteshub':
        return featureFlags.enableNotesHub;
      case 'workshop':
        return featureFlags.enableWorkshop;
      case 'punchin':
        return featureFlags.enablePunchIn;
      case 'advancedlogging':
        return featureFlags.enableAdvancedLogging;
      case 'crashreporting':
        return featureFlags.enableCrashReporting;
      case 'analytics':
        return featureFlags.enableAnalytics;
      case 'performancemonitoring':
        return featureFlags.enablePerformanceMonitoring;
      case 'experimentalfeatures':
        return featureFlags.enableExperimentalFeatures;
      case 'betafeatures':
        return featureFlags.enableBetaFeatures;
      case 'offlinemode':
        return featureFlags.enableOfflineMode;
      case 'cloudsync':
        return featureFlags.enableCloudSync;
      case 'notifications':
        return featureFlags.enableNotifications;
      case 'animations':
        return featureFlags.enableAnimations;
      case 'darkmode':
        return featureFlags.enableDarkMode;
      case 'accessibility':
        return featureFlags.enableAccessibility;
      default:
        return false;
    }
  }

  /// 获取API基础URL
  String get apiBaseUrl => environmentConfig.apiBaseUrl;
  
  /// 获取WebSocket基础URL
  String get wsBaseUrl => environmentConfig.wsBaseUrl;
  
  /// 是否为调试模式
  bool get isDebugMode => environmentConfig.enableDebugMode;
  
  /// 是否为生产环境
  bool get isProduction => environment.isProduction;
  
  /// 是否为开发环境
  bool get isDevelopment => environment.isDevelopment;
  
  /// 当前日志级别
  LogLevel get logLevel => environmentConfig.logLevel;

  // ========================================
  // 配置更新（运行时）
  // ========================================
  
  /// 更新特性开关（运行时）
  void updateFeatureFlags(FeatureFlags newFeatureFlags) {
    _instance = AppConfig._(
      environment: environment,
      environmentConfig: environmentConfig,
      featureFlags: newFeatureFlags,
      constants: constants,
    );
    _logDebug('FeatureFlags updated at runtime');
  }

  /// 切换单个特性开关
  void toggleFeature(String featureName, bool enabled) {
    FeatureFlags newFlags;
    
    switch (featureName.toLowerCase()) {
      case 'noteshub':
        newFlags = featureFlags.copyWith(enableNotesHub: enabled);
        break;
      case 'workshop':
        newFlags = featureFlags.copyWith(enableWorkshop: enabled);
        break;
      case 'punchin':
        newFlags = featureFlags.copyWith(enablePunchIn: enabled);
        break;
      case 'advancedlogging':
        newFlags = featureFlags.copyWith(enableAdvancedLogging: enabled);
        break;
      case 'crashreporting':
        newFlags = featureFlags.copyWith(enableCrashReporting: enabled);
        break;
      case 'analytics':
        newFlags = featureFlags.copyWith(enableAnalytics: enabled);
        break;
      case 'performancemonitoring':
        newFlags = featureFlags.copyWith(enablePerformanceMonitoring: enabled);
        break;
      case 'experimentalfeatures':
        newFlags = featureFlags.copyWith(enableExperimentalFeatures: enabled);
        break;
      case 'betafeatures':
        newFlags = featureFlags.copyWith(enableBetaFeatures: enabled);
        break;
      case 'offlinemode':
        newFlags = featureFlags.copyWith(enableOfflineMode: enabled);
        break;
      case 'cloudsync':
        newFlags = featureFlags.copyWith(enableCloudSync: enabled);
        break;
      case 'notifications':
        newFlags = featureFlags.copyWith(enableNotifications: enabled);
        break;
      case 'animations':
        newFlags = featureFlags.copyWith(enableAnimations: enabled);
        break;
      case 'darkmode':
        newFlags = featureFlags.copyWith(enableDarkMode: enabled);
        break;
      case 'accessibility':
        newFlags = featureFlags.copyWith(enableAccessibility: enabled);
        break;
      default:
        _logDebug('Unknown feature: $featureName');
        return;
    }
    
    updateFeatureFlags(newFlags);
    _logDebug('Feature $featureName ${enabled ? 'enabled' : 'disabled'}');
  }

  // ========================================
  // 调试和工具方法
  // ========================================
  
  /// 获取配置摘要信息
  Map<String, dynamic> getConfigSummary() {
    return {
      'environment': environment.displayName,
      'apiBaseUrl': apiBaseUrl,
      'isDebugMode': isDebugMode,
      'logLevel': logLevel.name,
      'enabledFeatures': featureFlags.enabledFeatures,
      'appVersion': AppConstants.appVersion,
      'buildNumber': AppConstants.appBuildNumber,
    };
  }

  /// 输出配置信息到日志
  void logConfigInfo() {
    final summary = getConfigSummary();
    _logDebug('=== AppConfig Summary ===');
    summary.forEach((key, value) {
      _logDebug('$key: $value');
    });
    _logDebug('========================');
  }

  /// 验证配置完整性
  bool validateConfig() {
    try {
      // 检查必要的配置项
      if (environmentConfig.apiBaseUrl.isEmpty) {
        _logDebug('Validation failed: apiBaseUrl is empty');
        return false;
      }
      
      if (environmentConfig.wsBaseUrl.isEmpty) {
        _logDebug('Validation failed: wsBaseUrl is empty');
        return false;
      }
      
      if (environmentConfig.databaseName.isEmpty) {
        _logDebug('Validation failed: databaseName is empty');
        return false;
      }
      
      _logDebug('AppConfig validation passed');
      return true;
    } catch (e) {
      _logDebug('AppConfig validation error: $e');
      return false;
    }
  }

  /// 调试日志输出方法
  static void _logDebug(String message) {
    // ignore: avoid_print
    print('[AppConfig] $message');
  }
}

// ========================================
// 便捷全局访问函数
// ========================================

/// 获取当前应用配置
AppConfig get appConfig => AppConfig.instance;

/// 检查特性是否启用
bool isFeatureEnabled(String featureName) => AppConfig.instance.isFeatureEnabled(featureName);

/// 获取配置常量
AppConstants get appConstants => AppConfig.instance.constants;

/// 获取当前环境
AppEnvironment get currentEnvironment => AppConfig.instance.environment; 