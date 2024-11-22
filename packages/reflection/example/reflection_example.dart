import 'package:platform_reflection/reflection.dart';

@reflectable
class User with Reflector {
  String name;
  int age;
  final String id;
  bool _isActive;

  User(this.name, this.age, {required this.id, bool isActive = true})
      : _isActive = isActive;

  // Guest constructor
  User.guest()
      : name = 'guest',
        age = 0,
        id = 'guest_id',
        _isActive = true;

  bool get isActive => _isActive;

  void deactivate() {
    _isActive = false;
  }

  void birthday() {
    age++;
  }

  String greet([String greeting = 'Hello']) => '$greeting, $name!';

  @override
  String toString() =>
      'User(name: $name age: $age id: $id isActive: $isActive)';
}

void main() {
  // Register User class for reflection
  Reflector.register(User);

  // Register properties
  Reflector.registerProperty(User, 'name', String);
  Reflector.registerProperty(User, 'age', int);
  Reflector.registerProperty(User, 'id', String, isWritable: false);
  Reflector.registerProperty(User, 'isActive', bool, isWritable: false);

  // Register methods
  Reflector.registerMethod(
    User,
    'birthday',
    [],
    true, // returns void
  );
  Reflector.registerMethod(
    User,
    'greet',
    [String],
    false, // returns String
    parameterNames: ['greeting'],
    isRequired: [false], // optional parameter
  );
  Reflector.registerMethod(
    User,
    'deactivate',
    [],
    true, // returns void
  );

  // Register constructors
  Reflector.registerConstructor(
    User,
    '', // default constructor
    (String name, int age, {required String id, bool isActive = true}) =>
        User(name, age, id: id, isActive: isActive),
    parameterTypes: [String, int, String, bool],
    parameterNames: ['name', 'age', 'id', 'isActive'],
    isRequired: [true, true, true, false],
    isNamed: [false, false, true, true],
  );

  Reflector.registerConstructor(
    User,
    'guest',
    () => User.guest(),
  );

  // Create a user instance
  final user = User('john_doe', 30, id: 'usr_123');
  print('Original user: $user');

  // Get the reflector instance
  final reflector = RuntimeReflector.instance;

  // Reflect on the User type
  final userType = reflector.reflectType(User);
  print('\nType information:');
  print('Type name: ${userType.name}');
  print('Properties: ${userType.properties.keys.join(', ')}');
  print('Methods: ${userType.methods.keys.join(', ')}');
  print('Constructors: ${userType.constructors.map((c) => c.name).join(', ')}');

  // Create an instance reflector
  final userReflector = reflector.reflect(user);

  // Read properties
  print('\nReading properties:');
  print('Name: ${userReflector.getField('name')}');
  print('Age: ${userReflector.getField('age')}');
  print('ID: ${userReflector.getField('id')}');
  print('Is active: ${userReflector.getField('isActive')}');

  // Modify properties
  print('\nModifying properties:');
  userReflector.setField('name', 'jane_doe');
  userReflector.setField('age', 25);
  print('Modified user: $user');

  // Invoke methods
  print('\nInvoking methods:');
  final greeting = userReflector.invoke('greet', ['Hi']);
  print('Greeting: $greeting');

  userReflector.invoke('birthday', []);
  print('After birthday: $user');

  userReflector.invoke('deactivate', []);
  print('After deactivation: $user');

  // Create new instances using reflection
  print('\nCreating instances:');
  final newUser = reflector.createInstance(
    User,
    positionalArgs: ['alice', 28],
    namedArgs: {'id': 'usr_456'},
  ) as User;
  print('Created user: $newUser');

  final guestUser = reflector.createInstance(
    User,
    constructorName: 'guest',
  ) as User;
  print('Created guest user: $guestUser');

  // Demonstrate error handling
  print('\nError handling:');
  try {
    userReflector.setField('id', 'new_id'); // Should throw - id is final
  } catch (e) {
    print('Expected error: $e');
  }

  try {
    userReflector
        .invoke('unknownMethod', []); // Should throw - method doesn't exist
  } catch (e) {
    print('Expected error: $e');
  }

  // Demonstrate non-reflectable class
  print('\nNon-reflectable class:');
  try {
    final nonReflectable = NonReflectable();
    reflector.reflect(nonReflectable);
  } catch (e) {
    print('Expected error: $e');
  }
}

// Class without @reflectable annotation for testing
class NonReflectable {
  String value = 'test';
}
