import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/reflection.dart';

/// Default reflector implementation for the container using RuntimeReflector.
class ContainerReflector implements ReflectorContract {
  final RuntimeReflector _reflector;

  ContainerReflector() : _reflector = RuntimeReflector.instance;

  @override
  ClassMirror? reflectClass(Type type) {
    try {
      return _reflector.reflectClass(type);
    } catch (_) {
      return null;
    }
  }

  @override
  TypeMirror reflectType(Type type) {
    return _reflector.reflectType(type);
  }

  @override
  InstanceMirror reflect(Object object) {
    return _reflector.reflect(object);
  }

  @override
  LibraryMirror reflectLibrary(Uri uri) {
    return _reflector.reflectLibrary(uri);
  }

  @override
  dynamic createInstance(
    Type type, {
    List<dynamic>? positionalArgs,
    Map<String, dynamic>? namedArgs,
    String? constructorName,
  }) {
    return _reflector.createInstance(
      type,
      positionalArgs: positionalArgs,
      namedArgs: namedArgs,
      constructorName: constructorName,
    );
  }
}
