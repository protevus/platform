// import 'package:test/test.dart';
// import 'package:platform_mirrors/src/discovery/parser/class_parser.dart';

// void main() {
//   group('Parser Tests', () {
//     late ClassParser parser;

//     setUp(() {
//       parser = ClassParser();
//     });

//     test('parses basic class', () {
//       final source = '''
//         class BasicClass {
//           String name;
//           int age;

//           void doSomething() {
//             print('Hello');
//           }
//         }
//       ''';

//       final result = parser.parse(source);
//       expect(result.isSuccess, isTrue);

//       final metadata = result.result!;
//       expect(metadata.name, equals('BasicClass'));
//       expect(metadata.properties.length, equals(2));
//       expect(metadata.methods.length, equals(1));
//       expect(metadata.constructors.length, equals(0));
//     });

//     test('parses generic class', () {
//       final source = '''
//         class Container<T> {
//           T value;
          
//           Container(this.value);
          
//           T getValue() => value;
//           void setValue(T newValue) {
//             value = newValue;
//           }
//         }
//       ''';

//       final result = parser.parse(source);
//       expect(result.isSuccess, isTrue);

//       final metadata = result.result!;
//       expect(metadata.name, equals('Container'));
//       expect(metadata.typeParameters, equals(['T']));
//       expect(metadata.properties.length, equals(1));
//       expect(metadata.methods.length, equals(2));
//       expect(metadata.constructors.length, equals(1));
//     });

//     test('parses class with inheritance and interfaces', () {
//       final source = '''
//         abstract class Animal implements Living, Breathing {
//           String species;
//           int age;
          
//           Animal(this.species, this.age);
          
//           void makeSound();
//           void move() {
//             print('Moving...');
//           }
//         }
//       ''';

//       final result = parser.parse(source);
//       expect(result.isSuccess, isTrue);

//       final metadata = result.result!;
//       expect(metadata.name, equals('Animal'));
//       expect(metadata.isAbstract, isTrue);
//       expect(metadata.interfaces, equals(['Living', 'Breathing']));
//       expect(metadata.properties.length, equals(2));
//       expect(metadata.methods.length, equals(2));
//       expect(metadata.constructors.length, equals(1));
//     });

//     test('parses properties with different modifiers', () {
//       final source = '''
//         class PropertyTest {
//           static const int MAX_VALUE = 100;
//           final String id;
//           late String? name;
//           List<int> numbers = [];
          
//           PropertyTest(this.id);
          
//           String get displayName => name ?? 'Unknown';
//           set displayName(String value) => name = value;
//         }
//       ''';

//       final result = parser.parse(source);
//       expect(result.isSuccess, isTrue);

//       final metadata = result.result!;
//       final props = metadata.properties;

//       expect(props['MAX_VALUE']!.isStatic, isTrue);
//       expect(props['id']!.isWritable, isFalse);
//       expect(props['name']!.isNullable, isTrue);
//       expect(props['numbers']!.hasInitializer, isTrue);
//       expect(props['displayName']!.isReadable, isTrue);
//       expect(props['displayName']!.isWritable, isTrue);
//     });

//     test('parses methods with different signatures', () {
//       final source = '''
//         class MethodTest {
//           static void staticMethod() {}
          
//           Future<String> asyncMethod() async {
//             return 'done';
//           }
          
//           Stream<int> streamMethod() async* {
//             yield 1;
//           }
          
//           void optionalParams([int count = 0]) {}
          
//           void namedParams({required String name, int? age}) {}
          
//           T genericMethod<T>(T value) => value;
//         }
//       ''';

//       final result = parser.parse(source);
//       expect(result.isSuccess, isTrue);

//       final metadata = result.result!;
//       final methods = metadata.methods;

//       expect(methods['staticMethod']!.isStatic, isTrue);
//       expect(methods['asyncMethod']!.isAsync, isTrue);
//       expect(methods['streamMethod']!.isGenerator, isTrue);

//       final optionalMethod = methods['optionalParams']!;
//       expect(optionalMethod.parameters.length, equals(1));
//       expect(optionalMethod.parameters[0].isRequired, isFalse);

//       final namedMethod = methods['namedParams']!;
//       expect(namedMethod.parameters.length, equals(2));
//       expect(namedMethod.parameters[0].isRequired, isTrue);
//       expect(namedMethod.parameters[1].isNullable, isTrue);
//     });

//     test('parses constructors with different forms', () {
//       final source = '''
//         class ConstructorTest {
//           final String id;
//           String? name;
//           int count;
          
//           ConstructorTest(this.id, [this.name]);
          
//           ConstructorTest.named({
//             required this.id,
//             this.name,
//             this.count = 0,
//           });
          
//           factory ConstructorTest.create(String value) {
//             return ConstructorTest(value);
//           }
          
//           const ConstructorTest.constant(this.id)
//               : name = null,
//                 count = 0;
//         }
//       ''';

//       final result = parser.parse(source);
//       expect(result.isSuccess, isTrue);

//       final metadata = result.result!;
//       final constructors = metadata.constructors;

//       expect(constructors.length, equals(4));

//       // Default constructor
//       expect(constructors[0].name, isEmpty);
//       expect(constructors[0].parameters.length, equals(2));
//       expect(constructors[0].parameters[1].isRequired, isFalse);

//       // Named constructor
//       expect(constructors[1].name, equals('named'));
//       expect(constructors[1].parameters.length, equals(3));
//       expect(constructors[1].parameters[0].isRequired, isTrue);

//       // Factory constructor
//       expect(constructors[2].name, equals('create'));
//       expect(constructors[2].parameters.length, equals(1));

//       // Const constructor
//       expect(constructors[3].name, equals('constant'));
//       expect(constructors[3].parameters.length, equals(1));
//     });

//     test('handles errors gracefully', () {
//       final source = '''
//         class InvalidClass {
//           void missingClosingBrace() {
//       ''';

//       final result = parser.parse(source);
//       expect(result.isSuccess, isFalse);
//       expect(result.errors, isNotEmpty);
//     });
//   });
// }
