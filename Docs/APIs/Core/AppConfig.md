# AppConfig API 文档

## 概述

AppConfig是整个应用的配置管理系统，负责环境配置、特性开关、常量管理等功能。它提供统一的配置访问接口，支持多环境配置和运行时特性开关管理。

- **主要功能**: 环境配置管理、特性开关系统、配置常量管理、运行时配置更新
- **设计模式**: 单例模式 + 工厂模式 + 策略模式
- **依赖关系**: 独立配置系统，无内部依赖
- **位置**: `packages/app_config/lib/app_config.dart`

## 核心类型定义

### AppEnvironment 枚举
```dart
enum AppEnvironment {
  development('dev', 'Development'),
  testing('test', 'Testing'),
  staging('staging', 'Staging'),
  production('prod', 'Production');
}
```

### LogLevel 枚举
```dart
enum LogLevel {
  verbose(0, 'VERBOSE'),
  debug(1, 'DEBUG'),
  info(2, 'INFO'),
  warning(3, 'WARNING'),
  error(4, 'ERROR'),
  wtf(5, 'WTF'); // What a Terrible Failure
}
```

### FeatureFlags 类
```dart
class FeatureFlags {
  const FeatureFlags({
    // 模块特性开关
    this.enableNotesHub = true,
    this.enableWorkshop = true,
    this.enablePunchIn = true,
    
    // 系统特性开关
    this.enableAdvancedLogging = false,
    this.enableCrashReporting = false,
    this.enableAnalytics = false,
    this.enablePerformanceMonitoring = false,
    
    // 实验性特性开关
    this.enableExperimentalFeatures = false,
    this.enableBetaFeatures = false,
    
    // 业务特性开关
    this.enableOfflineMode = false,
    this.enableCloudSync = false,
    this.enableNotifications = true,
    
    // UI特性开关
    this.enableAnimations = true,
    this.enableDarkMode = true,
    this.enableAccessibility = true,
  });
}
```

### AppConstants 类
```dart
class AppConstants {
  const AppConstants._();
  
  // 应用基本信息
  static const String appName = '桌宠助手';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // 网络配置
  static const String baseApiUrl = 'https://api.pet-app.com';
  static const int connectTimeout = 30000; // 30秒
  
  // 存储配置
  static const String databaseName = 'pet_app.db';
  static const int databaseVersion = 1;
  
  // UI配置
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // 性能配置
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxRetryAttempts = 3;
  
  // 安全配置
  static const String encryptionKeyAlias = 'pet_app_encryption_key';
  static const int sessionTimeout = 24 * 60 * 60 * 1000; // 24小时
}
```

### EnvironmentConfig 类
```dart
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
}
```

### AppConfig 类
```dart
class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.environmentConfig,
    required this.featureFlags,
    required this.constants,
  });
}
```

## 主要接口

### 配置系统管理

#### `AppConfig.initialize`
- **描述**: 初始化应用配置系统，检测环境并创建配置实例
- **签名**: `static Future<void> initialize({AppEnvironment? environment, EnvironmentConfig? customEnvironmentConfig, FeatureFlags? customFeatureFlags})`
- **参数**:
  - `environment`: 指定环境(可选，默认自动检测)
  - `customEnvironmentConfig`: 自定义环境配置(可选)
  - `customFeatureFlags`: 自定义特性开关(可选)
- **示例**:
```dart
await AppConfig.initialize(
  environment: AppEnvironment.staging,
  customFeatureFlags: const FeatureFlags(
    enableExperimentalFeatures: true,
    enableBetaFeatures: true,
  ),
);
```

#### `AppConfig.instance`
- **描述**: 获取应用配置单例实例
- **签名**: `static AppConfig get instance`
- **返回值**: 配置实例
- **异常**: `StateError` - 配置未初始化

### 特性开关管理

#### `isFeatureEnabled`
- **描述**: 检查指定特性是否启用
- **签名**: `bool isFeatureEnabled(String featureName)`
- **参数**: `featureName` - 特性名称
- **返回值**: 特性启用状态

#### `updateFeatureFlags`
- **描述**: 运行时更新特性开关配置
- **签名**: `void updateFeatureFlags(FeatureFlags newFeatureFlags)`
- **参数**: `newFeatureFlags` - 新的特性开关配置

#### `toggleFeature`
- **描述**: 切换单个特性开关状态
- **签名**: `void toggleFeature(String featureName, bool enabled)`
- **参数**: 
  - `featureName` - 特性名称
  - `enabled` - 启用状态

### 配置访问接口

#### `currentEnvironment`
- **描述**: 获取当前环境
- **签名**: `AppEnvironment get currentEnvironment`

#### `isDebugMode`
- **描述**: 检查是否为调试模式
- **签名**: `bool get isDebugMode`

#### `apiBaseUrl`
- **描述**: 获取API基础地址
- **签名**: `String get apiBaseUrl`

#### `logLevel`
- **描述**: 获取当前日志级别
- **签名**: `LogLevel get logLevel`

## 异常处理

### 配置异常
- **StateError**: 配置未初始化时访问配置实例
- **ArgumentError**: 无效的环境类型或特性名称
- **FormatException**: 环境变量格式错误

## 配置与性能

### 内部机制
- **环境检测**: 多级检测策略(环境变量 > 编译常量 > 调试模式)
- **单例模式**: 全局唯一配置实例，线程安全访问
- **缓存机制**: 配置值缓存，避免重复计算
- **特性开关**: 运行时动态切换支持

### 性能特性
- **懒加载**: 配置系统采用懒加载初始化
- **O(1)访问**: 提供快速的配置访问接口
- **内存优化**: 使用final和const减少GC压力
- **异步初始化**: 避免阻塞主线程

## 使用最佳实践

1. **早期初始化**: 在应用启动最早阶段初始化配置系统
2. **环境隔离**: 不同环境使用不同配置，避免混淆
3. **特性管理**: 通过特性开关控制功能启用，支持灰度发布
4. **敏感信息**: 通过环境变量传递，不硬编码
5. **配置验证**: 启动时验证关键配置的有效性

## 版本历史

### v1.0.0 (2025/06/25) - Step 21初始版本
- **环境管理**: 4种环境(Development/Testing/Staging/Production)配置管理
- **特性开关**: 15种特性开关，覆盖模块/系统/实验性/业务/UI特性
- **配置常量**: 统一管理应用信息/网络/存储/UI/性能/日志/安全配置
- **单例设计**: 全局唯一配置实例，线程安全访问
- **运行时更新**: 特性开关动态切换支持
- **环境检测**: 多级环境检测机制
- **全局访问**: 便捷的全局访问函数 