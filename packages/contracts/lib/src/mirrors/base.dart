/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Base mirror interface
abstract class MirrorContract {}

/// Base declaration mirror interface
abstract class DeclarationMirrorContract implements MirrorContract {
  /// The simple name for this Dart language entity.
  Symbol get simpleName;

  /// The fully-qualified name for this Dart language entity.
  Symbol get qualifiedName;

  /// A mirror on the owner of this Dart language entity.
  DeclarationMirrorContract? get owner;

  /// Whether this declaration is library private.
  bool get isPrivate;

  /// Whether this declaration is top-level.
  bool get isTopLevel;

  /// A list of the metadata associated with this declaration.
  List<InstanceMirrorContract> get metadata;

  /// The name of this declaration.
  String get name;
}

/// Base object mirror interface
abstract class ObjectMirrorContract implements MirrorContract {
  /// Invokes the named function and returns a mirror on the result.
  InstanceMirrorContract invoke(
      Symbol memberName, List<dynamic> positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]);

  /// Invokes a getter and returns a mirror on the result.
  InstanceMirrorContract getField(Symbol fieldName);

  /// Invokes a setter and returns a mirror on the result.
  InstanceMirrorContract setField(Symbol fieldName, dynamic value);
}

/// Base instance mirror interface
abstract class InstanceMirrorContract implements ObjectMirrorContract {
  /// A mirror on the type of the instance.
  ClassMirrorContract get type;

  /// Whether this mirror's reflectee is accessible.
  bool get hasReflectee;

  /// The reflectee of this mirror.
  dynamic get reflectee;
}

/// Base class mirror interface
abstract class ClassMirrorContract
    implements TypeMirrorContract, ObjectMirrorContract {
  /// A mirror on the superclass.
  ClassMirrorContract? get superclass;

  /// Mirrors on the superinterfaces.
  List<ClassMirrorContract> get superinterfaces;

  /// Whether this class is abstract.
  bool get isAbstract;

  /// Whether this class is an enum.
  bool get isEnum;

  /// The declarations in this class.
  Map<Symbol, DeclarationMirrorContract> get declarations;

  /// The instance members of this class.
  Map<Symbol, MethodMirrorContract> get instanceMembers;

  /// The static members of this class.
  Map<Symbol, MethodMirrorContract> get staticMembers;

  /// Creates a new instance using the specified constructor.
  InstanceMirrorContract newInstance(
      Symbol constructorName, List<dynamic> positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]);

  /// Whether this class is a subclass of [other].
  bool isSubclassOf(ClassMirrorContract other);
}

/// Base type mirror interface
abstract class TypeMirrorContract implements DeclarationMirrorContract {
  /// Whether this mirror reflects a type available at runtime.
  bool get hasReflectedType;

  /// The [Type] reflected by this mirror.
  Type get reflectedType;

  /// Type variables declared on this type.
  List<TypeVariableMirrorContract> get typeVariables;

  /// Type arguments provided to this type.
  List<TypeMirrorContract> get typeArguments;

  /// Whether this is the original declaration of this type.
  bool get isOriginalDeclaration;

  /// A mirror on the original declaration of this type.
  TypeMirrorContract get originalDeclaration;

  /// Checks if this type is a subtype of [other].
  bool isSubtypeOf(TypeMirrorContract other);

  /// Checks if this type is assignable to [other].
  bool isAssignableTo(TypeMirrorContract other);
}

/// Base method mirror interface
abstract class MethodMirrorContract implements DeclarationMirrorContract {
  /// A mirror on the return type.
  TypeMirrorContract get returnType;

  /// The source code if available.
  String? get source;

  /// Mirrors on the parameters.
  List<ParameterMirrorContract> get parameters;

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

/// Base parameter mirror interface
abstract class ParameterMirrorContract implements VariableMirrorContract {
  /// Whether this is an optional parameter.
  bool get isOptional;

  /// Whether this is a named parameter.
  bool get isNamed;

  /// Whether this parameter has a default value.
  bool get hasDefaultValue;

  /// The default value if this is an optional parameter.
  InstanceMirrorContract? get defaultValue;
}

/// Base variable mirror interface
abstract class VariableMirrorContract implements DeclarationMirrorContract {
  /// A mirror on the type of this variable.
  TypeMirrorContract get type;

  /// Whether this is a static variable.
  bool get isStatic;

  /// Whether this is a final variable.
  bool get isFinal;

  /// Whether this is a const variable.
  bool get isConst;
}

/// Base type variable mirror interface
abstract class TypeVariableMirrorContract implements TypeMirrorContract {
  /// A mirror on the upper bound of this type variable.
  TypeMirrorContract get upperBound;
}

/// Base library mirror interface
abstract class LibraryMirrorContract
    implements DeclarationMirrorContract, ObjectMirrorContract {
  /// The absolute URI of the library.
  Uri get uri;

  /// The declarations in this library.
  Map<Symbol, DeclarationMirrorContract> get declarations;

  /// The imports and exports of this library.
  List<LibraryDependencyMirrorContract> get libraryDependencies;
}

/// Base library dependency mirror interface
abstract class LibraryDependencyMirrorContract implements MirrorContract {
  /// Whether this is an import.
  bool get isImport;

  /// Whether this is an export.
  bool get isExport;

  /// Whether this is a deferred import.
  bool get isDeferred;

  /// The library containing this dependency.
  LibraryMirrorContract get sourceLibrary;

  /// The target library of this dependency.
  LibraryMirrorContract? get targetLibrary;

  /// The prefix if this is a prefixed import.
  Symbol? get prefix;

  /// The show/hide combinators on this dependency.
  List<CombinatorMirrorContract> get combinators;
}

/// Base combinator mirror interface
abstract class CombinatorMirrorContract implements MirrorContract {
  /// The identifiers in this combinator.
  List<Symbol> get identifiers;

  /// Whether this is a show combinator.
  bool get isShow;

  /// Whether this is a hide combinator.
  bool get isHide;
}

/// An [IsolateMirrorContract] reflects an isolate.
abstract class IsolateMirrorContract implements MirrorContract {
  /// A unique name used to refer to the isolate in debugging messages.
  String get debugName;

  /// Whether this mirror reflects the currently running isolate.
  bool get isCurrent;

  /// The root library for the reflected isolate.
  LibraryMirrorContract get rootLibrary;
}

/// A [MirrorSystemContract] is the main interface used to reflect on a set of libraries.
abstract class MirrorSystemContract {
  /// All libraries known to the mirror system.
  Map<Uri, LibraryMirrorContract> get libraries;

  /// Returns the unique library with the specified name.
  LibraryMirrorContract findLibrary(Symbol libraryName);

  /// Returns a mirror for the specified class.
  ClassMirrorContract reflectClass(Type type);

  /// Returns a mirror for the specified type.
  TypeMirrorContract reflectType(Type type);

  /// A mirror on the isolate associated with this mirror system.
  IsolateMirrorContract get isolate;

  /// A mirror on the dynamic type.
  TypeMirrorContract get dynamicType;

  /// A mirror on the void type.
  TypeMirrorContract get voidType;

  /// A mirror on the Never type.
  TypeMirrorContract get neverType;
}
