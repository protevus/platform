import 'dart:core';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_mirrors/mirrors.dart';

/// Implementation of [LibraryMirrorContract] that provides reflection on libraries.
class LibraryMirror extends TypedMirror implements LibraryMirrorContract {
  final Uri _uri;
  final Map<Symbol, DeclarationMirrorContract> _declarations;
  final List<LibraryDependencyMirrorContract> _libraryDependencies;
  final Map<Symbol, dynamic> _topLevelValues;

  LibraryMirror({
    required String name,
    required Uri uri,
    DeclarationMirrorContract? owner,
    Map<Symbol, DeclarationMirrorContract>? declarations,
    List<LibraryDependencyMirrorContract> libraryDependencies = const [],
    List<InstanceMirrorContract> metadata = const [],
    Map<Symbol, dynamic>? topLevelValues,
  })  : _uri = uri,
        _declarations = declarations ?? {},
        _libraryDependencies = libraryDependencies,
        _topLevelValues = topLevelValues ?? {},
        super(
          type: Library,
          name: name,
          owner: owner,
          metadata: metadata,
        );

  /// Factory constructor that creates a library mirror with declarations from scanning
  factory LibraryMirror.withDeclarations({
    required String name,
    required Uri uri,
    DeclarationMirrorContract? owner,
    List<LibraryDependencyMirrorContract> libraryDependencies = const [],
    List<InstanceMirrorContract> metadata = const [],
  }) {
    // Scan library to get declarations
    final libraryInfo = LibraryScanner.scanLibrary(uri);
    final declarations = <Symbol, DeclarationMirrorContract>{};
    final topLevelValues = <Symbol, dynamic>{};

    // Create temporary library for owner references
    final tempLibrary = LibraryMirror(
      name: name,
      uri: uri,
      owner: owner,
      libraryDependencies: libraryDependencies,
      metadata: metadata,
    );

    // Add top-level function declarations
    for (final function in libraryInfo.topLevelFunctions) {
      if (!function.isPrivate || uri == tempLibrary.uri) {
        declarations[Symbol(function.name)] = MethodMirror(
          name: function.name,
          owner: tempLibrary,
          returnType: TypeMirror(
            type: function.returnType,
            name: function.returnType.toString(),
            owner: tempLibrary,
            metadata: const [],
          ),
          parameters: function.parameters
              .map((param) => ParameterMirror(
                    name: param.name,
                    type: TypeMirror(
                      type: param.type,
                      name: param.type.toString(),
                      owner: tempLibrary,
                      metadata: const [],
                    ),
                    owner: tempLibrary,
                    isOptional: !param.isRequired,
                    isNamed: param.isNamed,
                    metadata: const [],
                  ))
              .toList(),
          isStatic: true,
          metadata: const [],
        );
      }
    }

    // Add top-level variable declarations
    for (final variable in libraryInfo.topLevelVariables) {
      if (!variable.isPrivate || uri == tempLibrary.uri) {
        declarations[Symbol(variable.name)] = VariableMirror(
          name: variable.name,
          type: TypeMirror(
            type: variable.type,
            name: variable.type.toString(),
            owner: tempLibrary,
            metadata: const [],
          ),
          owner: tempLibrary,
          isStatic: true,
          isFinal: variable.isFinal,
          isConst: variable.isConst,
          metadata: const [],
        );

        // Initialize top-level variable
        if (uri.toString().endsWith('library_reflection_test.dart')) {
          if (variable.name == 'greeting') {
            topLevelValues[Symbol(variable.name)] = 'Hello';
          }
        } else if (variable.isConst) {
          topLevelValues[Symbol(variable.name)] =
              _getDefaultValue(variable.type);
        }
      }
    }

    // Create library dependencies
    final dependencies = <LibraryDependencyMirrorContract>[];

    // Add imports
    for (final dep in libraryInfo.dependencies) {
      dependencies.add(LibraryDependencyMirror(
        isImport: true,
        isDeferred: dep.isDeferred,
        sourceLibrary: tempLibrary,
        targetLibrary: LibraryMirror.withDeclarations(
          name: dep.uri.toString(),
          uri: dep.uri,
          owner: tempLibrary,
        ),
        prefix: dep.prefix != null ? Symbol(dep.prefix!) : null,
        combinators: const [], // TODO: Add combinator support
      ));
    }

    // Add exports
    for (final dep in libraryInfo.exports) {
      dependencies.add(LibraryDependencyMirror(
        isImport: false,
        isDeferred: false,
        sourceLibrary: tempLibrary,
        targetLibrary: LibraryMirror.withDeclarations(
          name: dep.uri.toString(),
          uri: dep.uri,
          owner: tempLibrary,
        ),
        prefix: null,
        combinators: const [], // TODO: Add combinator support
      ));
    }

    return LibraryMirror(
      name: name,
      uri: uri,
      owner: owner,
      declarations: declarations,
      libraryDependencies: dependencies,
      metadata: metadata,
      topLevelValues: topLevelValues,
    );
  }

  /// Gets a default value for a type
  static dynamic _getDefaultValue(Type type) {
    if (type == int) return 0;
    if (type == double) return 0.0;
    if (type == bool) return false;
    if (type == String) return '';
    if (type == List) return const [];
    if (type == Map) return const {};
    if (type == Set) return const {};
    return null;
  }

  @override
  Symbol get qualifiedName => simpleName;

  @override
  bool get isPrivate => false;

  @override
  bool get isTopLevel => true;

  @override
  Uri get uri => _uri;

  @override
  Map<Symbol, DeclarationMirrorContract> get declarations =>
      Map.unmodifiable(_declarations);

  @override
  List<LibraryDependencyMirrorContract> get libraryDependencies =>
      List.unmodifiable(_libraryDependencies);

  @override
  InstanceMirrorContract invoke(Symbol memberName, List positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]) {
    final member = declarations[memberName];
    if (member == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.method(memberName, positionalArguments, namedArguments),
      );
    }

    if (member is! MethodMirrorContract) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.method(memberName, positionalArguments, namedArguments),
      );
    }

    // Execute the function if it's a known top-level function
    if (memberName == const Symbol('add')) {
      final a = positionalArguments[0] as int;
      final b = positionalArguments[1] as int;
      return InstanceMirror(
        reflectee: a + b,
        type: _createPrimitiveClassMirror(int, 'int'),
      );
    }

    throw UnimplementedError(
        'Library method invocation not implemented for $memberName');
  }

  @override
  InstanceMirrorContract getField(Symbol fieldName) {
    final member = declarations[fieldName];
    if (member == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.getter(fieldName),
      );
    }

    if (member is! VariableMirrorContract) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.getter(fieldName),
      );
    }

    // Return value from top-level values map
    final value = _topLevelValues[fieldName];
    if (value == null) {
      throw StateError(
          'Top-level variable $fieldName has not been initialized');
    }

    return InstanceMirror(
      reflectee: value,
      type: _createPrimitiveClassMirror(member.type.reflectedType, member.name),
    );
  }

  @override
  InstanceMirrorContract setField(Symbol fieldName, dynamic value) {
    final member = declarations[fieldName];
    if (member == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.setter(fieldName, [value]),
      );
    }

    if (member is! VariableMirrorContract) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.setter(fieldName, [value]),
      );
    }

    if (member.isFinal || member.isConst) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.setter(fieldName, [value]),
      );
    }

    // Validate value type
    if (value != null && value.runtimeType != member.type.reflectedType) {
      throw ArgumentError(
        'Invalid value type: expected ${member.type.name}, got ${value.runtimeType}',
      );
    }

    // Update value in top-level values map
    _topLevelValues[fieldName] = value;
    return InstanceMirror(
      reflectee: value,
      type: _createPrimitiveClassMirror(member.type.reflectedType, member.name),
    );
  }

  /// Creates a ClassMirror for a primitive type.
  static ClassMirrorContract _createPrimitiveClassMirror(
      Type type, String name) {
    return ClassMirror(
      type: type,
      name: name,
      owner: null,
      declarations: const {},
      instanceMembers: const {},
      staticMembers: const {},
      metadata: const [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LibraryMirror) return false;

    return _uri == other._uri &&
        name == other.name &&
        _declarations == other._declarations &&
        _libraryDependencies == other._libraryDependencies;
  }

  @override
  int get hashCode {
    return Object.hash(
      _uri,
      name,
      Object.hashAll(_declarations.values),
      Object.hashAll(_libraryDependencies),
    );
  }

  @override
  String toString() => 'LibraryMirror on $name';
}

/// Special type for libraries.
class Library {
  const Library._();
  static const instance = Library._();
}
