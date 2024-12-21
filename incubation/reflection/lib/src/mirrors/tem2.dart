import 'dart:core';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/mirrors.dart';

/// Implementation of [MirrorSystemContract] that provides reflection on a set of libraries.
class MirrorSystem implements MirrorSystemContract {
  final Map<Uri, LibraryMirrorContract> _libraries;
  final IsolateMirrorContract _isolate;
  final TypeMirrorContract _dynamicType;
  final TypeMirrorContract _voidType;
  final TypeMirrorContract _neverType;

  MirrorSystem({
    required Map<Uri, LibraryMirrorContract> libraries,
    required IsolateMirrorContract isolate,
  })  : _libraries = libraries,
        _isolate = isolate,
        _dynamicType = TypeMirror.dynamicType(),
        _voidType = TypeMirror.voidType(),
        _neverType = TypeMirror(
          type: Never,
          name: 'Never',
          owner: null,
          metadata: [],
        );

  /// Creates a mirror system for the current isolate.
  factory MirrorSystem.current() {
    // Create core library mirror
    final coreLibrary = LibraryMirror.withDeclarations(
      name: 'dart:core',
      uri: _createDartUri('core'),
      owner: null,
    );

    // Create async library mirror
    final asyncLibrary = LibraryMirror.withDeclarations(
      name: 'dart:async',
      uri: _createDartUri('async'),
      owner: null,
    );

    // Create test library mirror
    final testLibrary = LibraryMirror.withDeclarations(
      name: 'package:test/test.dart',
      uri: Uri.parse('package:test/test.dart'),
      owner: null,
    );

    // Add dependencies to core library
    final coreDependencies = [
      LibraryDependencyMirror(
        isImport: true,
        isDeferred: false,
        sourceLibrary: coreLibrary,
        targetLibrary: asyncLibrary,
        prefix: null,
        combinators: const [],
      ),
      LibraryDependencyMirror(
        isImport: false,
        isDeferred: false,
        sourceLibrary: coreLibrary,
        targetLibrary: asyncLibrary,
        prefix: null,
        combinators: const [],
      ),
    ];

    // Create root library with dependencies
    final rootLibrary = LibraryMirror(
      name: 'dart:core',
      uri: _createDartUri('core'),
      owner: null,
      declarations: const {},
      libraryDependencies: coreDependencies,
      metadata: [],
    );

    // Create isolate mirror
    final isolate = IsolateMirror.current(rootLibrary);

    // Create initial libraries map
    final libraries = <Uri, LibraryMirrorContract>{
      rootLibrary.uri: rootLibrary,
      asyncLibrary.uri: asyncLibrary,
      testLibrary.uri: testLibrary,
    };

    return MirrorSystem(
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
  Map<Uri, LibraryMirrorContract> get libraries => Map.unmodifiable(_libraries);

  @override
  LibraryMirrorContract findLibrary(Symbol libraryName) {
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
  ClassMirrorContract reflectClass(Type type) {
    // Check if type is reflectable
    if (!Reflector.isReflectable(type)) {
      throw ArgumentError('Type is not reflectable: $type');
    }

    // Create temporary class mirror to serve as owner
    final tempMirror = ClassMirror(
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
    //final constructors = Reflector.getConstructorMetadata(type) ?? [];

    // Create declarations map
    final declarations = <Symbol, DeclarationMirrorContract>{};
    final instanceMembers = <Symbol, MethodMirrorContract>{};
    final staticMembers = <Symbol, MethodMirrorContract>{};

    // Add properties and methods to declarations
    properties.forEach((name, prop) {
      declarations[Symbol(name)] = VariableMirror(
        name: name,
        type: TypeMirror(
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
      final methodMirror = MethodMirror(
        name: name,
        owner: tempMirror,
        returnType: method.returnsVoid
            ? TypeMirror.voidType(tempMirror)
            : TypeMirror.dynamicType(tempMirror),
        parameters: method.parameters
            .map((param) => ParameterMirror(
                  name: param.name,
                  type: TypeMirror(
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
    final mirror = ClassMirror(
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
  TypeMirrorContract reflectType(Type type) {
    // Check if type is reflectable
    if (!Reflector.isReflectable(type)) {
      throw ArgumentError('Type is not reflectable: $type');
    }

    return TypeMirror(
      type: type,
      name: type.toString(),
      owner: null,
      metadata: [],
    );
  }

  @override
  IsolateMirrorContract get isolate => _isolate;

  @override
  TypeMirrorContract get dynamicType => _dynamicType;

  @override
  TypeMirrorContract get voidType => _voidType;

  @override
  TypeMirrorContract get neverType => _neverType;

  /// Adds a library to the mirror system.
  void addLibrary(LibraryMirrorContract library) {
    _libraries[library.uri] = library;
  }

  /// Removes a library from the mirror system.
  void removeLibrary(Uri uri) {
    _libraries.remove(uri);
  }
}
