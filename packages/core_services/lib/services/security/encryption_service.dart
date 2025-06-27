// 安全工具 - 提供本地数据加密解密功能，保护敏感信息
// 
// Author: Ignorant-lu
// Date created: 2025/06/25
// Description: 为安全架构提供数据加密和隐私保护服务

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// 加密算法类型枚举
enum EncryptionAlgorithm {
  /// AES-256-GCM
  aes256Gcm,
  /// AES-256-CBC
  aes256Cbc,
  /// ChaCha20-Poly1305
  chacha20Poly1305,
}

/// 密钥派生算法枚举
enum KeyDerivationAlgorithm {
  /// PBKDF2
  pbkdf2,
  /// Argon2
  argon2,
  /// Scrypt
  scrypt,
}

/// 加密结果包装器
class EncryptionResult {
  final Uint8List encryptedData;
  final Uint8List salt;
  final Uint8List iv;
  final EncryptionAlgorithm algorithm;
  final KeyDerivationAlgorithm keyDerivation;
  final Map<String, dynamic> metadata;

  const EncryptionResult({
    required this.encryptedData,
    required this.salt,
    required this.iv,
    required this.algorithm,
    required this.keyDerivation,
    this.metadata = const {},
  });

  /// 转换为Base64编码的字符串
  String toBase64() {
    final combined = <int>[];
    
    // 版本标识符 (1 byte)
    combined.add(1);
    
    // 算法标识符 (1 byte)
    combined.add(algorithm.index);
    
    // 密钥派生算法标识符 (1 byte)
    combined.add(keyDerivation.index);
    
    // Salt长度 (1 byte) + Salt
    combined.add(salt.length);
    combined.addAll(salt);
    
    // IV长度 (1 byte) + IV
    combined.add(iv.length);
    combined.addAll(iv);
    
    // 加密数据长度 (4 bytes) + 加密数据
    final dataLength = encryptedData.length;
    combined.addAll([
      (dataLength >> 24) & 0xFF,
      (dataLength >> 16) & 0xFF,
      (dataLength >> 8) & 0xFF,
      dataLength & 0xFF,
    ]);
    combined.addAll(encryptedData);
    
    return base64Encode(combined);
  }

  /// 从Base64字符串解析
  static EncryptionResult fromBase64(String encodedData) {
    try {
      final bytes = base64Decode(encodedData);
      var offset = 0;
      
      // 验证版本
      final version = bytes[offset++];
      if (version != 1) {
        throw EncryptionException('Unsupported encryption format version: $version');
      }
      
      // 解析算法
      final algorithmIndex = bytes[offset++];
      final algorithm = EncryptionAlgorithm.values[algorithmIndex];
      
      // 解析密钥派生算法
      final keyDerivationIndex = bytes[offset++];
      final keyDerivation = KeyDerivationAlgorithm.values[keyDerivationIndex];
      
      // 解析Salt
      final saltLength = bytes[offset++];
      final salt = Uint8List.fromList(bytes.sublist(offset, offset + saltLength));
      offset += saltLength;
      
      // 解析IV
      final ivLength = bytes[offset++];
      final iv = Uint8List.fromList(bytes.sublist(offset, offset + ivLength));
      offset += ivLength;
      
      // 解析加密数据长度
      final dataLength = (bytes[offset] << 24) |
          (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];
      offset += 4;
      
      // 解析加密数据
      final encryptedData = Uint8List.fromList(bytes.sublist(offset, offset + dataLength));
      
      return EncryptionResult(
        encryptedData: encryptedData,
        salt: salt,
        iv: iv,
        algorithm: algorithm,
        keyDerivation: keyDerivation,
      );
    } catch (e) {
      throw EncryptionException('Failed to parse encrypted data: $e');
    }
  }

  @override
  String toString() {
    return 'EncryptionResult(algorithm: $algorithm, keyDerivation: $keyDerivation, '
        'saltLength: ${salt.length}, ivLength: ${iv.length}, dataLength: ${encryptedData.length})';
  }
}

/// 加密异常类
class EncryptionException implements Exception {
  final String message;
  final dynamic cause;
  final StackTrace? stackTrace;

  const EncryptionException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => 'EncryptionException: $message';
}

/// 密钥派生配置
class KeyDerivationConfig {
  final KeyDerivationAlgorithm algorithm;
  final int iterations;
  final int keyLength;
  final int saltLength;
  final Map<String, dynamic> parameters;

  const KeyDerivationConfig({
    this.algorithm = KeyDerivationAlgorithm.pbkdf2,
    this.iterations = 100000,
    this.keyLength = 32,
    this.saltLength = 16,
    this.parameters = const {},
  });

  /// 创建PBKDF2配置
  factory KeyDerivationConfig.pbkdf2({
    int iterations = 100000,
    int keyLength = 32,
    int saltLength = 16,
  }) {
    return KeyDerivationConfig(
      algorithm: KeyDerivationAlgorithm.pbkdf2,
      iterations: iterations,
      keyLength: keyLength,
      saltLength: saltLength,
    );
  }

  /// 创建安全的默认配置
  factory KeyDerivationConfig.secure() {
    return KeyDerivationConfig(
      algorithm: KeyDerivationAlgorithm.pbkdf2,
      iterations: 200000,
      keyLength: 32,
      saltLength: 32,
    );
  }

  /// 创建快速配置（用于开发/测试）
  factory KeyDerivationConfig.fast() {
    return KeyDerivationConfig(
      algorithm: KeyDerivationAlgorithm.pbkdf2,
      iterations: 10000,
      keyLength: 32,
      saltLength: 16,
    );
  }
}

/// 加密配置
class EncryptionConfig {
  final EncryptionAlgorithm algorithm;
  final KeyDerivationConfig keyDerivation;
  final int ivLength;
  final Map<String, dynamic> parameters;

  const EncryptionConfig({
    this.algorithm = EncryptionAlgorithm.aes256Gcm,
    this.keyDerivation = const KeyDerivationConfig(),
    this.ivLength = 12,
    this.parameters = const {},
  });

  /// 创建AES-256-GCM配置
  factory EncryptionConfig.aes256Gcm({
    KeyDerivationConfig? keyDerivation,
  }) {
    return EncryptionConfig(
      algorithm: EncryptionAlgorithm.aes256Gcm,
      keyDerivation: keyDerivation ?? const KeyDerivationConfig(),
      ivLength: 12,
    );
  }

  /// 创建AES-256-CBC配置
  factory EncryptionConfig.aes256Cbc({
    KeyDerivationConfig? keyDerivation,
  }) {
    return EncryptionConfig(
      algorithm: EncryptionAlgorithm.aes256Cbc,
      keyDerivation: keyDerivation ?? const KeyDerivationConfig(),
      ivLength: 16,
    );
  }

  /// 创建安全的默认配置
  factory EncryptionConfig.secure() {
    return EncryptionConfig(
      algorithm: EncryptionAlgorithm.aes256Gcm,
      keyDerivation: KeyDerivationConfig.secure(),
      ivLength: 12,
    );
  }

  /// 创建快速配置（用于开发/测试）
  factory EncryptionConfig.fast() {
    return EncryptionConfig(
      algorithm: EncryptionAlgorithm.aes256Gcm,
      keyDerivation: KeyDerivationConfig.fast(),
      ivLength: 12,
    );
  }
}

/// 安全随机数生成器
class SecureRandomGenerator {
  static final Random _random = Random.secure();

  /// 生成安全随机字节
  static Uint8List generateBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// 生成安全随机字符串
  static String generateString(int length, {String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'}) {
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
    );
  }

  /// 生成随机密码
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    final chars = StringBuffer();
    
    if (includeUppercase) chars.write('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    if (includeLowercase) chars.write('abcdefghijklmnopqrstuvwxyz');
    if (includeNumbers) chars.write('0123456789');
    if (includeSymbols) chars.write('!@#\$%^&*()-_=+[]{}|;:,.<>?');
    
    if (chars.isEmpty) {
      throw ArgumentError('At least one character type must be included');
    }
    
    return generateString(length, chars: chars.toString());
  }

  /// 生成随机盐值
  static Uint8List generateSalt(int length) => generateBytes(length);

  /// 生成随机IV
  static Uint8List generateIV(int length) => generateBytes(length);
}

/// 密钥派生服务
class KeyDerivationService {
  /// PBKDF2密钥派生
  static Uint8List deriveKeyPBKDF2({
    required String password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) {
    try {
      // 使用HMAC-SHA256进行PBKDF2
      final passwordBytes = utf8.encode(password);
      final hmac = Hmac(sha256, passwordBytes);
      
      final blocks = <int>[];
      final blockSize = 32; // SHA256 output size
      final blockCount = (keyLength + blockSize - 1) ~/ blockSize;
      
      for (int i = 1; i <= blockCount; i++) {
        final block = _pbkdf2Block(hmac, salt, iterations, i);
        blocks.addAll(block);
      }
      
      return Uint8List.fromList(blocks.take(keyLength).toList());
    } catch (e) {
      throw EncryptionException('PBKDF2 key derivation failed: $e');
    }
  }

  /// PBKDF2单个块计算
  static List<int> _pbkdf2Block(Hmac hmac, Uint8List salt, int iterations, int blockIndex) {
    // U1 = PRF(password, salt || blockIndex)
    final input = <int>[];
    input.addAll(salt);
    input.addAll([
      (blockIndex >> 24) & 0xFF,
      (blockIndex >> 16) & 0xFF,
      (blockIndex >> 8) & 0xFF,
      blockIndex & 0xFF,
    ]);
    
    var u = hmac.convert(input).bytes;
    final result = List<int>.from(u);
    
    // Un = PRF(password, Un-1)
    for (int i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    
    return result;
  }

  /// 通用密钥派生
  static Uint8List deriveKey({
    required String password,
    required Uint8List salt,
    required KeyDerivationConfig config,
  }) {
    switch (config.algorithm) {
      case KeyDerivationAlgorithm.pbkdf2:
        return deriveKeyPBKDF2(
          password: password,
          salt: salt,
          iterations: config.iterations,
          keyLength: config.keyLength,
        );
      case KeyDerivationAlgorithm.argon2:
        // 在实际实现中，这里应该使用Argon2库
        throw EncryptionException('Argon2 not implemented in this basic version');
      case KeyDerivationAlgorithm.scrypt:
        // 在实际实现中，这里应该使用Scrypt库
        throw EncryptionException('Scrypt not implemented in this basic version');
    }
  }
}

/// 哈希服务
class HashingService {
  /// SHA-256哈希
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// SHA-512哈希
  static String sha512Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  /// HMAC-SHA256
  static String hmacSha256(String message, String key) {
    final keyBytes = utf8.encode(key);
    final messageBytes = utf8.encode(message);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(messageBytes);
    return digest.toString();
  }

  /// HMAC-SHA512
  static String hmacSha512(String message, String key) {
    final keyBytes = utf8.encode(key);
    final messageBytes = utf8.encode(message);
    final hmac = Hmac(sha512, keyBytes);
    final digest = hmac.convert(messageBytes);
    return digest.toString();
  }

  /// 验证密码哈希
  static bool verifyPassword(String password, String hashedPassword) {
    final computedHash = sha256Hash(password);
    return computedHash == hashedPassword;
  }

  /// 生成带盐的密码哈希
  static String hashPasswordWithSalt(String password, [String? salt]) {
    salt ??= SecureRandomGenerator.generateString(16);
    final saltedPassword = '$password$salt';
    final hash = sha256Hash(saltedPassword);
    return '$salt:$hash';
  }

  /// 验证带盐的密码哈希
  static bool verifyPasswordWithSalt(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;
      
      final salt = parts[0];
      final hash = parts[1];
      
      final saltedPassword = '$password$salt';
      final computedHash = sha256Hash(saltedPassword);
      
      return computedHash == hash;
    } catch (e) {
      return false;
    }
  }
}

/// 加密服务主类
class EncryptionService {
  final EncryptionConfig _config;

  EncryptionService({EncryptionConfig? config})
      : _config = config ?? EncryptionConfig.secure();

  // ========== 字符串加密 ==========

  /// 加密字符串
  Future<String> encryptString(String plaintext, String password) async {
    try {
      final plaintextBytes = utf8.encode(plaintext);
      final result = await encryptBytes(plaintextBytes, password);
      return result.toBase64();
    } catch (e) {
      throw EncryptionException('String encryption failed: $e');
    }
  }

  /// 解密字符串
  Future<String> decryptString(String encryptedData, String password) async {
    try {
      final result = EncryptionResult.fromBase64(encryptedData);
      final decryptedBytes = await decryptBytes(result, password);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw EncryptionException('String decryption failed: $e');
    }
  }

  // ========== 字节数组加密 ==========

  /// 加密字节数组
  Future<EncryptionResult> encryptBytes(Uint8List plaintext, String password) async {
    try {
      // 生成随机盐值和IV
      final salt = SecureRandomGenerator.generateSalt(_config.keyDerivation.saltLength);
      final iv = SecureRandomGenerator.generateIV(_config.ivLength);

      // 派生密钥
      final key = KeyDerivationService.deriveKey(
        password: password,
        salt: salt,
        config: _config.keyDerivation,
      );

      // 执行加密
      final encryptedData = await _encryptWithAlgorithm(plaintext, key, iv, _config.algorithm);

      return EncryptionResult(
        encryptedData: encryptedData,
        salt: salt,
        iv: iv,
        algorithm: _config.algorithm,
        keyDerivation: _config.keyDerivation.algorithm,
      );
    } catch (e) {
      throw EncryptionException('Bytes encryption failed: $e');
    }
  }

  /// 解密字节数组
  Future<Uint8List> decryptBytes(EncryptionResult encryptedResult, String password) async {
    try {
      // 重新派生密钥
      final keyConfig = KeyDerivationConfig(
        algorithm: encryptedResult.keyDerivation,
        iterations: _config.keyDerivation.iterations,
        keyLength: _config.keyDerivation.keyLength,
        saltLength: encryptedResult.salt.length,
      );

      final key = KeyDerivationService.deriveKey(
        password: password,
        salt: encryptedResult.salt,
        config: keyConfig,
      );

      // 执行解密
      return await _decryptWithAlgorithm(
        encryptedResult.encryptedData,
        key,
        encryptedResult.iv,
        encryptedResult.algorithm,
      );
    } catch (e) {
      throw EncryptionException('Bytes decryption failed: $e');
    }
  }

  // ========== JSON加密 ==========

  /// 加密JSON对象
  Future<String> encryptJson(Map<String, dynamic> jsonData, String password) async {
    try {
      final jsonString = jsonEncode(jsonData);
      return await encryptString(jsonString, password);
    } catch (e) {
      throw EncryptionException('JSON encryption failed: $e');
    }
  }

  /// 解密JSON对象
  Future<Map<String, dynamic>> decryptJson(String encryptedData, String password) async {
    try {
      final jsonString = await decryptString(encryptedData, password);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw EncryptionException('JSON decryption failed: $e');
    }
  }

  // ========== 文件加密 ==========

  /// 加密文件数据
  Future<EncryptionResult> encryptFileData(Uint8List fileData, String password) async {
    return await encryptBytes(fileData, password);
  }

  /// 解密文件数据
  Future<Uint8List> decryptFileData(EncryptionResult encryptedResult, String password) async {
    return await decryptBytes(encryptedResult, password);
  }

  // ========== 密码管理 ==========

  /// 生成安全密码
  String generateSecurePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    return SecureRandomGenerator.generatePassword(
      length: length,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSymbols: includeSymbols,
    );
  }

  /// 哈希密码
  String hashPassword(String password) {
    return HashingService.hashPasswordWithSalt(password);
  }

  /// 验证密码
  bool verifyPassword(String password, String hashedPassword) {
    return HashingService.verifyPasswordWithSalt(password, hashedPassword);
  }

  // ========== 数据完整性 ==========

  /// 计算数据校验和
  String calculateChecksum(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  /// 验证数据完整性
  bool verifyDataIntegrity(Uint8List data, String expectedChecksum) {
    final actualChecksum = calculateChecksum(data);
    return actualChecksum == expectedChecksum;
  }

  /// 生成数字签名（简化版）
  String signData(String data, String privateKey) {
    return HashingService.hmacSha256(data, privateKey);
  }

  /// 验证数字签名（简化版）
  bool verifySignature(String data, String signature, String publicKey) {
    final expectedSignature = HashingService.hmacSha256(data, publicKey);
    return signature == expectedSignature;
  }

  // ========== 内部加密算法实现 ==========

  /// 使用指定算法加密数据
  Future<Uint8List> _encryptWithAlgorithm(
    Uint8List plaintext,
    Uint8List key,
    Uint8List iv,
    EncryptionAlgorithm algorithm,
  ) async {
    switch (algorithm) {
      case EncryptionAlgorithm.aes256Gcm:
        return _encryptAES256GCM(plaintext, key, iv);
      case EncryptionAlgorithm.aes256Cbc:
        return _encryptAES256CBC(plaintext, key, iv);
      case EncryptionAlgorithm.chacha20Poly1305:
        throw EncryptionException('ChaCha20-Poly1305 not implemented in this basic version');
    }
  }

  /// 使用指定算法解密数据
  Future<Uint8List> _decryptWithAlgorithm(
    Uint8List ciphertext,
    Uint8List key,
    Uint8List iv,
    EncryptionAlgorithm algorithm,
  ) async {
    switch (algorithm) {
      case EncryptionAlgorithm.aes256Gcm:
        return _decryptAES256GCM(ciphertext, key, iv);
      case EncryptionAlgorithm.aes256Cbc:
        return _decryptAES256CBC(ciphertext, key, iv);
      case EncryptionAlgorithm.chacha20Poly1305:
        throw EncryptionException('ChaCha20-Poly1305 not implemented in this basic version');
    }
  }

  /// AES-256-GCM加密（简化实现）
  Uint8List _encryptAES256GCM(Uint8List plaintext, Uint8List key, Uint8List iv) {
    // 注意：这是一个简化的实现示例
    // 在实际应用中，应该使用专业的加密库（如pointycastle）
    throw EncryptionException('AES-256-GCM requires a proper cryptographic library');
  }

  /// AES-256-GCM解密（简化实现）
  Uint8List _decryptAES256GCM(Uint8List ciphertext, Uint8List key, Uint8List iv) {
    // 注意：这是一个简化的实现示例
    // 在实际应用中，应该使用专业的加密库（如pointycastle）
    throw EncryptionException('AES-256-GCM requires a proper cryptographic library');
  }

  /// AES-256-CBC加密（简化实现）
  Uint8List _encryptAES256CBC(Uint8List plaintext, Uint8List key, Uint8List iv) {
    // 注意：这是一个简化的实现示例
    // 在实际应用中，应该使用专业的加密库（如pointycastle）
    throw EncryptionException('AES-256-CBC requires a proper cryptographic library');
  }

  /// AES-256-CBC解密（简化实现）
  Uint8List _decryptAES256CBC(Uint8List ciphertext, Uint8List key, Uint8List iv) {
    // 注意：这是一个简化的实现示例
    // 在实际应用中，应该使用专业的加密库（如pointycastle）
    throw EncryptionException('AES-256-CBC requires a proper cryptographic library');
  }

  // ========== 实用方法 ==========

  /// 获取当前配置信息
  Map<String, dynamic> getConfigInfo() {
    return {
      'algorithm': _config.algorithm.toString(),
      'keyDerivation': _config.keyDerivation.algorithm.toString(),
      'iterations': _config.keyDerivation.iterations,
      'keyLength': _config.keyDerivation.keyLength,
      'saltLength': _config.keyDerivation.saltLength,
      'ivLength': _config.ivLength,
    };
  }

  /// 测试加密解密功能
  Future<bool> testEncryption({String? testData, String? password}) async {
    try {
      final data = testData ?? 'Test encryption data';
      final pwd = password ?? 'test_password_123';
      
      final encrypted = await encryptString(data, pwd);
      final decrypted = await decryptString(encrypted, pwd);
      
      return data == decrypted;
    } catch (e) {
      return false;
    }
  }
}

/// 加密服务工厂
class EncryptionServiceFactory {
  static EncryptionService? _instance;

  /// 创建加密服务
  static EncryptionService create({EncryptionConfig? config}) {
    return EncryptionService(config: config);
  }

  /// 获取单例实例
  static EncryptionService getInstance({EncryptionConfig? config}) {
    _instance ??= EncryptionService(config: config);
    return _instance!;
  }

  /// 重置单例
  static void resetInstance() {
    _instance = null;
  }

  /// 创建安全配置的服务
  static EncryptionService createSecure() {
    return create(config: EncryptionConfig.secure());
  }

  /// 创建快速配置的服务（用于开发/测试）
  static EncryptionService createFast() {
    return create(config: EncryptionConfig.fast());
  }
}

/// 密钥管理器
class KeyManager {
  final Map<String, String> _keys = {};
  final EncryptionService _encryptionService;

  KeyManager({EncryptionService? encryptionService})
      : _encryptionService = encryptionService ?? EncryptionServiceFactory.createSecure();

  /// 存储密钥
  void storeKey(String keyId, String key) {
    _keys[keyId] = key;
  }

  /// 获取密钥
  String? getKey(String keyId) {
    return _keys[keyId];
  }

  /// 删除密钥
  void removeKey(String keyId) {
    _keys.remove(keyId);
  }

  /// 生成新密钥
  String generateKey(String keyId, {int length = 32}) {
    final key = SecureRandomGenerator.generateString(length);
    storeKey(keyId, key);
    return key;
  }

  /// 清除所有密钥
  void clearKeys() {
    _keys.clear();
  }

  /// 获取密钥列表
  List<String> getKeyIds() {
    return _keys.keys.toList();
  }

  /// 密钥是否存在
  bool hasKey(String keyId) {
    return _keys.containsKey(keyId);
  }

  /// 加密存储密钥
  Future<String> encryptAndStoreKey(String keyId, String key, String masterPassword) async {
    final encrypted = await _encryptionService.encryptString(key, masterPassword);
    _keys[keyId] = encrypted;
    return encrypted;
  }

  /// 解密获取密钥
  Future<String?> decryptAndGetKey(String keyId, String masterPassword) async {
    final encryptedKey = _keys[keyId];
    if (encryptedKey == null) return null;
    
    try {
      return await _encryptionService.decryptString(encryptedKey, masterPassword);
    } catch (e) {
      return null;
    }
  }
} 