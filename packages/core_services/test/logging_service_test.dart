import 'package:flutter_test/flutter_test.dart';
import 'package:core_services/core_services.dart';

void main() {
  group('LoggingService Tests', () {
    late LoggingService loggingService;

    setUp(() {
      loggingService = BasicLoggingService();
    });

    tearDown(() {
      loggingService.close();
    });

    test('should create logging service with default settings', () {
      expect(loggingService, isNotNull);
      expect(loggingService, isA<BasicLoggingService>());
    });

    test('should log different levels correctly', () {
      // 这些测试不会抛出异常即为成功
      expect(() => loggingService.debug('Debug message'), returnsNormally);
      expect(() => loggingService.info('Info message'), returnsNormally);
      expect(() => loggingService.warning('Warning message'), returnsNormally);
      expect(() => loggingService.error('Error message'), returnsNormally);
      expect(() => loggingService.fatal('Fatal message'), returnsNormally);
    });

    test('should handle log with additional data', () {
      expect(() => loggingService.info(
        'Message with data',
        tag: 'TEST',
        data: {'key': 'value', 'number': 42},
      ), returnsNormally);
    });

    test('should handle error logging with exception', () {
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.current;
      
      expect(() => loggingService.error(
        'Error with exception',
        tag: 'ERROR_TEST',
        error: exception,
        stackTrace: stackTrace,
      ), returnsNormally);
    });

    test('should allow setting minimum log level', () {
      expect(() => loggingService.setMinLevel(LogLevel.warning), returnsNormally);
    });

    test('should allow adding and removing outputs', () {
      final output = ConsoleLogOutput();
      expect(() => loggingService.addOutput(output), returnsNormally);
      expect(() => loggingService.removeOutput(output), returnsNormally);
    });
  });

  group('LogEntry Tests', () {
    test('should create log entry with all fields', () {
      final now = DateTime.now();
      final entry = LogEntry(
        timestamp: now,
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TEST',
        data: {'key': 'value'},
      );

      expect(entry.timestamp, equals(now));
      expect(entry.level, equals(LogLevel.info));
      expect(entry.message, equals('Test message'));
      expect(entry.tag, equals('TEST'));
      expect(entry.data, equals({'key': 'value'}));
    });

    test('should format log entry correctly', () {
      final entry = LogEntry.create(
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TEST',
      );

      final formatted = entry.format();
      expect(formatted, contains('[INFO]'));
      expect(formatted, contains('[TEST]'));
      expect(formatted, contains('Test message'));
    });

    test('should convert to JSON correctly', () {
      final entry = LogEntry.create(
        level: LogLevel.warning,
        message: 'Warning message',
        tag: 'WARN',
        data: {'severity': 'medium'},
      );

      final json = entry.toJson();
      expect(json['level'], equals('WARN'));
      expect(json['message'], equals('Warning message'));
      expect(json['tag'], equals('WARN'));
      expect(json['data'], equals({'severity': 'medium'}));
    });
  });

  group('LogLevel Tests', () {
    test('should have correct priority values', () {
      expect(LogLevel.debug.priority, equals(0));
      expect(LogLevel.info.priority, equals(1));
      expect(LogLevel.warning.priority, equals(2));
      expect(LogLevel.error.priority, equals(3));
      expect(LogLevel.fatal.priority, equals(4));
    });

    test('should have correct display names', () {
      expect(LogLevel.debug.displayName, equals('DEBUG'));
      expect(LogLevel.info.displayName, equals('INFO'));
      expect(LogLevel.warning.displayName, equals('WARN'));
      expect(LogLevel.error.displayName, equals('ERROR'));
      expect(LogLevel.fatal.displayName, equals('FATAL'));
    });
  });
} 