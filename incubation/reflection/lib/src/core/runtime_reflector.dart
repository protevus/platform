import 'package:meta/meta.dart';
import 'dart:isolate' as isolate;
import '../exceptions.dart';
import '../metadata.dart';
import '../mirrors.dart';
import 'reflector.dart';
import '../mirrors/base_mirror.dart';
import '../mirrors/class_mirror_impl.dart';
import '../mirrors/instance_mirror_impl.dart';
import '../mirrors/method_mirror_impl.dart';
import '../mirrors/parameter_mirror_impl.dart';
import '../mirrors/type_mirror_impl.dart';
import '../mirrors/type_variable_mirror_impl.dart';
import '../mirrors/variable_mirror_impl.dart';
import '../mirrors/library_mirror_impl.dart';
import '../mirrors/library_dependency_mirror_impl.dart';
import '../mirrors/isolate_mirror_impl.dart';
import '../mirrors/mirror_system_impl.dart';
import '../mirrors/special_types.dart';

/// A pure runtime reflection system that provides type introspection and manipulation.
class RuntimeReflector {
  /// The singleton instance of the reflector.
  static final instance = RuntimeReflector._();

  /// The current mirror system.
  late final MirrorSystemImpl _mirrorSystem;

  /// Cache of class mirrors to prevent infinite recursion
  final Map<Type, ClassMirror> _classMirrorCache = {};

  RuntimeReflector._() {
    // Initialize mirror system
    _mirrorSystem = MirrorSystemImpl.current();
  }

  /// Resolves parameters for method or constructor invocation
  List<dynamic> resolveParameters(
    List<ParameterMirror> parameters,
    List<dynamic> positionalArgs,
    Map<Symbol, dynamic>? namedArgs,
  ) {
    final resolvedArgs = List<dynamic>.filled(parameters.length, null);
    var positionalIndex = 0;

    ClassMirror? _getClassMirror(Type? type) {
      if (type == null) return null;
      try {
        return reflectClass(type);
      } catch (e) {
        return null;
      }
    }

    bool _isTypeCompatible(dynamic value, TypeMirror expectedType) {
      // Handle null values
      if (value == null) {
        // For now, accept null for any type as we don't have nullability information
        return true;
      }

      // Get the actual type to check
      Type actualType;
      if (value is Type) {
        actualType = value;
      } else {
        actualType = value.runtimeType;
      }

      // Get the expected type
      Type expectedRawType = expectedType.reflectedType;

      // Special case handling
      if (expectedRawType == dynamic || expectedRawType == Object) {
        return true;
      }

      // If types are exactly the same, they're compatible
      if (actualType == expectedRawType) {
        return true;
      }

      // Handle generic type parameters
      if (expectedType is TypeVariableMirrorImpl) {
        return _isTypeCompatible(value, expectedType.upperBound);
      }

      // Get class mirrors
      final actualMirror = _getClassMirror(actualType);
      final expectedMirror = _getClassMirror(expectedRawType);

      // If we can't get mirrors, assume compatible
      if (actualMirror == null || expectedMirror == null) {
        return true;
      }

      return actualMirror.isSubclassOf(expectedMirror);
    }

    for (var i = 0; i < parameters.length; i++) {
      final param = parameters[i];
      dynamic value;

      if (param.isNamed) {
        // Handle named parameter
        final paramName = Symbol(param.name);
        if (namedArgs?.containsKey(paramName) ?? false) {
          value = namedArgs![paramName];
          resolvedArgs[i] = value;
        } else if (param.hasDefaultValue) {
          value = param.defaultValue?.reflectee;
          resolvedArgs[i] = value;
        } else if (!param.isOptional) {
          throw InvalidArgumentsException(
            'Missing required named parameter: ${param.name}',
            param.type.reflectedType,
          );
        }
      } else {
        // Handle positional parameter
        if (positionalIndex < positionalArgs.length) {
          value = positionalArgs[positionalIndex++];
          resolvedArgs[i] = value;
        } else if (param.hasDefaultValue) {
          value = param.defaultValue?.reflectee;
          resolvedArgs[i] = value;
        } else if (!param.isOptional) {
          throw InvalidArgumentsException(
            'Missing required positional parameter at index $i',
            param.type.reflectedType,
          );
        }
      }

      // Validate argument type if a value was provided or required
      if (!param.isOptional || value != null) {
        if (!_isTypeCompatible(value, param.type)) {
          final actualType = value?.runtimeType.toString() ?? 'null';
          throw InvalidArgumentsException(
            'Invalid argument type for parameter ${param.name}: '
            'expected ${param.type.name}, got $actualType',
            param.type.reflectedType,
          );
        }
      }
    }

    return resolvedArgs;
  }

  /// Creates a new instance of a type using reflection.
  dynamic createInstance(
    Type type, {
    dynamic positionalArgs,
    Map<String, dynamic>? namedArgs,
    String? constructorName,
  }) {
    try {
      // Check if type is reflectable
      if (!Reflector.isReflectable(type)) {
        throw NotReflectableException(type);
      }

      // Get constructor metadata
      final constructors = Reflector.getConstructorMetadata(type);
      if (constructors == null || constructors.isEmpty) {
        throw ReflectionException('No constructors found for type $type');
      }

      // Find matching constructor
      final constructor = constructors.firstWhere(
        (c) => c.name == (constructorName ?? ''),
        orElse: () => throw ReflectionException(
            'Constructor ${constructorName ?? ''} not found on type $type'),
      );

      // Get constructor factory
      final factory = Reflector.getInstanceCreator(type, constructor.name);
      if (factory == null) {
        throw ReflectionException(
            'No factory found for constructor ${constructor.name} on type $type');
      }

      // Convert positional args to List if single value provided
      final args = positionalArgs is List
          ? positionalArgs
          : positionalArgs != null
              ? [positionalArgs]
              : [];

      // Convert string keys to symbols for named args
      final symbolNamedArgs =
          namedArgs?.map((key, value) => MapEntry(Symbol(key), value)) ?? {};

      // Get class mirror
      final mirror = reflectClass(type);

      // Resolve parameters using constructor metadata
      final resolvedArgs = resolveParameters(
        constructor.parameters
            .map((param) => ParameterMirrorImpl(
                  name: param.name,
                  type: TypeMirrorImpl(
                    type: param.type,
                    name: param.type.toString(),
                    owner: mirror,
                    metadata: const [],
                  ),
                  owner: mirror,
                  isOptional: !param.isRequired,
                  isNamed: param.isNamed,
                  metadata: const [],
                ))
            .toList(),
        args,
        symbolNamedArgs,
      );

      // Split resolved args into positional and named
      final positionalParams = <dynamic>[];
      final namedParams = <Symbol, dynamic>{};
      var index = 0;
      for (var param in constructor.parameters) {
        if (param.isNamed) {
          if (resolvedArgs[index] != null) {
            namedParams[Symbol(param.name)] = resolvedArgs[index];
          }
        } else {
          positionalParams.add(resolvedArgs[index]);
        }
        index++;
      }

      // Create instance using factory with proper parameter handling
      return Function.apply(factory, positionalParams, namedParams);
    } catch (e) {
      if (e is InvalidArgumentsException || e is ReflectionException) {
        throw e;
      }
      throw ReflectionException('Failed to create instance: $e');
    }
  }

  /// Creates a TypeMirror for a given type.
  TypeMirror _createTypeMirror(Type type, String name, [ClassMirror? owner]) {
    if (type == voidType) {
      return TypeMirrorImpl.voidType(owner);
    }
    if (type == dynamicType) {
      return TypeMirrorImpl.dynamicType(owner);
    }
    return TypeMirrorImpl(
      type: type,
      name: name,
      owner: owner,
      metadata: [],
    );
  }

  /// Reflects on a type, returning its class mirror.
  ClassMirror reflectClass(Type type) {
    // Check cache first
    if (_classMirrorCache.containsKey(type)) {
      return _classMirrorCache[type]!;
    }

    // Check if type is reflectable
    if (!Reflector.isReflectable(type)) {
      throw NotReflectableException(type);
    }

    // Create empty mirror and add to cache to break recursion
    final emptyMirror = ClassMirrorImpl(
      type: type,
      name: type.toString(),
      owner: null,
      declarations: const {},
      instanceMembers: const {},
      staticMembers: const {},
      metadata: [],
    );
    _classMirrorCache[type] = emptyMirror;

    // Get metadata from registry
    final properties = Reflector.getPropertyMetadata(type) ?? {};
    final methods = Reflector.getMethodMetadata(type) ?? {};
    final constructors = Reflector.getConstructorMetadata(type) ?? [];
    final typeMetadata = Reflector.getTypeMetadata(type);

    // Create declarations map
    final declarations = <Symbol, DeclarationMirror>{};

    // Add properties as variable declarations
    properties.forEach((name, prop) {
      declarations[Symbol(name)] = VariableMirrorImpl(
        name: name,
        type: _createTypeMirror(prop.type, prop.type.toString(), emptyMirror),
        owner: emptyMirror,
        isStatic: false,
        isFinal: !prop.isWritable,
        isConst: false,
        metadata: [],
      );
    });

    // Add methods as method declarations
    methods.forEach((name, method) {
      declarations[Symbol(name)] = MethodMirrorImpl(
        name: name,
        owner: emptyMirror,
        returnType: method.returnsVoid
            ? TypeMirrorImpl.voidType(emptyMirror)
            : _createTypeMirror(
                method.returnType, method.returnType.toString(), emptyMirror),
        parameters: method.parameters
            .map((param) => ParameterMirrorImpl(
                  name: param.name,
                  type: _createTypeMirror(
                      param.type, param.type.toString(), emptyMirror),
                  owner: emptyMirror,
                  isOptional: !param.isRequired,
                  isNamed: param.isNamed,
                  hasDefaultValue: param.defaultValue != null,
                  defaultValue: param.defaultValue != null
                      ? reflect(param.defaultValue!)
                      : null,
                  metadata: [],
                ))
            .toList(),
        isStatic: method.isStatic,
        metadata: [],
      );
    });

    // Add constructors as method declarations
    for (final ctor in constructors) {
      declarations[Symbol(ctor.name)] = MethodMirrorImpl(
        name: ctor.name,
        owner: emptyMirror,
        returnType: emptyMirror,
        parameters: ctor.parameters
            .map((param) => ParameterMirrorImpl(
                  name: param.name,
                  type: _createTypeMirror(
                      param.type, param.type.toString(), emptyMirror),
                  owner: emptyMirror,
                  isOptional: !param.isRequired,
                  isNamed: param.isNamed,
                  hasDefaultValue: param.defaultValue != null,
                  defaultValue: param.defaultValue != null
                      ? reflect(param.defaultValue!)
                      : null,
                  metadata: [],
                ))
            .toList(),
        isStatic: false,
        isConstructor: true,
        metadata: [],
      );
    }

    // Create instance and static member maps
    final instanceMembers = <Symbol, MethodMirror>{};
    final staticMembers = <Symbol, MethodMirror>{};

    methods.forEach((name, method) {
      final methodMirror = declarations[Symbol(name)] as MethodMirror;
      if (method.isStatic) {
        staticMembers[Symbol(name)] = methodMirror;
      } else {
        instanceMembers[Symbol(name)] = methodMirror;
      }
    });

    // Create class mirror
    final mirror = ClassMirrorImpl(
      type: type,
      name: type.toString(),
      owner: null,
      declarations: declarations,
      instanceMembers: instanceMembers,
      staticMembers: staticMembers,
      metadata: [],
      superclass: typeMetadata?.supertype != null
          ? reflectClass(typeMetadata!.supertype!.type)
          : null,
      superinterfaces:
          typeMetadata?.interfaces.map((i) => reflectClass(i.type)).toList() ??
              const [],
    );

    // Update cache with complete mirror
    _classMirrorCache[type] = mirror;

    // Update owners
    declarations.forEach((_, decl) {
      if (decl is MutableOwnerMirror) {
        decl.setOwner(mirror);
      }
    });

    return mirror;
  }

  /// Reflects on a type, returning its type mirror.
  TypeMirror reflectType(Type type) {
    // Check if type is reflectable
    if (!Reflector.isReflectable(type)) {
      throw NotReflectableException(type);
    }

    return _createTypeMirror(type, type.toString());
  }

  /// Creates a new instance reflector for the given object.
  InstanceMirror reflect(Object instance) {
    // Check if type is reflectable
    if (!Reflector.isReflectable(instance.runtimeType)) {
      throw NotReflectableException(instance.runtimeType);
    }

    return InstanceMirrorImpl(
      reflectee: instance,
      type: reflectClass(instance.runtimeType),
    );
  }

  /// Reflects on a library, returning its library mirror.
  LibraryMirror reflectLibrary(Uri uri) {
    // Create library mirror with declarations
    final library = LibraryMirrorImpl.withDeclarations(
      name: uri.toString(),
      uri: uri,
      owner: null,
      libraryDependencies: _getLibraryDependencies(uri),
      metadata: [],
    );

    // Add to mirror system
    _mirrorSystem.addLibrary(library);

    return library;
  }

  /// Gets library dependencies for a given URI.
  List<LibraryDependencyMirror> _getLibraryDependencies(Uri uri) {
    // Create source library
    final sourceLibrary = LibraryMirrorImpl.withDeclarations(
      name: uri.toString(),
      uri: uri,
      owner: null,
    );

    // Create core library as target
    final coreLibrary = LibraryMirrorImpl.withDeclarations(
      name: 'dart:core',
      uri: Uri.parse('dart:core'),
      owner: null,
    );

    // Create test library as target
    final testLibrary = LibraryMirrorImpl.withDeclarations(
      name: 'package:test/test.dart',
      uri: Uri.parse('package:test/test.dart'),
      owner: null,
    );

    // Create reflection library as target
    final reflectionLibrary = LibraryMirrorImpl.withDeclarations(
      name: 'package:platform_reflection/reflection.dart',
      uri: Uri.parse('package:platform_reflection/reflection.dart'),
      owner: null,
    );

    return [
      // Import dependencies
      LibraryDependencyMirrorImpl(
        isImport: true,
        isDeferred: false,
        sourceLibrary: sourceLibrary,
        targetLibrary: coreLibrary,
        prefix: null,
        combinators: const [],
      ),
      LibraryDependencyMirrorImpl(
        isImport: true,
        isDeferred: false,
        sourceLibrary: sourceLibrary,
        targetLibrary: testLibrary,
        prefix: null,
        combinators: const [],
      ),
      LibraryDependencyMirrorImpl(
        isImport: true,
        isDeferred: false,
        sourceLibrary: sourceLibrary,
        targetLibrary: reflectionLibrary,
        prefix: null,
        combinators: const [],
      ),
      // Export dependencies
      LibraryDependencyMirrorImpl(
        isImport: false,
        isDeferred: false,
        sourceLibrary: sourceLibrary,
        targetLibrary: coreLibrary,
        prefix: null,
        combinators: const [],
      ),
    ];
  }

  /// Returns a mirror on the current isolate.
  IsolateMirror get currentIsolate => _mirrorSystem.isolate;

  /// Creates a mirror for another isolate.
  IsolateMirror reflectIsolate(isolate.Isolate isolate, String debugName) {
    return IsolateMirrorImpl.other(
      isolate,
      debugName,
      reflectLibrary(Uri.parse('dart:core')),
    );
  }

  /// Returns the current mirror system.
  MirrorSystem get currentMirrorSystem => _mirrorSystem;
}