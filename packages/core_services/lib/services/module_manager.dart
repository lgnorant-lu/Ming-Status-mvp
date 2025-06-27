/*
---------------------------------------------------------------
File name:          module_manager.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/25
Description:        模块管理服务 - 负责模块注册、生命周期管理和向UI提供模块清单
---------------------------------------------------------------
Change History:
    2025/06/25: Initial creation - 建立混合架构的模块管理核心;
---------------------------------------------------------------
*/

import 'dart:async';
import 'dart:developer' as developer;

import '../event_bus.dart';
import '../module_interface.dart';
import '../di/service_locator.dart';

/// 模块生命周期状态枚举
enum ModuleLifecycleState {
  /// 已注册但未初始化
  registered,
  /// 正在初始化
  initializing,
  /// 已初始化并可用
  active,
  /// 正在销毁
  disposing,
  /// 已销毁或出错
  disposed,
  /// 初始化失败
  error,
}

/// 模块元数据 - 扩展模块接口信息
class ModuleMetadata {
  final String id;
  final String name;
  final String description;
  final String version;
  final String author;
  final List<String> dependencies;
  final Map<String, dynamic> configuration;
  final ModuleLifecycleState state;
  final DateTime registeredAt;
  final DateTime? initializedAt;
  final String? errorMessage;

  const ModuleMetadata({
    required this.id,
    required this.name,
    required this.description,
    this.version = '1.0.0',
    this.author = 'Unknown',
    this.dependencies = const [],
    this.configuration = const {},
    required this.state,
    required this.registeredAt,
    this.initializedAt,
    this.errorMessage,
  });

  /// 创建状态更新的副本
  ModuleMetadata copyWith({
    ModuleLifecycleState? state,
    DateTime? initializedAt,
    String? errorMessage,
    Map<String, dynamic>? configuration,
  }) {
    return ModuleMetadata(
      id: id,
      name: name,
      description: description,
      version: version,
      author: author,
      dependencies: dependencies,
      configuration: configuration ?? this.configuration,
      state: state ?? this.state,
      registeredAt: registeredAt,
      initializedAt: initializedAt ?? this.initializedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 序列化为Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'author': author,
      'dependencies': dependencies,
      'configuration': configuration,
      'state': state.toString(),
      'registeredAt': registeredAt.toIso8601String(),
      'initializedAt': initializedAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  /// 从Map反序列化
  static ModuleMetadata fromJson(Map<String, dynamic> json) {
    return ModuleMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String? ?? '1.0.0',
      author: json['author'] as String? ?? 'Unknown',
      dependencies: List<String>.from(json['dependencies'] as List? ?? []),
      configuration: Map<String, dynamic>.from(json['configuration'] as Map? ?? {}),
      state: ModuleLifecycleState.values.firstWhere(
        (e) => e.toString() == json['state'],
        orElse: () => ModuleLifecycleState.registered,
      ),
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      initializedAt: json['initializedAt'] != null
          ? DateTime.parse(json['initializedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

/// 模块注册包装器
class ModuleRegistration {
  final ModuleMetadata metadata;
  final PetModuleInterface moduleInstance;
  final StreamSubscription<dynamic>? eventSubscription;

  const ModuleRegistration({
    required this.metadata,
    required this.moduleInstance,
    this.eventSubscription,
  });

  /// 创建状态更新的副本
  ModuleRegistration copyWith({
    ModuleMetadata? metadata,
    StreamSubscription<dynamic>? eventSubscription,
  }) {
    return ModuleRegistration(
      metadata: metadata ?? this.metadata,
      moduleInstance: moduleInstance,
      eventSubscription: eventSubscription ?? this.eventSubscription,
    );
  }
}

/// 模块管理异常
class ModuleManagerException implements Exception {
  final String message;
  final String? moduleId;
  final dynamic originalError;

  const ModuleManagerException(
    this.message, {
    this.moduleId,
    this.originalError,
  });

  @override
  String toString() {
    return 'ModuleManagerException: $message'
        '${moduleId != null ? ' (Module: $moduleId)' : ''}'
        '${originalError != null ? ' - Original: $originalError' : ''}';
  }
}

/// 模块生命周期事件
abstract class ModuleLifecycleEvent {
  final String moduleId;
  final DateTime timestamp;

  const ModuleLifecycleEvent({
    required this.moduleId,
    required this.timestamp,
  });
}

class ModuleRegisteredEvent extends ModuleLifecycleEvent {
  final ModuleMetadata metadata;

  const ModuleRegisteredEvent({
    required super.moduleId,
    required super.timestamp,
    required this.metadata,
  });
}

class ModuleInitializedEvent extends ModuleLifecycleEvent {
  const ModuleInitializedEvent({
    required super.moduleId,
    required super.timestamp,
  });
}

class ModuleDisposedEvent extends ModuleLifecycleEvent {
  const ModuleDisposedEvent({
    required super.moduleId,
    required super.timestamp,
  });
}

class ModuleErrorEvent extends ModuleLifecycleEvent {
  final String errorMessage;
  final dynamic error;

  const ModuleErrorEvent({
    required super.moduleId,
    required super.timestamp,
    required this.errorMessage,
    this.error,
  });
}

/// 模块管理器核心类
/// 
/// 负责模块的注册、初始化、生命周期管理和与EventBus的集成
/// 提供统一的模块清单给UI层，支持动态模块加载和热重载
class ModuleManager {
  static ModuleManager? _instance;
  
  /// 单例实例获取
  static ModuleManager get instance {
    _instance ??= ModuleManager._internal();
    return _instance!;
  }

  /// 私有构造函数
  ModuleManager._internal() {
    _setupEventListeners();
  }

  /// 模块注册表 - 存储所有已注册的模块
  final Map<String, ModuleRegistration> _modules = {};

  /// 模块依赖图 - 用于依赖解析和初始化顺序
  final Map<String, Set<String>> _dependencyGraph = {};

  /// 生命周期事件流控制器
  final StreamController<ModuleLifecycleEvent> _lifecycleController =
      StreamController<ModuleLifecycleEvent>.broadcast();

  /// 是否已初始化管理器
  bool _isInitialized = false;

  /// 是否正在销毁
  bool _isDisposing = false;

  // ========== 生命周期事件流 ==========

  /// 获取模块生命周期事件流
  Stream<ModuleLifecycleEvent> get lifecycleEvents =>
      _lifecycleController.stream;

  /// 获取特定模块的生命周期事件流
  Stream<ModuleLifecycleEvent> getModuleLifecycleEvents(String moduleId) {
    return lifecycleEvents.where((event) => event.moduleId == moduleId);
  }

  // ========== 模块注册与管理 ==========

  /// 注册模块
  /// 
  /// [moduleInstance] - 模块实例，必须实现PetModuleInterface
  /// [metadata] - 可选的模块元数据，如果不提供则从模块实例中提取
  /// 
  /// 返回注册成功的模块ID
  Future<String> registerModule(
    PetModuleInterface moduleInstance, {
    ModuleMetadata? metadata,
  }) async {
    if (_isDisposing) {
      throw const ModuleManagerException('Cannot register modules during disposal');
    }

         final String moduleId = moduleInstance.name;

     // 检查模块是否已注册
     if (_modules.containsKey(moduleId)) {
       throw ModuleManagerException(
         'Module already registered',
         moduleId: moduleId,
       );
     }

     // 创建或使用提供的元数据
     final ModuleMetadata moduleMetadata = metadata ??
         ModuleMetadata(
           id: moduleId,
           name: moduleInstance.name,
           description: 'Module: ${moduleInstance.name}',
           state: ModuleLifecycleState.registered,
           registeredAt: DateTime.now(),
         );

    // 验证依赖项
    await _validateDependencies(moduleMetadata.dependencies);

    // 创建模块注册项
    final registration = ModuleRegistration(
      metadata: moduleMetadata,
      moduleInstance: moduleInstance,
    );

    // 注册模块
    _modules[moduleId] = registration;
    _dependencyGraph[moduleId] = Set.from(moduleMetadata.dependencies);

    // 发布注册事件
    _publishLifecycleEvent(ModuleRegisteredEvent(
      moduleId: moduleId,
      timestamp: DateTime.now(),
      metadata: moduleMetadata,
    ));

    developer.log(
      'Module registered: $moduleId (${moduleMetadata.name})',
      name: 'ModuleManager',
    );

    return moduleId;
  }

  /// 注销模块
  /// 
  /// [moduleId] - 要注销的模块ID
  /// [force] - 是否强制注销（忽略依赖检查）
  Future<void> unregisterModule(String moduleId, {bool force = false}) async {
    final registration = _modules[moduleId];
    if (registration == null) {
      throw ModuleManagerException(
        'Module not found',
        moduleId: moduleId,
      );
    }

    // 检查是否有其他模块依赖此模块
    if (!force) {
      final dependents = _getDependentModules(moduleId);
      if (dependents.isNotEmpty) {
        throw ModuleManagerException(
          'Module has active dependents: ${dependents.join(', ')}',
          moduleId: moduleId,
        );
      }
    }

    // 如果模块处于活跃状态，先销毁它
    if (registration.metadata.state == ModuleLifecycleState.active) {
      await disposeModule(moduleId);
    }

    // 清理事件订阅
    await registration.eventSubscription?.cancel();

    // 从注册表中移除
    _modules.remove(moduleId);
    _dependencyGraph.remove(moduleId);

    developer.log(
      'Module unregistered: $moduleId',
      name: 'ModuleManager',
    );
  }

  // ========== 模块生命周期管理 ==========

  /// 初始化模块
  /// 
  /// [moduleId] - 要初始化的模块ID
  /// 
  /// 自动处理依赖项的初始化顺序
  Future<void> initializeModule(String moduleId) async {
    final registration = _modules[moduleId];
    if (registration == null) {
      throw ModuleManagerException(
        'Module not found',
        moduleId: moduleId,
      );
    }

    if (registration.metadata.state == ModuleLifecycleState.active) {
      developer.log(
        'Module already initialized: $moduleId',
        name: 'ModuleManager',
      );
      return;
    }

    if (registration.metadata.state == ModuleLifecycleState.initializing) {
      throw ModuleManagerException(
        'Module is already being initialized',
        moduleId: moduleId,
      );
    }

    try {
      // 更新状态为初始化中
      _updateModuleState(moduleId, ModuleLifecycleState.initializing);

      // 首先初始化所有依赖项
      for (final dependency in registration.metadata.dependencies) {
        final depRegistration = _modules[dependency];
        if (depRegistration == null) {
          throw ModuleManagerException(
            'Dependency not found: $dependency',
            moduleId: moduleId,
          );
        }

        if (depRegistration.metadata.state != ModuleLifecycleState.active) {
          await initializeModule(dependency);
        }
      }

      // 执行模块的初始化方法
      try {
        // 尝试从ServiceLocator获取EventBus实例
        final eventBus = ServiceLocator.instance.get<EventBus>();
        await registration.moduleInstance.initialize(eventBus);
      } catch (e) {
        // 如果EventBus不可用，创建一个临时的EventBus实例给模块使用
        final tempEventBus = EventBus();
        await registration.moduleInstance.initialize(tempEventBus);
        developer.log(
          'Module initialized with temporary EventBus: $moduleId',
          name: 'ModuleManager',
        );
      }

      // 设置事件监听 - 现在通过模块自己的初始化过程处理
      // 模块在initialize方法中会自行设置事件监听
      StreamSubscription<dynamic>? eventSubscription;

      // 更新注册信息
      _modules[moduleId] = registration.copyWith(
        metadata: registration.metadata.copyWith(
          state: ModuleLifecycleState.active,
          initializedAt: DateTime.now(),
        ),
        eventSubscription: eventSubscription,
      );

      // 发布初始化事件
      _publishLifecycleEvent(ModuleInitializedEvent(
        moduleId: moduleId,
        timestamp: DateTime.now(),
      ));

      developer.log(
        'Module initialized: $moduleId',
        name: 'ModuleManager',
      );
    } catch (error) {
      // 初始化失败，更新状态并记录错误
      _updateModuleState(
        moduleId,
        ModuleLifecycleState.error,
        errorMessage: error.toString(),
      );

      _publishLifecycleEvent(ModuleErrorEvent(
        moduleId: moduleId,
        timestamp: DateTime.now(),
        errorMessage: error.toString(),
        error: error,
      ));

      developer.log(
        'Module initialization failed: $moduleId - $error',
        name: 'ModuleManager',
        error: error,
      );

      rethrow;
    }
  }

  /// 销毁模块
  /// 
  /// [moduleId] - 要销毁的模块ID
  Future<void> disposeModule(String moduleId) async {
    final registration = _modules[moduleId];
    if (registration == null) {
      throw ModuleManagerException(
        'Module not found',
        moduleId: moduleId,
      );
    }

    if (registration.metadata.state != ModuleLifecycleState.active) {
      developer.log(
        'Module not active, skipping disposal: $moduleId',
        name: 'ModuleManager',
      );
      return;
    }

    try {
      // 更新状态为销毁中
      _updateModuleState(moduleId, ModuleLifecycleState.disposing);

      // 检查是否有依赖此模块的其他模块，如果有则先销毁它们
      final dependents = _getDependentModules(moduleId);
      for (final dependent in dependents) {
        final depRegistration = _modules[dependent];
        if (depRegistration?.metadata.state == ModuleLifecycleState.active) {
          await disposeModule(dependent);
        }
      }

      // 取消事件订阅
      await registration.eventSubscription?.cancel();

             // 执行模块的销毁方法
       registration.moduleInstance.dispose();

      // 更新状态为已销毁
      _modules[moduleId] = registration.copyWith(
        metadata: registration.metadata.copyWith(
          state: ModuleLifecycleState.disposed,
        ),
        eventSubscription: null,
      );

      // 发布销毁事件
      _publishLifecycleEvent(ModuleDisposedEvent(
        moduleId: moduleId,
        timestamp: DateTime.now(),
      ));

      developer.log(
        'Module disposed: $moduleId',
        name: 'ModuleManager',
      );
    } catch (error) {
      // 销毁失败，记录错误
      _updateModuleState(
        moduleId,
        ModuleLifecycleState.error,
        errorMessage: error.toString(),
      );

      developer.log(
        'Module disposal failed: $moduleId - $error',
        name: 'ModuleManager',
        error: error,
      );

      rethrow;
    }
  }

  /// 初始化所有已注册的模块
  /// 
  /// 按照依赖顺序自动初始化所有模块
  Future<void> initializeAllModules() async {
    if (_isInitialized) {
      developer.log(
        'ModuleManager already initialized',
        name: 'ModuleManager',
      );
      return;
    }

    final initOrder = _calculateInitializationOrder();
    final List<String> failedModules = [];

    for (final moduleId in initOrder) {
      try {
        await initializeModule(moduleId);
      } catch (error) {
        failedModules.add(moduleId);
        developer.log(
          'Failed to initialize module during batch initialization: $moduleId - $error',
          name: 'ModuleManager',
          error: error,
        );
      }
    }

    _isInitialized = true;

    if (failedModules.isNotEmpty) {
      developer.log(
        'ModuleManager initialization completed with ${failedModules.length} failures: ${failedModules.join(', ')}',
        name: 'ModuleManager',
      );
    } else {
      developer.log(
        'ModuleManager initialization completed successfully',
        name: 'ModuleManager',
      );
    }
  }

  /// 销毁所有模块
  Future<void> disposeAllModules() async {
    _isDisposing = true;

    // 按照反向依赖顺序销毁模块
    final disposeOrder = _calculateInitializationOrder().reversed.toList();

    for (final moduleId in disposeOrder) {
      final registration = _modules[moduleId];
      if (registration?.metadata.state == ModuleLifecycleState.active) {
        try {
          await disposeModule(moduleId);
        } catch (error) {
          developer.log(
            'Failed to dispose module: $moduleId - $error',
            name: 'ModuleManager',
            error: error,
          );
        }
      }
    }

    _isInitialized = false;
    _isDisposing = false;

    developer.log(
      'All modules disposed',
      name: 'ModuleManager',
    );
  }

  // ========== 查询与信息接口 ==========

  /// 获取所有已注册模块的元数据
  List<ModuleMetadata> getAllModules() {
    return _modules.values.map((reg) => reg.metadata).toList();
  }

  /// 获取活跃状态的模块列表
  List<ModuleMetadata> getActiveModules() {
    return _modules.values
        .where((reg) => reg.metadata.state == ModuleLifecycleState.active)
        .map((reg) => reg.metadata)
        .toList();
  }

  /// 获取特定模块的元数据
  ModuleMetadata? getModuleMetadata(String moduleId) {
    return _modules[moduleId]?.metadata;
  }

  /// 获取特定模块的实例
  PetModuleInterface? getModuleInstance(String moduleId) {
    return _modules[moduleId]?.moduleInstance;
  }

  /// 检查模块是否已注册
  bool isModuleRegistered(String moduleId) {
    return _modules.containsKey(moduleId);
  }

  /// 检查模块是否处于活跃状态
  bool isModuleActive(String moduleId) {
    return _modules[moduleId]?.metadata.state == ModuleLifecycleState.active;
  }

  /// 获取模块统计信息
  Map<String, dynamic> getStatistics() {
    final states = <ModuleLifecycleState, int>{};
    for (final state in ModuleLifecycleState.values) {
      states[state] = 0;
    }

    for (final registration in _modules.values) {
      states[registration.metadata.state] = states[registration.metadata.state]! + 1;
    }

    return {
      'totalModules': _modules.length,
      'activeModules': states[ModuleLifecycleState.active] ?? 0,
      'errorModules': states[ModuleLifecycleState.error] ?? 0,
      'stateDistribution': states.map((key, value) => MapEntry(key.toString(), value)),
      'isInitialized': _isInitialized,
      'isDisposing': _isDisposing,
    };
  }

  // ========== 内部辅助方法 ==========

     /// 设置EventBus事件监听
   void _setupEventListeners() {
     try {
       // 监听模块相关的系统事件
       EventBus.instance.on<dynamic>().listen((event) {
         // 这里可以根据需要处理系统级别的模块管理事件
         // 例如：模块热重载、配置更新等
       });
     } catch (e) {
       // EventBus可能还未注册，在测试环境中这是正常的
       // 在实际运行时EventBus会在应用启动时注册
       developer.log(
         'EventBus not available during ModuleManager initialization: $e',
         name: 'ModuleManager',
       );
     }
   }

  /// 验证模块依赖项
  Future<void> _validateDependencies(List<String> dependencies) async {
    for (final dependency in dependencies) {
      if (!_modules.containsKey(dependency)) {
        throw ModuleManagerException(
          'Dependency not found: $dependency',
        );
      }
    }

    // 检查是否会产生循环依赖
    final visited = <String>{};
    final recursionStack = <String>{};

    bool hasCycle(String moduleId) {
      if (recursionStack.contains(moduleId)) {
        return true;
      }
      if (visited.contains(moduleId)) {
        return false;
      }

      visited.add(moduleId);
      recursionStack.add(moduleId);

      final deps = _dependencyGraph[moduleId] ?? <String>{};
      for (final dep in deps) {
        if (hasCycle(dep)) {
          return true;
        }
      }

      recursionStack.remove(moduleId);
      return false;
    }

    for (final moduleId in _dependencyGraph.keys) {
      if (hasCycle(moduleId)) {
        throw const ModuleManagerException(
          'Circular dependency detected in module graph',
        );
      }
    }
  }

  /// 计算模块初始化顺序（拓扑排序）
  List<String> _calculateInitializationOrder() {
    final result = <String>[];
    final visited = <String>{};
    final visiting = <String>{};

    void visit(String moduleId) {
      if (visiting.contains(moduleId)) {
        throw ModuleManagerException(
          'Circular dependency detected',
          moduleId: moduleId,
        );
      }
      if (visited.contains(moduleId)) {
        return;
      }

      visiting.add(moduleId);

      final dependencies = _dependencyGraph[moduleId] ?? <String>{};
      for (final dependency in dependencies) {
        visit(dependency);
      }

      visiting.remove(moduleId);
      visited.add(moduleId);
      result.add(moduleId);
    }

    for (final moduleId in _modules.keys) {
      if (!visited.contains(moduleId)) {
        visit(moduleId);
      }
    }

    return result;
  }

  /// 获取依赖某个模块的其他模块列表
  List<String> _getDependentModules(String moduleId) {
    final dependents = <String>[];
    for (final entry in _dependencyGraph.entries) {
      if (entry.value.contains(moduleId)) {
        dependents.add(entry.key);
      }
    }
    return dependents;
  }

  /// 更新模块状态
  void _updateModuleState(
    String moduleId,
    ModuleLifecycleState state, {
    String? errorMessage,
  }) {
    final registration = _modules[moduleId];
    if (registration != null) {
      _modules[moduleId] = registration.copyWith(
        metadata: registration.metadata.copyWith(
          state: state,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  /// 发布生命周期事件
  void _publishLifecycleEvent(ModuleLifecycleEvent event) {
    if (!_lifecycleController.isClosed) {
      _lifecycleController.add(event);
    }

    try {
      // 同时发布到EventBus以便其他组件监听
      EventBus.instance.fire(event);
    } catch (e) {
      // EventBus可能还未注册，在测试环境中这是正常的
      developer.log(
        'EventBus not available during event publishing: $e',
        name: 'ModuleManager',
      );
    }
  }

  // ========== 前瞻性接口 (Phase 2.2+扩展预留) ==========

  /// 模块热插拔接口 (Hot-swap Interface) - Phase 2.2目标
  /// 
  /// 为未来实现运行时模块热加载/热卸载功能预留接口
  /// 支持动态模块更新、配置热重载和零停机时间的模块升级
  ///
  /// 预期功能:
  /// - 运行时动态加载新模块代码
  /// - 保持模块状态的热重载
  /// - 模块版本升级和降级
  /// - 依赖关系的动态重建
  // DEBT-HOTSWAP-001: 热插拔接口预留 - Phase 2.2实现
  
  /// 检查模块是否支持热插拔
  /// [moduleId] - 模块标识符
  /// 返回模块是否支持热替换功能
  bool isModuleHotSwappable(String moduleId) {
    // TODO: Phase 2.2 - 检查模块元数据中的热插拔支持标志
    return false;
  }

  /// 热加载模块新版本
  /// [moduleId] - 要升级的模块ID
  /// [newModuleInstance] - 新版本的模块实例
  /// [preserveState] - 是否保持模块的现有状态
  /// 
  /// 返回热加载是否成功
  Future<bool> hotSwapModule(
    String moduleId, 
    PetModuleInterface newModuleInstance, {
    bool preserveState = true,
  }) async {
    // TODO: Phase 2.2 - 实现热插拔逻辑
    // 1. 检查模块是否支持热插拔
    // 2. 备份当前模块状态
    // 3. 卸载旧模块但保持依赖关系
    // 4. 安装新模块实例
    // 5. 恢复状态数据
    // 6. 重建依赖关系
    // 7. 通知依赖模块更新
    
    developer.log(
      'Hot-swap interface not yet implemented - Phase 2.2 planned feature',
      name: 'ModuleManager',
    );
    return false;
  }

  /// 模块配置热重载
  /// [moduleId] - 要重载配置的模块ID
  /// [newConfiguration] - 新的配置参数
  /// 
  /// 返回配置重载是否成功
  Future<bool> hotReloadModuleConfig(
    String moduleId, 
    Map<String, dynamic> newConfiguration,
  ) async {
    // TODO: Phase 2.2 - 实现配置热重载
    // 1. 验证新配置的有效性
    // 2. 备份当前配置
    // 3. 应用新配置到模块实例
    // 4. 触发模块配置更新事件
    // 5. 如果失败则回滚到备份配置
    
    developer.log(
      'Config hot-reload interface not yet implemented - Phase 2.2 planned feature',
      name: 'ModuleManager',
    );
    return false;
  }

  /// 获取模块热插拔历史记录
  /// [moduleId] - 模块标识符
  /// 
  /// 返回该模块的热插拔操作历史
  List<Map<String, dynamic>> getModuleHotSwapHistory(String moduleId) {
    // TODO: Phase 2.2 - 返回热插拔操作的历史记录
    // 包括：时间戳、版本信息、操作类型、成功状态等
    return [];
  }

  /// 模块性能热调优接口预留
  /// 
  /// 为与WindowManager的性能调度器协作预留接口
  /// 支持基于性能数据的模块资源动态调整
  // DEBT-PERF-003: 模块性能调优接口预留 - Phase 2.3实现
  
  /// 获取模块性能指标
  /// [moduleId] - 模块标识符
  /// 
  /// 返回模块的实时性能数据
  Map<String, dynamic> getModulePerformanceMetrics(String moduleId) {
    // TODO: Phase 2.3 - 返回模块性能指标
    // 包括：CPU使用率、内存占用、事件处理延迟、错误率等
    return {
      'cpuUsage': 0.0,
      'memoryUsage': 0,
      'eventLatency': 0.0,
      'errorRate': 0.0,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// 应用性能调优建议
  /// [moduleId] - 模块标识符
  /// [optimizationHints] - 性能调优建议
  /// 
  /// 返回调优是否成功应用
  Future<bool> applyPerformanceOptimization(
    String moduleId,
    Map<String, dynamic> optimizationHints,
  ) async {
    // TODO: Phase 2.3 - 根据性能调度器的建议应用优化
    // 例如：调整缓存大小、修改事件处理频率、优化内存使用等
    
    developer.log(
      'Performance optimization interface not yet implemented - Phase 2.3 planned feature',
      name: 'ModuleManager',
    );
    return false;
  }

  // ========== 资源清理 ==========

  /// 清理ModuleManager资源
  Future<void> dispose() async {
    await disposeAllModules();
    await _lifecycleController.close();
    _instance = null;

    developer.log(
      'ModuleManager disposed',
      name: 'ModuleManager',
    );
  }
} 