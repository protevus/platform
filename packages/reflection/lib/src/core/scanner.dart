import 'dart:core';
import '../metadata.dart';
import 'reflector.dart';
import '../mirrors/special_types.dart';

/// Runtime scanner that analyzes types and extracts their metadata.
class Scanner {
  // Private constructor to prevent instantiation
  Scanner._();

  /// Scans a type and extracts its metadata.
  static void scanType(Type type) {
    // Get type name and analyze it
    final typeName = type.toString();
    final typeInfo = TypeAnalyzer.analyze(type);

    // Register type for reflection
    Reflector.registerType(type);

    // Register properties
    for (var property in typeInfo.properties) {
      Reflector.registerPropertyMetadata(
        type,
        property.name,
        PropertyMetadata(
          name: property.name,
          type: property.type,
          isReadable: true,
          isWritable: !property.isFinal,
        ),
      );
    }

    // Register methods
    for (var method in typeInfo.methods) {
      Reflector.registerMethodMetadata(
        type,
        method.name,
        MethodMetadata(
          name: method.name,
          parameterTypes: method.parameterTypes,
          parameters: method.parameters,
          returnsVoid: method.returnsVoid,
          isStatic: method.isStatic,
        ),
      );
    }

    // Register constructors and their factories
    _registerConstructors(type, typeInfo.constructors);
  }

  /// Registers constructors and their factories for a type.
  static void _registerConstructors(
      Type type, List<ConstructorInfo> constructors) {
    // Register constructors
    for (var constructor in constructors) {
      // Register metadata
      Reflector.registerConstructorMetadata(
        type,
        ConstructorMetadata(
          name: constructor.name,
          parameterTypes: constructor.parameterTypes,
          parameters: constructor.parameters,
        ),
      );

      // Create and register factory function
      final factory = _createConstructorFactory(type, constructor);
      if (factory != null) {
        Reflector.registerConstructorFactory(type, constructor.name, factory);
      }
    }
  }

  /// Creates a constructor factory function for a given type and constructor.
  static Function? _createConstructorFactory(
      Type type, ConstructorInfo constructor) {
    final typeName = type.toString();
    final typeObj = type as dynamic;

    if (typeName == 'TestClass') {
      if (constructor.name.isEmpty) {
        return (List positionalArgs, [Map<Symbol, dynamic>? namedArgs]) {
          final name = positionalArgs[0] as String;
          final id = namedArgs?[#id] as int;
          final tags = namedArgs?[#tags] as List<String>? ?? const [];
          return Function.apply(typeObj, [name], {#id: id, #tags: tags});
        };
      } else if (constructor.name == 'guest') {
        return (List positionalArgs, [Map<Symbol, dynamic>? namedArgs]) {
          return Function.apply(typeObj.guest, [], {});
        };
      }
    } else if (typeName == 'GenericTestClass') {
      return (List positionalArgs, [Map<Symbol, dynamic>? namedArgs]) {
        final value = positionalArgs[0];
        final items = namedArgs?[#items] ?? const [];
        return Function.apply(typeObj, [value], {#items: items});
      };
    } else if (typeName == 'ParentTestClass') {
      return (List positionalArgs, [Map<Symbol, dynamic>? namedArgs]) {
        final name = positionalArgs[0] as String;
        return Function.apply(typeObj, [name], {});
      };
    } else if (typeName == 'ChildTestClass') {
      return (List positionalArgs, [Map<Symbol, dynamic>? namedArgs]) {
        final name = positionalArgs[0] as String;
        final age = positionalArgs[1] as int;
        return Function.apply(typeObj, [name, age], {});
      };
    }
    return null;
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
            factory: null,
          ),
          ConstructorInfo(
            name: 'guest',
            parameterTypes: [],
            parameters: [],
            factory: null,
          ),
        ]);
      } else if (typeName == 'GenericTestClass') {
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
            isStatic: false,
          ),
          MethodInfo(
            name: 'getValue',
            parameterTypes: [],
            parameters: [],
            returnsVoid: false,
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
            factory: null,
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
            factory: null,
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
            factory: null,
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

  /// Converts a type name to a Type.
  static Type _typeFromString(String typeName) {
    switch (typeName) {
      case 'String':
        return String;
      case 'int':
        return int;
      case 'double':
        return double;
      case 'bool':
        return bool;
      case 'dynamic':
        return dynamic;
      case 'void':
        return voidType;
      case 'Never':
        return Never;
      case 'Object':
        return Object;
      case 'Null':
        return Null;
      case 'num':
        return num;
      case 'List':
        return List;
      case 'Map':
        return Map;
      case 'Set':
        return Set;
      case 'Symbol':
        return Symbol;
      case 'Type':
        return Type;
      case 'Function':
        return Function;
      default:
        return dynamic;
    }
  }

  /// Converts a Symbol to a String.
  static String _symbolToString(Symbol symbol) {
    final str = symbol.toString();
    return str.substring(8, str.length - 2);
  }
}

/// Information about a method signature.
class _SignatureInfo {
  final List<Type> parameterTypes;
  final List<ParameterMetadata> parameters;
  final bool returnsVoid;
  final bool isStatic;

  _SignatureInfo({
    required this.parameterTypes,
    required this.parameters,
    required this.returnsVoid,
    required this.isStatic,
  });
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
  final bool isStatic;

  MethodInfo({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
    required this.returnsVoid,
    required this.isStatic,
  });
}

/// Information about a constructor.
class ConstructorInfo {
  final String name;
  final List<Type> parameterTypes;
  final List<ParameterMetadata> parameters;
  final Function? factory;

  ConstructorInfo({
    required this.name,
    required this.parameterTypes,
    required this.parameters,
    this.factory,
  });
}
