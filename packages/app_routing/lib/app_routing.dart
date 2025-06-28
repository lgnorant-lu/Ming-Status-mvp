/// App Routing Package
/// 
/// 提供应用的路由管理功能，包括声明式路由配置、
/// 类型安全的导航、路由守卫等
library app_routing;

/*
---------------------------------------------------------------
File name:          app_routing.dart  
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        应用路由包主库文件 - 导出所有路由管理相关功能
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 重构 - 添加路由定义和路径常量;
    2025/06/25: Initial creation - Phase 1路由包实现;
---------------------------------------------------------------
*/

// App Routing Package - 应用路由管理
// 提供声明式路由配置、类型安全导航、路由守卫等功能

// 导出路由器
export 'app_router.dart';

// 导出路由定义
export 'route_definitions.dart';

// 导出国际化
export 'l10n/routing_l10n.dart'; 