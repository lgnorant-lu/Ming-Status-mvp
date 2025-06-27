/*
---------------------------------------------------------------
File name:          navigation_service.dart
Author:             Ignorant-lu
Date created:       2025/06/25
Last modified:      2025/06/26
Description:        导航服务 - 提供统一的路由和导航管理
---------------------------------------------------------------
Change History:
    2025/06/26: Phase 1.5 重构 - 移除RoutePaths定义，避免与app_routing包冲突;
    2025/06/25: Initial creation - 导航服务基础实现;
---------------------------------------------------------------
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 路由参数常量
class RouteParams {
  static const String id = 'id';
  static const String type = 'type';
  static const String mode = 'mode';
}

/// 导航结果枚举
enum NavigationResult {
  success,
  cancelled,
  blocked,
  error,
}

/// 导航响应类
class NavigationResponse {
  final NavigationResult result;
  final String? route;
  final dynamic data;
  final String? errorMessage;

  const NavigationResponse({
    required this.result,
    this.route,
    this.data,
    this.errorMessage,
  });

  bool get isSuccess => result == NavigationResult.success;
  bool get isCancelled => result == NavigationResult.cancelled;
  bool get isBlocked => result == NavigationResult.blocked;
  bool get hasError => result == NavigationResult.error;
}

/// 导航服务接口
abstract class NavigationService {
  /// 当前路由
  String get currentRoute;
  
  /// 是否可以返回
  bool get canPop;
  
  /// 导航历史
  List<String> get history;
  
  /// 导航到指定路由
  Future<NavigationResponse> navigateTo(String route, {Map<String, dynamic>? arguments});
  
  /// 替换当前路由
  Future<NavigationResponse> navigateReplace(String route, {Map<String, dynamic>? arguments});
  
  /// 返回上一页
  Future<NavigationResponse> navigateBack({dynamic result});
  
  /// 清空堆栈并导航到新路由
  Future<NavigationResponse> navigateAndClearStack(String route, {Map<String, dynamic>? arguments});
  
  /// 显示模态对话框
  Future<T?> showModal<T>(Widget dialog);
  
  /// 显示底部表单
  Future<T?> showBottomSheet<T>(Widget sheet);
  
  /// 显示消息提示
  Future<void> showMessage(String message, {Duration? duration});
}

/// 基础导航服务实现
class BasicNavigationService implements NavigationService {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final List<String> _history = [];
  
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  NavigatorState? get _navigator => _navigatorKey.currentState;
  
  @override
  String get currentRoute {
    final context = _navigator?.context;
    if (context != null) {
      return GoRouterState.of(context).uri.toString();
    }
    return '/';
  }
  
  @override
  bool get canPop => _navigator?.canPop() ?? false;
  
  @override
  List<String> get history => List.unmodifiable(_history);
  
  @override
  Future<NavigationResponse> navigateTo(String route, {Map<String, dynamic>? arguments}) async {
    try {
      final context = _navigator?.context;
      if (context == null) {
        return const NavigationResponse(
          result: NavigationResult.error,
          errorMessage: 'Navigator context not available',
        );
      }
      
      context.go(route);
      _history.add(route);
      
      return NavigationResponse(
        result: NavigationResult.success,
        route: route,
      );
    } catch (e) {
      return NavigationResponse(
        result: NavigationResult.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  @override
  Future<NavigationResponse> navigateReplace(String route, {Map<String, dynamic>? arguments}) async {
    try {
      final context = _navigator?.context;
      if (context == null) {
        return const NavigationResponse(
          result: NavigationResult.error,
          errorMessage: 'Navigator context not available',
        );
      }
      
      context.pushReplacement(route);
      if (_history.isNotEmpty) {
        _history[_history.length - 1] = route;
      } else {
        _history.add(route);
      }
      
      return NavigationResponse(
        result: NavigationResult.success,
        route: route,
      );
    } catch (e) {
      return NavigationResponse(
        result: NavigationResult.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  @override
  Future<NavigationResponse> navigateBack({dynamic result}) async {
    try {
      final context = _navigator?.context;
      if (context == null || !canPop) {
        return const NavigationResponse(
          result: NavigationResult.blocked,
          errorMessage: 'Cannot navigate back',
        );
      }
      
      context.pop(result);
      if (_history.isNotEmpty) {
        _history.removeLast();
      }
      
      return const NavigationResponse(
        result: NavigationResult.success,
      );
    } catch (e) {
      return NavigationResponse(
        result: NavigationResult.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  @override
  Future<NavigationResponse> navigateAndClearStack(String route, {Map<String, dynamic>? arguments}) async {
    try {
      final context = _navigator?.context;
      if (context == null) {
        return const NavigationResponse(
          result: NavigationResult.error,
          errorMessage: 'Navigator context not available',
        );
      }
      
      context.go(route);
      _history.clear();
      _history.add(route);
      
      return NavigationResponse(
        result: NavigationResult.success,
        route: route,
      );
    } catch (e) {
      return NavigationResponse(
        result: NavigationResult.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  @override
  Future<T?> showModal<T>(Widget dialog) async {
    final context = _navigator?.context;
    if (context == null) return null;
    
    return showDialog<T>(
      context: context,
      builder: (context) => dialog,
    );
  }
  
  @override
  Future<T?> showBottomSheet<T>(Widget sheet) async {
    final context = _navigator?.context;
    if (context == null) return null;
    
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => sheet,
    );
  }
  
  @override
  Future<void> showMessage(String message, {Duration? duration}) async {
    final context = _navigator?.context;
    if (context == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
} 