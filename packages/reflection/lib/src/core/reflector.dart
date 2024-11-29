import 'dart:collection';
import '../metadata.dart';
import '../mirrors.dart';
import '../mirrors/mirrors.dart';

/// Static registry for reflection metadata.
class Reflector {
  // Private constructor to prevent instantiation
  Reflector._();

  // Type metadata storage
  static final Map<Type, Map<String, PropertyMetadata>> _propertyMetadata =
      HashMap<Type, Map<String, PropertyMetadata>>();
  static final Map<Type, Map<String, MethodMetadata>> _methodMetadata =
      HashMap<Type, Map<String, MethodMetadata>>();
  static final Map<Type, List<ConstructorMetadata>> _constructorMetadata =
      HashMap<Type, List<ConstructorMetadata>>();
  static final Map<Type, Map<String, Function>> _constructorFactories =
      HashMap<Type, Map<String, Function>>();
  static final Set<Type> _reflectableTypes = HashSet<Type>();

  /// Registers a type for reflection.
  static void registerType(Type type) {
    _reflectableTypes.add(type);
    _propertyMetadata.putIfAbsent(
        type, () => HashMap<String, PropertyMetadata>());
    _methodMetadata.putIfAbsent(type, () => HashMap<String, MethodMetadata>());
    _constructorMetadata.putIfAbsent(type, () => []);
    _constructorFactories.putIfAbsent(type, () => {});
  }

  /// Register this type for reflection.
  static void register(Type type) {
    if (!isReflectable(type)) {
      registerType(type);
    }
  }

  /// Register a property for reflection.
  static void registerProperty(
    Type type,
    String name,
    Type propertyType, {
    bool isReadable = true,
    bool isWritable = true,
  }) {
    registerPropertyMetadata(
      type,
      name,
      PropertyMetadata(
        name: name,
        type: propertyType,
        isReadable: isReadable,
        isWritable: isWritable,
      ),
    );
  }

  /// Register a method for reflection.
  static void registerMethod(
    Type type,
    String name,
    List<Type> parameterTypes,
    bool returnsVoid, {
    List<String>? parameterNames,
    List<bool>? isRequired,
    List<bool>? isNamed,
    bool isStatic = false,
  }) {
    final parameters = <ParameterMetadata>[];
    for (var i = 0; i < parameterTypes.length; i++) {
      parameters.add(ParameterMetadata(
        name: parameterNames?[i] ?? 'param$i',
        type: parameterTypes[i],
        isRequired: isRequired?[i] ?? true,
        isNamed: isNamed?[i] ?? false,
      ));
    }

    registerMethodMetadata(
      type,
      name,
      MethodMetadata(
        name: name,
        parameterTypes: parameterTypes,
        parameters: parameters,
        returnsVoid: returnsVoid,
        isStatic: isStatic,
      ),
    );
  }

  /// Register a constructor for reflection.
  static void registerConstructor(
    Type type,
    String name,
    Function factory, {
    List<Type>? parameterTypes,
    List<String>? parameterNames,
    List<bool>? isRequired,
    List<bool>? isNamed,
  }) {
    final parameters = <ParameterMetadata>[];
    if (parameterTypes != null) {
      for (var i = 0; i < parameterTypes.length; i++) {
        parameters.add(ParameterMetadata(
          name: parameterNames?[i] ?? 'param$i',
          type: parameterTypes[i],
          isRequired: isRequired?[i] ?? true,
          isNamed: isNamed?[i] ?? false,
        ));
      }
    }

    registerConstructorMetadata(
      type,
      ConstructorMetadata(
        name: name,
        parameterTypes: parameterTypes ?? [],
        parameters: parameters,
      ),
    );
    registerConstructorFactory(type, name, factory);
  }

  /// Checks if a type is reflectable.
  static bool isReflectable(Type type) {
    return _reflectableTypes.contains(type);
  }

  /// Gets property metadata for a type.
  static Map<String, PropertyMetadata>? getPropertyMetadata(Type type) {
    return _propertyMetadata[type];
  }

  /// Gets method metadata for a type.
  static Map<String, MethodMetadata>? getMethodMetadata(Type type) {
    return _methodMetadata[type];
  }

  /// Gets constructor metadata for a type.
  static List<ConstructorMetadata>? getConstructorMetadata(Type type) {
    return _constructorMetadata[type];
  }

  /// Gets a constructor factory function.
  static Function? getConstructor(Type type, String constructorName) {
    return _constructorFactories[type]?[constructorName];
  }

  /// Registers property metadata for a type.
  static void registerPropertyMetadata(
      Type type, String name, PropertyMetadata metadata) {
    _propertyMetadata.putIfAbsent(
        type, () => HashMap<String, PropertyMetadata>());
    _propertyMetadata[type]![name] = metadata;
  }

  /// Registers method metadata for a type.
  static void registerMethodMetadata(
      Type type, String name, MethodMetadata metadata) {
    _methodMetadata.putIfAbsent(type, () => HashMap<String, MethodMetadata>());
    _methodMetadata[type]![name] = metadata;
  }

  /// Registers constructor metadata for a type.
  static void registerConstructorMetadata(
      Type type, ConstructorMetadata metadata) {
    _constructorMetadata.putIfAbsent(type, () => []);

    // Update existing constructor if it exists
    final existing = _constructorMetadata[type]!
        .indexWhere((ctor) => ctor.name == metadata.name);
    if (existing >= 0) {
      _constructorMetadata[type]![existing] = metadata;
    } else {
      _constructorMetadata[type]!.add(metadata);
    }
  }

  /// Registers a constructor factory function.
  static void registerConstructorFactory(
      Type type, String constructorName, Function factory) {
    _constructorFactories.putIfAbsent(type, () => {});
    _constructorFactories[type]![constructorName] = factory;
  }

  /// Clears all registered metadata.
  /// This is primarily used for testing.
  static void reset() {
    _propertyMetadata.clear();
    _methodMetadata.clear();
    _constructorMetadata.clear();
    _constructorFactories.clear();
    _reflectableTypes.clear();
  }
}
