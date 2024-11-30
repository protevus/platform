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

      // Convert positional args to List if single value provided
      final args = positionalArgs is List
          ? positionalArgs
          : positionalArgs != null
              ? [positionalArgs]
              : [];

      // Convert string keys to symbols for named args
      final symbolNamedArgs =
          namedArgs?.map((key, value) => MapEntry(Symbol(key), value)) ?? {};

      // Extract positional args based on parameter metadata
      final positionalParams =
          constructor.parameters.where((p) => !p.isNamed).toList();
      final finalPositionalArgs = args.take(positionalParams.length).toList();

      // Validate positional arguments
      if (finalPositionalArgs.length <
          positionalParams.where((p) => p.isRequired).length) {
        throw InvalidArgumentsException(constructorName ?? '', type);
      }

      // Validate required named parameters
      final requiredNamedParams = constructor.parameters
          .where((p) => p.isRequired && p.isNamed)
          .map((p) => p.name)
          .toSet();
      if (requiredNamedParams.isNotEmpty &&
          !requiredNamedParams
              .every((param) => namedArgs?.containsKey(param) ?? false)) {
        throw InvalidArgumentsException(constructorName ?? '', type);
      }

      // Create instance using mirror system directly
      final mirror = reflectClass(type);
      return mirror
          .newInstance(Symbol(constructorName ?? ''), finalPositionalArgs,
              symbolNamedArgs)
          .reflectee;
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
            : TypeMirrorImpl.dynamicType(emptyMirror),
        parameters: method.parameters
            .map((param) => ParameterMirrorImpl(
                  name: param.name,
                  type: _createTypeMirror(
                      param.type, param.type.toString(), emptyMirror),
                  owner: emptyMirror,
                  isOptional: !param.isRequired,
                  isNamed: param.isNamed,
                  metadata: [],
                ))
            .toList(),
        isStatic: method.isStatic,
        metadata: [],
      );
    });

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
