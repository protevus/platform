import 'package:platform_contracts/contracts.dart';
import 'package:platform_container/platform_container.dart';

// Example services
abstract class Logger {
  void log(String message);
}

class ProductionLogger implements Logger {
  @override
  void log(String message) => print('PROD: $message');
}

class TestLogger implements Logger {
  @override
  void log(String message) => print('TEST: $message');
}

class RequestScope {
  final String id = DateTime.now().toIso8601String();

  @override
  String toString() => 'RequestScope($id)';
}

class UserRepository {
  final Logger logger;
  final RequestScope scope;

  UserRepository(this.logger, this.scope);

  void save(String userId) {
    logger.log('[${scope.id}] Saving user: $userId');
  }
}

void main() {
  // Create root container
  final container = IlluminateContainer(ExampleReflector());

  print('1. Child Containers');
  print('------------------');
  // Register production logger in root
  container.singleton<Logger>((c) => ProductionLogger());

  // Create child container with test logger
  final testContainer = container.createChild();
  testContainer.singleton<Logger>((c) => TestLogger());

  // Use both containers
  container.make<Logger>().log('Using production logger');
  testContainer.make<Logger>().log('Using test logger');
  container.make<Logger>().log('Still using production logger');

  print('\n2. Scoped Bindings');
  print('-----------------');
  // Register scoped request
  container.scoped<RequestScope>((c) {
    final scope = RequestScope();
    print('Created new scope: $scope');
    return scope;
  });

  // Register repository that uses scope
  container.bind<UserRepository>(
      (c) => UserRepository(c.make<Logger>(), c.make<RequestScope>()));

  print('\nFirst request:');
  // Same scope within request
  final repo1 = container.make<UserRepository>();
  final repo2 = container.make<UserRepository>();
  repo1.save('user1');
  repo2.save('user2');

  // Verify same scope
  print('Using same scope: ${identical(repo1.scope, repo2.scope)}');

  print('\nNew request:');
  // Clear scope
  container.forgetScopedInstances();

  // New scope for new request
  final repo3 = container.make<UserRepository>();
  repo3.save('user3');

  // Verify different scope
  print('Using different scope: ${!identical(repo1.scope, repo3.scope)}');
}

/// Example reflector implementation
class ExampleReflector implements ReflectorContract {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClassContract? reflectClass(Type clazz) => null;

  @override
  ReflectedFunctionContract? reflectFunction(Function function) => null;

  @override
  ReflectedInstanceContract? reflectInstance(Object object) => null;

  @override
  ReflectedTypeContract reflectFutureOf(Type type) {
    throw UnsupportedError('Future reflection not needed for example');
  }

  @override
  ReflectedTypeContract? reflectType(Type type) => null;
}
