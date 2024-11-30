import 'package:platform_reflection/reflection.dart';

@reflectable
class Person {
  String name;
  int age;

  Person(this.name, this.age);

  Person.guest()
      : name = 'Guest',
        age = 0;

  String greet([String greeting = 'Hello']) {
    return '$greeting $name!';
  }

  @override
  String toString() => '$name ($age)';
}

void main() {
  // Register Person class for reflection
  Reflector.register(Person);

  // Register properties
  Reflector.registerProperty(Person, 'name', String);
  Reflector.registerProperty(Person, 'age', int);

  // Register methods
  Reflector.registerMethod(
    Person,
    'greet',
    [String],
    false,
    parameterNames: ['greeting'],
    isRequired: [false],
  );

  // Register constructors
  Reflector.registerConstructor(
    Person,
    '',
    parameterTypes: [String, int],
    parameterNames: ['name', 'age'],
  );

  Reflector.registerConstructor(
    Person,
    'guest',
  );

  // Create reflector instance
  final reflector = RuntimeReflector.instance;

  // Create Person instance using reflection
  final person = reflector.createInstance(
    Person,
    positionalArgs: ['John', 30],
  ) as Person;

  print(person); // John (30)

  // Create guest instance using reflection
  final guest = reflector.createInstance(
    Person,
    constructorName: 'guest',
  ) as Person;

  print(guest); // Guest (0)

  // Get property values
  final mirror = reflector.reflect(person);
  print(mirror.getField(const Symbol('name')).reflectee); // John
  print(mirror.getField(const Symbol('age')).reflectee); // 30

  // Set property values
  mirror.setField(const Symbol('name'), 'Jane');
  print(person.name); // Jane

  // Invoke methods
  final greeting = mirror.invoke(const Symbol('greet'), ['Hi']).reflectee;
  print(greeting); // Hi Jane!
}
