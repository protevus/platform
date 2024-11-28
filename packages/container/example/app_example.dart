import 'package:platform_contracts/contracts.dart';
import 'package:platform_container/platform_container.dart';

// Domain Models
class User {
  final String id;
  final String name;
  final String email;

  User(this.id, this.name, this.email);
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
  void save(User user) {
    print('DB: Saving user ${user.id}');
    _users[user.id] = user;
  }
}

// Service Layer
class UserService {
  final UserRepository repository;
  final EmailService emailService;

  UserService(this.repository, this.emailService);

  void registerUser(String name, String email) {
    // Create user
    final user =
        User(DateTime.now().millisecondsSinceEpoch.toString(), name, email);

    // Save user
    repository.save(user);

    // Send welcome email
    emailService.sendWelcomeEmail(user);
  }

  User? getUser(String id) => repository.findById(id);
}

class EmailService {
  void sendWelcomeEmail(User user) {
    print('Sending welcome email to ${user.email}');
  }
}

// Controller Layer
class UserController {
  final UserService userService;

  UserController(this.userService);

  void createUser(String name, String email) {
    try {
      userService.registerUser(name, email);
      print('User created successfully');
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  void getUser(String id) {
    final user = userService.getUser(id);
    if (user != null) {
      print('Found user: ${user.name} (${user.email})');
    } else {
      print('User not found');
    }
  }
}

void main() {
  // Create container
  final container = IlluminateContainer(ExampleReflector());

  // Register repositories
  container.singleton<UserRepository>((c) => DatabaseUserRepository());

  // Register services
  container.singleton<EmailService>((c) => EmailService());
  container.singleton<UserService>(
      (c) => UserService(c.make<UserRepository>(), c.make<EmailService>()));

  // Register controllers
  container
      .singleton<UserController>((c) => UserController(c.make<UserService>()));

  // Use the application
  final controller = container.make<UserController>();

  // Create a user
  print('Creating user...');
  controller.createUser('John Doe', 'john@example.com');

  // Try to find the user
  print('\nLooking up user...');
  controller.getUser('123'); // Not found
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
