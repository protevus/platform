import 'package:platform_container/container.dart';
import 'package:platform_events/events.dart';
import 'package:platform_contracts/contracts.dart';

/// Example event that should be broadcasted
class UserLoggedIn implements ShouldBroadcast {
  final String email;
  final DateTime timestamp;

  UserLoggedIn(this.email) : timestamp = DateTime.now();

  @override
  List<String> broadcastOn() => ['user-events', 'activity-log'];

  @override
  String broadcastAs() => 'user.logged_in';

  @override
  Map<String, dynamic> broadcastWith() => {
        'email': email,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  bool broadcastWhen() {
    final hour = timestamp.hour;
    return hour >= 9 && hour <= 17;
  }
}

/// Example service that depends on event dispatcher
class AuthenticationService {
  final EventDispatcherContract _events;

  AuthenticationService(this._events);

  Future<void> login(String email, String password) async {
    // Simulate authentication
    await Future.delayed(Duration(milliseconds: 100));

    // Dispatch login event
    await _events.dispatch(UserLoggedIn(email));

    print('User logged in: $email');
  }
}

// Simple reflector implementation
class SimpleReflector implements Reflector {
  @override
  dynamic createInstance(Type type, [List<dynamic>? args]) {
    if (type == AuthenticationService) {
      return AuthenticationService(args![0] as EventDispatcherContract);
    }
    return null;
  }

  @override
  Type? findTypeByName(String name) => null;

  @override
  ReflectedFunction? findInstanceMethod(Object instance, String name) => null;

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
  bool isClass(Type type) => type == AuthenticationService;

  @override
  ReflectedClass? reflectClass(Type type) {
    if (type == AuthenticationService) {
      return SimpleReflectedClass(
        name: 'AuthenticationService',
        type: type,
        methods: ['login'],
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
    if (type == AuthenticationService) {
      return SimpleReflectedType(type);
    }
    return null;
  }

  @override
  String? getName(Symbol symbol) => symbol.toString().replaceAll('"', '');
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

  // Register event dispatcher
  final dispatcher = EventDispatcher(container);
  container.registerSingleton<EventDispatcherContract>(dispatcher);

  // Register auth service factory
  container.registerFactory<AuthenticationService>((container) {
    return AuthenticationService(
      container.make<EventDispatcherContract>()!,
    );
  });

  // Get auth service from container
  final auth = container.make<AuthenticationService>()!;

  // Register event listeners
  dispatcher.listen(UserLoggedIn, (event, data) {
    final login = data[0] as UserLoggedIn;
    print('Broadcast: User ${login.email} logged in at ${login.timestamp}');
  });

  // Perform login which will trigger event
  await auth.login('john@example.com', 'password123');

  // Example of using null dispatcher for testing
  final nullDispatcher = NullDispatcher();
  final testAuth = AuthenticationService(nullDispatcher);

  // This won't trigger any events
  await testAuth.login('test@example.com', 'password123');
}
