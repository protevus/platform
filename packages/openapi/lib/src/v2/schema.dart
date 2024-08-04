/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/cast.dart' as cast;
import 'package:protevus_typeforge/codable.dart';
import 'package:protevus_openapi/v2.dart';

/// Represents a schema object in the OpenAPI specification.
///
/// This class extends [APIProperty] and provides additional properties and methods
/// specific to schema objects in the OpenAPI specification.
///
/// Properties:
/// - [title]: A string representing the title of the schema.
/// - [description]: A string describing the schema.
/// - [example]: An example value for the schema.
/// - [isRequired]: A list of required properties.
/// - [readOnly]: A boolean indicating if the schema is read-only.
/// - [items]: An [APISchemaObject] representing array items (valid when type is array).
/// - [properties]: A map of property names to [APISchemaObject]s (valid when type is null).
/// - [additionalProperties]: An [APISchemaObject] for additional properties (valid when type is object).
///
/// Methods:
/// - [representation]: Returns the [APISchemaRepresentation] of the schema.
/// - [decode]: Decodes the schema from a [KeyedArchive].
/// - [encode]: Encodes the schema to a [KeyedArchive].
///
/// This class also overrides the [castMap] getter to provide custom casting for the 'required' field.
class APISchemaObject extends APIProperty {
  /// Default constructor for APISchemaObject.
  ///
  /// Creates a new instance of APISchemaObject with default values.
  /// This constructor doesn't take any parameters and initializes
  /// the object with its default state.
  APISchemaObject();

  /// The title of the schema.
  ///
  /// This property represents the title of the schema object.
  /// It can be null if no title is specified.
  String? title;

  /// A description of the schema.
  ///
  /// This property provides a detailed explanation of the schema object.
  /// It can be null if no description is specified.
  String? description;

  /// An example value for the schema.
  ///
  /// This property holds an example value that represents the schema.
  /// It can be of any type (String, int, bool, Map, List, etc.) depending on the schema definition.
  /// The example is used to provide a clear illustration of what data conforming to the schema might look like.
  /// This property can be null if no example is specified.
  String? example;

  /// A list of required properties for this schema object.
  ///
  /// This list contains the names of properties that are required
  /// for this schema to be valid. Each element is a String representing
  /// a property name. The list can be empty if no properties are required,
  /// or it can be null if the required properties are not specified.
  ///
  /// Note: The list allows null values, though typically all elements
  /// should be non-null property names.
  List<String?>? isRequired = [];

  /// Indicates whether the schema is read-only.
  ///
  /// When set to true, it specifies that the schema should be treated as read-only,
  /// meaning it can be retrieved and read, but should not be modified or updated.
  /// This is particularly useful for properties that are auto-generated or controlled by the system.
  ///
  /// Defaults to false, indicating that the schema is writable by default.
  bool readOnly = false;

  /// Represents the schema for array items when the type is 'array'.
  ///
  /// This property is only applicable when the schema's type is set to 'array'.
  /// It defines the schema for the items within the array.
  ///
  /// - If [items] is null, it means the array items have no specific schema defined.
  /// - If [items] is set, it provides the schema that all items in the array must conform to.
  ///
  /// Example:
  /// If this schema represents an array of strings, [items] would be an APISchemaObject
  /// with its type set to 'string'.
  APISchemaObject? items;

  /// A map of property names to their corresponding schema objects.
  ///
  /// This property is valid when the schema's type is null or 'object'.
  /// It defines the structure of an object by specifying the schemas of its properties.
  ///
  /// The keys in the map are strings representing property names.
  /// The values are [APISchemaObject] instances that define the schema for each property.
  ///
  /// This property can be null if no properties are defined, or if the schema
  /// represents a type other than an object.
  ///
  /// Example:
  /// ```dart
  /// properties = {
  ///   "name": APISchemaObject()..type = "string",
  ///   "age": APISchemaObject()..type = "integer"
  /// };
  /// ```
  Map<String, APISchemaObject?>? properties;

  /// Represents the schema for additional properties when the type is 'object'.
  ///
  /// This property is applicable when the schema's type is set to 'object'.
  /// It defines the schema for any additional properties that are not explicitly defined
  /// in the [properties] map.
  ///
  /// - If [additionalProperties] is null, it means additional properties are not allowed.
  /// - If [additionalProperties] is set to an [APISchemaObject], it specifies the schema
  ///   that any additional properties must conform to.
  ///
  /// This property allows for flexible object structures where some properties are
  /// explicitly defined, while others can follow a general schema.
  ///
  /// Example:
  /// If set to an [APISchemaObject] with type "string", it means any additional
  /// properties not listed in [properties] must have string values.
  ///
  /// Valid when type == object
  APISchemaObject? additionalProperties;

  /// Returns the representation of this schema object.
  ///
  /// This method overrides the base [representation] getter to provide
  /// specific behavior for schema objects with properties.
  ///
  /// If the [properties] map is not null, it indicates that this schema
  /// represents a structured object, so it returns [APISchemaRepresentation.structure].
  ///
  /// If [properties] is null, it falls back to the superclass implementation
  /// to determine the representation based on other attributes of the schema.
  ///
  /// Returns:
  ///   [APISchemaRepresentation.structure] if [properties] is not null,
  ///   otherwise returns the result of the superclass [representation] getter.
  @override
  APISchemaRepresentation get representation {
    if (properties != null) {
      return APISchemaRepresentation.structure;
    }

    return super.representation;
  }

  /// Overrides the [castMap] getter to provide custom casting for the 'required' field.
  ///
  /// This getter returns a Map that defines how certain fields should be cast
  /// when encoding or decoding the object. Specifically:
  ///
  /// - The 'required' field is cast to a List of strings.
  ///
  /// This ensures that the 'required' field, which represents the list of required
  /// properties for this schema object, is always treated as a list of strings,
  /// even if the incoming data might have a different format.
  ///
  /// Returns:
  ///   A Map where the key is the field name ('required') and the value is a Cast
  ///   object specifying how to cast the field (List of strings in this case).
  @override
  Map<String, cast.Cast> get castMap =>
      {"required": const cast.List(cast.string)};

  /// Decodes the APISchemaObject from a KeyedArchive.
  ///
  /// This method overrides the base [decode] method to provide custom decoding
  /// for APISchemaObject properties. It populates the object's fields from the
  /// provided [KeyedArchive] object.
  ///
  /// Parameters:
  /// - [object]: A [KeyedArchive] containing the encoded data for this schema object.
  ///
  /// The method decodes the following properties:
  /// - title: The schema's title (String)
  /// - description: The schema's description (String)
  /// - isRequired: List of required properties (List<String?>)
  /// - example: An example value for the schema (String)
  /// - readOnly: Whether the schema is read-only (bool, defaults to false)
  /// - items: The schema for array items (APISchemaObject)
  /// - additionalProperties: The schema for additional properties (APISchemaObject)
  /// - properties: A map of property names to their schemas (Map<String, APISchemaObject?>)
  ///
  /// Note: This method calls the superclass [decode] method first to handle any
  /// decoding defined in the parent class.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    title = object.decode("title");
    description = object.decode("description");
    isRequired = object.decode("required");
    example = object.decode("example");
    readOnly = object.decode("readOnly") ?? false;

    items = object.decodeObject("items", () => APISchemaObject());
    additionalProperties =
        object.decodeObject("additionalProperties", () => APISchemaObject());
    properties = object.decodeObjectMap("properties", () => APISchemaObject());
  }

  /// Encodes the APISchemaObject into a KeyedArchive.
  ///
  /// This method overrides the base [encode] method to provide custom encoding
  /// for APISchemaObject properties. It serializes the object's fields into the
  /// provided [KeyedArchive] object.
  ///
  /// Parameters:
  /// - [object]: A [KeyedArchive] where the encoded data for this schema object will be stored.
  ///
  /// The method encodes the following properties:
  /// - title: The schema's title (String)
  /// - description: The schema's description (String)
  /// - isRequired: List of required properties (List<String?>)
  /// - example: An example value for the schema (String)
  /// - readOnly: Whether the schema is read-only (bool)
  /// - items: The schema for array items (APISchemaObject)
  /// - additionalProperties: The schema for additional properties (APISchemaObject)
  /// - properties: A map of property names to their schemas (Map<String, APISchemaObject?>)
  ///
  /// Note: This method calls the superclass [encode] method first to handle any
  /// encoding defined in the parent class.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("title", title);
    object.encode("description", description);
    object.encode("required", isRequired);
    object.encode("example", example);
    object.encode("readOnly", readOnly);

    object.encodeObject("items", items);
    object.encodeObject("additionalProperties", additionalProperties);
    object.encodeObjectMap("properties", properties);
  }
}
