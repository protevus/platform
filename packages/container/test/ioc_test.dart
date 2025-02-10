import 'package:illuminate_container/container.dart';
import 'package:illuminate_mirrors/mirrors.dart';
import 'package:test/test.dart';

class ABC {
  ABC();

  String sayHello() {
    return 'hello';
  }
}

// Test classes for new features
class Logger {
  final List<String> logs = [];
  void log(String message) => logs.add(message);
}

class FileLogger extends Logger {
  @override
  void log(String message) {
    logs.add('File: $message');
  }
}

class ConsoleLogger extends Logger {
  @override
  void log(String message) {
    logs.add('Console: $message');
  }
}

class UserService {
  final Logger logger;
  bool initialized = false;
  UserService(this.logger);

  void logMessage(String msg) => logger.log(msg);
}

@reflectable
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});
}

class Repository {}

class UserRepository extends Repository {}

class ProductRepository extends Repository {}

void main() {
  setUpAll(() {
    // Register User class with illuminate_mirrors
    ReflectionRegistry.register(User);
    ReflectionRegistry.registerConstructor(
      User,
      '',
      parameterTypes: [String, String],
      parameterNames: ['name', 'email'],
      isRequired: [true, true],
      isNamed: [true, true],
      creator: ({String name = '', String email = ''}) {
        return User(name: name, email: email);
      },
    );
  });

  group('IOC Container |', () {
    test('register', () {
      Container ioc = Container();
      ioc.register<ABC>((Container i) => ABC());

      ABC abc = ioc.get<ABC>();
      expect(abc.sayHello(), 'hello');
    });

    test('register by name', () {
      Container ioc = Container();
      ioc.registerByName('ABC', (Container i) => ABC());

      ABC abc = ioc.get<ABC>();
      expect(abc.sayHello(), 'hello');
    });

    test('get by name', () {
      Container ioc = Container();
      ioc.registerByName('ABC', (Container i) => ABC());

      ABC abc = ioc.getByName('ABC');
      expect(abc.sayHello(), 'hello');
    });

    test('register singleton', () {
      Container ioc = Container();
      ioc.registerSingleton<ABC>((Container i) => ABC());

      ABC abc = ioc.get<ABC>();
      ABC newAbc = ioc.get<ABC>();
      expect(abc, newAbc);
    });

    test('register singleton and get by name', () {
      Container ioc = Container();
      ioc.registerSingleton<ABC>((Container i) => ABC());

      ABC abc = ioc.getByName('ABC');
      ABC newAbc = ioc.getByName('ABC');
      expect(abc, newAbc);
    });

    test('register request', () {
      Container ioc = Container();
      ioc.registerRequest('ABC', () => ABC());

      ABC abc = ioc.get<ABC>();
      expect(abc.sayHello(), 'hello');
    });

    test('register should not equal 2 instance', () {
      Container ioc = Container();
      ioc.register<ABC>((Container i) => ABC());

      ABC abc = ioc.get<ABC>();
      ABC newAbc = ioc.get<ABC>();
      expect(abc != newAbc, true);
    });

    // New feature tests
    group('Contextual Bindings |', () {
      test('registers and resolves contextual binding', () {
        final ioc = Container();

        // Register base services
        ioc.register<Logger>((c) => ConsoleLogger());
        ioc.register<UserService>((c) => UserService(c.get<Logger>()));

        // Register contextual binding
        ioc.registerFor<UserService, Logger>((c) => FileLogger());

        final service = ioc.get<UserService>();
        service.logMessage('test');

        expect(service.logger, isA<FileLogger>());
        expect((service.logger as FileLogger).logs.first, equals('File: test'));
      });
    });

    group('Extenders |', () {
      test('extends instance with additional functionality', () {
        final ioc = Container();
        ioc.register<UserService>((c) => UserService(ConsoleLogger()));

        // Add extender
        ioc.extend<UserService>((service) {
          service.initialized = true;
        });

        final service = ioc.get<UserService>();
        expect(service.initialized, isTrue);
      });

      test('applies multiple extenders in order', () {
        final ioc = Container();
        ioc.register<Logger>((c) => Logger());

        final logs = <String>[];
        ioc.extend<Logger>((logger) => logger.log('first'));
        ioc.extend<Logger>((logger) => logger.log('second'));

        final logger = ioc.get<Logger>();
        expect(logger.logs, equals(['first', 'second']));
      });
    });

    group('Resolving Callbacks |', () {
      test('executes resolving callbacks when resolving instance', () {
        final ioc = Container();
        ioc.register<UserService>((c) => UserService(ConsoleLogger()));

        var callbackExecuted = false;
        ioc.resolving<UserService>((service) {
          callbackExecuted = true;
        });

        ioc.get<UserService>();
        expect(callbackExecuted, isTrue);
      });

      test('executes multiple resolving callbacks in order', () {
        final ioc = Container();
        ioc.register<Logger>((c) => Logger());

        final order = <int>[];
        ioc.resolving<Logger>((logger) => order.add(1));
        ioc.resolving<Logger>((logger) => order.add(2));

        ioc.get<Logger>();
        expect(order, equals([1, 2]));
      });
    });

    group('Tags |', () {
      test('retrieves all instances by tag', () {
        final ioc = Container();

        // Register repositories
        final userRepo = UserRepository();
        final productRepo = ProductRepository();

        ioc.register<UserRepository>((c) => userRepo);
        ioc.register<ProductRepository>((c) => productRepo);

        // Tag repositories
        ioc.tag<UserRepository>('repositories');
        ioc.tag<ProductRepository>('repositories');

        // Get tagged instances
        final repos = ioc.tagged<Repository>('repositories');
        expect(repos.length, equals(2));
        expect(repos.any((r) => r is UserRepository), isTrue);
        expect(repos.any((r) => r is ProductRepository), isTrue);
      });
    });

    group('Make Method |', () {
      test('creates instance with parameters', () {
        final ioc = Container();

        final user =
            ioc.make<User>({'name': 'John', 'email': 'john@example.com'});

        expect(user.name, equals('John'));
        expect(user.email, equals('john@example.com'));
      });

      test('throws on invalid parameters', () {
        final ioc = Container();

        expect(
            () => ioc.make<User>({
                  'name': 'John',
                  // Missing required email parameter
                }),
            throwsException);
      });
    });
  });
}
