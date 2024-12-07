import 'package:platform_contracts/contracts.dart' hide ContainerContract;
import 'package:platform_container/platform_container.dart';

// Domain Models
class User {
  final String id;
  final String name;
  final int age;

  User(this.id, this.name, this.age);
}

// Repository Layer
abstract class UserRepository {
  User? findById(String id);
  void save(User user);
}

class DatabaseUserRepository implements UserRepository {
  final Map<String, User> _users = {};

  @override
  User? findById(String id) => _users[id];

  @override
  void save(User user) => _users[user.id] = user;
}

// Service Layer
class UserService {
  final UserRepository repository;
  final EmailService emailService;

  UserService(this.repository, this.emailService);

  User createUser(String name, int age) {
    final user = User(DateTime.now().toString(), name, age);
    repository.save(user);
    emailService.sendWelcomeEmail(user);
    return user;
  }
}

class EmailService {
  void sendWelcomeEmail(User user) {
    print('Sending welcome email to ${user.name}');
  }
}

// Controller Layer
class UserController {
  final UserService userService;

  UserController(this.userService);

  void createUser(String name, int age) {
    final user = userService.createUser(name, age);
    print('Created user: ${user.name}');
  }
}

/// Example reflector implementation
class ExampleReflector implements ReflectorContract {
  @override
  ClassMirror? reflectClass(Type type) {
    // Implementation
    return null;
  }

  @override
  TypeMirror reflectType(Type type) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  InstanceMirror reflect(Object object) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  LibraryMirror reflectLibrary(Uri uri) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  dynamic createInstance(
    Type type, {
    List<dynamic>? positionalArgs,
    Map<String, dynamic>? namedArgs,
    String? constructorName,
  }) {
    // Implementation
    throw UnimplementedError();
  }
}

void main() {
  // Create container with example reflector
  final container = Container(ExampleReflector());

  // Register dependencies
  container.bind<UserRepository>((c) => DatabaseUserRepository());
  container.bind<EmailService>((c) => EmailService());
  container.bind<UserService>((c) => UserService(
        c.make<UserRepository>(),
        c.make<EmailService>(),
      ));
  container.bind<UserController>((c) => UserController(
        c.make<UserService>(),
      ));

  // Resolve controller and create user
  final controller = container.make<UserController>();
  controller.createUser('John Doe', 30);
}
