/*
---------------------------------------------------------------
File name:          service_locator.dart
Author:             AI Assistant
Date created:       2025/06/25
Last modified:      2025/06/25
Dart Version:       3.32.4
Description:        企业级依赖注入服务定位器，为Phase 1提供统一的服务生命周期管理
---------------------------------------------------------------
Change History:
    2025/06/25: Initial creation - Step 19 DI configuration;
---------------------------------------------------------------
*/

import 'package:get_it/get_it.dart';

/// 服务注册优先级枚举
/// 定义服务注册的优先级顺序，确保依赖关系的正确初始化
enum ServicePriority {
  /// 优先级1: 核心基础设施服务 (EventBus, 配置等)
  core(1),
  
  /// 优先级2: 基础服务层 (Repository, Network, Security等)
  foundation(2),
  
  /// 优先级3: 应用服务层 (Navigation, ModuleManager等)
  application(3),
  
  /// 优先级4: 业务模块层 (各种业务模块)
  modules(4),
  
  /// 优先级5: UI和表现层服务
  presentation(5);

  const ServicePriority(this.level);
  final int level;
}

/// 服务生命周期枚举
/// 定义服务的生命周期管理策略
enum ServiceLifecycle {
  /// 单例模式 - 全局唯一实例
  singleton,
  
  /// 懒加载单例 - 首次使用时创建
  lazySingleton,
  
  /// 工厂模式 - 每次调用创建新实例
  factory,
  
  /// 作用域单例 - 在特定作用域内唯一
  scoped,
}

/// 服务状态枚举
/// 跟踪服务的当前状态
enum ServiceStatus {
  /// 未注册状态
  unregistered,
  
  /// 已注册但未初始化
  registered,
  
  /// 正在初始化
  initializing,
  
  /// 已初始化并可用
  ready,
  
  /// 已销毁
  disposed,
  
  /// 错误状态
  error,
}

/// 服务配置元数据
/// 包含服务注册的详细配置信息
class ServiceConfig<T extends Object> {
  /// 服务类型
  final Type serviceType;
  
  /// 服务实现类型
  final Type implementationType;
  
  /// 服务生命周期
  final ServiceLifecycle lifecycle;
  
  /// 注册优先级
  final ServicePriority priority;
  
  /// 服务工厂函数
  final T Function()? factoryFunc;
  
  /// 异步工厂函数
  final Future<T> Function()? asyncFactoryFunc;
  
  /// 服务依赖列表
  final List<Type> dependencies;
  
  /// 是否必需服务
  final bool isRequired;
  
  /// 服务描述
  final String description;
  
  /// 是否为接口注册
  final bool isInterface;

  const ServiceConfig({
    required this.serviceType,
    required this.implementationType,
    required this.lifecycle,
    required this.priority,
    this.factoryFunc,
    this.asyncFactoryFunc,
    this.dependencies = const [],
    this.isRequired = true,
    this.description = '',
    this.isInterface = false,
  });
}

/// 服务定位器异常类
/// 处理依赖注入过程中的各种异常情况
class ServiceLocatorException implements Exception {
  final String message;
  final Type? serviceType;
  final String? operation;
  final dynamic cause;

  const ServiceLocatorException({
    required this.message,
    this.serviceType,
    this.operation,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ServiceLocatorException: $message');
    if (serviceType != null) buffer.write(' (Service: $serviceType)');
    if (operation != null) buffer.write(' (Operation: $operation)');
    if (cause != null) buffer.write(' (Cause: $cause)');
    return buffer.toString();
  }
}

/// 服务状态信息
/// 包含服务的详细状态信息
class ServiceStatusInfo {
  final Type serviceType;
  final ServiceStatus status;
  final DateTime lastUpdated;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  ServiceStatusInfo({
    required this.serviceType,
    required this.status,
    required this.lastUpdated,
    this.errorMessage,
    this.metadata = const {},
  });

  ServiceStatusInfo copyWith({
    ServiceStatus? status,
    DateTime? lastUpdated,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return ServiceStatusInfo(
      serviceType: serviceType,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 企业级服务定位器
/// 提供完整的依赖注入和服务生命周期管理
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  /// GetIt 实例
  static final GetIt _getIt = GetIt.instance;
  
  /// 服务状态跟踪
  final Map<Type, ServiceStatusInfo> _serviceStatus = {};
  
  /// 服务配置注册表
  final Map<Type, ServiceConfig> _serviceConfigs = {};
  
  /// 初始化标志
  bool _isInitialized = false;
  
  /// 调试模式标志
  bool _debugMode = false;

  /// 获取GetIt实例
  static GetIt get instance => _getIt;

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取调试模式状态
  bool get debugMode => _debugMode;

  /// 设置调试模式
  void setDebugMode(bool enabled) {
    _debugMode = enabled;
    if (_debugMode) {
      _logDebug('Debug mode enabled for ServiceLocator');
    }
  }

  /// 调试日志方法
  void _logDebug(String message) {
    if (_debugMode) {
      // 在开发模式下输出调试信息，生产环境可通过日志服务替代
      // ignore: avoid_print
      print('[ServiceLocator] $message');
    }
  }

  /// 更新服务状态
  void _updateServiceStatus(Type serviceType, ServiceStatus status, {String? errorMessage}) {
    _serviceStatus[serviceType] = ServiceStatusInfo(
      serviceType: serviceType,
      status: status,
      lastUpdated: DateTime.now(),
      errorMessage: errorMessage,
      metadata: _serviceStatus[serviceType]?.metadata ?? {},
    );
    _logDebug('Service $serviceType status updated to $status');
  }

  /// 获取服务状态
  ServiceStatusInfo? getServiceStatus(Type serviceType) {
    return _serviceStatus[serviceType];
  }

  /// 获取所有服务状态
  Map<Type, ServiceStatusInfo> getAllServiceStatus() {
    return Map.unmodifiable(_serviceStatus);
  }

  /// 获取服务实例
  T get<T extends Object>({String? instanceName}) {
    try {
      final name = instanceName ?? T.toString();
      
      if (!_getIt.isRegistered<Object>(instanceName: name)) {
        throw ServiceLocatorException(
          message: 'Service not registered',
          serviceType: T,
          operation: 'get',
        );
      }

      final instance = _getIt.get<Object>(instanceName: name) as T;
      
      // 更新状态为ready（如果还不是）
      final currentStatus = _serviceStatus[T]?.status;
      if (currentStatus != ServiceStatus.ready && currentStatus != ServiceStatus.error) {
        _updateServiceStatus(T, ServiceStatus.ready);
      }
      
      return instance;
      
    } catch (e) {
      _updateServiceStatus(T, ServiceStatus.error, errorMessage: e.toString());
      throw ServiceLocatorException(
        message: 'Failed to get service instance',
        serviceType: T,
        operation: 'get',
        cause: e,
      );
    }
  }

  /// 检查服务是否已注册
  bool isRegistered<T extends Object>({String? instanceName}) {
    try {
      final name = instanceName ?? T.toString();
      return _getIt.isRegistered<T>(instanceName: name);
    } catch (e) {
      // 如果类型检查失败，返回false
      return false;
    }
  }

  /// 重置所有服务
  Future<void> reset() async {
    try {
      _logDebug('Resetting ServiceLocator...');
      
      await _getIt.reset();
      _serviceStatus.clear();
      _serviceConfigs.clear();
      _isInitialized = false;
      
      _logDebug('ServiceLocator reset completed');
      
    } catch (e) {
      throw ServiceLocatorException(
        message: 'Failed to reset ServiceLocator',
        operation: 'reset',
        cause: e,
      );
    }
  }
}

/// 全局服务定位器实例
final serviceLocator = ServiceLocator();

/// 便捷的全局getter方法
T getService<T extends Object>({String? instanceName}) {
  return serviceLocator.get<T>(instanceName: instanceName);
}

/// 检查服务是否可用
bool isServiceAvailable<T extends Object>({String? instanceName}) {
  return serviceLocator.isRegistered<T>(instanceName: instanceName);
}
