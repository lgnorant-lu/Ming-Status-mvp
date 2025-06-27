import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

// 使用 get_it 创建服务定位器实例
final getIt = GetIt.instance;

/// 全局事件总线
///
/// 使用 RxDart 的 PublishSubject 来分发事件。
/// 这是一个简单的实现，可以根据需要扩展，例如：
/// - 为不同类型的事件使用不同的 Subject。
/// - 添加事件过滤或转换逻辑。
class EventBus {
  // PublishSubject 会将接收到的事件广播给所有监听者。
  // 与 BehaviorSubject 不同，它不会在监听者订阅时发送最新的事件。
  final PublishSubject<dynamic> _subject = PublishSubject<dynamic>();

  /// 注册 EventBus 为一个单例
  ///
  /// 这使得我们可以通过 `getIt<EventBus>()` 在应用的任何地方获取到同一个实例。
  static void register() {
    // 使用 isRegistered 来防止重复注册，这在热重载等场景下很有用。
    if (!getIt.isRegistered<EventBus>()) {
      getIt.registerSingleton<EventBus>(EventBus());
    }
  }

  /// 获取 EventBus 的单例实例
  static EventBus get instance => getIt<EventBus>();

  /// 发布一个事件
  ///
  /// [event] 要发布的事件对象
  void fire(dynamic event) {
    _subject.add(event);
  }

  /// 订阅指定类型的事件流
  ///
  /// 使用 `ofType<T>()` 来过滤出特定类型的事件。
  ///
  /// 示例:
  /// EventBus.instance.on`<MyEvent>`().listen((event) {
  ///   // 处理 MyEvent
  /// });
  ///
  /// 返回一个 `Stream<T>`，可以被监听。
  Stream<T> on<T>() {
    return _subject.stream.where((event) => event is T).cast<T>();
  }

  /// 关闭事件总线
  ///
  /// 在应用关闭或不再需要事件总线时调用，以释放资源。
  void dispose() {
    _subject.close();
  }
} 