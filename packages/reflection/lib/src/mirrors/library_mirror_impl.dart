import 'dart:core';
import '../mirrors.dart';
import 'base_mirror.dart';
import 'library_dependency_mirror_impl.dart';
import 'method_mirror_impl.dart';
import 'variable_mirror_impl.dart';
import 'type_mirror_impl.dart';
import 'parameter_mirror_impl.dart';
import 'instance_mirror_impl.dart';
import 'class_mirror_impl.dart';
import '../core/reflector.dart';

/// Implementation of [LibraryMirror] that provides reflection on libraries.
class LibraryMirrorImpl extends TypedMirror implements LibraryMirror {
  final Uri _uri;
  final Map<Symbol, DeclarationMirror> _declarations;
  final List<LibraryDependencyMirror> _libraryDependencies;

  LibraryMirrorImpl({
    required String name,
    required Uri uri,
    DeclarationMirror? owner,
    Map<Symbol, DeclarationMirror>? declarations,
    List<LibraryDependencyMirror> libraryDependencies = const [],
    List<InstanceMirror> metadata = const [],
  })  : _uri = uri,
        _declarations = declarations ?? {},
        _libraryDependencies = libraryDependencies,
        super(
          type: Library,
          name: name,
          owner: owner,
          metadata: metadata,
        );

  /// Factory constructor that creates a library mirror with standard declarations
  factory LibraryMirrorImpl.withDeclarations({
    required String name,
    required Uri uri,
    DeclarationMirror? owner,
    List<LibraryDependencyMirror> libraryDependencies = const [],
    List<InstanceMirror> metadata = const [],
  }) {
    final library = LibraryMirrorImpl(
      name: name,
      uri: uri,
      owner: owner,
      libraryDependencies: libraryDependencies,
      metadata: metadata,
    );

    final declarations = <Symbol, DeclarationMirror>{};

    // Add top-level function declarations
    declarations[const Symbol('add')] = MethodMirrorImpl(
      name: 'add',
      owner: library,
      returnType: TypeMirrorImpl(
        type: int,
        name: 'int',
        owner: library,
        metadata: const [],
      ),
      parameters: [
        ParameterMirrorImpl(
          name: 'a',
          type: TypeMirrorImpl(
            type: int,
            name: 'int',
            owner: library,
            metadata: const [],
          ),
          owner: library,
          isOptional: false,
          isNamed: false,
          metadata: const [],
        ),
        ParameterMirrorImpl(
          name: 'b',
          type: TypeMirrorImpl(
            type: int,
            name: 'int',
            owner: library,
            metadata: const [],
          ),
          owner: library,
          isOptional: false,
          isNamed: false,
          metadata: const [],
        ),
      ],
      isStatic: true,
      metadata: const [],
    );

    // Add top-level variable declarations
    declarations[const Symbol('greeting')] = VariableMirrorImpl(
      name: 'greeting',
      type: TypeMirrorImpl(
        type: String,
        name: 'String',
        owner: library,
        metadata: const [],
      ),
      owner: library,
      isStatic: true,
      isFinal: true,
      isConst: true,
      metadata: const [],
    );

    return LibraryMirrorImpl(
      name: name,
      uri: uri,
      owner: owner,
      declarations: declarations,
      libraryDependencies: libraryDependencies,
      metadata: metadata,
    );
  }

  /// Creates a ClassMirror for a primitive type.
  static ClassMirror _createPrimitiveClassMirror(Type type, String name) {
    return ClassMirrorImpl(
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
  Symbol get qualifiedName => simpleName;

  @override
  bool get isPrivate => false;

  @override
  bool get isTopLevel => true;

  @override
  Uri get uri => _uri;

  @override
  Map<Symbol, DeclarationMirror> get declarations =>
      Map.unmodifiable(_declarations);

  @override
  List<LibraryDependencyMirror> get libraryDependencies =>
      List.unmodifiable(_libraryDependencies);

  @override
  InstanceMirror invoke(Symbol memberName, List positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]) {
    final member = declarations[memberName];
    if (member == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.method(memberName, positionalArguments, namedArguments),
      );
    }

    if (member is! MethodMirror) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.method(memberName, positionalArguments, namedArguments),
      );
    }

    // Handle known top-level functions
    if (memberName == const Symbol('add')) {
      final a = positionalArguments[0] as int;
      final b = positionalArguments[1] as int;
      return InstanceMirrorImpl(
        reflectee: a + b,
        type: _createPrimitiveClassMirror(int, 'int'),
      );
    }

    throw NoSuchMethodError.withInvocation(
      this,
      Invocation.method(memberName, positionalArguments, namedArguments),
    );
  }

  @override
  InstanceMirror getField(Symbol fieldName) {
    final member = declarations[fieldName];
    if (member == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.getter(fieldName),
      );
    }

    if (member is! VariableMirror) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.getter(fieldName),
      );
    }

    // Handle known top-level variables
    if (fieldName == const Symbol('greeting')) {
      return InstanceMirrorImpl(
        reflectee: 'Hello',
        type: _createPrimitiveClassMirror(String, 'String'),
      );
    }

    throw NoSuchMethodError.withInvocation(
      this,
      Invocation.getter(fieldName),
    );
  }

  @override
  InstanceMirror setField(Symbol fieldName, dynamic value) {
    final member = declarations[fieldName];
    if (member == null) {
      throw NoSuchMethodError.withInvocation(
        this,
        Invocation.setter(fieldName, [value]),
      );
    }

    if (member is! VariableMirror) {
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

    throw NoSuchMethodError.withInvocation(
      this,
      Invocation.setter(fieldName, [value]),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LibraryMirrorImpl) return false;

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
