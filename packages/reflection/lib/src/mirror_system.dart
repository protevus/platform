import 'dart:core';
import 'mirrors.dart';

/// The default implementation of [MirrorSystem].
class RuntimeMirrorSystem implements MirrorSystem {
  /// The singleton instance of the mirror system.
  static final instance = RuntimeMirrorSystem._();

  RuntimeMirrorSystem._();

  @override
  Map<Uri, LibraryMirror> get libraries {
    // TODO: Implement library tracking
    return {};
  }

  @override
  LibraryMirror findLibrary(Symbol libraryName) {
    // TODO: Implement library lookup
    throw UnimplementedError();
  }

  @override
  IsolateMirror get isolate {
    // TODO: Implement isolate mirror
    throw UnimplementedError();
  }

  @override
  TypeMirror get dynamicType {
    // TODO: Implement dynamic type mirror
    throw UnimplementedError();
  }

  @override
  TypeMirror get voidType {
    // TODO: Implement void type mirror
    throw UnimplementedError();
  }

  @override
  TypeMirror get neverType {
    // TODO: Implement never type mirror
    throw UnimplementedError();
  }

  /// Creates a mirror reflecting [reflectee].
  InstanceMirror reflect(Object reflectee) {
    // TODO: Implement instance reflection
    throw UnimplementedError();
  }

  /// Creates a mirror reflecting the class [key].
  ClassMirror reflectClass(Type key) {
    // TODO: Implement class reflection
    throw UnimplementedError();
  }

  /// Creates a mirror reflecting the type [key].
  TypeMirror reflectType(Type key) {
    // TODO: Implement type reflection
    throw UnimplementedError();
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
