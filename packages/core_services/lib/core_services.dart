/// Core Services Package
/// 
/// 提供应用的核心服务功能，包括依赖注入、事件总线、
/// 模块管理、导航服务、网络服务、安全服务等
library core_services;

/*
---------------------------------------------------------------
File name:          core_services.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        核心服务包主库文件 - 导出所有依赖注入、事件总线、模块管理、基础服务等核心功能
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 重构 - 添加新的基础服务框架：日志、错误处理、性能监控服务;
    2025/06/25: Initial creation - Phase 1核心服务包实现;
---------------------------------------------------------------
*/

// Core Services Package - 核心服务框架
// 提供依赖注入、事件总线、模块管理、日志记录、错误处理、性能监控等基础服务

// 导出依赖注入服务
export 'di/service_locator.dart';

// 导出核心模型
export 'models/base_item.dart';
export 'models/repository_result.dart';
export 'models/user_model.dart';

// 导出事件总线
export 'event_bus.dart';

// 导出模块接口
export 'module_interface.dart';

// 导出核心服务
export 'services/module_manager.dart';
export 'services/navigation_service.dart';
export 'services/logging_service.dart';
export 'services/error_handling_service.dart';
export 'services/performance_monitoring_service.dart';
export 'services/display_mode_service.dart';

// 导出存储库服务
export 'services/repositories/persistence_repository.dart';
export 'services/repositories/in_memory_repository.dart';

// 导出安全服务
export 'services/security/encryption_service.dart';
export 'services/auth/auth_service_interface.dart'; 