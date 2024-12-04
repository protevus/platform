import 'dart:core';
import 'mirrors.dart';
import 'mirrors/class_mirror_impl.dart';
import 'mirrors/instance_mirror_impl.dart';
import 'mirrors/library_mirror_impl.dart';
import 'mirrors/type_mirror_impl.dart';
import 'mirrors/isolate_mirror_impl.dart';
import 'mirrors/special_types.dart';

/// The default implementation of [MirrorSystem].
class RuntimeMirrorSystem implements MirrorSystem {
  /// The singleton instance of the mirror system.
  static final instance = RuntimeMirrorSystem._();

  RuntimeMirrorSystem._() {
    _initializeRootLibrary();
  }

  final Map<Uri, LibraryMirror> _libraries = {};
  final Map<Type, ClassMirror> _classes = {};
  final Map<Type, TypeMirror> _types = {};
  late final LibraryMirror _rootLibrary;

  @override
  Map<Uri, LibraryMirror> get libraries => Map.unmodifiable(_libraries);

  @override
  LibraryMirror findLibrary(Symbol libraryName) {
    final lib = _libraries.values.firstWhere(
      (lib) => lib.qualifiedName == libraryName,
      orElse: () => throw ArgumentError('Library not found: $libraryName'),
    );
    return lib;
  }

  @override
  IsolateMirror get isolate => IsolateMirrorImpl.current(_rootLibrary);

  @override
  TypeMirror get dynamicType => _getOrCreateTypeMirror(dynamic);

  @override
  TypeMirror get voidType => _getOrCreateTypeMirror(VoidType);

  @override
  TypeMirror get neverType => _getOrCreateTypeMirror(NeverType);

  /// Creates a mirror reflecting [reflectee].
  InstanceMirror reflect(Object reflectee) {
    return InstanceMirrorImpl(
      reflectee: reflectee,
      type: reflectClass(reflectee.runtimeType),
    );
  }

  /// Creates a mirror reflecting the class [key].
  ClassMirror reflectClass(Type key) {
    return _classes.putIfAbsent(
      key,
      () => ClassMirrorImpl(
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
  TypeMirror reflectType(Type key) {
    return _getOrCreateTypeMirror(key);
  }

  TypeMirror _getOrCreateTypeMirror(Type type) {
    return _types.putIfAbsent(
      type,
      () => TypeMirrorImpl(
        type: type,
        name: type.toString(),
        owner: _rootLibrary,
        metadata: const [],
      ),
    );
  }

  void _initializeRootLibrary() {
    _rootLibrary = LibraryMirrorImpl.withDeclarations(
      name: 'dart.core',
      uri: Uri.parse('dart:core'),
    );
    _libraries[_rootLibrary.uri] = _rootLibrary;
  }
}

/// The current mirror system.
MirrorSystem currentMirrorSystem() => RuntimeMirrorSystem.instance;

/// Reflects an instance.
InstanceMirror reflect(Object reflectee) =>
    RuntimeMirrorSystem.instance.reflect(reflectee);

/// Reflects a class.
ClassMirror reflectClass(Type key) =>
    RuntimeMirrorSystem.instance.reflectClass(key);

/// Reflects a type.
TypeMirror reflectType(Type key) =>
    RuntimeMirrorSystem.instance.reflectType(key);
