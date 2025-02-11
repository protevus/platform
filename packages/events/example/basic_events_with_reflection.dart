import 'package:illuminate_container/container.dart';
import 'package:illuminate_events/events.dart';

// Example event class
class OrderShipped {
  final String orderId;
  final DateTime shippedAt;

  OrderShipped(this.orderId, this.shippedAt);
}

// Example subscriber class
class OrderEventSubscriber {
  void handleOrderShipped(List<dynamic> payload) {
    final event = payload[0] as OrderShipped;
    print('Order ${event.orderId} was shipped at ${event.shippedAt}');
  }

  void handleOrderCancelled(List<dynamic> payload) {
    print('Order ${payload[0]} was cancelled');
  }

  Map<dynamic, dynamic> subscribe(EventDispatcher events) {
    return {
      OrderShipped: 'handleOrderShipped',
      'order.cancelled': 'handleOrderCancelled',
    };
  }
}

// Example listener class
class SendShipmentNotification {
  void handle(List<dynamic> payload) {
    final event = payload[0] as OrderShipped;
    print('Sending shipment notification for order ${event.orderId}...');
  }
}

// Example reflection implementations
class ExampleReflectedTypeParameter implements ReflectedTypeParameter {
  @override
  final String name;

  const ExampleReflectedTypeParameter(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflectedTypeParameter && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

// Simple reflector implementation
class SimpleReflector implements Reflector {
  dynamic createInstance(Type type, [List<dynamic>? args]) {
    if (type == SendShipmentNotification) {
      return SendShipmentNotification();
    }
    if (type == OrderEventSubscriber) {
      return OrderEventSubscriber();
    }
    return null;
  }

  @override
  Type? findTypeByName(String name) => null;

  @override
  ReflectedFunction? findInstanceMethod(Object instance, String name) {
    if (instance is SendShipmentNotification && name == 'handle') {
      return SimpleReflectedFunction(
        name: 'handle',
        instance: instance,
        implementation: (args) => instance.handle(args[0] as List),
      );
    }
    if (instance is OrderEventSubscriber) {
      switch (name) {
        case 'handleOrderShipped':
          return SimpleReflectedFunction(
            name: 'handleOrderShipped',
            instance: instance,
            implementation: (args) =>
                instance.handleOrderShipped(args[0] as List),
          );
        case 'handleOrderCancelled':
          return SimpleReflectedFunction(
            name: 'handleOrderCancelled',
            instance: instance,
            implementation: (args) =>
                instance.handleOrderCancelled(args[0] as List),
          );
      }
    }
    return null;
  }

  @override
  List<ReflectedInstance> getAnnotations(Type type) => [];

  @override
  List<ReflectedInstance> getParameterAnnotations(
          Type type, String constructorName, String parameterName) =>
      [];

  List<Type> getParameterTypes(Function function) => [];

  Type? getReturnType(Function function) => null;

  bool hasDefaultConstructor(Type type) => true;

  bool isClass(Type type) =>
      type == SendShipmentNotification || type == OrderEventSubscriber;

  @override
  ReflectedClass? reflectClass(Type type) => null;

  @override
  ReflectedFunction? reflectFunction(Function function) => null;

  @override
  ReflectedType reflectFutureOf(Type type) =>
      throw UnsupportedError('Not needed for this example');

  @override
  ReflectedInstance? reflectInstance(Object instance) => null;

  @override
  ReflectedType? reflectType(Type type) => null;

  @override
  String? getName(Symbol symbol) => symbol.toString().replaceAll('"', '');
}

class SimpleReflectedFunction implements ReflectedFunction {
  final String methodName;
  final Object instance;
  final Function(List<dynamic>) implementation;

  SimpleReflectedFunction({
    required String name,
    required this.instance,
    required this.implementation,
  }) : methodName = name;

  @override
  String get name => methodName;

  @override
  List<ReflectedTypeParameter> get typeParameters => [];

  @override
  List<ReflectedInstance> get annotations => [];

  @override
  List<ReflectedParameter> get parameters => [];

  @override
  bool get isGetter => false;

  @override
  bool get isSetter => false;

  @override
  ReflectedType get returnType => SimpleReflectedType(dynamic);

  @override
  ReflectedInstance invoke(Invocation invocation) {
    implementation(invocation.positionalArguments);
    return SimpleReflectedInstance(SimpleReflectedType(dynamic));
  }
}

class SimpleReflectedType implements ReflectedType {
  final Type type;

  SimpleReflectedType(this.type);

  @override
  String get name => type.toString();

  @override
  List<ReflectedTypeParameter> get typeParameters => [];

  @override
  Type get reflectedType => type;

  @override
  bool isAssignableTo(ReflectedType? other) => true;

  @override
  ReflectedInstance newInstance(
      String constructorName, List positionalArguments,
      [Map<String, dynamic> namedArguments = const {},
      List<Type> typeArguments = const []]) {
    throw UnsupportedError('Not needed for this example');
  }
}

class SimpleReflectedInstance implements ReflectedInstance {
  @override
  final ReflectedType type;

  SimpleReflectedInstance(this.type);

  @override
  ReflectedClass get clazz =>
      throw UnsupportedError('Not needed for this example');

  @override
  Object get reflectee => throw UnsupportedError('Not needed for this example');

  @override
  ReflectedInstance getField(String name) {
    throw UnsupportedError('Not needed for this example');
  }

  dynamic invoke(String name,
      [List<dynamic>? positionalArguments,
      Map<Symbol, dynamic>? namedArguments]) {
    throw UnsupportedError('Not needed for this example');
  }

  @override
  void setField(String name, value) {
    // TODO: implement setField
  }
}

void main() {
  // Create container with simple reflector
  final container = Container(SimpleReflector());

  // Create event dispatcher
  final events = EventDispatcher(container);

  // Register subscriber
  final subscriber = OrderEventSubscriber();
  container.registerSingleton<OrderEventSubscriber>(subscriber);
  events.subscribe(subscriber);

  // Register single event listener
  events.listen(OrderShipped, (event, data) {
    print('Order shipped listener called');
  });

  // Register wildcard listener
  events.listen('order.*', (event, data) {
    print('Wildcard listener caught event: $event');
  });

  // Register class-based listener
  final notification = SendShipmentNotification();
  container.registerSingleton<SendShipmentNotification>(notification);
  events.listen(OrderShipped, [SendShipmentNotification, 'handle']);

  // Dispatch events
  print('\nDispatching OrderShipped event...');
  events.dispatch(OrderShipped('123', DateTime.now()));

  print('\nDispatching order.cancelled event...');
  events.dispatch('order.cancelled', ['456']);

  // Example of queueing events
  print('\nQueuing event...');
  events.push('order.cancelled', ['789']);
  print('Processing queued event...');
  events.flush('order.cancelled');
}
