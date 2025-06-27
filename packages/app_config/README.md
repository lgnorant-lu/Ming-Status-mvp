# App Config Package

企业级应用配置管理包，提供环境配置、特性开关和常量管理。

## 概述

`app_config` 包提供完整的应用配置管理系统，包含环境检测、特性开关、配置验证等企业级功能。支持四种运行环境和15种特性开关。

## 安装

在你的`pubspec.yaml`中添加依赖：

```yaml
dependencies:
  app_config:
    path: ../app_config
```

## 核心组件

### AppEnvironment 枚举

支持四种运行环境：

```dart
enum AppEnvironment {
  development('dev', 'Development'),
  testing('test', 'Testing'), 
  staging('staging', 'Staging'),
  production('prod', 'Production');
}
```

**属性**：
- `code`: 环境代码
- `displayName`: 显示名称
- `isDevelopment/isTesting/isStaging/isProduction`: 环境判断
- `isDebugEnvironment/isReleaseEnvironment`: 环境分组判断
- `fromString(String value)`: 从字符串解析环境

### LogLevel 枚举

六级日志系统：

```dart
enum LogLevel {
  verbose(0, 'VERBOSE'),
  debug(1, 'DEBUG'), 
  info(2, 'INFO'),
  warning(3, 'WARNING'),
  error(4, 'ERROR'),
  wtf(5, 'WTF');
}
```

**方法**：
- `allows(LogLevel level)`: 检查是否允许输出指定级别的日志

### FeatureFlags 特性开关

管理15种应用特性的启用/禁用：

```dart
class FeatureFlags {
  // 模块特性开关
  final bool enableNotesHub;
  final bool enableWorkshop; 
  final bool enablePunchIn;
  
  // 系统特性开关
  final bool enableAdvancedLogging;
  final bool enableCrashReporting;
  final bool enableAnalytics;
  final bool enablePerformanceMonitoring;
  
  // 实验性特性
  final bool enableExperimentalFeatures;
  final bool enableBetaFeatures;
  
  // 业务特性
  final bool enableOfflineMode;
  final bool enableCloudSync;
  final bool enableNotifications;
  
  // UI特性
  final bool enableAnimations;
  final bool enableDarkMode;
  final bool enableAccessibility;
}
```

**方法**：
- `enabledFeatures`: 获取所有启用特性列表
- `copyWith({...})`: 复制并修改特性开关

### AppConstants 应用常量

```dart
class AppConstants {
  // 应用信息
  static const String appName = '桌宠助手';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // 网络配置
  static const String baseApiUrl = 'https://api.pet-app.com';
  static const String wsBaseUrl = 'wss://ws.pet-app.com';
  static const int connectTimeout = 30000;
  
  // 存储配置
  static const String databaseName = 'pet_app.db';
  static const int databaseVersion = 1;
  
  // UI配置
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  
  // 性能配置
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxRetryAttempts = 3;
  
  // 日志配置
  static const int maxLogFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxLogFiles = 5;
  
  // 安全配置
  static const String encryptionKeyAlias = 'pet_app_encryption_key';
  static const int sessionTimeout = 24 * 60 * 60 * 1000; // 24小时
  static const int maxLoginAttempts = 5;
}
```

### EnvironmentConfig 环境配置

每个环境的特定配置：

```dart
class EnvironmentConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final LogLevel logLevel;
  final bool enableDebugMode;
  final bool enablePerformanceOverlay;
  final bool enableInspector;
  final String databaseName;
  final FeatureFlags? customFeatureFlags;
}
```

**方法**：
- `effectiveFeatureFlags`: 获取有效的特性开关配置

### AppConfig 主配置类

单例模式的配置管理中心：

```dart
class AppConfig {
  static AppConfig get instance; // 单例访问
  static bool get isInitialized; // 检查初始化状态
  
  // 配置属性
  final AppEnvironment environment;
  final EnvironmentConfig environmentConfig;
  final FeatureFlags featureFlags;
  final AppConstants constants;
}
```

**静态方法**：
- `initialize({AppEnvironment? environment, ...})`: 初始化配置
- `reset()`: 重置配置（主要用于测试）

**实例方法**：
- `isFeatureEnabled(String featureName)`: 检查特性是否启用
- `updateFeatureFlags(FeatureFlags)`: 运行时更新特性开关
- `toggleFeature(String, bool)`: 切换单个特性
- `getConfigSummary()`: 获取配置摘要
- `logConfigInfo()`: 输出配置信息到日志
- `validateConfig()`: 验证配置完整性

**便捷属性**：
- `apiBaseUrl`: API基础URL
- `wsBaseUrl`: WebSocket基础URL
- `isDebugMode`: 是否调试模式
- `isProduction/isDevelopment`: 环境判断
- `logLevel`: 当前日志级别

## 使用示例

### 基础使用

```dart
import 'package:app_config/app_config.dart';

// 初始化配置
await AppConfig.initialize();

// 获取配置实例
final config = AppConfig.instance;

// 访问环境信息
print('当前环境: ${config.environment.displayName}');
print('API地址: ${config.apiBaseUrl}');
print('调试模式: ${config.isDebugMode}');
```

### 特性开关检查

```dart
// 检查特性是否启用
if (AppConfig.instance.isFeatureEnabled('noteshub')) {
  // 启用笔记中心功能
}

// 或使用全局函数
if (isFeatureEnabled('darkmode')) {
  // 启用深色模式
}
```

### 自定义配置

```dart
// 自定义环境配置
await AppConfig.initialize(
  environment: AppEnvironment.development,
  customFeatureFlags: FeatureFlags(
    enableExperimentalFeatures: true,
    enableBetaFeatures: true,
  ),
);
```

### 运行时配置更新

```dart
// 切换单个特性
AppConfig.instance.toggleFeature('darkmode', true);

// 批量更新特性
final newFlags = AppConfig.instance.featureFlags.copyWith(
  enableNotifications: false,
  enableAnimations: true,
);
AppConfig.instance.updateFeatureFlags(newFlags);
```

### 配置验证

```dart
// 验证配置
if (AppConfig.instance.validateConfig()) {
  print('配置验证通过');
} else {
  print('配置验证失败');
}

// 输出配置摘要
AppConfig.instance.logConfigInfo();
```

## 环境特定配置

系统会根据环境自动选择配置：

- **Development**: 启用调试、性能监控、实验特性
- **Testing**: 启用高级日志、崩溃报告
- **Staging**: 启用分析、Beta特性、崩溃报告  
- **Production**: 启用分析、崩溃报告、云同步

## 全局访问函数

```dart
// 便捷全局函数
AppConfig get appConfig;
bool isFeatureEnabled(String featureName);
AppConstants get appConstants;
AppEnvironment get currentEnvironment;
```

## 技术特性

- **单例模式**: 全局唯一配置实例
- **环境检测**: 自动检测运行环境
- **特性开关**: 15种可配置特性
- **类型安全**: 强类型配置访问
- **运行时更新**: 支持配置热更新
- **配置验证**: 内置完整性检查

## 依赖关系

`app_config` 是架构底层包，无其他包依赖。

## 注意事项

- 必须在使用前调用 `AppConfig.initialize()`
- 配置实例为单例，全局唯一
- 环境检测基于环境变量和编译时常量
- 特性开关支持运行时动态修改

## 变更历史

### v1.0.0 (2025-06-26)
- ✅ 初始版本发布
- ✅ 基础配置管理功能
- ✅ 多环境支持
- ✅ 常量定义和访问
- ✅ 配置验证机制

## 许可证

本包遵循PetApp项目的许可证协议。

## 贡献

欢迎提交Issue和Pull Request来改进这个包。

## 支持

如有问题，请在项目仓库中提交Issue。 