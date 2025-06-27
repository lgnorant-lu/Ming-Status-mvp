/*
---------------------------------------------------------------
File name:          route_definitions.dart
Author:             AI Assistant
Date created:       2025/06/26
Last modified:      2025/06/26
Dart Version:       3.32.4
Description:        路由定义和路径常量
---------------------------------------------------------------
Change History:
    2025/06/26: Initial creation - 为app_routing创建路由定义;
---------------------------------------------------------------
*/

/// 路由路径常量
class RoutePaths {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String notesHub = '/notes';
  static const String workshop = '/workshop';
  static const String punchIn = '/punch-in';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String about = '/about';
  static const String help = '/help';
  
  /// 获取所有路由路径
  static const List<String> all = [
    home,
    dashboard,
    notesHub,
    workshop,
    punchIn,
    settings,
    profile,
    login,
    register,
    about,
    help,
  ];
}

/// 路由参数
class RouteParams {
  static const String id = 'id';
  static const String tab = 'tab';
  static const String mode = 'mode';
  static const String filter = 'filter';
  static const String search = 'search';
  static const String page = 'page';
  static const String limit = 'limit';
  static const String category = 'category';
  static const String type = 'type';
  static const String status = 'status';
}

/// 路由元数据
class RouteMetadata {
  final String title;
  final String? description;
  final bool requiresAuth;
  final List<String> requiredRoles;
  final Map<String, dynamic> extra;

  const RouteMetadata({
    required this.title,
    this.description,
    this.requiresAuth = false,
    this.requiredRoles = const [],
    this.extra = const {},
  });
}

/// 预定义的路由元数据
class RouteMetadataDefinitions {
  static const RouteMetadata home = RouteMetadata(
    title: '首页',
    description: '应用主页',
  );

  static const RouteMetadata dashboard = RouteMetadata(
    title: '仪表板',
    description: '数据概览',
    requiresAuth: true,
  );

  static const RouteMetadata notesHub = RouteMetadata(
    title: '事务中心',
    description: '笔记和任务管理',
    requiresAuth: true,
  );

  static const RouteMetadata workshop = RouteMetadata(
    title: '创意工坊',
    description: '创意项目管理',
    requiresAuth: true,
  );

  static const RouteMetadata punchIn = RouteMetadata(
    title: '打卡',
    description: '考勤打卡',
    requiresAuth: true,
  );

  static const RouteMetadata settings = RouteMetadata(
    title: '设置',
    description: '应用设置',
    requiresAuth: true,
  );

  static const RouteMetadata profile = RouteMetadata(
    title: '个人资料',
    description: '用户信息管理',
    requiresAuth: true,
  );

  static const RouteMetadata login = RouteMetadata(
    title: '登录',
    description: '用户登录',
  );

  static const RouteMetadata register = RouteMetadata(
    title: '注册',
    description: '用户注册',
  );

  static const RouteMetadata about = RouteMetadata(
    title: '关于',
    description: '关于应用',
  );

  static const RouteMetadata help = RouteMetadata(
    title: '帮助',
    description: '帮助文档',
  );
} 