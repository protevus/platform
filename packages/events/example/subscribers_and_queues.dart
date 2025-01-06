import 'package:platform_container/container.dart';
import 'package:platform_events/events.dart';

/// Example event subscriber class
class UserEventSubscriber {
  Map<String, dynamic> subscribe(EventDispatcher events) {
    return {
      'UserRegistered': 'handleUserRegistration',
      'UserDeleted': 'handleUserDeletion',
      'user.login': ['handleUserLogin', 'logLoginAttempt'],
    };
  }

  void handleUserRegistration(List<dynamic> data) {
    final email = data[0] as String;
    print('Subscriber handling registration for: $email');
    print('Sending welcome email...');
  }

  void handleUserDeletion(List<dynamic> data) {
    final email = data[0] as String;
    print('Subscriber handling deletion for: $email');
    print('Cleaning up user data...');
  }

  void handleUserLogin(List<dynamic> data) {
    final email = data[0] as String;
    print('Subscriber handling login for: $email');
    print('Updating last login timestamp...');
  }

  void logLoginAttempt(List<dynamic> data) {
    final email = data[0] as String;
    print('Logging login attempt for: $email');
  }
}

/// Example queued event handler
class SendWelcomeEmail {
  void handle(List<dynamic> data) {
    final email = data[0] as String;
    print('Sending welcome email to: $email');
  }

  void failed(List<dynamic> data, Object error) {
    final email = data[0] as String;
    print('Failed to send welcome email to: $email');
    print('Error: $error');
  }
}

// Simple reflector implementation
class SimpleReflector implements Reflector {
  dynamic createInstance(Type type, [List<dynamic>? args]) {
    if (type == UserEventSubscriber) {
      return UserEventSubscriber();
    }
    if (type == SendWelcomeEmail) {
      return SendWelcomeEmail();
    }
    return null;
  }

  @override
  Type? findTypeByName(String name) => null;

  @override
  ReflectedFunction? findInstanceMethod(Object instance, String name) {
    if (instance is UserEventSubscriber) {
      switch (name) {
        case 'handleUserRegistration':
          return SimpleReflectedFunction(
            name: name,
            instance: instance,
            implementation: (args) =>
                instance.handleUserRegistration(args[0] as List),
          );
        case 'handleUserDeletion':
          return SimpleReflectedFunction(
            name: name,
            instance: instance,
            implementation: (args) =>
                instance.handleUserDeletion(args[0] as List),
          );
        case 'handleUserLogin':
          return SimpleReflectedFunction(
            name: name,
            instance: instance,
            implementation: (args) => instance.handleUserLogin(args[0] as List),
          );
        case 'logLoginAttempt':
          return SimpleReflectedFunction(
            name: name,
            instance: instance,
            implementation: (args) => instance.logLoginAttempt(args[0] as List),
          );
      }
    }
    if (instance is SendWelcomeEmail && name == 'handle') {
      return SimpleReflectedFunction(
        name: name,
        instance: instance,
        implementation: (args) => instance.handle(args[0] as List),
      );
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
      type == UserEventSubscriber || type == SendWelcomeEmail;

  @override
  ReflectedClass? reflectClass(Type type) {
    if (type == UserEventSubscriber) {
      return SimpleReflectedClass(
        name: 'UserEventSubscriber',
        type: type,
        methods: [
          'handleUserRegistration',
          'handleUserDeletion',
          'handleUserLogin',
          'logLoginAttempt'
        ],
      );
    }
    if (type == SendWelcomeEmail) {
      return SimpleReflectedClass(
        name: 'SendWelcomeEmail',
        type: type,
        methods: ['handle', 'failed'],
      );
    }
    return null;
  }

  @override
  ReflectedFunction? reflectFunction(Function function) => null;

  @override
  ReflectedType reflectFutureOf(Type type) =>
      throw UnsupportedError('Not needed for this example');

  @override
  ReflectedInstance? reflectInstance(Object instance) => null;

  @override
  ReflectedType? reflectType(Type type) {
    if (type == UserEventSubscriber || type == SendWelcomeEmail) {
      return SimpleReflectedType(type);
    }
    return null;
  }

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

class SimpleReflectedClass extends SimpleReflectedType
    implements ReflectedClass {
  final String className;
  final List<String> methods;

  SimpleReflectedClass({
    required String name,
    required Type type,
    required this.methods,
  })  : className = name,
        super(type);

  @override
  List<ReflectedInstance> get annotations => [];

  @override
  List<ReflectedFunction> get constructors => [];

  @override
  List<ReflectedDeclaration> get declarations =>
      methods.map((m) => SimpleReflectedDeclaration(m)).toList();
}

class SimpleReflectedDeclaration implements ReflectedDeclaration {
  @override
  final String name;
  @override
  final bool isStatic;
  @override
  final ReflectedFunction? function;

  SimpleReflectedDeclaration(this.name, [this.isStatic = false, this.function]);
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
}

void main() {
  // Create container with simple reflector
  final container = Container(SimpleReflector());

  // Create event dispatcher
  final events = EventDispatcher(container);

  // Register the subscriber
  final subscriber = UserEventSubscriber();
  container.registerSingleton<UserEventSubscriber>(subscriber);
  events.subscribe(subscriber);

  // Register a queued event listener
  events.listen('UserRegistered', (event, data) {
    print('Queued: Sending welcome email to ${data[0]}');
  });

  // Dispatch some events
  print('\nRegistering user:');
  events.dispatch('UserRegistered', ['jane@example.com']);

  print('\nUser logging in:');
  events.dispatch('user.login', ['jane@example.com']);

  print('\nDeleting user:');
  events.dispatch('UserDeleted', ['jane@example.com']);

  // Example of serializable closure
  final greetUser = SerializableClosure.create(
    (String name) => 'Hello $name',
    'greet-user',
    () => (String name) => 'Hello $name',
  );

  // Later reconstruct and use the closure
  final reconstructed = SerializableClosure.fromJson({
    'identifier': 'greet-user',
  });

  print('\nGreeting from reconstructed closure:');
  print((reconstructed).call('Jane'));
}
