import 'metadata.dart';

/// Registry of reflectable types and their metadata.
class ReflectionRegistry {
  /// Map of type to its property metadata
  static final _properties = <Type, Map<String, PropertyMetadata>>{};

  /// Map of type to its method metadata
  static final _methods = <Type, Map<String, MethodMetadata>>{};

  /// Map of type to its constructor metadata
  static final _constructors = <Type, List<ConstructorMetadata>>{};

  /// Map of type to its constructor factories
  static final _constructorFactories = <Type, Map<String, Function>>{};

  /// Registers a type as reflectable
  static void registerType(Type type) {
    _properties[type] = {};
    _methods[type] = {};
    _constructors[type] = [];
    _constructorFactories[type] = {};
  }

  /// Registers a property for a type
  static void registerProperty(
    Type type,
    String name,
    Type propertyType, {
    bool isReadable = true,
    bool isWritable = true,
  }) {
    _properties[type]![name] = PropertyMetadata(
      name: name,
      type: propertyType,
      isReadable: isReadable,
      isWritable: isWritable,
    );
  }

  /// Registers a method for a type
  static void registerMethod(
    Type type,
    String name,
    List<Type> parameterTypes,
    bool returnsVoid, {
    List<String>? parameterNames,
    List<bool>? isRequired,
    List<bool>? isNamed,
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

    _methods[type]![name] = MethodMetadata(
      name: name,
      parameterTypes: parameterTypes,
      parameters: parameters,
      returnsVoid: returnsVoid,
    );
  }

  /// Registers a constructor for a type
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

    _constructors[type]!.add(ConstructorMetadata(
      name: name,
      parameterTypes: parameterTypes ?? [],
      parameters: parameters,
    ));
    _constructorFactories[type]![name] = factory;
  }

  /// Gets property metadata for a type
  static Map<String, PropertyMetadata>? getProperties(Type type) =>
      _properties[type];

  /// Gets method metadata for a type
  static Map<String, MethodMetadata>? getMethods(Type type) => _methods[type];

  /// Gets constructor metadata for a type
  static List<ConstructorMetadata>? getConstructors(Type type) =>
      _constructors[type];

  /// Gets a constructor factory for a type
  static Function? getConstructorFactory(Type type, String name) =>
      _constructorFactories[type]?[name];

  /// Checks if a type is registered
  static bool isRegistered(Type type) => _properties.containsKey(type);
}

/// Marks a class as reflectable, allowing runtime reflection capabilities.
class Reflectable {
  const Reflectable();
}

/// The annotation used to mark classes as reflectable.
const reflectable = Reflectable();

/// Mixin that provides reflection capabilities to a class.
mixin Reflector {
  /// Register this type for reflection.
  /// This should be called in the class's static initializer.
  static void register(Type type) {
    if (!ReflectionRegistry.isRegistered(type)) {
      ReflectionRegistry.registerType(type);
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
    ReflectionRegistry.registerProperty(
      type,
      name,
      propertyType,
      isReadable: isReadable,
      isWritable: isWritable,
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
  }) {
    ReflectionRegistry.registerMethod(
      type,
      name,
      parameterTypes,
      returnsVoid,
      parameterNames: parameterNames,
      isRequired: isRequired,
      isNamed: isNamed,
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
    ReflectionRegistry.registerConstructor(
      type,
      name,
      factory,
      parameterTypes: parameterTypes,
      parameterNames: parameterNames,
      isRequired: isRequired,
      isNamed: isNamed,
    );
  }

  /// Checks if a type is registered for reflection.
  static bool isReflectable(Type type) => ReflectionRegistry.isRegistered(type);

  /// Gets property metadata for a type.
  static Map<String, PropertyMetadata>? getPropertyMetadata(Type type) =>
      ReflectionRegistry.getProperties(type);

  /// Gets method metadata for a type.
  static Map<String, MethodMetadata>? getMethodMetadata(Type type) =>
      ReflectionRegistry.getMethods(type);

  /// Gets constructor metadata for a type.
  static List<ConstructorMetadata>? getConstructorMetadata(Type type) =>
      ReflectionRegistry.getConstructors(type);

  /// Gets a constructor factory for a type.
  static Function? getConstructor(Type type, String name) =>
      ReflectionRegistry.getConstructorFactory(type, name);
}

/// Checks if a type is registered for reflection.
bool isReflectable(Type type) => Reflector.isReflectable(type);
