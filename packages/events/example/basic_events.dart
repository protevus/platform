import 'package:platform_container/container.dart';
import 'package:platform_events/events.dart';

void main() {
  // Create container with basic reflector
  final container = Container(BasicReflector());

  // Create event dispatcher
  final events = EventDispatcher(container);

  // Register event listeners
  events.listen('user.registered', (event, data) {
    final username = data[0] as String;
    print('New user registered: $username');
  });

  // Register wildcard listener
  events.listen('user.*', (event, data) {
    print('User event caught: $event with data: $data');
  });

  // Dispatch events
  print('\nDispatching user.registered event...');
  events.dispatch('user.registered', ['john_doe']);

  print('\nDispatching user.logged_in event...');
  events.dispatch('user.logged_in', ['john_doe']);

  // Example of queueing events
  print('\nQueuing event...');
  events.push('user.logged_out', ['john_doe']);
  print('Processing queued event...');
  events.flush('user.logged_out');
}

/// A basic reflector that doesn't need to do anything since we're only using string-based events
class BasicReflector implements Reflector {
  @override
  dynamic createInstance(Type type, [List<dynamic>? args]) => null;

  @override
  Type? findTypeByName(String name) => null;

  @override
  ReflectedFunction? findInstanceMethod(Object instance, String name) => null;

  @override
  List<ReflectedInstance> getAnnotations(Type type) => [];

  @override
  String? getName(Symbol symbol) => null;

  @override
  List<ReflectedInstance> getParameterAnnotations(
          Type type, String constructorName, String parameterName) =>
      [];

  @override
  List<Type> getParameterTypes(Function function) => [];

  @override
  Type? getReturnType(Function function) => null;

  @override
  bool hasDefaultConstructor(Type type) => false;

  @override
  bool isClass(Type type) => false;

  @override
  ReflectedClass? reflectClass(Type type) => null;

  @override
  ReflectedFunction? reflectFunction(Function function) => null;

  @override
  ReflectedType reflectFutureOf(Type type) =>
      throw UnsupportedError('Not needed');

  @override
  ReflectedInstance? reflectInstance(Object instance) => null;

  @override
  ReflectedType? reflectType(Type type) => null;
}
