import 'dart:core';
import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/mirrors.dart';

/// The default implementation of [MirrorSystemContract].
class RuntimeMirrorSystem implements MirrorSystemContract {
  /// The singleton instance of the mirror system.
  static final instance = RuntimeMirrorSystem._();

  RuntimeMirrorSystem._() {
    _initializeRootLibrary();
  }

  final Map<Uri, LibraryMirrorContract> _libraries = {};
  final Map<Type, ClassMirrorContract> _classes = {};
  final Map<Type, TypeMirrorContract> _types = {};
  late final LibraryMirrorContract _rootLibrary;

  @override
  Map<Uri, LibraryMirrorContract> get libraries => Map.unmodifiable(_libraries);

  @override
  LibraryMirrorContract findLibrary(Symbol libraryName) {
    final lib = _libraries.values.firstWhere(
      (lib) => lib.qualifiedName == libraryName,
      orElse: () => throw ArgumentError('Library not found: $libraryName'),
    );
    return lib;
  }

  @override
  IsolateMirrorContract get isolate => IsolateMirror.current(_rootLibrary);

  @override
  TypeMirrorContract get dynamicType => _getOrCreateTypeMirror(dynamic);

  @override
  TypeMirrorContract get voidType => _getOrCreateTypeMirror(VoidType);

  @override
  TypeMirrorContract get neverType => _getOrCreateTypeMirror(NeverType);

  /// Creates a mirror reflecting [reflectee].
  InstanceMirrorContract reflect(Object reflectee) {
    return InstanceMirror(
      reflectee: reflectee,
      type: reflectClass(reflectee.runtimeType),
    );
  }

  /// Creates a mirror reflecting the class [key].
  @override
  ClassMirrorContract reflectClass(Type key) {
    return _classes.putIfAbsent(
      key,
      () => ClassMirror(
        type: key,
        name: key.toString(),
        owner: _rootLibrary,
        declarations: {},
        instanceMembers: {},
        staticMembers: {},
        metadata: [],
      ),
    );
  }

  /// Creates a mirror reflecting the type [key].
  @override
  TypeMirrorContract reflectType(Type key) {
    return _getOrCreateTypeMirror(key);
  }

  TypeMirrorContract _getOrCreateTypeMirror(Type type) {
    return _types.putIfAbsent(
      type,
      () => TypeMirror(
        type: type,
        name: type.toString(),
        owner: _rootLibrary,
        metadata: const [],
      ),
    );
  }

  void _initializeRootLibrary() {
    _rootLibrary = LibraryMirror.withDeclarations(
      name: 'dart.core',
      uri: Uri.parse('dart:core'),
    );
    _libraries[_rootLibrary.uri] = _rootLibrary;
  }
}

/// The current mirror system.
MirrorSystemContract currentMirrorSystem() => RuntimeMirrorSystem.instance;

/// Reflects an instance.
InstanceMirrorContract reflect(Object reflectee) =>
    RuntimeMirrorSystem.instance.reflect(reflectee);

/// Reflects a class.
ClassMirrorContract reflectClass(Type key) =>
    RuntimeMirrorSystem.instance.reflectClass(key);

/// Reflects a type.
TypeMirrorContract reflectType(Type key) =>
    RuntimeMirrorSystem.instance.reflectType(key);
