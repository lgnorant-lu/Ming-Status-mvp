/*
---------------------------------------------------------------
File name:          module_manager_test.dart
Author:             Ignorant-lu
Date created:       2025/06/26
Last modified:      2025/06/27
Dart Version:       3.32.4
Description:        ModuleManager和Desktop Environment测试
---------------------------------------------------------------
Change History:
    2025/06/26: 创建基础测试;
    2025/06/27: Phase 2.0 Sprint 2.0b - 添加desktop_environment包测试;
---------------------------------------------------------------
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:core_services/core_services.dart';

// 测试用的简单模块实现
class TestModule implements PetModuleInterface {
  final String _name;
  bool _isInitialized = false;
  bool _isActive = false;

  TestModule(this._name);

  @override
  String get id => _name;

  @override
  String get name => _name;

  @override
  String get description => 'Test module for $_name';

  @override
  String get version => '1.0.0';

  @override
  String get author => 'Test';

  @override
  List<String> get dependencies => [];

  @override
  Map<String, dynamic> get metadata => {'test': true};

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isActive => _isActive;

  @override
  Future<void> initialize(EventBus eventBus) async {
    _isInitialized = true;
  }

  @override
  Future<void> boot() async {
    _isActive = true;
  }

  @override
  void dispose() {
    _isActive = false;
    _isInitialized = false;
  }
}

void main() {
  group('ModuleManager Tests', () {
    test('should get singleton instance', () {
      final moduleManager1 = ModuleManager.instance;
      final moduleManager2 = ModuleManager.instance;
      
      expect(moduleManager1, isNotNull);
      expect(moduleManager1, same(moduleManager2));
    });

    test('should have lifecycle events stream', () {
      final moduleManager = ModuleManager.instance;
      
      expect(moduleManager.lifecycleEvents, isNotNull);
      expect(moduleManager.lifecycleEvents, isA<Stream>());
    });
  });


} 