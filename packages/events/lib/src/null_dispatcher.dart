import 'package:illuminate_contracts/contracts.dart';

/// A dispatcher implementation that does nothing.
class NullDispatcher implements EventDispatcherContract {
  @override
  void listen(dynamic events, [dynamic listener]) {}

  @override
  bool hasListeners(String eventName) => false;

  @override
  void subscribe(dynamic subscriber) {}

  @override
  dynamic until(dynamic event, [dynamic payload = const []]) {}

  @override
  List<dynamic>? dispatch(dynamic event,
      [dynamic payload = const [], bool halt = false]) {
    return null;
  }

  @override
  void push(String event, [List<dynamic> payload = const []]) {}

  @override
  void flush(String event) {}

  @override
  void forget(String event) {}

  @override
  void forgetPushed() {}
}
