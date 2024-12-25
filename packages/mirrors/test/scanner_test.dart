import 'package:platform_mirrors/mirrors.dart';
import 'package:test/test.dart';

@reflectable
class TestClass {
  String name;
  final int id;
  List<String> tags;
  static const version = '1.0.0';

  TestClass(this.name, {required this.id, List<String>? tags})
      : tags = List<String>.from(tags ?? []); // Make sure tags is mutable

  TestClass.guest()
      : name = 'Guest',
        id = 0,
        tags = []; // Initialize with empty mutable list

  void addTag(String tag) {
    tags.add(tag);
  }

  String greet([String greeting = 'Hello']) {
    return '$greeting $name!';
  }

  static TestClass create(String name, {required int id}) {
    return TestClass(name, id: id);
  }
}

@reflectable
class GenericTestClass<T> {
  T value;
  List<T> items;

  GenericTestClass(this.value, {List<T>? items})
      : items = List<T>.from(items ?? []); // Make sure items is mutable

  void addItem(T item) {
    items.add(item);
  }

  T getValue() => value;
}

@reflectable
class ParentTestClass {
  String name;
  ParentTestClass(this.name);

  String getName() => name;
}

@reflectable
class ChildTestClass extends ParentTestClass {
  int age;
  ChildTestClass(String name, this.age) : super(name);

  @override
  String getName() => '$name ($age)';
}

void main() {
  group('Scanner', () {
    setUp(() {
      ReflectionRegistry.reset();
    });

    test('scans properties correctly', () {
      // Register base metadata
      ReflectionRegistry.register(TestClass);
      ReflectionRegistry.registerProperty(TestClass, 'name', String);
      ReflectionRegistry.registerProperty(TestClass, 'id', int,
          isWritable: false);
      ReflectionRegistry.registerProperty(TestClass, 'tags', List<String>);
      ReflectionRegistry.registerProperty(TestClass, 'version', String,
          isWritable: false);

      // Scan type
      Scanner.scanType(TestClass);
      final metadata = ReflectionRegistry.getPropertyMetadata(TestClass);

      expect(metadata, isNotNull);
      expect(metadata!['name'], isNotNull);
      expect(metadata['name']!.type, equals(String));
      expect(metadata['name']!.isWritable, isTrue);

      expect(metadata['id'], isNotNull);
      expect(metadata['id']!.type, equals(int));
      expect(metadata['id']!.isWritable, isFalse);

      expect(metadata['tags'], isNotNull);
      expect(metadata['tags']!.type, equals(List<String>));
      expect(metadata['tags']!.isWritable, isTrue);

      expect(metadata['version'], isNotNull);
      expect(metadata['version']!.type, equals(String));
      expect(metadata['version']!.isWritable, isFalse);
    });

    test('scans methods correctly', () {
      // Register base metadata
      ReflectionRegistry.register(TestClass);
      ReflectionRegistry.registerMethod(
        TestClass,
        'addTag',
        [String],
        true,
        parameterNames: ['tag'],
        isRequired: [true],
      );
      ReflectionRegistry.registerMethod(
        TestClass,
        'greet',
        [String],
        false,
        parameterNames: ['greeting'],
        isRequired: [false],
      );
      ReflectionRegistry.registerMethod(
        TestClass,
        'create',
        [String, int],
        false,
        parameterNames: ['name', 'id'],
        isRequired: [true, true],
        isNamed: [false, true],
        isStatic: true,
      );

      // Scan type
      Scanner.scanType(TestClass);
      final metadata = ReflectionRegistry.getMethodMetadata(TestClass);

      expect(metadata, isNotNull);

      // addTag method
      expect(metadata!['addTag'], isNotNull);
      expect(metadata['addTag']!.parameterTypes, equals([String]));
      expect(metadata['addTag']!.parameters.length, equals(1));
      expect(metadata['addTag']!.parameters[0].name, equals('tag'));
      expect(metadata['addTag']!.parameters[0].type, equals(String));
      expect(metadata['addTag']!.parameters[0].isRequired, isTrue);
      expect(metadata['addTag']!.returnsVoid, isTrue);
      expect(metadata['addTag']!.isStatic, isFalse);

      // greet method
      expect(metadata['greet'], isNotNull);
      expect(metadata['greet']!.parameterTypes, equals([String]));
      expect(metadata['greet']!.parameters.length, equals(1));
      expect(metadata['greet']!.parameters[0].name, equals('greeting'));
      expect(metadata['greet']!.parameters[0].type, equals(String));
      expect(metadata['greet']!.parameters[0].isRequired, isFalse);
      expect(metadata['greet']!.returnsVoid, isFalse);
      expect(metadata['greet']!.isStatic, isFalse);

      // create method
      expect(metadata['create'], isNotNull);
      expect(metadata['create']!.parameterTypes, equals([String, int]));
      expect(metadata['create']!.parameters.length, equals(2));
      expect(metadata['create']!.parameters[0].name, equals('name'));
      expect(metadata['create']!.parameters[0].type, equals(String));
      expect(metadata['create']!.parameters[0].isRequired, isTrue);
      expect(metadata['create']!.parameters[1].name, equals('id'));
      expect(metadata['create']!.parameters[1].type, equals(int));
      expect(metadata['create']!.parameters[1].isRequired, isTrue);
      expect(metadata['create']!.parameters[1].isNamed, isTrue);
      expect(metadata['create']!.returnsVoid, isFalse);
      expect(metadata['create']!.isStatic, isTrue);
    });

    test('scans constructors correctly', () {
      // Register base metadata
      ReflectionRegistry.register(TestClass);
      ReflectionRegistry.registerConstructor(
        TestClass,
        '',
        parameterTypes: [String, int, List<String>],
        parameterNames: ['name', 'id', 'tags'],
        isRequired: [true, true, false],
        isNamed: [false, true, true],
      );
      ReflectionRegistry.registerConstructor(
        TestClass,
        'guest',
      );

      // Scan type
      Scanner.scanType(TestClass);
      final metadata = ReflectionRegistry.getConstructorMetadata(TestClass);

      expect(metadata, isNotNull);
      expect(metadata!.length, equals(2));

      // Default constructor
      final defaultCtor = metadata.firstWhere((m) => m.name.isEmpty);
      expect(defaultCtor.parameterTypes, equals([String, int, List<String>]));
      expect(defaultCtor.parameters.length, equals(3));
      expect(defaultCtor.parameters[0].name, equals('name'));
      expect(defaultCtor.parameters[0].type, equals(String));
      expect(defaultCtor.parameters[0].isRequired, isTrue);
      expect(defaultCtor.parameters[1].name, equals('id'));
      expect(defaultCtor.parameters[1].type, equals(int));
      expect(defaultCtor.parameters[1].isRequired, isTrue);
      expect(defaultCtor.parameters[1].isNamed, isTrue);
      expect(defaultCtor.parameters[2].name, equals('tags'));
      expect(defaultCtor.parameters[2].type, equals(List<String>));
      expect(defaultCtor.parameters[2].isRequired, isFalse);
      expect(defaultCtor.parameters[2].isNamed, isTrue);

      // Guest constructor
      final guestCtor = metadata.firstWhere((m) => m.name == 'guest');
      expect(guestCtor.parameterTypes, isEmpty);
      expect(guestCtor.parameters, isEmpty);
    });

    test('scanned type works with reflection', () {
      // Register base metadata
      ReflectionRegistry.register(TestClass);
      ReflectionRegistry.registerProperty(TestClass, 'name', String);
      ReflectionRegistry.registerProperty(TestClass, 'id', int,
          isWritable: false);
      ReflectionRegistry.registerProperty(TestClass, 'tags', List<String>);
      ReflectionRegistry.registerMethod(
        TestClass,
        'addTag',
        [String],
        true,
        parameterNames: ['tag'],
        isRequired: [true],
      );
      ReflectionRegistry.registerMethod(
        TestClass,
        'greet',
        [String],
        false,
        parameterNames: ['greeting'],
        isRequired: [false],
      );
      ReflectionRegistry.registerConstructor(
        TestClass,
        '',
        parameterTypes: [String, int, List<String>],
        parameterNames: ['name', 'id', 'tags'],
        isRequired: [true, true, false],
        isNamed: [false, true, true],
        creator: (String name, {required int id, List<String>? tags}) =>
            TestClass(name, id: id, tags: tags),
      );
      ReflectionRegistry.registerConstructor(
        TestClass,
        'guest',
        creator: () => TestClass.guest(),
      );

      // Scan type
      Scanner.scanType(TestClass);

      final reflector = RuntimeReflector.instance;

      // Create instance
      final instance = reflector.createInstance(
        TestClass,
        positionalArgs: ['John'],
        namedArgs: {'id': 123},
      ) as TestClass;

      expect(instance.name, equals('John'));
      expect(instance.id, equals(123));
      expect(instance.tags, isEmpty);

      // Create guest instance
      final guest = reflector.createInstance(
        TestClass,
        constructorName: 'guest',
      ) as TestClass;

      expect(guest.name, equals('Guest'));
      expect(guest.id, equals(0));
      expect(guest.tags, isEmpty);

      // Reflect on instance
      final mirror = reflector.reflect(instance);

      // Access properties
      expect(mirror.getField(const Symbol('name')).reflectee, equals('John'));
      expect(mirror.getField(const Symbol('id')).reflectee, equals(123));

      // Modify properties
      mirror.setField(const Symbol('name'), 'Jane');
      expect(instance.name, equals('Jane'));

      // Invoke methods
      mirror.invoke(const Symbol('addTag'), ['test']);
      expect(instance.tags, equals(['test']));

      final greeting = mirror.invoke(const Symbol('greet'), ['Hi']).reflectee;
      expect(greeting, equals('Hi Jane!'));
    });

    test('handles generic types correctly', () {
      // Register base metadata
      ReflectionRegistry.register(GenericTestClass);
      ReflectionRegistry.registerProperty(GenericTestClass, 'value', dynamic);
      ReflectionRegistry.registerProperty(GenericTestClass, 'items', List);
      ReflectionRegistry.registerMethod(
        GenericTestClass,
        'addItem',
        [dynamic],
        true,
        parameterNames: ['item'],
        isRequired: [true],
      );
      ReflectionRegistry.registerMethod(
        GenericTestClass,
        'getValue',
        [],
        false,
      );

      // Scan type
      Scanner.scanType(GenericTestClass);
      final metadata = ReflectionRegistry.getPropertyMetadata(GenericTestClass);

      expect(metadata, isNotNull);
      expect(metadata!['value'], isNotNull);
      expect(metadata['items'], isNotNull);
      expect(metadata['items']!.type, equals(List));

      final methodMeta = ReflectionRegistry.getMethodMetadata(GenericTestClass);
      expect(methodMeta, isNotNull);
      expect(methodMeta!['addItem'], isNotNull);
      expect(methodMeta['getValue'], isNotNull);
    });

    test('handles inheritance correctly', () {
      // Register base metadata
      ReflectionRegistry.register(ParentTestClass);
      ReflectionRegistry.register(ChildTestClass);
      ReflectionRegistry.registerProperty(ParentTestClass, 'name', String);
      ReflectionRegistry.registerProperty(ChildTestClass, 'name', String);
      ReflectionRegistry.registerProperty(ChildTestClass, 'age', int);
      ReflectionRegistry.registerMethod(
        ParentTestClass,
        'getName',
        [],
        false,
      );
      ReflectionRegistry.registerMethod(
        ChildTestClass,
        'getName',
        [],
        false,
      );
      ReflectionRegistry.registerConstructor(
        ChildTestClass,
        '',
        parameterTypes: [String, int],
        parameterNames: ['name', 'age'],
        isRequired: [true, true],
        isNamed: [false, false],
        creator: (String name, int age) => ChildTestClass(name, age),
      );

      // Scan types
      Scanner.scanType(ParentTestClass);
      Scanner.scanType(ChildTestClass);

      final parentMeta =
          ReflectionRegistry.getPropertyMetadata(ParentTestClass);
      final childMeta = ReflectionRegistry.getPropertyMetadata(ChildTestClass);

      expect(parentMeta, isNotNull);
      expect(parentMeta!['name'], isNotNull);

      expect(childMeta, isNotNull);
      expect(childMeta!['name'], isNotNull);
      expect(childMeta['age'], isNotNull);

      final reflector = RuntimeReflector.instance;
      final child = reflector.createInstance(
        ChildTestClass,
        positionalArgs: ['John', 30],
      ) as ChildTestClass;

      final mirror = reflector.reflect(child);
      final result = mirror.invoke(const Symbol('getName'), []).reflectee;
      expect(result, equals('John (30)'));
    });
  });
}
