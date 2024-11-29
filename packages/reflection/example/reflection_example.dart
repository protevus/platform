import 'dart:isolate';
import 'package:platform_reflection/reflection.dart';

// Mark class as reflectable
@reflectable
class Person {
  String name;
  int age;
  final String id;

  Person(this.name, this.age, {required this.id});

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

// Function to run in isolate
void isolateFunction(SendPort sendPort) {
  sendPort.send('Hello from isolate!');
}

void main() async {
  // Register Person class for reflection
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

  // Register constructor
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
    (String name, int age, {required String id}) => Person(name, age, id: id),
  );

  // Get reflector instance
  final reflector = RuntimeReflector.instance;

  // Get mirror system
  final mirrorSystem = reflector.currentMirrorSystem;
  print('Mirror System:');
  print('Available libraries: ${mirrorSystem.libraries.keys.join(', ')}');
  print('Dynamic type: ${mirrorSystem.dynamicType.name}');
  print('Void type: ${mirrorSystem.voidType.name}');
  print('Never type: ${mirrorSystem.neverType.name}');

  // Create instance using reflection
  final person = reflector.createInstance(
    Person,
    positionalArgs: ['John', 30],
    namedArgs: {'id': '123'},
  ) as Person;

  print('\nCreated person: ${person.name}, age ${person.age}, id ${person.id}');

  // Get type information using mirror system
  final typeMirror = mirrorSystem.reflectType(Person);
  print('\nType information:');
  print('Name: ${typeMirror.name}');
  print('Properties: ${typeMirror.properties.keys}');
  print('Methods: ${typeMirror.methods.keys}');

  // Get instance mirror
  final instanceMirror = reflector.reflect(person);

  // Access properties
  print('\nProperty access:');
  print('name: ${instanceMirror.getField(const Symbol('name')).reflectee}');
  print('age: ${instanceMirror.getField(const Symbol('age')).reflectee}');

  // Modify properties
  instanceMirror.setField(const Symbol('name'), 'Jane');
  instanceMirror.setField(const Symbol('age'), 25);

  print('\nAfter modification:');
  print('name: ${person.name}');
  print('age: ${person.age}');

  // Invoke methods
  print('\nMethod invocation:');
  final greeting =
      instanceMirror.invoke(const Symbol('greet'), ['Hello']).reflectee;
  print('Greeting: $greeting');

  instanceMirror.invoke(const Symbol('birthday'), []);
  print('After birthday: age ${person.age}');

  // Try to modify final field (will throw)
  try {
    instanceMirror.setField(const Symbol('id'), '456');
  } catch (e) {
    print('\nTried to modify final field:');
    print('Error: $e');
  }

  // Library reflection using mirror system
  print('\nLibrary reflection:');
  final libraryMirror = mirrorSystem.findLibrary(const Symbol('dart:core'));
  print('Library name: ${libraryMirror.qualifiedName}');
  print('Library URI: ${libraryMirror.uri}');
  print('Top-level declarations: ${libraryMirror.declarations.keys}');

  // Check type relationships
  print('\nType relationships:');
  final stringType = mirrorSystem.reflectType(String);
  final dynamicType = mirrorSystem.dynamicType;
  print(
      'String assignable to dynamic: ${stringType.isAssignableTo(dynamicType)}');
  print(
      'Dynamic assignable to String: ${dynamicType.isAssignableTo(stringType)}');

  // Isolate reflection
  print('\nIsolate reflection:');

  // Get current isolate mirror from mirror system
  final currentIsolate = mirrorSystem.isolate;
  print(
      'Current isolate: ${currentIsolate.debugName} (isCurrent: ${currentIsolate.isCurrent})');

  // Create and reflect on a new isolate
  final receivePort = ReceivePort();
  final isolate = await Isolate.spawn(
    isolateFunction,
    receivePort.sendPort,
  );

  final isolateMirror =
      reflector.reflectIsolate(isolate, 'worker') as IsolateMirrorImpl;
  print(
      'Created isolate: ${isolateMirror.debugName} (isCurrent: ${isolateMirror.isCurrent})');

  // Add error and exit listeners
  isolateMirror.addErrorListener((error, stackTrace) {
    print('Isolate error: $error');
    print('Stack trace: $stackTrace');
  });

  isolateMirror.addExitListener((message) {
    print('Isolate exited with message: $message');
  });

  // Receive message from isolate
  final message = await receivePort.first;
  print('Received message: $message');

  // Control isolate
  await isolateMirror.pause();
  print('Isolate paused');

  await isolateMirror.resume();
  print('Isolate resumed');

  await isolateMirror.kill();
  print('Isolate killed');

  // Clean up
  receivePort.close();
}
