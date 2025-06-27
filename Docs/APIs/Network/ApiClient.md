# ApiClient API 文档

## 概述

ApiClient是桌宠应用的核心网络客户端服务，基于Dio框架提供统一的HTTP/HTTPS通信接口。它支持JWT认证拦截器、请求重试机制、日志记录和错误处理，是应用与后端服务通信的核心组件。

- **主要功能**: HTTP请求、JWT认证管理、请求重试、错误处理、日志记录
- **设计模式**: 单例模式 + 拦截器模式 + 工厂模式
- **核心技术**: Dio + 自定义拦截器
- **位置**: `lib/core/services/network/api_client.dart`

## 核心配置类

### ApiConfig 配置类
```dart
class ApiConfig {
  final String baseUrl;                    // 基础URL
  final Duration connectTimeout;           // 连接超时
  final Duration receiveTimeout;           // 接收超时
  final Duration sendTimeout;              // 发送超时
  final Map<String, String> defaultHeaders; // 默认请求头
  final bool enableLogging;                // 是否启用日志
  final int maxRetries;                    // 最大重试次数
  final Duration retryDelay;               // 重试延迟
  final List<int> retryStatusCodes;        // 需要重试的状态码
  
  // 预定义配置
  factory ApiConfig.development({String? baseUrl});
  factory ApiConfig.production({required String baseUrl});
  factory ApiConfig.testing({String? baseUrl});
}
```

### ApiErrorType 枚举
```dart
enum ApiErrorType {
  networkError,        // 网络连接错误
  timeout,            // 请求超时
  unauthorized,       // 认证失败
  forbidden,          // 权限不足
  notFound,           // 资源不存在
  conflict,           // 请求冲突
  tooManyRequests,    // 请求频率过高
  serverError,        // 服务器错误
  badRequest,         // 请求格式错误
  cancelled,          // 取消请求
  parseError,         // 解析错误
  unknown,            // 未知错误
}
```

### ApiException 异常类
```dart
class ApiException implements Exception {
  final ApiErrorType type;                    // 错误类型
  final String message;                       // 错误消息
  final int? statusCode;                      // HTTP状态码
  final Map<String, dynamic>? responseData;   // 响应数据
  final DioException? originalError;          // 原始Dio错误
  final StackTrace? stackTrace;               // 堆栈跟踪
  
  // 工厂构造方法
  factory ApiException.fromDioException(DioException dioError);
  factory ApiException.networkError([String? message]);
  factory ApiException.unauthorized([String? message]);
  factory ApiException.serverError([String? message, int? statusCode]);
}
```

### ApiResponse 响应包装器
```dart
class ApiResponse<T> {
  final bool success;                    // 请求是否成功
  final T? data;                        // 响应数据
  final String? message;                // 响应消息
  final String? errorCode;              // 错误代码
  final Map<String, dynamic>? metadata; // 元数据
  final int? statusCode;                // HTTP状态码
  
  // 工厂构造方法
  factory ApiResponse.success(T data, {String? message, int? statusCode});
  factory ApiResponse.failure({required String message, String? errorCode, Map<String, dynamic>? metadata, int? statusCode});
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) dataParser);
}
```

## 核心拦截器

### JwtAuthInterceptor JWT认证拦截器
```dart
class JwtAuthInterceptor extends Interceptor {
  final IAuthService? authService;      // 认证服务
  final String authHeaderName;          // 认证头名称
  final String tokenPrefix;             // 令牌前缀
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler);
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler);
}
```

#### 功能特性
- **自动添加认证头**: 从AuthService获取当前用户令牌
- **令牌过期处理**: 401错误时自动尝试刷新令牌
- **请求追踪**: 为每个请求添加唯一ID
- **重试机制**: 令牌刷新成功后重试原请求

#### 使用示例
```dart
// 配置JWT拦截器
final authInterceptor = JwtAuthInterceptor(
  authService: AuthService.instance,
  authHeaderName: 'Authorization',
  tokenPrefix: 'Bearer',
);

// 添加到Dio实例
dio.interceptors.add(authInterceptor);
```

### RetryInterceptor 重试拦截器
```dart
class RetryInterceptor extends Interceptor {
  final int maxRetries;                           // 最大重试次数
  final Duration retryDelay;                      // 重试延迟
  final List<int> retryStatusCodes;               // 重试状态码
  final bool Function(DioException)? shouldRetry; // 自定义重试逻辑
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler);
}
```

#### 重试策略
- **网络错误**: 连接超时、接收超时、连接错误
- **服务器错误**: 502、503、504状态码
- **自定义逻辑**: 支持自定义重试判断函数
- **退避策略**: 指数退避延迟重试

#### 使用示例
```dart
// 配置重试拦截器
final retryInterceptor = RetryInterceptor(
  maxRetries: 3,
  retryDelay: Duration(milliseconds: 1000),
  retryStatusCodes: [502, 503, 504],
  shouldRetry: (error) {
    // 自定义重试逻辑
    return error.type == DioExceptionType.connectionTimeout;
  },
);

dio.interceptors.add(retryInterceptor);
```

### LoggingInterceptor 日志拦截器
```dart
class LoggingInterceptor extends Interceptor {
  final bool logRequests;      // 是否记录请求
  final bool logResponses;     // 是否记录响应
  final bool logErrors;        // 是否记录错误
  final bool logHeaders;       // 是否记录请求头
  final bool logRequestBody;   // 是否记录请求体
  final bool logResponseBody;  // 是否记录响应体
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler);
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler);
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler);
}
```

#### 日志功能
- **请求日志**: URL、方法、请求头、请求体
- **响应日志**: 状态码、响应头、响应体、耗时
- **错误日志**: 错误类型、错误消息、堆栈跟踪
- **格式化输出**: 结构化日志格式

## 错误处理机制

### DioException转换
```dart
// 从DioException创建ApiException
factory ApiException.fromDioException(DioException dioError) {
  ApiErrorType type;
  String message;
  int? statusCode = dioError.response?.statusCode;
  
  switch (dioError.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      type = ApiErrorType.timeout;
      message = '请求超时，请检查网络连接';
      break;
    case DioExceptionType.connectionError:
      type = ApiErrorType.networkError;
      message = '网络连接失败，请检查网络设置';
      break;
    case DioExceptionType.cancel:
      type = ApiErrorType.cancelled;
      message = '请求已取消';
      break;
    case DioExceptionType.badResponse:
      // 根据状态码细分错误类型
      switch (statusCode) {
        case 400:
          type = ApiErrorType.badRequest;
          break;
        case 401:
          type = ApiErrorType.unauthorized;
          break;
        case 403:
          type = ApiErrorType.forbidden;
          break;
        case 404:
          type = ApiErrorType.notFound;
          break;
        case 409:
          type = ApiErrorType.conflict;
          break;
        case 429:
          type = ApiErrorType.tooManyRequests;
          break;
        default:
          type = ApiErrorType.serverError;
      }
      break;
  }
  
  return ApiException(type: type, message: message, statusCode: statusCode);
}
```

### 统一错误处理
```dart
class ApiErrorHandler {
  static void handleApiError(ApiException error) {
    switch (error.type) {
      case ApiErrorType.networkError:
        showSnackBar('网络连接失败，请检查网络设置');
        break;
      case ApiErrorType.timeout:
        showSnackBar('请求超时，请重试');
        break;
      case ApiErrorType.unauthorized:
        // 跳转到登录页面
        navigateToLogin();
        break;
      case ApiErrorType.forbidden:
        showSnackBar('权限不足');
        break;
      case ApiErrorType.notFound:
        showSnackBar('请求的资源不存在');
        break;
      case ApiErrorType.serverError:
        showSnackBar('服务器错误，请稍后重试');
        break;
      default:
        showSnackBar('未知错误: ${error.message}');
    }
  }
}
```

## 使用示例

### 基础API客户端设置
```dart
class ApiClientService {
  static late Dio _dio;
  static late ApiConfig _config;
  
  static void initialize({required ApiConfig config}) {
    _config = config;
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: config.defaultHeaders,
    ));
    
    // 添加拦截器
    _setupInterceptors();
  }
  
  static void _setupInterceptors() {
    // JWT认证拦截器
    _dio.interceptors.add(JwtAuthInterceptor(
      authService: AuthService.instance,
    ));
    
    // 重试拦截器
    _dio.interceptors.add(RetryInterceptor(
      maxRetries: _config.maxRetries,
      retryDelay: _config.retryDelay,
      retryStatusCodes: _config.retryStatusCodes,
    ));
    
    // 日志拦截器（仅开发模式）
    if (_config.enableLogging) {
      _dio.interceptors.add(LoggingInterceptor(
        logRequests: true,
        logResponses: true,
        logErrors: true,
      ));
    }
  }
}
```

### API服务封装
```dart
class UserApiService {
  static final Dio _dio = ApiClientService._dio;
  
  // 获取用户信息
  static Future<ApiResponse<Map<String, dynamic>>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      final apiError = ApiException.fromDioException(e);
      throw apiError;
    }
  }
  
  // 更新用户信息
  static Future<ApiResponse<Map<String, dynamic>>> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/$userId', data: data);
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      final apiError = ApiException.fromDioException(e);
      throw apiError;
    }
  }
  
  // 上传头像
  static Future<ApiResponse<String>> uploadAvatar(String userId, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar.jpg',
        ),
      });
      
      final response = await _dio.post('/users/$userId/avatar', data: formData);
      return ApiResponse.success(response.data['avatarUrl']);
    } on DioException catch (e) {
      final apiError = ApiException.fromDioException(e);
      throw apiError;
    }
  }
}
```

### 错误处理使用
```dart
class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  Future<void> _loadUserProfile() async {
    try {
      setState(() => isLoading = true);
      
      final response = await UserApiService.getUserProfile('user123');
      
      setState(() {
        userProfile = response.data;
        isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() => isLoading = false);
      ApiErrorHandler.handleApiError(e);
    }
  }
  
  Future<void> _updateProfile(Map<String, dynamic> data) async {
    try {
      await UserApiService.updateUserProfile('user123', data);
      showSnackBar('更新成功');
      _loadUserProfile(); // 重新加载
    } on ApiException catch (e) {
      ApiErrorHandler.handleApiError(e);
    }
  }
}
```

## 配置最佳实践

### 环境配置
```dart
class ApiEnvironment {
  static ApiConfig getConfig() {
    if (kDebugMode) {
      return ApiConfig.development(
        baseUrl: 'http://localhost:8080/api',
      );
    } else if (kProfileMode) {
      return ApiConfig.testing(
        baseUrl: 'https://test-api.example.com/api',
      );
    } else {
      return ApiConfig.production(
        baseUrl: 'https://api.example.com/api',
      );
    }
  }
}

// 应用启动时初始化
void main() {
  ApiClientService.initialize(config: ApiEnvironment.getConfig());
  runApp(MyApp());
}
```

### 请求取消
```dart
class ApiRequestManager {
  static final Map<String, CancelToken> _tokens = {};
  
  static CancelToken createToken(String requestId) {
    final token = CancelToken();
    _tokens[requestId] = token;
    return token;
  }
  
  static void cancelRequest(String requestId) {
    final token = _tokens.remove(requestId);
    token?.cancel('Request cancelled by user');
  }
  
  static void clearTokens() {
    _tokens.values.forEach((token) => token.cancel());
    _tokens.clear();
  }
}

// 使用示例
final cancelToken = ApiRequestManager.createToken('getUserProfile');
try {
  final response = await _dio.get('/users/123', cancelToken: cancelToken);
} on DioException catch (e) {
  if (CancelToken.isCancel(e)) {
    print('请求已取消');
  }
}
```

## 性能优化

### 请求缓存
```dart
class ApiCache {
  static final Map<String, CachedResponse> _cache = {};
  
  static void cacheResponse(String key, Response response, Duration ttl) {
    _cache[key] = CachedResponse(
      response: response,
      expiresAt: DateTime.now().add(ttl),
    );
  }
  
  static Response? getCachedResponse(String key) {
    final cached = _cache[key];
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      return cached.response;
    }
    _cache.remove(key);
    return null;
  }
}

class CachedResponse {
  final Response response;
  final DateTime expiresAt;
  
  CachedResponse({required this.response, required this.expiresAt});
}
```

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 基于Dio的HTTP客户端
  - JWT认证拦截器
  - 请求重试机制
  - 统一错误处理
  - 日志记录功能
  - 配置化API管理 