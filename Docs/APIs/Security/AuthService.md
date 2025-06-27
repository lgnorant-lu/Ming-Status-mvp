# AuthService API 文档

## 概述

AuthService是桌宠应用的核心认证服务，负责用户身份验证、会话管理、权限控制和安全策略执行。它提供完整的认证生命周期管理，支持多种认证方式和安全机制，确保应用的安全性和用户数据保护。

- **主要功能**: 用户认证、会话管理、权限验证、安全策略、双因子认证
- **设计模式**: 单例模式 + 策略模式 + 观察者模式
- **实现接口**: `IAuthService`
- **位置**: `lib/core/services/auth/auth_service_interface.dart`

## 核心接口定义

### IAuthService 接口
```dart
abstract class IAuthService {
  // 认证状态
  Stream<AuthState> get authStateStream;
  AuthState get currentAuthState;
  UserModel? get currentUser;
  bool get isAuthenticated;
  bool get isGuest;
  
  // 基础认证
  Future<AuthResult> login(String identifier, String password);
  Future<AuthResult> loginWithEmail(String email, String password);
  Future<AuthResult> loginWithUsername(String username, String password);
  Future<AuthResult> logout();
  Future<AuthResult> logoutAll(); // 登出所有设备
  
  // 用户注册
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
    Map<String, dynamic>? metadata,
  });
  
  // 访客模式
  Future<AuthResult> loginAsGuest();
  Future<AuthResult> convertGuestToUser({
    required String username,
    required String email,
    required String password,
  });
  
  // 密码管理
  Future<AuthResult> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<AuthResult> resetPassword(String email);
  Future<AuthResult> confirmPasswordReset({
    required String token,
    required String newPassword,
  });
  
  // 双因子认证
  Future<AuthResult> enableTwoFactor();
  Future<AuthResult> disableTwoFactor(String password);
  Future<AuthResult> verifyTwoFactor(String code);
  Future<AuthResult> generateBackupCodes();
  
  // 会话管理
  Future<AuthResult> refreshSession();
  Future<AuthResult> validateSession();
  Future<List<UserSession>> getActiveSessions();
  Future<AuthResult> terminateSession(String sessionId);
  Future<AuthResult> terminateAllOtherSessions();
  
  // 权限验证
  bool hasPermission(String permission);
  bool hasRolePermission(UserRole requiredRole);
  Future<List<String>> getUserPermissions();
  Future<AuthResult> checkPermission(String permission);
  
  // 设备管理
  Future<AuthResult> registerDevice(DeviceInfo deviceInfo);
  Future<List<TrustedDevice>> getTrustedDevices();
  Future<AuthResult> trustCurrentDevice();
  Future<AuthResult> removeTrustedDevice(String deviceId);
  
  // 安全事件
  Future<List<SecurityEvent>> getSecurityEvents({int? limit});
  Future<AuthResult> reportSecurityIncident(SecurityIncident incident);
  
  // 服务管理
  Future<void> initialize();
  Future<void> dispose();
  Future<AuthServiceHealth> getHealth();
}
```

## 核心类型定义

### AuthState 枚举
```dart
enum AuthState {
  initial,           // 初始状态
  authenticating,    // 认证中
  authenticated,     // 已认证
  guest,            // 访客模式
  unauthenticated,  // 未认证
  sessionExpired,   // 会话过期
  suspended,        // 账户被暂停
  banned,           // 账户被封禁
  twoFactorRequired, // 需要双因子认证
  passwordExpired,   // 密码过期
  error;            // 错误状态
  
  bool get isLoggedIn => this == AuthState.authenticated || this == AuthState.guest;
  bool get requiresAction => this == AuthState.twoFactorRequired || 
                            this == AuthState.passwordExpired ||
                            this == AuthState.sessionExpired;
}
```

### AuthResult 类
```dart
class AuthResult {
  final bool isSuccess;              // 操作是否成功
  final AuthState? newState;         // 新的认证状态
  final UserModel? user;             // 用户信息
  final String? token;               // 访问令牌
  final String? refreshToken;        // 刷新令牌
  final String? errorMessage;        // 错误消息
  final AuthErrorType? errorType;    // 错误类型
  final Map<String, dynamic>? metadata; // 附加元数据
  final DateTime timestamp;          // 操作时间戳
  
  // 成功结果构造方法
  factory AuthResult.success({
    required AuthState newState,
    UserModel? user,
    String? token,
    String? refreshToken,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResult(
      isSuccess: true,
      newState: newState,
      user: user,
      token: token,
      refreshToken: refreshToken,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }
  
  // 失败结果构造方法
  factory AuthResult.failure({
    required String errorMessage,
    required AuthErrorType errorType,
    AuthState? newState,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorType: errorType,
      newState: newState,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }
}
```

### AuthErrorType 枚举
```dart
enum AuthErrorType {
  invalidCredentials,    // 凭据无效
  userNotFound,         // 用户不存在
  userSuspended,        // 用户被暂停
  userBanned,           // 用户被封禁
  passwordExpired,      // 密码过期
  accountLocked,        // 账户被锁定
  twoFactorRequired,    // 需要双因子认证
  invalidTwoFactor,     // 双因子认证码无效
  sessionExpired,       // 会话过期
  sessionInvalid,       // 会话无效
  tokenExpired,         // 令牌过期
  tokenInvalid,         // 令牌无效
  permissionDenied,     // 权限拒绝
  rateLimitExceeded,    // 速率限制超出
  deviceNotTrusted,     // 设备不受信任
  networkError,         // 网络错误
  serverError,          // 服务器错误
  validationError,      // 验证错误
  unknown;              // 未知错误
}
```

### UserSession 类
```dart
class UserSession {
  final String id;                   // 会话ID
  final String userId;               // 用户ID
  final String deviceId;             // 设备ID
  final String? deviceName;          // 设备名称
  final String? platform;           // 平台信息
  final String? location;           // 登录位置
  final String? ipAddress;          // IP地址
  final DateTime createdAt;         // 创建时间
  final DateTime lastActiveAt;      // 最后活动时间
  final DateTime expiresAt;         // 过期时间
  final bool isCurrent;             // 是否当前会话
  final Map<String, dynamic>? metadata; // 会话元数据
}
```

### TrustedDevice 类
```dart
class TrustedDevice {
  final String id;                   // 设备ID
  final String name;                 // 设备名称
  final String platform;            // 平台
  final String? model;               // 设备型号
  final DateTime firstTrustedAt;     // 首次信任时间
  final DateTime lastSeenAt;        // 最后看到时间
  final bool isActive;              // 是否活跃
  final Map<String, dynamic>? metadata; // 设备元数据
}
```

### SecurityEvent 类
```dart
class SecurityEvent {
  final String id;                   // 事件ID
  final String userId;               // 用户ID
  final SecurityEventType type;      // 事件类型
  final String description;          // 事件描述
  final String? deviceId;            // 设备ID
  final String? ipAddress;           // IP地址
  final String? location;            // 位置
  final DateTime timestamp;          // 时间戳
  final SecuritySeverity severity;   // 严重程度
  final Map<String, dynamic>? context; // 事件上下文
  final bool resolved;              // 是否已解决
}
```

## 主要方法详解

### 基础认证

#### `login`
- **描述**: 通用登录方法，自动识别邮箱或用户名
- **签名**: `Future<AuthResult> login(String identifier, String password)`
- **参数**:
  - `identifier` - 邮箱地址或用户名
  - `password` - 密码
- **返回值**: AuthResult包含认证结果
- **示例**:
```dart
final result = await authService.login('alice@example.com', 'password123');
if (result.isSuccess) {
  print('登录成功，用户: ${result.user?.displayName}');
  print('新状态: ${result.newState}');
} else {
  print('登录失败: ${result.errorMessage}');
  _handleAuthError(result.errorType);
}
```

#### `register`
- **描述**: 用户注册
- **签名**: `Future<AuthResult> register({required String username, required String email, required String password, String? displayName, Map<String, dynamic>? metadata})`
- **参数**:
  - `username` - 用户名
  - `email` - 邮箱地址
  - `password` - 密码
  - `displayName` - 显示名称（可选）
  - `metadata` - 附加元数据（可选）
- **返回值**: AuthResult包含注册结果
- **示例**:
```dart
final result = await authService.register(
  username: 'alice_chen',
  email: 'alice@example.com',
  password: 'SecurePass123!',
  displayName: '陈小雅',
  metadata: {'source': 'mobile_app'},
);

if (result.isSuccess) {
  print('注册成功，请检查邮箱验证');
} else {
  switch (result.errorType) {
    case AuthErrorType.validationError:
      showValidationErrors();
      break;
    case AuthErrorType.userAlreadyExists:
      showUserExistsError();
      break;
    default:
      showGenericError(result.errorMessage);
  }
}
```

#### `logout`
- **描述**: 登出当前用户
- **签名**: `Future<AuthResult> logout()`
- **返回值**: AuthResult包含登出结果
- **特性**:
  - 清除当前会话
  - 清除本地存储的令牌
  - 触发认证状态变更
- **示例**:
```dart
final result = await authService.logout();
if (result.isSuccess) {
  print('已安全登出');
  navigateToLoginScreen();
} else {
  print('登出时遇到问题: ${result.errorMessage}');
}
```

### 访客模式

#### `loginAsGuest`
- **描述**: 以访客身份登录
- **签名**: `Future<AuthResult> loginAsGuest()`
- **返回值**: AuthResult包含访客登录结果
- **特性**:
  - 创建临时访客用户
  - 有限的权限和功能
  - 可稍后转换为正式用户
- **示例**:
```dart
final result = await authService.loginAsGuest();
if (result.isSuccess) {
  print('以访客身份进入应用');
  showGuestModeNotification();
} else {
  print('访客模式登录失败: ${result.errorMessage}');
}
```

#### `convertGuestToUser`
- **描述**: 将访客用户转换为正式用户
- **签名**: `Future<AuthResult> convertGuestToUser({required String username, required String email, required String password})`
- **参数**:
  - `username` - 用户名
  - `email` - 邮箱地址
  - `password` - 密码
- **返回值**: AuthResult包含转换结果
- **示例**:
```dart
// 检查是否为访客用户
if (authService.isGuest) {
  final result = await authService.convertGuestToUser(
    username: 'alice_chen',
    email: 'alice@example.com',
    password: 'SecurePass123!',
  );
  
  if (result.isSuccess) {
    print('访客账户已成功转换为正式用户');
    showWelcomeMessage();
  } else {
    print('转换失败: ${result.errorMessage}');
  }
}
```

### 双因子认证

#### `enableTwoFactor`
- **描述**: 启用双因子认证
- **签名**: `Future<AuthResult> enableTwoFactor()`
- **返回值**: AuthResult包含启用结果和设置信息
- **特性**:
  - 生成TOTP密钥
  - 提供QR码
  - 生成备份代码
- **示例**:
```dart
final result = await authService.enableTwoFactor();
if (result.isSuccess) {
  final secret = result.metadata?['secret'] as String;
  final qrCode = result.metadata?['qrCode'] as String;
  final backupCodes = result.metadata?['backupCodes'] as List<String>;
  
  showTwoFactorSetup(secret, qrCode, backupCodes);
} else {
  print('启用双因子认证失败: ${result.errorMessage}');
}
```

#### `verifyTwoFactor`
- **描述**: 验证双因子认证码
- **签名**: `Future<AuthResult> verifyTwoFactor(String code)`
- **参数**: `code` - 6位验证码或备份代码
- **返回值**: AuthResult包含验证结果
- **示例**:
```dart
// 当认证状态为twoFactorRequired时
if (authService.currentAuthState == AuthState.twoFactorRequired) {
  final code = await getTwoFactorCodeFromUser();
  final result = await authService.verifyTwoFactor(code);
  
  if (result.isSuccess) {
    print('双因子认证成功');
    proceedToMainApp();
  } else {
    print('验证码无效: ${result.errorMessage}');
    showTwoFactorError();
  }
}
```

### 会话管理

#### `refreshSession`
- **描述**: 刷新当前会话
- **签名**: `Future<AuthResult> refreshSession()`
- **返回值**: AuthResult包含刷新结果
- **用途**: 延长会话有效期，获取新的访问令牌
- **示例**:
```dart
// 定期刷新会话
Timer.periodic(Duration(minutes: 15), (timer) async {
  if (authService.isAuthenticated) {
    final result = await authService.refreshSession();
    if (!result.isSuccess) {
      print('会话刷新失败，可能需要重新登录');
      handleSessionExpired();
    }
  }
});
```

#### `getActiveSessions`
- **描述**: 获取用户的所有活跃会话
- **签名**: `Future<List<UserSession>> getActiveSessions()`
- **返回值**: 活跃会话列表
- **示例**:
```dart
final sessions = await authService.getActiveSessions();
for (final session in sessions) {
  print('设备: ${session.deviceName}');
  print('位置: ${session.location}');
  print('最后活动: ${session.lastActiveAt}');
  print('当前会话: ${session.isCurrent}');
}
```

#### `terminateSession`
- **描述**: 终止指定会话
- **签名**: `Future<AuthResult> terminateSession(String sessionId)`
- **参数**: `sessionId` - 要终止的会话ID
- **返回值**: AuthResult包含操作结果
- **示例**:
```dart
// 用户选择终止某个会话
final result = await authService.terminateSession(suspiciousSessionId);
if (result.isSuccess) {
  print('已终止可疑会话');
  refreshSessionList();
} else {
  print('终止会话失败: ${result.errorMessage}');
}
```

### 权限验证

#### `hasPermission`
- **描述**: 检查当前用户是否有指定权限
- **签名**: `bool hasPermission(String permission)`
- **参数**: `permission` - 权限字符串
- **返回值**: 是否有权限
- **示例**:
```dart
// 功能权限检查
if (authService.hasPermission('module.admin')) {
  showAdminMenu();
} else {
  hideAdminMenu();
}

// 数据权限检查
if (authService.hasPermission('data.export')) {
  enableExportFeature();
}
```

#### `hasRolePermission`
- **描述**: 检查当前用户角色是否满足要求
- **签名**: `bool hasRolePermission(UserRole requiredRole)`
- **参数**: `requiredRole` - 所需的最低角色级别
- **返回值**: 是否满足角色要求
- **示例**:
```dart
// 角色级别检查
if (authService.hasRolePermission(UserRole.moderator)) {
  enableModerationTools();
}

// 管理员功能
if (authService.hasRolePermission(UserRole.admin)) {
  showSystemSettings();
}
```

### 设备管理

#### `trustCurrentDevice`
- **描述**: 将当前设备添加到信任列表
- **签名**: `Future<AuthResult> trustCurrentDevice()`
- **返回值**: AuthResult包含操作结果
- **示例**:
```dart
// 用户选择信任此设备
final result = await authService.trustCurrentDevice();
if (result.isSuccess) {
  print('设备已添加到信任列表');
  showTrustDeviceConfirmation();
} else {
  print('添加信任设备失败: ${result.errorMessage}');
}
```

#### `getTrustedDevices`
- **描述**: 获取用户的信任设备列表
- **签名**: `Future<List<TrustedDevice>> getTrustedDevices()`
- **返回值**: 信任设备列表
- **示例**:
```dart
final trustedDevices = await authService.getTrustedDevices();
for (final device in trustedDevices) {
  print('设备: ${device.name} (${device.platform})');
  print('首次信任: ${device.firstTrustedAt}');
  print('最后见到: ${device.lastSeenAt}');
}
```

## 状态管理

### AuthState 流监听
```dart
class AuthStateListener {
  late StreamSubscription<AuthState> _subscription;
  
  void startListening() {
    _subscription = authService.authStateStream.listen((state) {
      switch (state) {
        case AuthState.authenticated:
          navigateToMainApp();
          break;
        case AuthState.guest:
          showGuestModeUI();
          break;
        case AuthState.unauthenticated:
          navigateToLogin();
          break;
        case AuthState.sessionExpired:
          showSessionExpiredDialog();
          break;
        case AuthState.twoFactorRequired:
          showTwoFactorDialog();
          break;
        case AuthState.suspended:
          showAccountSuspendedDialog();
          break;
        case AuthState.banned:
          showAccountBannedDialog();
          break;
        case AuthState.passwordExpired:
          showPasswordExpiredDialog();
          break;
        default:
          // 处理其他状态
          break;
      }
    });
  }
  
  void dispose() {
    _subscription.cancel();
  }
}
```

## 错误处理

### 统一错误处理策略
```dart
class AuthErrorHandler {
  static void handleAuthError(AuthErrorType? errorType, String? message) {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        showError('用户名或密码错误');
        break;
      case AuthErrorType.userNotFound:
        showError('用户不存在');
        break;
      case AuthErrorType.userSuspended:
        showError('账户已被暂停，请联系管理员');
        break;
      case AuthErrorType.userBanned:
        showError('账户已被封禁');
        break;
      case AuthErrorType.passwordExpired:
        navigateToPasswordReset();
        break;
      case AuthErrorType.accountLocked:
        showError('账户已被锁定，请稍后重试');
        break;
      case AuthErrorType.twoFactorRequired:
        showTwoFactorDialog();
        break;
      case AuthErrorType.sessionExpired:
        showSessionExpiredDialog();
        break;
      case AuthErrorType.rateLimitExceeded:
        showError('操作过于频繁，请稍后重试');
        break;
      case AuthErrorType.networkError:
        showError('网络连接失败，请检查网络设置');
        break;
      default:
        showError(message ?? '认证服务遇到未知错误');
    }
  }
}
```

### 重试机制
```dart
class AuthRetryPolicy {
  static Future<AuthResult> retryWithBackoff<T>(
    Future<AuthResult> Function() operation,
    {int maxRetries = 3, Duration initialDelay = const Duration(seconds: 1)}
  ) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (attempts < maxRetries) {
      try {
        final result = await operation();
        if (result.isSuccess || !_shouldRetry(result.errorType)) {
          return result;
        }
      } catch (e) {
        if (attempts == maxRetries - 1) rethrow;
      }
      
      await Future.delayed(delay);
      delay *= 2; // 指数退避
      attempts++;
    }
    
    return AuthResult.failure(
      errorMessage: '操作失败，已重试$maxRetries次',
      errorType: AuthErrorType.serverError,
    );
  }
  
  static bool _shouldRetry(AuthErrorType? errorType) {
    switch (errorType) {
      case AuthErrorType.networkError:
      case AuthErrorType.serverError:
      case AuthErrorType.tokenExpired:
        return true;
      default:
        return false;
    }
  }
}
```

## 安全功能

### 密码强度验证
```dart
class PasswordValidator {
  static const int minLength = 8;
  static const int maxLength = 128;
  
  static List<String> validatePassword(String password) {
    final errors = <String>[];
    
    if (password.length < minLength) {
      errors.add('密码至少需要$minLength个字符');
    }
    
    if (password.length > maxLength) {
      errors.add('密码不能超过$maxLength个字符');
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('密码必须包含至少一个大写字母');
    }
    
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('密码必须包含至少一个小写字母');
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('密码必须包含至少一个数字');
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('密码必须包含至少一个特殊字符');
    }
    
    return errors;
  }
  
  static int calculateStrength(String password) {
    int score = 0;
    
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 1;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 1;
    
    return score;
  }
}
```

### 速率限制
```dart
class AuthRateLimiter {
  static final Map<String, List<DateTime>> _attempts = {};
  static const int maxAttempts = 5;
  static const Duration windowDuration = Duration(minutes: 15);
  
  static bool isRateLimited(String identifier) {
    final now = DateTime.now();
    final attempts = _attempts[identifier] ?? [];
    
    // 清理过期的尝试记录
    attempts.removeWhere((attempt) => 
        now.difference(attempt) > windowDuration);
    
    return attempts.length >= maxAttempts;
  }
  
  static void recordAttempt(String identifier) {
    final attempts = _attempts[identifier] ?? [];
    attempts.add(DateTime.now());
    _attempts[identifier] = attempts;
  }
  
  static Duration getRemainingLockout(String identifier) {
    final attempts = _attempts[identifier] ?? [];
    if (attempts.isEmpty) return Duration.zero;
    
    final oldestAttempt = attempts.first;
    final unlockTime = oldestAttempt.add(windowDuration);
    final remaining = unlockTime.difference(DateTime.now());
    
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
```

## 性能优化

### 令牌缓存策略
```dart
class TokenCache {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  
  static Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
      prefs.setString(_tokenExpiryKey, expiresAt.toIso8601String()),
    ]);
  }
  
  static Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    
    if (expiryString == null) return false;
    
    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isBefore(expiry);
  }
  
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_tokenExpiryKey),
    ]);
  }
}
```

## 使用最佳实践

### 认证流程集成
```dart
class AuthIntegrationExample {
  late final AuthService _authService;
  late final StreamSubscription _authSubscription;
  
  void initializeAuth() {
    _authService = AuthService.instance;
    
    // 监听认证状态变化
    _authSubscription = _authService.authStateStream.listen(_handleAuthStateChange);
    
    // 检查本地存储的会话
    _checkStoredSession();
  }
  
  void _handleAuthStateChange(AuthState state) {
    switch (state) {
      case AuthState.authenticated:
        _onUserAuthenticated();
        break;
      case AuthState.unauthenticated:
        _onUserUnauthenticated();
        break;
      case AuthState.sessionExpired:
        _onSessionExpired();
        break;
      // ... 处理其他状态
    }
  }
  
  Future<void> _checkStoredSession() async {
    if (await TokenCache.hasValidToken()) {
      final result = await _authService.validateSession();
      if (!result.isSuccess) {
        await TokenCache.clearTokens();
      }
    }
  }
  
  void dispose() {
    _authSubscription.cancel();
  }
}
```

### 权限装饰器
```dart
class PermissionDecorator {
  static Widget requirePermission({
    required String permission,
    required Widget child,
    Widget? fallback,
  }) {
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.authStateStream,
      builder: (context, snapshot) {
        if (AuthService.instance.hasPermission(permission)) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
  
  static Widget requireRole({
    required UserRole role,
    required Widget child,
    Widget? fallback,
  }) {
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.authStateStream,
      builder: (context, snapshot) {
        if (AuthService.instance.hasRolePermission(role)) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}
```

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 完整的认证服务接口定义
  - 基础认证和用户注册
  - 访客模式和用户转换
  - 双因子认证支持
  - 会话管理和权限验证
  - 设备管理和安全事件
  - 错误处理和重试机制
  - 性能优化和最佳实践 