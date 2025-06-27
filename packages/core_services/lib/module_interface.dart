/*
---------------------------------------------------------------
File name:          module_interface.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        模块接口 - 定义宠物应用模块的标准接口和生命周期管理
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 修复 - 恢复完整的API文档规范接口定义;
    2025/06/25: Initial creation - 基础模块接口实现;
---------------------------------------------------------------
*/

import 'event_bus.dart';

/// 所有宠物模块必须实现的标准接口
///
/// 定义了模块的基本信息、生命周期管理和状态跟踪，
/// 确保所有模块都能以统一的方式被 ModuleManager 管理。
abstract class PetModuleInterface {
  // === 模块基本信息 ===
  
  /// 模块的唯一标识符
  ///
  /// 用于模块间的识别和依赖管理，必须全局唯一
  String get id;
  
  /// 模块的显示名称
  ///
  /// 用于用户界面显示的友好名称
  String get name;
  
  /// 模块的详细描述
  ///
  /// 描述模块的功能和用途
  String get description;
  
  /// 模块版本号
  ///
  /// 遵循语义化版本控制规范
  String get version;
  
  /// 模块作者
  ///
  /// 模块的开发者或维护者信息
  String get author;
  
  /// 模块依赖列表
  ///
  /// 此模块依赖的其他模块ID列表
  List<String> get dependencies;
  
  /// 模块元数据
  ///
  /// 包含模块的配置信息、功能特性等额外数据
  Map<String, dynamic> get metadata;

  // === 状态管理 ===
  
  /// 模块是否已初始化
  ///
  /// 标识模块是否已完成initialize()调用
  bool get isInitialized;
  
  /// 模块是否处于活跃状态
  ///
  /// 标识模块是否已完成boot()调用并正在运行
  bool get isActive;

  // === 生命周期方法 ===
  
  /// 初始化模块
  ///
  /// 当 ModuleManager 注册此模块时调用。
  /// 模块可以在这里进行必要的设置，例如：
  /// - 订阅它关心的事件
  /// - 准备它需要暴露的服务
  /// - 加载配置和数据
  ///
  /// [eventBus] 全局事件总线实例，用于模块间的通信
  Future<void> initialize(EventBus eventBus);

  /// 启动模块
  ///
  /// 在所有模块都完成 initialize 后，ModuleManager 会调用此方法。
  /// 模块可以在这里开始执行其核心功能，例如：
  /// - 启动后台任务
  /// - 注册路由和UI组件
  /// - 开始数据同步
  Future<void> boot();

  /// 销毁模块
  ///
  /// 当应用关闭或模块被卸载时调用。
  /// 模块应在这里释放所有资源，例如：
  /// - 取消事件订阅
  /// - 关闭数据库连接
  /// - 停止所有正在运行的进程
  /// - 清理缓存和临时数据
  void dispose();
} 