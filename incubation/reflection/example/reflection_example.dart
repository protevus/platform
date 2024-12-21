import 'package:platform_reflection/mirrors.dart';

// Custom annotation to demonstrate metadata
class Validate {
  final String pattern;
  const Validate(this.pattern);
}

// Interface to demonstrate reflection with interfaces
@reflectable
abstract class Identifiable {
  String get id;
}

// Base class to demonstrate inheritance
@reflectable
abstract class Entity implements Identifiable {
  final String _id;

  Entity(this._id);

  @override
  String get id => _id;

  @override
  String toString() => 'Entity($_id)';
}

// Generic class to demonstrate type parameters
@reflectable
class Container<T> {
  final T value;

  Container(this.value);

  T getValue() => value;
}

@reflectable
class User extends Entity {
  @Validate(r'^[a-zA-Z\s]+$')
  String name;

  int age;

  final List<String> tags;

  User(String id, this.name, this.age, [this.tags = const []]) : super(id) {
    _userCount++;
  }

  User.guest() : this('guest', 'Guest User', 0);

  static int _userCount = 0;
  static int get userCount => _userCount;

  String greet([String greeting = 'Hello']) {
    return '$greeting $name!';
  }

  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }

  String getName() => name;

  @override
  String toString() =>
      'User($id, $name, age: $age)${tags.isNotEmpty ? " [${tags.join(", ")}]" : ""}';
}

void main() async {
  // Register classes for reflection
  Reflector.register(Identifiable);
  Reflector.register(Entity);
  Reflector.register(User);
  Reflector.register(Container);

  // Register Container<int> specifically for reflection
  final container = Container<int>(42);
  Reflector.register(container.runtimeType);

  // Register property metadata directly
  Reflector.registerPropertyMetadata(
    User,
    'name',
    PropertyMetadata(
      name: 'name',
      type: String,
      isReadable: true,
      isWritable: true,
      attributes: [Validate(r'^[a-zA-Z\s]+$')],
    ),
  );

  Reflector.registerPropertyMetadata(
    User,
    'age',
    PropertyMetadata(
      name: 'age',
      type: int,
      isReadable: true,
      isWritable: true,
    ),
  );

  Reflector.registerPropertyMetadata(
    User,
    'tags',
    PropertyMetadata(
      name: 'tags',
      type: List,
      isReadable: true,
      isWritable: false,
    ),
  );

  Reflector.registerPropertyMetadata(
    User,
    'id',
    PropertyMetadata(
      name: 'id',
      type: String,
      isReadable: true,
      isWritable: false,
    ),
  );

  // Register User methods
  Reflector.registerMethod(
    User,
    'greet',
    [String],
    false,
    parameterNames: ['greeting'],
    isRequired: [false],
  );

  Reflector.registerMethod(
    User,
    'addTag',
    [String],
    true,
    parameterNames: ['tag'],
    isRequired: [true],
  );

  Reflector.registerMethod(
    User,
    'getName',
    [],
    false,
  );

  // Register constructors with creators
  Reflector.registerConstructor(
    User,
    '',
    parameterTypes: [String, String, int, List],
    parameterNames: ['id', 'name', 'age', 'tags'],
    isRequired: [true, true, true, false],
    creator: (id, name, age, [tags]) => User(
      id as String,
      name as String,
      age as int,
      tags as List<String>? ?? const [],
    ),
  );

  Reflector.registerConstructor(
    User,
    'guest',
    creator: () => User.guest(),
  );

  // Create reflector instance
  final reflector = RuntimeReflector.instance;

  // Demonstrate generic type reflection
  print('Container value: ${container.getValue()}');

  try {
    // Create User instance using reflection
    final user = reflector.createInstance(
      User,
      positionalArgs: [
        'user1',
        'John Doe',
        30,
        ['admin', 'user']
      ],
    ) as User;

    print('\nCreated user: $user');

    // Create guest user using named constructor
    final guest = reflector.createInstance(
      User,
      constructorName: 'guest',
    ) as User;

    print('Created guest: $guest');

    // Demonstrate property reflection
    final userMirror = reflector.reflect(user);

    // Get property values
    print('\nProperty values:');
    print('ID: ${userMirror.getField(const Symbol('id')).reflectee}');
    print('Name: ${userMirror.getField(const Symbol('name')).reflectee}');
    print('Age: ${userMirror.getField(const Symbol('age')).reflectee}');
    print('Tags: ${userMirror.getField(const Symbol('tags')).reflectee}');

    // Try to modify properties
    userMirror.setField(const Symbol('name'), 'Jane Doe');
    userMirror.setField(const Symbol('age'), 25);
    print('\nAfter property changes: $user');

    // Try to modify read-only property (should throw)
    try {
      userMirror.setField(const Symbol('id'), 'new_id');
      print('ERROR: Should not be able to modify read-only property');
    } catch (e) {
      print('\nExpected error when modifying read-only property id: $e');
    }

    // Invoke methods
    final greeting = userMirror.invoke(const Symbol('greet'), ['Hi']).reflectee;
    print('\nGreeting: $greeting');

    userMirror.invoke(const Symbol('addTag'), ['vip']);
    print('After adding tag: $user');

    final name = userMirror.invoke(const Symbol('getName'), []).reflectee;
    print('Got name: $name');

    // Demonstrate type metadata and relationships
    final userType = reflector.reflectType(User);
    print('\nType information:');
    print('Type name: ${userType.name}');

    // Show available properties
    final properties = (userType as dynamic).properties;
    print('\nDeclared properties:');
    properties.forEach((name, metadata) {
      print(
          '- $name: ${metadata.type}${metadata.isWritable ? "" : " (read-only)"}');
      if (metadata.attributes.isNotEmpty) {
        metadata.attributes.forEach((attr) {
          if (attr is Validate) {
            print('  @Validate(${attr.pattern})');
          }
        });
      }
    });

    // Show available methods
    final methods = (userType as dynamic).methods;
    print('\nDeclared methods:');
    methods.forEach((name, metadata) {
      print('- $name');
    });

    // Show constructors
    final constructors = (userType as dynamic).constructors;
    print('\nDeclared constructors:');
    constructors.forEach((metadata) {
      print('- ${metadata.name}');
    });

    // Demonstrate type relationships
    final identifiableType = reflector.reflectType(Identifiable);
    print('\nType relationships:');
    print(
        'User is assignable to Identifiable: ${userType.isAssignableTo(identifiableType)}');
    print(
        'User is subtype of Entity: ${userType.isSubtypeOf(reflector.reflectType(Entity))}');
  } catch (e) {
    print('Error: $e');
    print(e.runtimeType);
  }
}
