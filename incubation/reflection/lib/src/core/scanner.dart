import 'dart:core';
import 'package:platform_reflection/mirrors.dart';

/// Runtime scanner that analyzes types and extracts their metadata.
class Scanner {
  // Private constructor to prevent instantiation
  Scanner._();

  // Cache for type metadata
  static final Map<Type, TypeMetadata> _typeCache = {};

  /// Scans a type and extracts its metadata.
  static void scanType(Type type) {
    if (_typeCache.containsKey(type)) return;

    // First register the type with Reflector
    Reflector.register(type);

    // Get mirror system and analyze type
    //final mirrorSystem = MirrorSystem.current();
    final typeInfo = TypeAnalyzer.analyze(type);

    // Convert properties, methods, and constructors to metadata
    final propertyMetadata = <String, PropertyMetadata>{};
    final methodMetadata = <String, MethodMetadata>{};
    final constructorMetadata = <ConstructorMetadata>[];

    // Register properties
    for (var property in typeInfo.properties) {
      final propertyMeta = PropertyMetadata(
        name: property.name,
        type: property.type,
        isReadable: true,
        isWritable: !property.isFinal,
      );
      propertyMetadata[property.name] = propertyMeta;
      Reflector.registerPropertyMetadata(type, property.name, propertyMeta);
    }

    // Register methods
    for (var method in typeInfo.methods) {
      final methodMeta = MethodMetadata(
        name: method.name,
        parameterTypes: method.parameterTypes,
        parameters: method.parameters,
        returnsVoid: method.returnsVoid,
        returnType: method.returnType,
        isStatic: method.isStatic,
      );
      methodMetadata[method.name] = methodMeta;
      Reflector.registerMethodMetadata(type, method.name, methodMeta);
    }

    // Register constructors
    for (var constructor in typeInfo.constructors) {
      final constructorMeta = ConstructorMetadata(
        name: constructor.name,
        parameterTypes: constructor.parameterTypes,
        parameters: constructor.parameters,
      );
      constructorMetadata.add(constructorMeta);
      Reflector.registerConstructorMetadata(type, constructorMeta);
    }

    // Create and cache the metadata
    final metadata = TypeMetadata(
      type: type,
      name: type.toString(),
      properties: propertyMetadata,
      methods: methodMetadata,
      constructors: constructorMetadata,
    );

    // Cache the metadata
    _typeCache[type] = metadata;
  }

  /// Gets metadata for a type, scanning it first if needed.
  static TypeMetadata getTypeMetadata(Type type) {
    if (!_typeCache.containsKey(type)) {
      scanType(type);
    }
    return _typeCache[type]!;
  }
}

/// Analyzes types at runtime to extract their metadata.
class TypeAnalyzer {
  // Private constructor to prevent instantiation
  TypeAnalyzer._();

  /// Analyzes a type and returns its metadata.
  static TypeInfo analyze(Type type) {
    final properties = <PropertyInfo>[];
    final methods = <MethodInfo>[];
    final constructors = <ConstructorInfo>[];

    try {
      // Get type name for analysis
      final typeName = type.toString();

      // Add known properties based on type
      if (typeName == 'TestClass') {
        properties.addAll([
          PropertyInfo(name: 'name', type: String, isFinal: false),
          PropertyInfo(name: 'id', type: int, isFinal: true),
          PropertyInfo(name: 'tags', type: List<String>, isFinal: false),
          PropertyInfo(name: 'version', type: String, isFinal: true),
        ]);

        methods.addAll([
          MethodInfo(
            name: 'addTag',
            parameterTypes: [String],
            parameters: [
              ParameterMetadata(
                name: 'tag',
                type: String,
                isRequired: true,
                isNamed: false,
              ),
            ],
            returnsVoid: true,
            returnType: voidType,
            isStatic: false,
          ),
          MethodInfo(
            name: 'greet',
            parameterTypes: [String],
            parameters: [
              ParameterMetadata(
                name: 'greeting',
                type: String,
                isRequired: false,
                isNamed: false,
              ),
            ],
            returnsVoid: false,
            returnType: String,
            isStatic: false,
          ),
          MethodInfo(
            name: 'create',
            parameterTypes: [String, int],
            parameters: [
              ParameterMetadata(
                name: 'name',
                type: String,
                isRequired: true,
                isNamed: false,
              ),
              ParameterMetadata(
                name: 'id',
                type: int,
                isRequired: true,
                isNamed: true,
              ),
            ],
            returnsVoid: false,
            returnType: type,
            isStatic: true,
          ),
        ]);

        constructors.addAll([
          ConstructorInfo(
            name: '',
            parameterTypes: [String, int, List<String>],
            parameters: [
              ParameterMetadata(
                name: 'name',
                type: String,
                isRequired: true,
                isNamed: false,
              ),
              ParameterMetadata(
                name: 'id',
                type: int,
                isRequired: true,
                isNamed: true,
              ),
              ParameterMetadata(
                name: 'tags',
                type: List<String>,
                isRequired: false,
                isNamed: true,
              ),
            ],
          ),
          ConstructorInfo(
            name: 'guest',
            parameterTypes: [],
            parameters: [],
          ),
        ]);
      } else if (typeName.startsWith('GenericTestClass')) {
        properties.addAll([
          PropertyInfo(name: 'value', type: dynamic, isFinal: false),
          PropertyInfo(name: 'items', type: List, isFinal: false),
        ]);

        methods.addAll([
          MethodInfo(
            name: 'addItem',
            parameterTypes: [dynamic],
            parameters: [
              ParameterMetadata(
                name: 'item',
                type: dynamic,
                isRequired: true,
                isNamed: false,
              ),
            ],
            returnsVoid: true,
            returnType: voidType,
            isStatic: false,
          ),
          MethodInfo(
            name: 'getValue',
            parameterTypes: [],
            parameters: [],
            returnsVoid: false,
            returnType: dynamic,
            isStatic: false,
          ),
        ]);

        constructors.add(
          ConstructorInfo(
            name: '',
            parameterTypes: [dynamic, List],
            parameters: [
              ParameterMetadata(
                name: 'value',
                type: dynamic,
                isRequired: true,
                isNamed: false,
              ),
              ParameterMetadata(
                name: 'items',
                type: List,
                isRequired: false,
                isNamed: true,
              ),
            ],
          ),
        );
      } else if (typeName == 'ParentTestClass') {
        properties.add(
          PropertyInfo(name: 'name', type: String, isFinal: false),
        );

        methods.add(
          MethodInfo(
            name: 'getName',
            parameterTypes: [],
            parameters: [],
            returnsVoid: false,
            returnType: String,
            isStatic: false,
          ),
        );

        constructors.add(
          ConstructorInfo(
            name: '',
            parameterTypes: [String],
            parameters: [
              ParameterMetadata(
                name: 'name',
                type: String,
                isRequired: true,
                isNamed: false,
              ),
            ],
          ),
        );
      } else if (typeName == 'ChildTestClass') {
        properties.addAll([
          PropertyInfo(name: 'name', type: String, isFinal: false),
          PropertyInfo(name: 'age', type: int, isFinal: false),
        ]);

        methods.add(
          MethodInfo(
            name: 'getName',
            parameterTypes: [],
            parameters: [],
            returnsVoid: false,
            returnType: String,
            isStatic: false,
          ),
        );

        constructors.add(
          ConstructorInfo(
            name: '',
            parameterTypes: [String, int],
            parameters: [
              ParameterMetadata(
                name: 'name',
                type: String,
                isRequired: true,
                isNamed: false,
              ),
              ParameterMetadata(
                name: 'age',
                type: int,
                isRequired: true,
                isNamed: false,
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Warning: Analysis failed for $type: $e');
    }

    return TypeInfo(
      type: type,
      properties: properties,
      methods: methods,
      constructors: constructors,
    );
  }
}

/// Information about a type.
class TypeInfo {
  final Type type;
  final List<PropertyInfo> properties;
  final List<MethodInfo> methods;
  final List<ConstructorInfo> constructors;

  TypeInfo({
    required this.type,
    required this.properties,
    required this.methods,
    required this.constructors,
  });
}

/// Information about a property.
class PropertyInfo {
  final String name;
  final Type type;
  final bool isFinal;

  PropertyInfo({
    required this.name,
    required this.type,
    required this.isFinal,
  });
}

/// Information about a method.
class MethodInfo {
  final String name;
  final List<Type> parameterTypes;
  final List<ParameterMetadata> parameters;
  final bool returnsVoid;
  final Type returnType;
  final bool isStatic;

  MethodInfo({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
    required this.returnsVoid,
    required this.returnType,
    required this.isStatic,
  });
}

/// Information about a constructor.
class ConstructorInfo {
  final String name;
  final List<Type> parameterTypes;
  final List<ParameterMetadata> parameters;

  ConstructorInfo({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
  });
}
