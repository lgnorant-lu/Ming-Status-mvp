import 'package:flutter_test/flutter_test.dart';
import 'package:core_services/core_services.dart';

// 测试服务接口
abstract class TestService {
  String getValue();
}

// 测试服务实现
class TestServiceImpl implements TestService {
  final String value;
  
  TestServiceImpl(this.value);
  
  @override
  String getValue() => value;
}

void main() {
  group('ServiceLocator Tests', () {
    setUp(() async {
      // 重置ServiceLocator状态
      await serviceLocator.reset();
    });

    tearDown(() async {
      // 清理ServiceLocator状态
      await serviceLocator.reset();
    });

    test('should create singleton instance', () {
      final locator1 = ServiceLocator();
      final locator2 = ServiceLocator();
      expect(identical(locator1, locator2), isTrue);
    });

    test('should start uninitialized', () {
      expect(serviceLocator.isInitialized, isFalse); // reset后应该为false
    });

    test('should allow debug mode setting', () {
      expect(() => serviceLocator.setDebugMode(true), returnsNormally);
      expect(serviceLocator.debugMode, isTrue);
      
      serviceLocator.setDebugMode(false);
      expect(serviceLocator.debugMode, isFalse);
    });

    test('should track service status', () {
      final status = serviceLocator.getServiceStatus(TestService);
      // 初始状态应该是null（未注册）
      expect(status, isNull);
    });

    test('should get all service status', () {
      final allStatus = serviceLocator.getAllServiceStatus();
      expect(allStatus, isA<Map<Type, ServiceStatusInfo>>());
    });

    test('should check if service is registered', () {
      expect(serviceLocator.isRegistered<TestService>(), isFalse);
    });

    test('should throw when getting unregistered service', () {
      expect(
        () => serviceLocator.get<TestService>(),
        throwsA(isA<ServiceLocatorException>()),
      );
    });
  });

  group('ServiceLocatorException Tests', () {
    test('should create exception with all fields', () {
      const exception = ServiceLocatorException(
        message: 'Test error',
        serviceType: TestService,
        operation: 'test_op',
        cause: 'test cause',
      );

      expect(exception.message, equals('Test error'));
      expect(exception.serviceType, equals(TestService));
      expect(exception.operation, equals('test_op'));
      expect(exception.cause, equals('test cause'));
    });

    test('should format toString correctly', () {
      const exception = ServiceLocatorException(
        message: 'Test error',
        serviceType: TestService,
        operation: 'get',
      );

      final str = exception.toString();
      expect(str, contains('ServiceLocatorException'));
      expect(str, contains('Test error'));
      expect(str, contains('TestService'));
      expect(str, contains('get'));
    });
  });

  group('ServiceStatusInfo Tests', () {
    test('should create status info correctly', () {
      final now = DateTime.now();
      final info = ServiceStatusInfo(
        serviceType: TestService,
        status: ServiceStatus.ready,
        lastUpdated: now,
        errorMessage: 'Test error',
        metadata: {'key': 'value'},
      );

      expect(info.serviceType, equals(TestService));
      expect(info.status, equals(ServiceStatus.ready));
      expect(info.lastUpdated, equals(now));
      expect(info.errorMessage, equals('Test error'));
      expect(info.metadata, equals({'key': 'value'}));
    });

    test('should copy with new values', () {
      final original = ServiceStatusInfo(
        serviceType: TestService,
        status: ServiceStatus.registered,
        lastUpdated: DateTime.now(),
      );

      final copied = original.copyWith(
        status: ServiceStatus.ready,
        errorMessage: 'New error',
      );

      expect(copied.serviceType, equals(original.serviceType));
      expect(copied.status, equals(ServiceStatus.ready));
      expect(copied.errorMessage, equals('New error'));
      expect(copied.lastUpdated, equals(original.lastUpdated));
    });
  });

  group('Global Helper Functions Tests', () {
    test('should check service availability', () {
      expect(isServiceAvailable<TestService>(), isFalse);
    });

    test('should throw when getting unavailable service', () {
      expect(
        () => getService<TestService>(),
        throwsA(isA<ServiceLocatorException>()),
      );
    });
  });
} 