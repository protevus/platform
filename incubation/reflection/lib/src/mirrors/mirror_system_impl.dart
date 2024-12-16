import 'dart:core';
import '../mirrors.dart';
import '../core/reflector.dart';
import 'type_mirror_impl.dart';
import 'class_mirror_impl.dart';
import 'library_mirror_impl.dart';
import 'library_dependency_mirror_impl.dart';
import 'isolate_mirror_impl.dart';
import 'special_types.dart';
import 'variable_mirror_impl.dart';
import 'method_mirror_impl.dart';
import 'parameter_mirror_impl.dart';
import 'base_mirror.dart';

/// Implementation of [MirrorSystem] that provides reflection on a set of libraries.
class MirrorSystemImpl implements MirrorSystem {
  final Map<Uri, LibraryMirror> _libraries;
  final IsolateMirror _isolate;
  final TypeMirror _dynamicType;
  final TypeMirror _voidType;
  final TypeMirror _neverType;

  MirrorSystemImpl({
    required Map<Uri, LibraryMirror> libraries,
    required IsolateMirror isolate,
  })  : _libraries = libraries,
        _isolate = isolate,
        _dynamicType = TypeMirrorImpl.dynamicType(),
        _voidType = TypeMirrorImpl.voidType(),
        _neverType = TypeMirrorImpl(
          type: Never,
          name: 'Never',
          owner: null,
          metadata: [],
        );

  /// Creates a mirror system for the current isolate.
  factory MirrorSystemImpl.current() {
    // Create core library mirror
    final coreLibrary = LibraryMirrorImpl.withDeclarations(
      name: 'dart:core',
      uri: _createDartUri('core'),
      owner: null,
    );

    // Create async library mirror
    final asyncLibrary = LibraryMirrorImpl.withDeclarations(
      name: 'dart:async',
      uri: _createDartUri('async'),
      owner: null,
    );

    // Create test library mirror
    final testLibrary = LibraryMirrorImpl.withDeclarations(
      name: 'package:test/test.dart',
      uri: Uri.parse('package:test/test.dart'),
      owner: null,
    );

    // Add dependencies to core library
    final coreDependencies = [
      LibraryDependencyMirrorImpl(
        isImport: true,
        isDeferred: false,
        sourceLibrary: coreLibrary,
        targetLibrary: asyncLibrary,
        prefix: null,
        combinators: const [],
      ),
      LibraryDependencyMirrorImpl(
        isImport: false,
        isDeferred: false,
        sourceLibrary: coreLibrary,
        targetLibrary: asyncLibrary,
        prefix: null,
        combinators: const [],
      ),
    ];

    // Create root library with dependencies
    final rootLibrary = LibraryMirrorImpl(
      name: 'dart:core',
      uri: _createDartUri('core'),
      owner: null,
      declarations: const {},
      libraryDependencies: coreDependencies,
      metadata: [],
    );

    // Create isolate mirror
    final isolate = IsolateMirrorImpl.current(rootLibrary);

    // Create initial libraries map
    final libraries = <Uri, LibraryMirror>{
      rootLibrary.uri: rootLibrary,
      asyncLibrary.uri: asyncLibrary,
      testLibrary.uri: testLibrary,
    };

    return MirrorSystemImpl(
      libraries: libraries,
      isolate: isolate,
    );
  }

  /// Creates a URI for a dart: library.
  static Uri _createDartUri(String library) {
    return Uri(scheme: 'dart', path: library);
  }

  /// Parses a library name into a URI.
  static Uri _parseLibraryName(String name) {
    if (name.startsWith('"') && name.endsWith('"')) {
      name = name.substring(1, name.length - 1);
    }

    if (name.startsWith('dart:')) {
      final library = name.substring(5);
      return _createDartUri(library);
    }

    return Uri.parse(name);
  }

  @override
  Map<Uri, LibraryMirror> get libraries => Map.unmodifiable(_libraries);

  @override
  LibraryMirror findLibrary(Symbol libraryName) {
    final name = libraryName.toString();
    // Remove leading 'Symbol(' and trailing ')'
    final normalizedName = name.substring(7, name.length - 1);

    final uri = _parseLibraryName(normalizedName);
    final library = _libraries[uri];
    if (library == null) {
      throw ArgumentError('Library not found: $normalizedName');
    }
    return library;
  }

  @override
  ClassMirror reflectClass(Type type) {
    // Check if type is reflectable
    if (!Reflector.isReflectable(type)) {
      throw ArgumentError('Type is not reflectable: $type');
    }

    // Create temporary class mirror to serve as owner
    final tempMirror = ClassMirrorImpl(
      type: type,
      name: type.toString(),
      owner: null,
      declarations: const {},
      instanceMembers: const {},
      staticMembers: const {},
      metadata: [],
    );

    // Get metadata from registry
    final properties = Reflector.getPropertyMetadata(type) ?? {};
    final methods = Reflector.getMethodMetadata(type) ?? {};
    final constructors = Reflector.getConstructorMetadata(type) ?? [];

    // Create declarations map
    final declarations = <Symbol, DeclarationMirror>{};
    final instanceMembers = <Symbol, MethodMirror>{};
    final staticMembers = <Symbol, MethodMirror>{};

    // Add properties and methods to declarations
    properties.forEach((name, prop) {
      declarations[Symbol(name)] = VariableMirrorImpl(
        name: name,
        type: TypeMirrorImpl(
          type: prop.type,
          name: prop.type.toString(),
          owner: tempMirror,
          metadata: [],
        ),
        owner: tempMirror,
        isStatic: false,
        isFinal: !prop.isWritable,
        isConst: false,
        metadata: [],
      );
    });

    methods.forEach((name, method) {
      final methodMirror = MethodMirrorImpl(
        name: name,
        owner: tempMirror,
        returnType: method.returnsVoid
            ? TypeMirrorImpl.voidType(tempMirror)
            : TypeMirrorImpl.dynamicType(tempMirror),
        parameters: method.parameters
            .map((param) => ParameterMirrorImpl(
                  name: param.name,
                  type: TypeMirrorImpl(
                    type: param.type,
                    name: param.type.toString(),
                    owner: tempMirror,
                    metadata: [],
                  ),
                  owner: tempMirror,
                  isOptional: !param.isRequired,
                  isNamed: param.isNamed,
                  metadata: [],
                ))
            .toList(),
        isStatic: method.isStatic,
        metadata: [],
      );

      declarations[Symbol(name)] = methodMirror;
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

    // Update owners to point to the real class mirror
    declarations.forEach((_, decl) {
      if (decl is MutableOwnerMirror) {
        decl.setOwner(mirror);
      }
    });

    return mirror;
  }

  @override
  TypeMirror reflectType(Type type) {
    // Check if type is reflectable
    if (!Reflector.isReflectable(type)) {
      throw ArgumentError('Type is not reflectable: $type');
    }

    return TypeMirrorImpl(
      type: type,
      name: type.toString(),
      owner: null,
      metadata: [],
    );
  }

  @override
  IsolateMirror get isolate => _isolate;

  @override
  TypeMirror get dynamicType => _dynamicType;

  @override
  TypeMirror get voidType => _voidType;

  @override
  TypeMirror get neverType => _neverType;

  /// Adds a library to the mirror system.
  void addLibrary(LibraryMirror library) {
    _libraries[library.uri] = library;
  }

  /// Removes a library from the mirror system.
  void removeLibrary(Uri uri) {
    _libraries.remove(uri);
  }
}
