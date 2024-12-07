import 'package:platform_contracts/contracts.dart' hide ContainerContract;
import 'package:platform_container/platform_container.dart';

/// Example reflector implementation
class ExampleReflector implements ReflectorContract {
  @override
  ClassMirror? reflectClass(Type type) {
    // Implementation
    return null;
  }

  @override
  TypeMirror reflectType(Type type) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  InstanceMirror reflect(Object object) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  LibraryMirror reflectLibrary(Uri uri) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  dynamic createInstance(
    Type type, {
    List<dynamic>? positionalArgs,
    Map<String, dynamic>? namedArgs,
    String? constructorName,
  }) {
    // Implementation
    throw UnimplementedError();
  }
}

void main() {
  // Create container with example reflector
  final container = Container(ExampleReflector());

  // Register some bindings
  container.bind<String>((c) => 'Hello');
  container.bind<int>((c) => 42);

  // Resolve instances
  final greeting = container.make<String>();
  final number = container.make<int>();

  print('$greeting $number'); // Hello 42
}
