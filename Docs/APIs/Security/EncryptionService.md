# EncryptionService API 文档

## 概述

EncryptionService是桌宠应用的核心加密服务，提供基础的数据加密、解密、哈希和密钥管理功能。它确保敏感数据的安全存储和传输，支持AES加密算法和PBKDF2密钥派生，是应用安全架构的重要组成部分。

- **主要功能**: 对称加密、哈希算法、密钥派生、安全随机数生成
- **设计模式**: 工厂模式 + 策略模式
- **安全标准**: AES-256-GCM/CBC, SHA-256/512, PBKDF2
- **位置**: `lib/core/services/security/encryption_service.dart`

## 核心枚举定义

### EncryptionAlgorithm 枚举
```dart
enum EncryptionAlgorithm {
  aes256Gcm,        // AES-256-GCM
  aes256Cbc,        // AES-256-CBC
  chacha20Poly1305, // ChaCha20-Poly1305
}
```

### KeyDerivationAlgorithm 枚举
```dart
enum KeyDerivationAlgorithm {
  pbkdf2,  // PBKDF2
  argon2,  // Argon2（基础版本未实现）
  scrypt,  // Scrypt（基础版本未实现）
}
```

## 核心类定义

### EncryptionResult 类
```dart
class EncryptionResult {
  final Uint8List encryptedData;              // 加密后的数据
  final Uint8List salt;                       // 盐值
  final Uint8List iv;                         // 初始化向量
  final EncryptionAlgorithm algorithm;        // 使用的算法
  final KeyDerivationAlgorithm keyDerivation; // 密钥派生算法
  final Map<String, dynamic> metadata;        // 加密元数据
  
  // 转换为Base64编码
  String toBase64();
  
  // 从Base64字符串解析
  static EncryptionResult fromBase64(String encodedData);
}
```

### EncryptionException 类
```dart
class EncryptionException implements Exception {
  final String message;        // 错误消息
  final dynamic cause;         // 原因
  final StackTrace? stackTrace; // 堆栈跟踪
}
```

### KeyDerivationConfig 类
```dart
class KeyDerivationConfig {
  final KeyDerivationAlgorithm algorithm; // 算法类型
  final int iterations;                   // 迭代次数
  final int keyLength;                    // 密钥长度
  final int saltLength;                   // 盐值长度
  final Map<String, dynamic> parameters;  // 额外参数
  
  // 预定义配置
  factory KeyDerivationConfig.pbkdf2({int iterations = 100000, int keyLength = 32, int saltLength = 16});
  factory KeyDerivationConfig.secure();  // 安全配置
  factory KeyDerivationConfig.fast();    // 快速配置
}
```

### EncryptionConfig 类
```dart
class EncryptionConfig {
  final EncryptionAlgorithm algorithm;         // 加密算法
  final KeyDerivationConfig keyDerivation;    // 密钥派生配置
  final int ivLength;                          // IV长度
  final Map<String, dynamic> parameters;       // 额外参数
  
  // 预定义配置
  factory EncryptionConfig.aes256Gcm({KeyDerivationConfig? keyDerivation});
  factory EncryptionConfig.aes256Cbc({KeyDerivationConfig? keyDerivation});
  factory EncryptionConfig.secure();  // 安全配置
  factory EncryptionConfig.fast();    // 快速配置
}
```

## 核心服务类

### EncryptionService 主类
```dart
class EncryptionService {
  final EncryptionConfig _config;
  
  EncryptionService({EncryptionConfig? config});
}
```

## 主要方法详解

### 字符串加密解密

#### `encryptString`
- **描述**: 加密字符串数据
- **签名**: `Future<String> encryptString(String plaintext, String password)`
- **参数**:
  - `plaintext`: 要加密的明文字符串
  - `password`: 用于派生密钥的密码
- **返回值**: Base64编码的加密结果
- **示例**:
```dart
final encryptionService = EncryptionService();
final encrypted = await encryptionService.encryptString('敏感数据', 'myPassword123');
print('加密结果: $encrypted');
```

#### `decryptString`
- **描述**: 解密字符串数据
- **签名**: `Future<String> decryptString(String encryptedData, String password)`
- **参数**:
  - `encryptedData`: Base64编码的加密数据
  - `password`: 用于派生密钥的密码
- **返回值**: 解密后的明文字符串
- **示例**:
```dart
final decrypted = await encryptionService.decryptString(encrypted, 'myPassword123');
print('解密结果: $decrypted');
```

### 字节数组加密解密

#### `encryptBytes`
- **描述**: 加密字节数组
- **签名**: `Future<EncryptionResult> encryptBytes(Uint8List plaintext, String password)`
- **参数**:
  - `plaintext`: 要加密的字节数组
  - `password`: 用于派生密钥的密码
- **返回值**: EncryptionResult对象
- **示例**:
```dart
final data = Uint8List.fromList([1, 2, 3, 4, 5]);
final result = await encryptionService.encryptBytes(data, 'myPassword123');
print('加密算法: ${result.algorithm}');
print('盐值长度: ${result.salt.length}');
```

#### `decryptBytes`
- **描述**: 解密字节数组
- **签名**: `Future<Uint8List> decryptBytes(EncryptionResult result, String password)`
- **参数**:
  - `result`: EncryptionResult对象
  - `password`: 用于派生密钥的密码
- **返回值**: 解密后的字节数组
- **示例**:
```dart
final decryptedData = await encryptionService.decryptBytes(result, 'myPassword123');
print('解密数据: ${decryptedData.toList()}');
```

## 辅助服务类

### SecureRandomGenerator 随机数生成器
```dart
class SecureRandomGenerator {
  // 生成安全随机字节
  static Uint8List generateBytes(int length);
  
  // 生成安全随机字符串
  static String generateString(int length, {String chars});
  
  // 生成随机密码
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  });
  
  // 生成随机盐值
  static Uint8List generateSalt(int length);
  
  // 生成随机IV
  static Uint8List generateIV(int length);
}
```

#### 使用示例
```dart
// 生成安全密码
final password = SecureRandomGenerator.generatePassword(
  length: 16,
  includeSymbols: true,
);

// 生成随机盐值
final salt = SecureRandomGenerator.generateSalt(32);

// 生成随机字符串
final randomString = SecureRandomGenerator.generateString(10);
```

### KeyDerivationService 密钥派生服务
```dart
class KeyDerivationService {
  // PBKDF2密钥派生
  static Uint8List deriveKeyPBKDF2({
    required String password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  });
  
  // 通用密钥派生
  static Uint8List deriveKey({
    required String password,
    required Uint8List salt,
    required KeyDerivationConfig config,
  });
}
```

#### 使用示例
```dart
// PBKDF2密钥派生
final password = 'userPassword123';
final salt = SecureRandomGenerator.generateSalt(16);
final key = KeyDerivationService.deriveKeyPBKDF2(
  password: password,
  salt: salt,
  iterations: 100000,
  keyLength: 32,
);

// 使用配置的密钥派生
final config = KeyDerivationConfig.secure();
final key2 = KeyDerivationService.deriveKey(
  password: password,
  salt: salt,
  config: config,
);
```

### HashingService 哈希服务
```dart
class HashingService {
  // SHA-256哈希
  static String sha256Hash(String input);
  
  // SHA-512哈希
  static String sha512Hash(String input);
  
  // HMAC-SHA256
  static String hmacSha256(String message, String key);
  
  // HMAC-SHA512
  static String hmacSha512(String message, String key);
  
  // 生成带盐的密码哈希
  static String hashPasswordWithSalt(String password, [String? salt]);
  
  // 验证带盐的密码哈希
  static bool verifyPasswordWithSalt(String password, String storedHash);
  
  // 验证密码哈希
  static bool verifyPassword(String password, String hashedPassword);
}
```

#### 哈希使用示例
```dart
// 基础哈希
final hash = HashingService.sha256Hash('Hello World');
print('SHA-256: $hash');

// 密码哈希（带盐）
final passwordHash = HashingService.hashPasswordWithSalt('userPassword123');
print('密码哈希: $passwordHash');

// 密码验证
final isValid = HashingService.verifyPasswordWithSalt('userPassword123', passwordHash);
print('密码验证: $isValid');

// HMAC
final hmac = HashingService.hmacSha256('message', 'secret-key');
print('HMAC-SHA256: $hmac');
```

## 配置与优化

### 预定义配置

#### 安全配置
```dart
// 高安全性配置（推荐生产环境）
final secureConfig = EncryptionConfig.secure();
final secureService = EncryptionService(config: secureConfig);

// 自定义安全配置
final customConfig = EncryptionConfig(
  algorithm: EncryptionAlgorithm.aes256Gcm,
  keyDerivation: KeyDerivationConfig(
    algorithm: KeyDerivationAlgorithm.pbkdf2,
    iterations: 200000,  // 更高的迭代次数
    keyLength: 32,
    saltLength: 32,
  ),
  ivLength: 12,
);
```

#### 快速配置
```dart
// 开发/测试环境快速配置
final fastConfig = EncryptionConfig.fast();
final fastService = EncryptionService(config: fastConfig);
```

### 性能考虑

#### 迭代次数选择
- **开发/测试**: 10,000次迭代
- **一般应用**: 100,000次迭代  
- **高安全应用**: 200,000+次迭代

#### 算法选择
- **AES-256-GCM**: 推荐，提供加密+认证
- **AES-256-CBC**: 传统模式，需要额外认证
- **ChaCha20-Poly1305**: 未来考虑，高性能

## 错误处理

### 常见异常
```dart
try {
  final encrypted = await encryptionService.encryptString('data', 'password');
} on EncryptionException catch (e) {
  switch (e.message) {
    case 'PBKDF2 key derivation failed':
      // 密钥派生失败
      break;
    case 'String encryption failed':
      // 字符串加密失败
      break;
    case 'Failed to parse encrypted data':
      // 解析加密数据失败
      break;
    default:
      // 其他加密错误
      break;
  }
}
```

## 使用最佳实践

### 密码管理
```dart
// 密码强度验证
bool isStrongPassword(String password) {
  return password.length >= 8 &&
         password.contains(RegExp(r'[A-Z]')) &&
         password.contains(RegExp(r'[a-z]')) &&
         password.contains(RegExp(r'[0-9]')) &&
         password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
}

// 安全密码生成
final strongPassword = SecureRandomGenerator.generatePassword(
  length: 16,
  includeSymbols: true,
);
```

### 数据加密
```dart
// 用户敏感数据加密
class UserDataEncryption {
  static final _service = EncryptionService(config: EncryptionConfig.secure());
  
  static Future<String> encryptUserData(String data, String userPassword) async {
    return await _service.encryptString(data, userPassword);
  }
  
  static Future<String> decryptUserData(String encryptedData, String userPassword) async {
    return await _service.decryptString(encryptedData, userPassword);
  }
}

// 使用示例
final userData = '{"profile": {"name": "Alice"}}';
final userPassword = 'userSecretPassword';

final encrypted = await UserDataEncryption.encryptUserData(userData, userPassword);
final decrypted = await UserDataEncryption.decryptUserData(encrypted, userPassword);
```

### 文件加密
```dart
// 文件加密工具
class FileEncryption {
  static Future<void> encryptFile(String filePath, String outputPath, String password) async {
    final file = File(filePath);
    final data = await file.readAsBytes();
    
    final service = EncryptionService();
    final result = await service.encryptBytes(data, password);
    
    final outputFile = File(outputPath);
    await outputFile.writeAsString(result.toBase64());
  }
  
  static Future<void> decryptFile(String encryptedFilePath, String outputPath, String password) async {
    final file = File(encryptedFilePath);
    final base64Data = await file.readAsString();
    
    final result = EncryptionResult.fromBase64(base64Data);
    final service = EncryptionService();
    final decryptedData = await service.decryptBytes(result, password);
    
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(decryptedData);
  }
}
```

## 安全注意事项

1. **密码处理**: 永远不要在日志中记录明文密码
2. **盐值管理**: 每个加密操作使用不同的随机盐值
3. **密钥派生**: 使用足够的迭代次数防止暴力破解
4. **内存安全**: 加密操作后及时清理敏感数据
5. **算法选择**: 优先使用带认证的加密算法（如AES-GCM）

## 版本历史

- **v1.0.0** (2025-06-25): Phase 1初始实现
  - 基础AES加密支持
  - PBKDF2密钥派生
  - SHA系列哈希算法
  - 安全随机数生成
  - 配置化加密服务 