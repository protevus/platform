import 'reflected_function.dart';
import 'reflected_parameter.dart';
import 'reflected_type.dart';

/// Interface for class reflection information.
abstract class ReflectedClass {
  /// Get the name of the class.
  String get name;

  /// Get the qualified name of the class (including namespace).
  String get qualifiedName;

  /// Get the type represented by this class.
  Type get type;

  /// Get the constructor methods of the class.
  List<ReflectedFunction> get constructors;

  /// Get all methods defined in the class.
  List<ReflectedFunction> get methods;

  /// Get all instance properties defined in the class.
  List<ReflectedParameter> get properties;

  /// Get the parent class if any.
  ReflectedClass? get parent;

  /// Get all interfaces implemented by this class.
  List<ReflectedType> get interfaces;

  /// Get all attributes applied to this class.
  List<dynamic> get attributes;

  /// Check if this class has a specific attribute.
  bool hasAttribute(Type attributeType);

  /// Get all attributes of a specific type.
  List<dynamic> getAttributes(Type attributeType);

  /// Create a new instance of the class.
  ///
  /// If [constructorName] is provided, uses the named constructor.
  /// The [arguments] map contains the arguments to pass to the constructor.
  dynamic newInstance(
      [String? constructorName, Map<String, dynamic>? arguments]);

  /// Determine if this class is abstract.
  bool get isAbstract;

  /// Determine if this class implements the given interface.
  bool implementsInterface(Type interfaceType);

  /// Determine if this class extends the given class.
  bool extendsClass(Type classType);

  /// Get a method by name.
  ReflectedFunction? getMethod(String name);

  /// Get a property by name.
  ReflectedParameter? getProperty(String name);
}
