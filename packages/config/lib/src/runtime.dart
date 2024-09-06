/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:mirrors';
import 'package:protevus_config/config.dart';
import 'package:protevus_runtime/runtime.dart';

/// ConfigurationRuntimeImpl is a class that extends ConfigurationRuntime and implements SourceCompiler.
///
/// This class is responsible for handling the runtime configuration of the application. It uses
/// Dart's mirror system to introspect and manipulate configuration objects at runtime.
///
/// Key features:
/// - Decodes configuration input from a Map into a strongly-typed Configuration object
/// - Validates the configuration to ensure all required fields are present
/// - Generates implementation code for decoding and validating configurations
/// - Collects and manages configuration properties
///
/// The class provides methods for decoding input, validating configurations, and compiling
/// source code for runtime configuration handling. It also includes utility methods for
/// collecting properties and generating implementation strings for decode and validate operations.
class ConfigurationRuntimeImpl extends ConfigurationRuntime
    implements SourceCompiler {
  /// Constructs a ConfigurationRuntimeImpl instance for the given type.
  ///
  /// The constructor initializes the type and properties of the configuration runtime.
  /// It collects properties using the `_collectProperties` method.
  ///
  /// Parameters:
  /// - type: The ClassMirror representing the type of the configuration object.
  ConfigurationRuntimeImpl(this.type) {
    // Should be done in the constructor so a type check could be run.
    properties = _collectProperties();
  }

  /// The ClassMirror representing the type of the configuration object.
  ///
  /// This field stores the reflection information for the configuration class,
  /// allowing for runtime introspection and manipulation of the configuration object.
  final ClassMirror type;

  /// A map of property names to MirrorConfigurationProperty objects.
  ///
  /// This late-initialized field stores the configuration properties of the class.
  /// Each key is a string representing the property name, and the corresponding value
  /// is a MirrorConfigurationProperty object containing metadata about that property.
  ///
  /// The properties are collected during the initialization of the ConfigurationRuntimeImpl
  /// instance and are used for decoding, validating, and generating implementation code
  /// for the configuration.
  late final Map<String, MirrorConfigurationProperty> properties;

  /// Decodes the input map into the given configuration object.
  ///
  /// This method takes a [Configuration] object and a [Map] input, and populates
  /// the configuration object with the decoded values from the input map.
  ///
  /// The method performs the following steps:
  /// 1. Creates a copy of the input map.
  /// 2. Iterates through each property in the configuration.
  /// 3. For each property, it attempts to decode the corresponding value from the input.
  /// 4. If the decoded value is not null and of the correct type, it sets the value on the configuration object.
  /// 5. After processing all properties, it checks if there are any unexpected keys left in the input map.
  ///
  /// Throws a [ConfigurationException] if:
  /// - A decoded value is of the wrong type.
  /// - There are unexpected keys in the input map after processing all known properties.
  ///
  /// Parameters:
  /// - [configuration]: The Configuration object to be populated with decoded values.
  /// - [input]: A Map containing the input values to be decoded.
  @override
  void decode(Configuration configuration, Map input) {
    final values = Map.from(input);
    properties.forEach((name, property) {
      final takingValue = values.remove(name);
      if (takingValue == null) {
        return;
      }

      final decodedValue = tryDecode(
        configuration,
        name,
        () => property.decode(takingValue),
      );
      if (decodedValue == null) {
        return;
      }

      if (!reflect(decodedValue).type.isAssignableTo(property.property.type)) {
        throw ConfigurationException(
          configuration,
          "input is wrong type",
          keyPath: [name],
        );
      }

      final mirror = reflect(configuration);
      mirror.setField(property.property.simpleName, decodedValue);
    });

    if (values.isNotEmpty) {
      throw ConfigurationException(
        configuration,
        "unexpected keys found: ${values.keys.map((s) => "'$s'").join(", ")}.",
      );
    }
  }

  /// Generates the implementation string for the decode method.
  ///
  /// This getter creates a String representation of the decode method implementation.
  /// The generated code does the following:
  /// 1. Creates a copy of the input map.
  /// 2. Iterates through each property in the configuration.
  /// 3. For each property:
  ///    - Retrieves the value from the input, considering environment variables.
  ///    - If a value exists, it attempts to decode it.
  ///    - Checks if the decoded value is of the expected type.
  ///    - If valid, assigns the decoded value to the configuration object.
  /// 4. After processing all properties, it checks for any unexpected keys in the input.
  ///
  /// The generated code includes proper error handling, throwing ConfigurationExceptions
  /// for type mismatches or unexpected input keys.
  ///
  /// Returns:
  ///   A String containing the implementation code for the decode method.
  String get decodeImpl {
    final buf = StringBuffer();

    buf.writeln("final valuesCopy = Map.from(input);");
    properties.forEach((k, v) {
      buf.writeln("{");
      buf.writeln(
        "final v = Configuration.getEnvironmentOrValue(valuesCopy.remove('$k'));",
      );
      buf.writeln("if (v != null) {");
      buf.writeln(
        "  final decodedValue = tryDecode(configuration, '$k', () { ${v.source} });",
      );
      buf.writeln("  if (decodedValue is! ${v.codec.expectedType}) {");
      buf.writeln(
        "    throw ConfigurationException(configuration, 'input is wrong type', keyPath: ['$k']);",
      );
      buf.writeln("  }");
      buf.writeln(
        "  (configuration as ${type.reflectedType}).$k = decodedValue as ${v.codec.expectedType};",
      );
      buf.writeln("}");
      buf.writeln("}");
    });

    buf.writeln(
      """
    if (valuesCopy.isNotEmpty) {
      throw ConfigurationException(configuration,
          "unexpected keys found: \${valuesCopy.keys.map((s) => "'\$s'").join(", ")}.");
    }
    """,
    );

    return buf.toString();
  }

  /// Validates the given configuration object to ensure all required properties are present.
  ///
  /// This method performs the following steps:
  /// 1. Creates a mirror of the configuration object for reflection.
  /// 2. Iterates through all properties of the configuration.
  /// 3. For each property, it checks if:
  ///    - The property is required.
  ///    - The property value is null or cannot be accessed.
  /// 4. Collects a list of all required properties that are missing or null.
  /// 5. If any required properties are missing, it throws a ConfigurationException.
  ///
  /// Parameters:
  /// - configuration: The Configuration object to be validated.
  ///
  /// Throws:
  /// - ConfigurationException: If any required properties are missing or null.
  @override
  void validate(Configuration configuration) {
    final configMirror = reflect(configuration);
    final requiredValuesThatAreMissing = properties.values
        .where((v) {
          try {
            final value = configMirror.getField(Symbol(v.key)).reflectee;
            return v.isRequired && value == null;
          } catch (e) {
            return true;
          }
        })
        .map((v) => v.key)
        .toList();

    if (requiredValuesThatAreMissing.isNotEmpty) {
      throw ConfigurationException.missingKeys(
        configuration,
        requiredValuesThatAreMissing,
      );
    }
  }

  /// Collects and returns a map of configuration properties for the current type.
  ///
  /// This method traverses the class hierarchy, starting from the current type
  /// up to (but not including) the Configuration class, collecting all non-static
  /// and non-private variable declarations. It then creates a map where:
  ///
  /// - Keys are the string names of the properties
  /// - Values are MirrorConfigurationProperty objects created from the VariableMirrors
  ///
  /// The method performs the following steps:
  /// 1. Initializes an empty list to store VariableMirror objects.
  /// 2. Traverses the class hierarchy, collecting relevant VariableMirrors.
  /// 3. Creates a map from the collected VariableMirrors.
  /// 4. Returns the resulting map of property names to MirrorConfigurationProperty objects.
  ///
  /// Returns:
  ///   A Map<String, MirrorConfigurationProperty> representing the configuration properties.
  Map<String, MirrorConfigurationProperty> _collectProperties() {
    final declarations = <VariableMirror>[];

    var ptr = type;
    while (ptr.isSubclassOf(reflectClass(Configuration))) {
      declarations.addAll(
        ptr.declarations.values
            .whereType<VariableMirror>()
            .where((vm) => !vm.isStatic && !vm.isPrivate),
      );
      ptr = ptr.superclass!;
    }

    final m = <String, MirrorConfigurationProperty>{};
    for (final vm in declarations) {
      final name = MirrorSystem.getName(vm.simpleName);
      m[name] = MirrorConfigurationProperty(vm);
    }
    return m;
  }

  /// Generates the implementation string for the validate method.
  ///
  /// This getter creates a String representation of the validate method implementation.
  /// The generated code does the following:
  /// 1. Initializes a list to store missing keys.
  /// 2. Iterates through each property in the configuration.
  /// 3. For each property:
  ///    - Attempts to retrieve the property value from the configuration object.
  ///    - Checks if the property is required and its value is null.
  ///    - If required and null, or if an error occurs during retrieval, adds the property name to the missing keys list.
  /// 4. After checking all properties, throws a ConfigurationException if any keys are missing.
  ///
  /// The generated code includes error handling to catch any issues during property access.
  ///
  /// Returns:
  ///   A String containing the implementation code for the validate method.
  String get validateImpl {
    final buf = StringBuffer();

    const startValidation = """
    final missingKeys = <String>[];
""";
    buf.writeln(startValidation);
    properties.forEach((name, property) {
      final propCheck = """
    try {
      final $name = (configuration as ${type.reflectedType}).$name;
      if (${property.isRequired} && $name == null) {
        missingKeys.add('$name');
      }
    } on Error catch (e) {
      missingKeys.add('$name');
    }""";
      buf.writeln(propCheck);
    });
    const throwIfErrors = """
    if (missingKeys.isNotEmpty) {
      throw ConfigurationException.missingKeys(configuration, missingKeys);
    }""";
    buf.writeln(throwIfErrors);

    return buf.toString();
  }

  /// Compiles the configuration runtime implementation into a string representation.
  ///
  /// This method generates the source code for a ConfigurationRuntimeImpl class
  /// that extends ConfigurationRuntime. The generated class includes implementations
  /// for the 'decode' and 'validate' methods.
  ///
  /// The method performs the following steps:
  /// 1. Retrieves import directives for the current type and adds them to the generated code.
  /// 2. Adds an import for the intermediate_exception.dart file.
  /// 3. Creates an instance of ConfigurationRuntimeImpl.
  /// 4. Generates the class definition with implementations of decode and validate methods.
  ///
  /// Parameters:
  /// - ctx: A BuildContext object used to retrieve import directives.
  ///
  /// Returns:
  /// A Future<String> containing the generated source code for the ConfigurationRuntimeImpl class.
  @override
  Future<String> compile(BuildContext ctx) async {
    final directives = await ctx.getImportDirectives(
      uri: type.originalDeclaration.location!.sourceUri,
      alsoImportOriginalFile: true,
    )
      ..add("import 'package:conduit_config/src/intermediate_exception.dart';");
    return """
    ${directives.join("\n")}
    final instance = ConfigurationRuntimeImpl();
    class ConfigurationRuntimeImpl extends ConfigurationRuntime {
      @override
      void decode(Configuration configuration, Map input) {
        $decodeImpl
      }

      @override
      void validate(Configuration configuration) {
        $validateImpl
      }
    }
    """;
  }
}
