import 'package:platform_reflection/reflection.dart';
import 'package:test/test.dart';

@reflectable
class Person {
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
      Reflector.registerType(Person);

      // Register properties
      Reflector.registerPropertyMetadata(
        Person,
        'name',
        PropertyMetadata(
          name: 'name',
          type: String,
          isReadable: true,
          isWritable: true,
        ),
      );

      Reflector.registerPropertyMetadata(
        Person,
        'age',
        PropertyMetadata(
          name: 'age',
          type: int,
          isReadable: true,
          isWritable: true,
        ),
      );

      Reflector.registerPropertyMetadata(
        Person,
        'id',
        PropertyMetadata(
          name: 'id',
          type: String,
          isReadable: true,
          isWritable: false,
        ),
      );

      // Register methods
      Reflector.registerMethodMetadata(
        Person,
        'birthday',
        MethodMetadata(
          name: 'birthday',
          parameterTypes: [],
          parameters: [],
          returnsVoid: true,
        ),
      );

      Reflector.registerMethodMetadata(
        Person,
        'greet',
        MethodMetadata(
          name: 'greet',
          parameterTypes: [String],
          parameters: [
            ParameterMetadata(
              name: 'greeting',
              type: String,
              isRequired: true,
            ),
          ],
          returnsVoid: false,
        ),
      );

      // Register constructors
      Reflector.registerConstructorMetadata(
        Person,
        ConstructorMetadata(
          name: '',
          parameterTypes: [String, int, String],
          parameters: [
            ParameterMetadata(name: 'name', type: String, isRequired: true),
            ParameterMetadata(name: 'age', type: int, isRequired: true),
            ParameterMetadata(
                name: 'id', type: String, isRequired: true, isNamed: true),
          ],
        ),
      );

      Reflector.registerConstructorFactory(
        Person,
        '',
        (String name, int age, {required String id}) =>
            Person(name, age, id: id),
      );

      Reflector.registerConstructorMetadata(
        Person,
        ConstructorMetadata(
          name: 'guest',
          parameterTypes: [],
          parameters: [],
        ),
      );

      Reflector.registerConstructorFactory(
        Person,
        'guest',
        () => Person.guest(),
      );

      Reflector.registerConstructorMetadata(
        Person,
        ConstructorMetadata(
          name: 'withDefaults',
          parameterTypes: [String, int],
          parameters: [
            ParameterMetadata(name: 'name', type: String, isRequired: true),
            ParameterMetadata(name: 'age', type: int, isRequired: false),
          ],
        ),
      );

      Reflector.registerConstructorFactory(
        Person,
        'withDefaults',
        (String name, [int age = 18]) => Person.withDefaults(name, age),
      );

      reflector = RuntimeReflector.instance;
      person = Person('John', 30, id: '123');
    });

    group('Type Reflection', () {
      test('reflectType returns correct type metadata', () {
        final typeMirror = reflector.reflectType(Person);

        expect(typeMirror.name, equals('Person'));
        expect(typeMirror.properties.length, equals(3));
        expect(typeMirror.methods.length, equals(2)); // birthday and greet
        expect(typeMirror.constructors.length,
            equals(3)); // default, guest, withDefaults
      });

      test('reflect creates instance mirror', () {
        final instanceMirror = reflector.reflect(person);

        expect(instanceMirror, isNotNull);
        expect(instanceMirror.type.name, equals('Person'));
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
        final instanceMirror = reflector.reflect(person);

        expect(instanceMirror.getField(const Symbol('name')).reflectee,
            equals('John'));
        expect(
            instanceMirror.getField(const Symbol('age')).reflectee, equals(30));
        expect(instanceMirror.getField(const Symbol('id')).reflectee,
            equals('123'));
      });

      test('setField updates property value', () {
        final instanceMirror = reflector.reflect(person);

        instanceMirror.setField(const Symbol('name'), 'Jane');
        instanceMirror.setField(const Symbol('age'), 25);

        expect(person.name, equals('Jane'));
        expect(person.age, equals(25));
      });

      test('setField throws on final field', () {
        final instanceMirror = reflector.reflect(person);

        expect(
          () => instanceMirror.setField(const Symbol('id'), '456'),
          throwsA(isA<ReflectionException>()),
        );
      });
    });

    group('Method Invocation', () {
      test('invoke calls method with arguments', () {
        final instanceMirror = reflector.reflect(person);

        final result =
            instanceMirror.invoke(const Symbol('greet'), ['Hello']).reflectee;
        expect(result, equals('Hello, John!'));

        instanceMirror.invoke(const Symbol('birthday'), []);
        expect(person.age, equals(31));
      });

      test('invoke throws on invalid arguments', () {
        final instanceMirror = reflector.reflect(person);

        expect(
          () => instanceMirror.invoke(const Symbol('greet'), [42]),
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
