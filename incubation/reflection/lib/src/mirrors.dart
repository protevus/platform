/// Basic reflection in Dart, with support for introspection and dynamic invocation.
library mirrors;

import 'package:platform_contracts/contracts.dart';

export 'package:platform_contracts/contracts.dart'
    show
        Mirror,
        DeclarationMirror,
        ObjectMirror,
        InstanceMirror,
        TypeMirror,
        ClassMirror,
        LibraryMirror,
        MethodMirror,
        VariableMirror,
        ParameterMirror,
        TypeVariableMirror,
        LibraryDependencyMirror,
        CombinatorMirror;

export 'mirrors/mirrors.dart';

/// An [IsolateMirror] reflects an isolate.
abstract class IsolateMirror implements Mirror {
  /// A unique name used to refer to the isolate in debugging messages.
  String get debugName;

  /// Whether this mirror reflects the currently running isolate.
  bool get isCurrent;

  /// The root library for the reflected isolate.
  LibraryMirror get rootLibrary;
}

/// A [MirrorSystem] is the main interface used to reflect on a set of libraries.
abstract class MirrorSystem {
  /// All libraries known to the mirror system.
  Map<Uri, LibraryMirror> get libraries;

  /// Returns the unique library with the specified name.
  LibraryMirror findLibrary(Symbol libraryName);

  /// Returns a mirror for the specified class.
  ClassMirror reflectClass(Type type);

  /// Returns a mirror for the specified type.
  TypeMirror reflectType(Type type);

  /// A mirror on the isolate associated with this mirror system.
  IsolateMirror get isolate;

  /// A mirror on the dynamic type.
  TypeMirror get dynamicType;

  /// A mirror on the void type.
  TypeMirror get voidType;

  /// A mirror on the Never type.
  TypeMirror get neverType;
}
