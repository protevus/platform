/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';
import 'package:protevus_openapi/object.dart';

/// An object representing a Server.
///
/// This class is used to describe a server in an OpenAPI specification.
/// It includes information about the server's URL, an optional description,
/// and any variables that can be used in the URL template.
///
/// The [url] property is required and represents the URL to the target host.
/// It may include server variables in {brackets} for substitution.
///
/// The [description] property is optional and can provide additional
/// information about the server.
///
/// The [variables] property is a map of server variables that can be used
/// for substitution in the URL template.
class APIServerDescription extends APIObject {
  /// Creates a new [APIServerDescription] instance.
  ///
  /// [url] is a required parameter representing the URL to the target host.
  /// It may include server variables in {brackets} for substitution.
  ///
  /// [description] is an optional parameter that provides additional
  /// information about the server.
  ///
  /// [variables] is an optional parameter representing a map of server
  /// variables that can be used for substitution in the URL template.
  APIServerDescription(this.url, {this.description, this.variables});

  /// Creates an empty [APIServerDescription] instance.
  ///
  /// This constructor initializes an [APIServerDescription] object without setting any of its properties.
  /// It can be useful when you need to create an instance that will be populated later.
  APIServerDescription.empty();

  /// A URL to the target host.
  ///
  /// This URL is required and represents the location of the target host.
  /// It supports Server Variables and may be relative, indicating that the host
  /// location is relative to where the OpenAPI document is being served.
  ///
  /// Variable substitutions will be made when a variable is named in {brackets}.
  /// For example, a URL like "https://{username}.example.com" would allow
  /// substitution of the {username} part.
  ///
  /// This field is crucial for specifying where API requests should be sent.
  Uri? url;

  /// An optional string describing the host designated by the URL.
  ///
  /// This property provides additional information about the server, which can be useful for API consumers.
  /// It may include details such as the environment (e.g., production, staging), the purpose of the server,
  /// or any specific characteristics.
  ///
  /// The description can use CommonMark syntax for rich text representation, allowing for formatted text,
  /// links, and other markup elements.
  ///
  /// Example:
  /// ```
  /// description: "Production server for the European region"
  /// ```
  ///
  /// This field is optional and can be null if no description is provided.
  String? description;

  /// A map between a variable name and its value.
  ///
  /// This property represents a mapping of server variable names to their corresponding [APIServerVariable] objects.
  /// These variables can be used for substitution in the server's URL template.
  ///
  /// Each key in the map is a string representing the variable name, and the corresponding value
  /// is an [APIServerVariable] object (or null) that defines the properties of that variable.
  ///
  /// For example, if the server URL is "https://{username}.example.com", the variables map might contain
  /// a key "username" with an [APIServerVariable] value that specifies the default username and possible alternatives.
  ///
  /// This field is optional and can be null if no variables are defined for the server.
  Map<String, APIServerVariable?>? variables;

  /// Decodes the [APIServerDescription] object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the properties of the [APIServerDescription]
  /// instance from the provided [KeyedArchive] object. It performs the following steps:
  ///
  /// 1. Calls the superclass's decode method to handle any inherited properties.
  /// 2. Decodes the 'url' field from the archive and assigns it to the [url] property.
  /// 3. Decodes the 'description' field and assigns it to the [description] property.
  /// 4. Decodes the 'variables' field as an object map, where each value is an [APIServerVariable].
  ///    It uses [APIServerVariable.empty()] as a factory function to create new instances.
  ///
  /// This method is typically called when deserializing the object from a JSON or similar format.
  ///
  /// [object] is the [KeyedArchive] containing the encoded data for this object.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    url = object.decode("url");
    description = object.decode("description");
    variables =
        object.decodeObjectMap("variables", () => APIServerVariable.empty());
  }

  /// Encodes the [APIServerDescription] object into a [KeyedArchive].
  ///
  /// This method is responsible for serializing the properties of the [APIServerDescription]
  /// instance into the provided [KeyedArchive] object. It performs the following steps:
  ///
  /// 1. Calls the superclass's encode method to handle any inherited properties.
  /// 2. Checks if the [url] property is null. If it is, an [ArgumentError] is thrown
  ///    because the 'url' field is required for a valid [APIServerDescription].
  /// 3. Encodes the [url] property into the archive with the key "url".
  /// 4. Encodes the [description] property into the archive with the key "description".
  /// 5. Encodes the [variables] property as an object map into the archive with the key "variables".
  ///
  /// This method is typically called when serializing the object to JSON or a similar format.
  ///
  /// [object] is the [KeyedArchive] where the encoded data for this object will be stored.
  ///
  /// Throws an [ArgumentError] if the [url] property is null.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (url == null) {
      throw ArgumentError(
        "APIServerDescription must have non-null values for: 'url'.",
      );
    }

    object.encode("url", url);
    object.encode("description", description);
    object.encodeObjectMap("variables", variables);
  }
}

/// An object representing a Server Variable for server URL template substitution.
///
/// This class extends [APIObject] and represents a variable that can be used
/// in a server URL template. It includes properties for the default value,
/// available values (enum), and an optional description.
///
/// The [defaultValue] is required and represents the value to be used if no
/// other value is provided.
///
/// [availableValues] is an optional list of allowed values for the variable.
///
/// [description] is an optional field providing additional information about
/// the variable.
class APIServerVariable extends APIObject {
  /// Creates a new [APIServerVariable] instance.
  ///
  /// [defaultValue] is a required parameter representing the default value to use for substitution.
  /// This value MUST be provided by the consumer.
  ///
  /// [availableValues] is an optional parameter that provides a list of allowed values for the variable.
  /// If provided, it represents an enumeration of string values to be used if the substitution options
  /// are from a limited set.
  ///
  /// [description] is an optional parameter that provides additional information about the server variable.
  /// CommonMark syntax MAY be used for rich text representation.
  APIServerVariable(
    this.defaultValue, {
    this.availableValues,
    this.description,
  });

  /// Creates an empty [APIServerVariable] instance.
  ///
  /// This constructor initializes an [APIServerVariable] object without setting any of its properties.
  /// It can be useful when you need to create an instance that will be populated later.
  APIServerVariable.empty();

  /// An enumeration of string values to be used if the substitution options are from a limited set.
  ///
  /// This property represents an optional list of allowed values for the server variable.
  /// If provided, it restricts the possible values that can be used for substitution
  /// in the server URL template to this specific set of strings.
  ///
  /// When defined, the variable value used for URL substitution must be one of the values
  /// listed in this array. This allows for validation and helps ensure that only
  /// pre-defined, valid values are used in the server URL.
  ///
  /// The list can be null if there are no restrictions on the possible values for the variable.
  List<String>? availableValues;

  /// The default value to use for substitution in the server URL template.
  ///
  /// REQUIRED. Unlike the Schema Object's default, this value MUST be provided by the consumer.
  String? defaultValue;

  /// An optional description for the server variable.
  ///
  /// This property provides additional information about the server variable,
  /// which can be helpful for API consumers to understand its purpose or usage.
  /// The description can include details such as the expected format of the value,
  /// any constraints, or examples of valid inputs.
  ///
  /// CommonMark syntax MAY be used for rich text representation, allowing for
  /// formatted text, links, and other markup elements to enhance readability
  /// and provide more detailed explanations.
  ///
  /// This field is optional and can be null if no description is provided.
  ///
  /// Example:
  /// ```
  /// description: "The username for authentication. Use 'demo' for testing."
  /// ```
  String? description;

  /// Decodes the [APIServerVariable] object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the properties of the [APIServerVariable]
  /// instance from the provided [KeyedArchive] object. It performs the following steps:
  ///
  /// 1. Calls the superclass's decode method to handle any inherited properties.
  /// 2. Decodes the 'enum' field from the archive, casts it to a List<String>, and assigns it to [availableValues].
  /// 3. Decodes the 'default' field and assigns it to the [defaultValue] property.
  /// 4. Decodes the 'description' field and assigns it to the [description] property.
  ///
  /// This method is typically called when deserializing the object from a JSON or similar format.
  ///
  /// [object] is the [KeyedArchive] containing the encoded data for this object.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    final enumMap = object.decode("enum") as List<String>;
    availableValues = List<String>.from(enumMap);
    defaultValue = object.decode("default");
    description = object.decode("description");
  }

  /// Encodes the [APIServerVariable] object into a [KeyedArchive].
  ///
  /// This method is responsible for serializing the properties of the [APIServerVariable]
  /// instance into the provided [KeyedArchive] object. It performs the following steps:
  ///
  /// 1. Calls the superclass's encode method to handle any inherited properties.
  /// 2. Checks if the [defaultValue] property is null. If it is, an [ArgumentError] is thrown
  ///    because the 'defaultValue' field is required for a valid [APIServerVariable].
  /// 3. Encodes the [availableValues] property into the archive with the key "enum".
  /// 4. Encodes the [defaultValue] property into the archive with the key "default".
  /// 5. Encodes the [description] property into the archive with the key "description".
  ///
  /// This method is typically called when serializing the object to JSON or a similar format.
  ///
  /// [object] is the [KeyedArchive] where the encoded data for this object will be stored.
  ///
  /// Throws an [ArgumentError] if the [defaultValue] property is null.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (defaultValue == null) {
      throw ArgumentError(
        "APIServerVariable must have non-null values for: 'defaultValue'.",
      );
    }

    object.encode("enum", availableValues);
    object.encode("default", defaultValue);
    object.encode("description", description);
  }
}
