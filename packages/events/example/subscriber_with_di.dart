import 'package:platform_container/container.dart';
import 'package:platform_events/events.dart';
import 'package:platform_contracts/contracts.dart';

/// Example notification service
class NotificationService {
  void sendEmail(String email, String message) {
    print('Sending email to $email: $message');
  }

  void sendPushNotification(String userId, String message) {
    print('Sending push notification to $userId: $message');
  }
}

/// Example activity logger
class ActivityLogger {
  void log(String activity) {
    print('Activity: $activity [${DateTime.now()}]');
  }
}

/// Example user event subscriber that depends on other services
class UserEventSubscriber {
  final NotificationService _notifications;
  final ActivityLogger _logger;

  UserEventSubscriber(this._notifications, this._logger);

  Map<String, dynamic> subscribe(EventDispatcher events) {
    return {
      'UserRegistered': 'handleUserRegistration',
      'UserLoggedIn': 'handleUserLogin',
      'UserLoggedOut': 'handleUserLogout',
    };
  }

  void handleUserRegistration(List<dynamic> data) {
    final email = data[0] as String;
    _notifications.sendEmail(
      email,
      'Welcome! Your account has been created successfully.',
    );
    _logger.log('New user registered: $email');
  }

  void handleUserLogin(List<dynamic> data) {
    final email = data[0] as String;
    _notifications.sendPushNotification(
      email,
      'New login detected on your account.',
    );
    _logger.log('User logged in: $email');
  }

  void handleUserLogout(List<dynamic> data) {
    final email = data[0] as String;
    _logger.log('User logged out: $email');
  }
}

// Simple reflector implementation
class SimpleReflector implements Reflector {
  @override
  dynamic createInstance(Type type, [List<dynamic>? args]) {
    if (type == NotificationService) {
      return NotificationService();
    }
    if (type == ActivityLogger) {
      return ActivityLogger();
    }
    if (type == UserEventSubscriber) {
      return UserEventSubscriber(
        args![0] as NotificationService,
        args[1] as ActivityLogger,
      );
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
        case 'handleUserLogin':
          return SimpleReflectedFunction(
            name: name,
            instance: instance,
            implementation: (args) => instance.handleUserLogin(args[0] as List),
          );
        case 'handleUserLogout':
          return SimpleReflectedFunction(
            name: name,
            instance: instance,
            implementation: (args) =>
                instance.handleUserLogout(args[0] as List),
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

  @override
  List<Type> getParameterTypes(Function function) => [];

  @override
  Type? getReturnType(Function function) => null;

  @override
  bool hasDefaultConstructor(Type type) => true;

  @override
  bool isClass(Type type) =>
      type == NotificationService ||
      type == ActivityLogger ||
      type == UserEventSubscriber;

  @override
  ReflectedClass? reflectClass(Type type) {
    if (type == UserEventSubscriber) {
      return SimpleReflectedClass(
        name: 'UserEventSubscriber',
        type: type,
        methods: [
          'handleUserRegistration',
          'handleUserLogin',
          'handleUserLogout',
        ],
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
    if (type == NotificationService ||
        type == ActivityLogger ||
        type == UserEventSubscriber) {
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

  @override
  dynamic invoke(String name,
      [List<dynamic>? positionalArguments,
      Map<Symbol, dynamic>? namedArguments]) {
    throw UnsupportedError('Not needed for this example');
  }
}

void main() async {
  // Set up container
  final container = Container(SimpleReflector());

  // Register services
  container.registerSingleton<NotificationService>(NotificationService());
  container.registerSingleton<ActivityLogger>(ActivityLogger());

  // Register event dispatcher
  final dispatcher = EventDispatcher(container);
  container.registerSingleton<EventDispatcherContract>(dispatcher);

  // Register subscriber with dependencies injected from container
  container.registerFactory<UserEventSubscriber>((container) {
    return UserEventSubscriber(
      container.make<NotificationService>()!,
      container.make<ActivityLogger>()!,
    );
  });

  // Subscribe using container-resolved subscriber
  final subscriber = container.make<UserEventSubscriber>()!;
  dispatcher.subscribe(subscriber);

  // Dispatch some events
  print('\nRegistering user:');
  dispatcher.dispatch('UserRegistered', ['jane@example.com']);

  print('\nUser logging in:');
  dispatcher.dispatch('UserLoggedIn', ['jane@example.com']);

  print('\nUser logging out:');
  dispatcher.dispatch('UserLoggedOut', ['jane@example.com']);

  // Example of using child container for testing
  final testContainer = container.createChild();

  // Override services in child container with test doubles
  testContainer.registerSingleton<NotificationService>(
    NotificationService(), // In real tests this would be a mock
  );
  testContainer.registerSingleton<ActivityLogger>(
    ActivityLogger(), // In real tests this would be a mock
  );

  // Create test subscriber with overridden dependencies
  final testSubscriber = testContainer.make<UserEventSubscriber>()!;

  // Create test dispatcher
  final testDispatcher = EventDispatcher(testContainer);
  testDispatcher.subscribe(testSubscriber);

  // Test events will use the overridden services
  print('\nTesting with overridden services:');
  testDispatcher.dispatch('UserRegistered', ['test@example.com']);
}
