import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';

@reflectable
class Person with Reflector {
  String name;
  int age;
  final String id;

  Person(this.name, this.age, {required this.id});

  // Guest constructor
  Person.guest()
      : name = 'Guest',
        age = 0,
        id = 'guest';

  // Constructor with optional parameters
  Person.withDefaults(this.name, [this.age = 18]) : id = 'default';

  void birthday() {
    age++;
  }

  String greet(String greeting) {
    return '$greeting, $name!';
  }

  static Person create(String name, int age, String id) {
    return Person(name, age, id: id);
  }
}

// Class without @reflectable annotation for testing
class NotReflectable {
  String value = 'test';
}

void main() {
  group('RuntimeReflector', () {
    late RuntimeReflector reflector;
    late Person person;

    setUp(() {
      // Register Person as reflectable
      Reflector.register(Person);

      // Register properties
      Reflector.registerProperty(Person, 'name', String);
      Reflector.registerProperty(Person, 'age', int);
      Reflector.registerProperty(Person, 'id', String, isWritable: false);

      // Register methods
      Reflector.registerMethod(
        Person,
        'birthday',
        [],
        true,
      );
      Reflector.registerMethod(
        Person,
        'greet',
        [String],
        false,
        parameterNames: ['greeting'],
      );

      // Register constructors
      Reflector.registerConstructor(
        Person,
        '',
        (String name, int age, {required String id}) =>
            Person(name, age, id: id),
        parameterTypes: [String, int, String],
        parameterNames: ['name', 'age', 'id'],
        isRequired: [true, true, true],
        isNamed: [false, false, true],
      );

      Reflector.registerConstructor(
        Person,
        'guest',
        () => Person.guest(),
      );

      Reflector.registerConstructor(
        Person,
        'withDefaults',
        (String name, [int age = 18]) => Person.withDefaults(name, age),
        parameterTypes: [String, int],
        parameterNames: ['name', 'age'],
        isRequired: [true, false],
        isNamed: [false, false],
      );

      reflector = RuntimeReflector.instance;
      person = Person('John', 30, id: '123');
    });

    group('Type Reflection', () {
      test('reflectType returns correct type metadata', () {
        final metadata = reflector.reflectType(Person);

        expect(metadata.name, equals('Person'));
        expect(metadata.properties.length, equals(3));
        expect(metadata.methods.length, equals(2)); // birthday and greet
        expect(metadata.constructors.length,
            equals(3)); // default, guest, withDefaults
      });

      test('reflect creates instance reflector', () {
        final instanceReflector = reflector.reflect(person);

        expect(instanceReflector, isNotNull);
        expect(instanceReflector.type.name, equals('Person'));
      });

      test('throws NotReflectableException for non-reflectable class', () {
        final instance = NotReflectable();

        expect(
          () => reflector.reflect(instance),
          throwsA(isA<NotReflectableException>()),
        );
      });
    });

    group('Property Access', () {
      test('getField returns property value', () {
        final instanceReflector = reflector.reflect(person);

        expect(instanceReflector.getField('name'), equals('John'));
        expect(instanceReflector.getField('age'), equals(30));
        expect(instanceReflector.getField('id'), equals('123'));
      });

      test('setField updates property value', () {
        final instanceReflector = reflector.reflect(person);

        instanceReflector.setField('name', 'Jane');
        instanceReflector.setField('age', 25);

        expect(person.name, equals('Jane'));
        expect(person.age, equals(25));
      });

      test('setField throws on final field', () {
        final instanceReflector = reflector.reflect(person);

        expect(
          () => instanceReflector.setField('id', '456'),
          throwsA(isA<ReflectionException>()),
        );
      });
    });

    group('Method Invocation', () {
      test('invoke calls method with arguments', () {
        final instanceReflector = reflector.reflect(person);

        final result = instanceReflector.invoke('greet', ['Hello']);
        expect(result, equals('Hello, John!'));

        instanceReflector.invoke('birthday', []);
        expect(person.age, equals(31));
      });

      test('invoke throws on invalid arguments', () {
        final instanceReflector = reflector.reflect(person);

        expect(
          () => instanceReflector.invoke('greet', [42]),
          throwsA(isA<InvalidArgumentsException>()),
        );
      });
    });

    group('Constructor Invocation', () {
      test('creates instance with default constructor', () {
        final instance = reflector.createInstance(
          Person,
          positionalArgs: ['Alice', 25],
          namedArgs: {'id': '456'},
        ) as Person;

        expect(instance.name, equals('Alice'));
        expect(instance.age, equals(25));
        expect(instance.id, equals('456'));
      });

      test('creates instance with named constructor', () {
        final instance = reflector.createInstance(
          Person,
          constructorName: 'guest',
        ) as Person;

        expect(instance.name, equals('Guest'));
        expect(instance.age, equals(0));
        expect(instance.id, equals('guest'));
      });

      test('creates instance with optional parameters', () {
        final instance = reflector.createInstance(
          Person,
          constructorName: 'withDefaults',
          positionalArgs: ['Bob'],
        ) as Person;

        expect(instance.name, equals('Bob'));
        expect(instance.age, equals(18)); // Default value
        expect(instance.id, equals('default'));
      });

      test('throws on invalid constructor arguments', () {
        expect(
          () => reflector.createInstance(
            Person,
            positionalArgs: ['Alice'], // Missing required age
            namedArgs: {'id': '456'},
          ),
          throwsA(isA<InvalidArgumentsException>()),
        );
      });

      test('throws on non-existent constructor', () {
        expect(
          () => reflector.createInstance(
            Person,
            constructorName: 'nonexistent',
          ),
          throwsA(isA<ReflectionException>()),
        );
      });
    });
  });
}
