/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Base mirror interface
abstract class Mirror {}

/// Base declaration mirror interface
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

/// Base object mirror interface
abstract class ObjectMirror implements Mirror {
  /// Invokes the named function and returns a mirror on the result.
  InstanceMirror invoke(Symbol memberName, List<dynamic> positionalArguments,
      [Map<Symbol, dynamic> namedArguments = const {}]);

  /// Invokes a getter and returns a mirror on the result.
  InstanceMirror getField(Symbol fieldName);

  /// Invokes a setter and returns a mirror on the result.
  InstanceMirror setField(Symbol fieldName, dynamic value);
}

/// Base instance mirror interface
abstract class InstanceMirror implements ObjectMirror {
  /// A mirror on the type of the instance.
  ClassMirror get type;

  /// Whether this mirror's reflectee is accessible.
  bool get hasReflectee;

  /// The reflectee of this mirror.
  dynamic get reflectee;
}

/// Base class mirror interface
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

/// Base type mirror interface
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
}

/// Base method mirror interface
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

/// Base parameter mirror interface
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

/// Base variable mirror interface
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

/// Base type variable mirror interface
abstract class TypeVariableMirror implements TypeMirror {
  /// A mirror on the upper bound of this type variable.
  TypeMirror get upperBound;
}

/// Base library mirror interface
abstract class LibraryMirror implements DeclarationMirror, ObjectMirror {
  /// The absolute URI of the library.
  Uri get uri;

  /// The declarations in this library.
  Map<Symbol, DeclarationMirror> get declarations;

  /// The imports and exports of this library.
  List<LibraryDependencyMirror> get libraryDependencies;
}

/// Base library dependency mirror interface
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

/// Base combinator mirror interface
abstract class CombinatorMirror implements Mirror {
  /// The identifiers in this combinator.
  List<Symbol> get identifiers;

  /// Whether this is a show combinator.
  bool get isShow;

  /// Whether this is a hide combinator.
  bool get isHide;
}
