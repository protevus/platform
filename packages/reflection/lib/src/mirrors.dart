/// Basic reflection in Dart, with support for introspection and dynamic invocation.
library mirrors;

import 'dart:core';
import 'metadata.dart';

/// A [Mirror] reflects some Dart language entity.
abstract class Mirror {}

/// A [DeclarationMirror] reflects some entity declared in a Dart program.
abstract class DeclarationMirror implements Mirror {
  /// The simple name for this Dart language entity.
  Symbol get simpleName;

  /// The fully-qualified name for this Dart language entity.
  Symbol get qualifiedName;

  /// A mirror on the owner of this Dart language entity.
  DeclarationMirror? get owner;

  /// Whether this declaration is library private.
  bool get isPrivate;

  /// Whether this declaration is top-level.
  bool get isTopLevel;

  /// A list of the metadata associated with this declaration.
  List<InstanceMirror> get metadata;

  /// The name of this declaration.
  String get name;
}

/// An [ObjectMirror] provides shared functionality for instances, classes and libraries.
abstract class ObjectMirror implements Mirror {
  /// Invokes the named function and returns a mirror on the result.
  InstanceMirror invoke(Symbol memberName, List<dynamic> positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]);

  /// Invokes a getter and returns a mirror on the result.
  InstanceMirror getField(Symbol fieldName);

  /// Invokes a setter and returns a mirror on the result.
  InstanceMirror setField(Symbol fieldName, dynamic value);
}

/// An [InstanceMirror] reflects an instance of a Dart language object.
abstract class InstanceMirror implements ObjectMirror {
  /// A mirror on the type of the reflectee.
  ClassMirror get type;

  /// Whether this mirror's reflectee is accessible.
  bool get hasReflectee;

  /// The reflectee of this mirror.
  dynamic get reflectee;
}

/// An [IsolateMirror] reflects an isolate.
abstract class IsolateMirror implements Mirror {
  /// A unique name used to refer to the isolate in debugging messages.
  String get debugName;

  /// Whether this mirror reflects the currently running isolate.
  bool get isCurrent;

  /// The root library for the reflected isolate.
  LibraryMirror get rootLibrary;
}

/// A [TypeMirror] reflects a Dart language class, typedef, function type or type variable.
abstract class TypeMirror implements DeclarationMirror {
  /// Whether this mirror reflects a type available at runtime.
  bool get hasReflectedType;

  /// The [Type] reflected by this mirror.
  Type get reflectedType;

  /// Type variables declared on this type.
  List<TypeVariableMirror> get typeVariables;

  /// Type arguments provided to this type.
  List<TypeMirror> get typeArguments;

  /// Whether this is the original declaration of this type.
  bool get isOriginalDeclaration;

  /// A mirror on the original declaration of this type.
  TypeMirror get originalDeclaration;

  /// Checks if this type is a subtype of [other].
  bool isSubtypeOf(TypeMirror other);

  /// Checks if this type is assignable to [other].
  bool isAssignableTo(TypeMirror other);

  /// The properties defined on this type.
  Map<String, PropertyMetadata> get properties;

  /// The methods defined on this type.
  Map<String, MethodMetadata> get methods;

  /// The constructors defined on this type.
  List<ConstructorMetadata> get constructors;
}

/// A [ClassMirror] reflects a Dart language class.
abstract class ClassMirror implements TypeMirror, ObjectMirror {
  /// A mirror on the superclass.
  ClassMirror? get superclass;

  /// Mirrors on the superinterfaces.
  List<ClassMirror> get superinterfaces;

  /// Whether this class is abstract.
  bool get isAbstract;

  /// Whether this class is an enum.
  bool get isEnum;

  /// The declarations in this class.
  Map<Symbol, DeclarationMirror> get declarations;

  /// The instance members of this class.
  Map<Symbol, MethodMirror> get instanceMembers;

  /// The static members of this class.
  Map<Symbol, MethodMirror> get staticMembers;

  /// Creates a new instance using the specified constructor.
  InstanceMirror newInstance(
      Symbol constructorName, List<dynamic> positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]);

  /// Whether this class is a subclass of [other].
  bool isSubclassOf(ClassMirror other);
}

/// A [LibraryMirror] reflects a Dart language library.
abstract class LibraryMirror implements DeclarationMirror, ObjectMirror {
  /// The absolute URI of the library.
  Uri get uri;

  /// The declarations in this library.
  Map<Symbol, DeclarationMirror> get declarations;

  /// The imports and exports of this library.
  List<LibraryDependencyMirror> get libraryDependencies;
}

/// A [MethodMirror] reflects a Dart language function, method, constructor, getter, or setter.
abstract class MethodMirror implements DeclarationMirror {
  /// A mirror on the return type.
  TypeMirror get returnType;

  /// The source code if available.
  String? get source;

  /// Mirrors on the parameters.
  List<ParameterMirror> get parameters;

  /// Whether this is a static method.
  bool get isStatic;

  /// Whether this is an abstract method.
  bool get isAbstract;

  /// Whether this is a synthetic method.
  bool get isSynthetic;

  /// Whether this is a regular method.
  bool get isRegularMethod;

  /// Whether this is an operator.
  bool get isOperator;

  /// Whether this is a getter.
  bool get isGetter;

  /// Whether this is a setter.
  bool get isSetter;

  /// Whether this is a constructor.
  bool get isConstructor;

  /// The constructor name for named constructors.
  Symbol get constructorName;

  /// Whether this is a const constructor.
  bool get isConstConstructor;

  /// Whether this is a generative constructor.
  bool get isGenerativeConstructor;

  /// Whether this is a redirecting constructor.
  bool get isRedirectingConstructor;

  /// Whether this is a factory constructor.
  bool get isFactoryConstructor;
}

/// A [VariableMirror] reflects a Dart language variable declaration.
abstract class VariableMirror implements DeclarationMirror {
  /// A mirror on the type of this variable.
  TypeMirror get type;

  /// Whether this is a static variable.
  bool get isStatic;

  /// Whether this is a final variable.
  bool get isFinal;

  /// Whether this is a const variable.
  bool get isConst;
}

/// A [ParameterMirror] reflects a Dart formal parameter declaration.
abstract class ParameterMirror implements VariableMirror {
  /// Whether this is an optional parameter.
  bool get isOptional;

  /// Whether this is a named parameter.
  bool get isNamed;

  /// Whether this parameter has a default value.
  bool get hasDefaultValue;

  /// The default value if this is an optional parameter.
  InstanceMirror? get defaultValue;
}

/// A [TypeVariableMirror] reflects a type parameter of a generic type.
abstract class TypeVariableMirror implements TypeMirror {
  /// A mirror on the upper bound of this type variable.
  TypeMirror get upperBound;
}

/// A mirror on an import or export declaration.
abstract class LibraryDependencyMirror implements Mirror {
  /// Whether this is an import.
  bool get isImport;

  /// Whether this is an export.
  bool get isExport;

  /// Whether this is a deferred import.
  bool get isDeferred;

  /// The library containing this dependency.
  LibraryMirror get sourceLibrary;

  /// The target library of this dependency.
  LibraryMirror? get targetLibrary;

  /// The prefix if this is a prefixed import.
  Symbol? get prefix;

  /// The show/hide combinators on this dependency.
  List<CombinatorMirror> get combinators;
}

/// A mirror on a show/hide combinator.
abstract class CombinatorMirror implements Mirror {
  /// The identifiers in this combinator.
  List<Symbol> get identifiers;

  /// Whether this is a show combinator.
  bool get isShow;

  /// Whether this is a hide combinator.
  bool get isHide;
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
