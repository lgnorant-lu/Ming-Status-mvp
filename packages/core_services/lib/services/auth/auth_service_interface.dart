// 认证服务接口 - 定义认证服务契约，包含登录、登出、token验证等方法
// 
// Author: Ignorant-lu
// Date created: 2025/06/25
// Description: 为安全架构提供认证服务的统一契约定义

import 'dart:async';
import '../../models/user_model.dart';

/// 认证错误类型枚举
enum AuthErrorType {
  /// 网络连接错误
  networkError,
  /// 无效凭据
  invalidCredentials,
  /// 账户被锁定
  accountLocked,
  /// 账户被禁用
  accountDisabled,
  /// 令牌已过期
  tokenExpired,
  /// 令牌无效
  invalidToken,
  /// 权限不足
  insufficientPermissions,
  /// 服务器错误
  serverError,
  /// 未知错误
  unknownError,
  /// 用户已存在
  userAlreadyExists,
  /// 用户不存在
  userNotFound,
  /// 密码不符合要求
  weakPassword,
  /// 验证码错误
  invalidVerificationCode,
  /// 操作超时
  timeout,
  /// 认证服务不可用
  serviceUnavailable,
  /// 频率限制
  rateLimited,
}

/// 认证结果状态枚举
enum AuthResultStatus {
  /// 成功
  success,
  /// 失败
  failure,
  /// 需要验证
  requiresVerification,
  /// 需要额外认证
  requiresAdditionalAuth,
  /// 部分成功
  partialSuccess,
}

/// 认证异常类
class AuthException implements Exception {
  final AuthErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AuthException({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
  });

  /// 创建网络错误异常
  factory AuthException.networkError([String? details]) {
    return AuthException(
      type: AuthErrorType.networkError,
      message: '网络连接失败',
      details: details,
    );
  }

  /// 创建无效凭据异常
  factory AuthException.invalidCredentials([String? details]) {
    return AuthException(
      type: AuthErrorType.invalidCredentials,
      message: '用户名或密码错误',
      details: details,
    );
  }

  /// 创建令牌过期异常
  factory AuthException.tokenExpired([String? details]) {
    return AuthException(
      type: AuthErrorType.tokenExpired,
      message: '登录已过期，请重新登录',
      details: details,
    );
  }

  /// 创建权限不足异常
  factory AuthException.insufficientPermissions([String? details]) {
    return AuthException(
      type: AuthErrorType.insufficientPermissions,
      message: '权限不足',
      details: details,
    );
  }

  /// 创建服务器错误异常
  factory AuthException.serverError([String? details]) {
    return AuthException(
      type: AuthErrorType.serverError,
      message: '服务器错误',
      details: details,
    );
  }

  /// 从其他异常创建
  factory AuthException.fromError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AuthException) return error;
    
    return AuthException(
      type: AuthErrorType.unknownError,
      message: '认证服务发生未知错误',
      details: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('AuthException: $message');
    if (details != null) {
      buffer.write(' ($details)');
    }
    return buffer.toString();
  }
}

/// 认证操作结果
class AuthResult<T> {
  final AuthResultStatus status;
  final T? data;
  final String? message;
  final AuthException? error;
  final Map<String, dynamic> metadata;

  const AuthResult({
    required this.status,
    this.data,
    this.message,
    this.error,
    this.metadata = const {},
  });

  /// 创建成功结果
  factory AuthResult.success(T data, [String? message]) {
    return AuthResult<T>(
      status: AuthResultStatus.success,
      data: data,
      message: message ?? '操作成功',
    );
  }

  /// 创建失败结果
  factory AuthResult.failure(AuthException error, [String? message]) {
    return AuthResult<T>(
      status: AuthResultStatus.failure,
      error: error,
      message: message ?? error.message,
    );
  }

  /// 创建需要验证结果
  factory AuthResult.requiresVerification([String? message, Map<String, dynamic>? metadata]) {
    return AuthResult<T>(
      status: AuthResultStatus.requiresVerification,
      message: message ?? '需要验证',
      metadata: metadata ?? {},
    );
  }

  /// 创建需要额外认证结果
  factory AuthResult.requiresAdditionalAuth([String? message, Map<String, dynamic>? metadata]) {
    return AuthResult<T>(
      status: AuthResultStatus.requiresAdditionalAuth,
      message: message ?? '需要额外认证',
      metadata: metadata ?? {},
    );
  }

  /// 检查是否成功
  bool get isSuccess => status == AuthResultStatus.success;

  /// 检查是否失败
  bool get isFailure => status == AuthResultStatus.failure;

  /// 检查是否需要验证
  bool get requiresVerification => status == AuthResultStatus.requiresVerification;

  /// 检查是否需要额外认证
  bool get requiresAdditionalAuth => status == AuthResultStatus.requiresAdditionalAuth;

  /// 获取数据或抛出异常
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error ?? AuthException(
      type: AuthErrorType.unknownError,
      message: message ?? '操作失败',
    );
  }

  /// 转换数据类型
  AuthResult<R> map<R>(R Function(T) mapper) {
    if (isSuccess && data != null) {
      try {
        final nonNullData = data;
        if (nonNullData != null) {
          final mappedData = mapper(nonNullData);
          return AuthResult<R>(
            status: status,
            data: mappedData,
            message: message,
            metadata: metadata,
          );
        }
      } catch (e) {
        return AuthResult<R>.failure(
          AuthException.fromError(e),
          '数据转换失败',
        );
      }
    }
    
    return AuthResult<R>(
      status: status,
      message: message,
      error: error,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'AuthResult(status: $status, message: $message, hasData: ${data != null})';
  }
}

/// 登录凭据
abstract class LoginCredentials {
  const LoginCredentials();
}

/// 用户名密码凭据
class UsernamePasswordCredentials extends LoginCredentials {
  final String username;
  final String password;
  final bool rememberMe;
  final Map<String, dynamic> additionalData;

  const UsernamePasswordCredentials({
    required this.username,
    required this.password,
    this.rememberMe = false,
    this.additionalData = const {},
  });

  @override
  String toString() => 'UsernamePasswordCredentials(username: $username, rememberMe: $rememberMe)';
}

/// 邮箱密码凭据
class EmailPasswordCredentials extends LoginCredentials {
  final String email;
  final String password;
  final bool rememberMe;
  final Map<String, dynamic> additionalData;

  const EmailPasswordCredentials({
    required this.email,
    required this.password,
    this.rememberMe = false,
    this.additionalData = const {},
  });

  @override
  String toString() => 'EmailPasswordCredentials(email: $email, rememberMe: $rememberMe)';
}

/// 令牌凭据
class TokenCredentials extends LoginCredentials {
  final String accessToken;
  final String? refreshToken;
  final Map<String, dynamic> additionalData;

  const TokenCredentials({
    required this.accessToken,
    this.refreshToken,
    this.additionalData = const {},
  });

  @override
  String toString() => 'TokenCredentials(hasAccessToken: true, hasRefreshToken: ${refreshToken != null})';
}

/// 验证码凭据
class VerificationCodeCredentials extends LoginCredentials {
  final String identifier; // 可以是用户名、邮箱或手机号
  final String code;
  final String? codeType; // 验证码类型：sms, email, totp等
  final Map<String, dynamic> additionalData;

  const VerificationCodeCredentials({
    required this.identifier,
    required this.code,
    this.codeType,
    this.additionalData = const {},
  });

  @override
  String toString() => 'VerificationCodeCredentials(identifier: $identifier, codeType: $codeType)';
}

/// 注册信息
class RegistrationInfo {
  final String username;
  final String email;
  final String password;
  final String? displayName;
  final String? phoneNumber;
  final UserRole role;
  final UserPreferences? preferences;
  final Map<String, dynamic> additionalData;

  const RegistrationInfo({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
    this.phoneNumber,
    this.role = UserRole.user,
    this.preferences,
    this.additionalData = const {},
  });

  @override
  String toString() => 'RegistrationInfo(username: $username, email: $email, role: $role)';
}

/// 密码重置信息
class PasswordResetInfo {
  final String identifier; // 用户名或邮箱
  final String? verificationCode;
  final String? newPassword;
  final String? resetToken;
  final Map<String, dynamic> additionalData;

  const PasswordResetInfo({
    required this.identifier,
    this.verificationCode,
    this.newPassword,
    this.resetToken,
    this.additionalData = const {},
  });

  @override
  String toString() => 'PasswordResetInfo(identifier: $identifier, hasVerificationCode: ${verificationCode != null})';
}

/// 认证状态变化事件
class AuthStateChangedEvent {
  final User? previousUser;
  final User? currentUser;
  final AuthResultStatus status;
  final String? message;
  final DateTime timestamp;

  AuthStateChangedEvent({
    this.previousUser,
    this.currentUser,
    required this.status,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 检查是否为登录事件
  bool get isLogin => previousUser == null && currentUser != null;

  /// 检查是否为登出事件
  bool get isLogout => previousUser != null && currentUser == null;

  /// 检查是否为用户更新事件
  bool get isUserUpdate => previousUser != null && currentUser != null;

  @override
  String toString() {
    if (isLogin) return 'AuthStateChangedEvent: Login (${currentUser?.username})';
    if (isLogout) return 'AuthStateChangedEvent: Logout (${previousUser?.username})';
    if (isUserUpdate) return 'AuthStateChangedEvent: UserUpdate (${currentUser?.username})';
    return 'AuthStateChangedEvent: Unknown';
  }
}

/// 认证服务接口
/// 
/// 定义了完整的认证服务契约，包含用户认证、权限管理、令牌处理等功能
abstract class IAuthService {
  // ========== 认证状态管理 ==========

  /// 当前认证用户流
  Stream<User?> get currentUserStream;

  /// 认证状态变化流
  Stream<AuthStateChangedEvent> get authStateChanges;

  /// 当前认证用户
  User? get currentUser;

  /// 是否已认证
  bool get isAuthenticated;

  /// 是否为管理员
  bool get isAdmin;

  /// 是否为高级用户
  bool get isPremium;

  // ========== 登录认证 ==========

  /// 用户名密码登录
  Future<AuthResult<User>> loginWithUsernamePassword(
    String username,
    String password, {
    bool rememberMe = false,
    Map<String, dynamic>? additionalData,
  });

  /// 邮箱密码登录
  Future<AuthResult<User>> loginWithEmailPassword(
    String email,
    String password, {
    bool rememberMe = false,
    Map<String, dynamic>? additionalData,
  });

  /// 令牌登录
  Future<AuthResult<User>> loginWithToken(
    String accessToken, {
    String? refreshToken,
    Map<String, dynamic>? additionalData,
  });

  /// 验证码登录
  Future<AuthResult<User>> loginWithVerificationCode(
    String identifier,
    String code, {
    String? codeType,
    Map<String, dynamic>? additionalData,
  });

  /// 通用登录方法
  Future<AuthResult<User>> login(LoginCredentials credentials);

  /// 静默登录（使用存储的凭据）
  Future<AuthResult<User>> silentLogin();

  // ========== 注册管理 ==========

  /// 用户注册
  Future<AuthResult<User>> register(RegistrationInfo registrationInfo);

  /// 检查用户名是否可用
  Future<AuthResult<bool>> isUsernameAvailable(String username);

  /// 检查邮箱是否可用
  Future<AuthResult<bool>> isEmailAvailable(String email);

  /// 发送验证邮件
  Future<AuthResult<bool>> sendVerificationEmail(String email);

  /// 验证邮箱
  Future<AuthResult<bool>> verifyEmail(String email, String verificationCode);

  // ========== 登出管理 ==========

  /// 登出当前用户
  Future<AuthResult<bool>> logout();

  /// 登出所有设备
  Future<AuthResult<bool>> logoutAllDevices();

  /// 撤销指定令牌
  Future<AuthResult<bool>> revokeToken(String token);

  // ========== 令牌管理 ==========

  /// 刷新访问令牌
  Future<AuthResult<TokenInfo>> refreshToken([String? refreshToken]);

  /// 验证令牌有效性
  Future<AuthResult<bool>> validateToken(String token);

  /// 获取令牌信息
  Future<AuthResult<TokenInfo>> getTokenInfo();

  /// 检查令牌是否即将过期
  bool isTokenNearExpiry({Duration threshold = const Duration(minutes: 5)});

  // ========== 密码管理 ==========

  /// 修改密码
  Future<AuthResult<bool>> changePassword(
    String currentPassword,
    String newPassword,
  );

  /// 请求密码重置
  Future<AuthResult<bool>> requestPasswordReset(String identifier);

  /// 验证密码重置代码
  Future<AuthResult<bool>> verifyPasswordResetCode(
    String identifier,
    String code,
  );

  /// 重置密码
  Future<AuthResult<bool>> resetPassword(PasswordResetInfo resetInfo);

  // ========== 用户信息管理 ==========

  /// 获取用户信息
  Future<AuthResult<User>> getUserInfo();

  /// 更新用户信息
  Future<AuthResult<User>> updateUserInfo(Map<String, dynamic> updates);

  /// 更新用户偏好设置
  Future<AuthResult<User>> updatePreferences(UserPreferences preferences);

  /// 上传用户头像
  Future<AuthResult<String>> uploadAvatar(List<int> avatarData);

  // ========== 权限验证 ==========

  /// 检查用户权限
  Future<AuthResult<bool>> checkPermission(String permission);

  /// 检查多个权限
  Future<AuthResult<Map<String, bool>>> checkPermissions(List<String> permissions);

  /// 检查角色权限
  Future<AuthResult<bool>> checkRole(UserRole role);

  /// 检查最小角色等级
  Future<AuthResult<bool>> checkMinimumRole(UserRole minimumRole);

  // ========== 会话管理 ==========

  /// 获取活跃会话列表
  Future<AuthResult<List<Map<String, dynamic>>>> getActiveSessions();

  /// 终止指定会话
  Future<AuthResult<bool>> terminateSession(String sessionId);

  /// 获取登录历史
  Future<AuthResult<List<Map<String, dynamic>>>> getLoginHistory({
    int limit = 20,
    int offset = 0,
  });

  // ========== 安全功能 ==========

  /// 启用双因素认证
  Future<AuthResult<Map<String, dynamic>>> enableTwoFactorAuth();

  /// 禁用双因素认证
  Future<AuthResult<bool>> disableTwoFactorAuth(String verificationCode);

  /// 生成恢复代码
  Future<AuthResult<List<String>>> generateRecoveryCodes();

  /// 验证双因素认证代码
  Future<AuthResult<bool>> verifyTwoFactorCode(String code);

  // ========== 服务管理 ==========

  /// 初始化服务
  Future<void> initialize();

  /// 销毁服务
  Future<void> dispose();

  /// 清除缓存
  Future<void> clearCache();

  /// 服务健康检查
  Future<AuthResult<Map<String, dynamic>>> healthCheck();

  // ========== 配置管理 ==========

  /// 更新服务配置
  Future<void> updateConfiguration(Map<String, dynamic> config);

  /// 获取服务配置
  Map<String, dynamic> getConfiguration();

  /// 设置API端点
  void setApiEndpoint(String endpoint);

  /// 设置认证超时时间
  void setTimeout(Duration timeout);
}

/// 认证服务工厂接口
abstract class IAuthServiceFactory {
  /// 创建认证服务实例
  IAuthService createAuthService(Map<String, dynamic> config);

  /// 创建本地认证服务（开发/测试用）
  IAuthService createLocalAuthService();

  /// 创建远程认证服务
  IAuthService createRemoteAuthService(String apiEndpoint);

  /// 获取默认认证服务
  IAuthService getDefaultAuthService();
}

/// 认证缓存接口
abstract class IAuthCache {
  /// 存储用户信息
  Future<void> storeUser(User user);

  /// 获取用户信息
  Future<User?> getUser();

  /// 存储令牌信息
  Future<void> storeToken(TokenInfo tokenInfo);

  /// 获取令牌信息
  Future<TokenInfo?> getToken();

  /// 清除所有缓存
  Future<void> clear();

  /// 检查缓存是否存在
  Future<bool> hasCache();
}

/// 认证监听器接口
abstract class IAuthListener {
  /// 认证状态变化回调
  void onAuthStateChanged(AuthStateChangedEvent event);

  /// 令牌即将过期回调
  void onTokenNearExpiry(TokenInfo tokenInfo);

  /// 认证错误回调
  void onAuthError(AuthException error);

  /// 用户信息更新回调
  void onUserUpdated(User user);
}

/// 认证拦截器接口
abstract class IAuthInterceptor {
  /// 请求前拦截
  Future<Map<String, String>> onRequest(Map<String, String> headers);

  /// 响应后拦截
  Future<void> onResponse(int statusCode, Map<String, dynamic> response);

  /// 错误拦截
  Future<void> onError(dynamic error);
}