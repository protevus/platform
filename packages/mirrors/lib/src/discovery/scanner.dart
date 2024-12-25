import 'dart:core';
import 'package:platform_mirrors/mirrors.dart';

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
    ReflectionRegistry.register(type);

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
      ReflectionRegistry.registerPropertyMetadata(
          type, property.name, propertyMeta);
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
      ReflectionRegistry.registerMethodMetadata(type, method.name, methodMeta);
    }

    // Register constructors
    for (var constructor in typeInfo.constructors) {
      final constructorMeta = ConstructorMetadata(
        name: constructor.name,
        parameterTypes: constructor.parameterTypes,
        parameters: constructor.parameters,
      );
      constructorMetadata.add(constructorMeta);
      ReflectionRegistry.registerConstructorMetadata(type, constructorMeta);
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
