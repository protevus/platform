import 'package:platform_contracts/contracts.dart';
import 'package:platform_mirrors/mirrors.dart';
import 'package:test/test.dart';

@reflectable
class Person {
  String name;
  final int age;

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
  group('RuntimeReflector', () {
    late RuntimeReflector reflector;

    setUp(() {
      reflector = RuntimeReflector.instance;
      ReflectionRegistry.reset();
    });

    group('Type Reflection', () {
      test('reflectType returns correct type metadata', () {
        ReflectionRegistry.register(Person);
        final mirror = reflector.reflectType(Person);
        expect(mirror.simpleName.toString(), contains('Person'));
      });

      test('reflect creates instance mirror', () {
        ReflectionRegistry.register(Person);
        final person = Person('John', 30);
        final mirror = reflector.reflect(person);
        expect(mirror.reflectee, equals(person));
      });

      test('throws NotReflectableException for non-reflectable class', () {
        expect(
          () => reflector.reflectType(Object),
          throwsA(isA<NotReflectableException>()),
        );
      });
    });

    group('Property Access', () {
      late Person person;
      late InstanceMirrorContract mirror;

      setUp(() {
        ReflectionRegistry.register(Person);
        ReflectionRegistry.registerProperty(Person, 'name', String);
        ReflectionRegistry.registerProperty(Person, 'age', int,
            isWritable: false);

        person = Person('John', 30);
        mirror = reflector.reflect(person);
      });

      test('getField returns property value', () {
        expect(
          mirror.getField(const Symbol('name')).reflectee,
          equals('John'),
        );
        expect(
          mirror.getField(const Symbol('age')).reflectee,
          equals(30),
        );
      });

      test('setField updates property value', () {
        mirror.setField(const Symbol('name'), 'Jane');
        expect(person.name, equals('Jane'));
      });

      test('setField throws on final field', () {
        expect(
          () => mirror.setField(const Symbol('age'), 25),
          throwsA(isA<ReflectionException>()),
        );
      });
    });

    group('Method Invocation', () {
      late Person person;
      late InstanceMirrorContract mirror;

      setUp(() {
        ReflectionRegistry.register(Person);
        ReflectionRegistry.registerMethod(
          Person,
          'greet',
          [String],
          false,
          parameterNames: ['greeting'],
          isRequired: [false],
        );

        person = Person('John', 30);
        mirror = reflector.reflect(person);
      });

      test('invoke calls method with arguments', () {
        final result = mirror.invoke(const Symbol('greet'), ['Hi']).reflectee;
        expect(result, equals('Hi John!'));
      });

      test('invoke throws on invalid arguments', () {
        expect(
          () => mirror.invoke(const Symbol('greet'), [42]),
          throwsA(isA<ReflectionException>()),
        );
      });
    });

    group('Constructor Invocation', () {
      setUp(() {
        ReflectionRegistry.register(Person);
        ReflectionRegistry.registerConstructor(
          Person,
          '',
          parameterTypes: [String, int],
          parameterNames: ['name', 'age'],
          creator: (String name, int age) => Person(name, age),
        );
        ReflectionRegistry.registerConstructor(
          Person,
          'guest',
          creator: () => Person.guest(),
        );
      });

      test('creates instance with default constructor', () {
        final instance = reflector.createInstance(
          Person,
          positionalArgs: ['John', 30],
        ) as Person;

        expect(instance.name, equals('John'));
        expect(instance.age, equals(30));
      });

      test('creates instance with named constructor', () {
        final instance = reflector.createInstance(
          Person,
          constructorName: 'guest',
        ) as Person;

        expect(instance.name, equals('Guest'));
        expect(instance.age, equals(0));
      });

      test('creates instance with optional parameters', () {
        final instance = reflector.createInstance(
          Person,
          positionalArgs: ['John', 30],
        ) as Person;

        expect(instance.greet(), equals('Hello John!'));
        expect(instance.greet('Hi'), equals('Hi John!'));
      });

      test('throws on invalid constructor arguments', () {
        expect(
          () => reflector.createInstance(
            Person,
            positionalArgs: ['John'],
          ),
          throwsA(isA<InvalidArgumentsException>()),
        );
      });

      test('throws on non-existent constructor', () {
        expect(
          () => reflector.createInstance(
            Person,
            constructorName: 'invalid',
          ),
          throwsA(isA<ReflectionException>()),
        );
      });
    });
  });
}
