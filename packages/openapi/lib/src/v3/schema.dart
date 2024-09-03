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
import 'package:protevus_openapi/object.dart';
import 'package:protevus_openapi/v3.dart';

/// Enum representing the policy for additional properties in an API schema.
///
/// This enum defines three possible policies for handling additional properties
/// in an API schema object:
///
/// - [disallowed]: Prevents properties other than those defined by [APISchemaObject.properties]
///   from being included in the schema. This is the most restrictive policy.
///
/// - [freeForm]: Allows any additional properties to be included in the schema.
///   This is the most permissive policy.
///
/// - [restricted]: Indicates that [APISchemaObject.additionalPropertySchema] contains
///   a schema object that defines the structure for any additional properties.
///   This policy allows additional properties, but they must conform to the
///   specified schema.
///
/// These policies provide different levels of control over the structure and
/// content of API schemas, allowing for flexible schema definitions based on
/// specific requirements.
enum APISchemaAdditionalPropertyPolicy {
  /// Indicates that the [APISchemaObject] prevents properties other than those defined by [APISchemaObject.properties] from being included.
  ///
  /// This policy is the most restrictive, disallowing any additional properties beyond those explicitly defined in the schema.
  /// It ensures that the object structure strictly adheres to the specified properties.
  disallowed,

  /// Indicates that the [APISchemaObject] allows any additional properties to be included.
  ///
  /// This policy is the most permissive, allowing any extra properties beyond those explicitly defined in the schema.
  /// It provides flexibility for including arbitrary additional data in the object structure.
  freeForm,

  /// Indicates that [APISchemaObject.additionalPropertySchema] contains a schema object that defines
  /// the structure for any additional properties.
  ///
  /// This policy allows additional properties, but they must conform to the schema specified in
  /// [APISchemaObject.additionalPropertySchema]. It provides a way to allow extra properties while
  /// still maintaining some control over their structure and content.
  restricted
}

/// This class extends [APIObject] and provides a comprehensive representation of
/// schema objects as defined in the OpenAPI specification. It includes properties
/// for various schema constraints such as type, format, range limitations,
/// length restrictions, pattern matching, and more.
///
/// The class offers multiple constructors for creating different types of schemas:
/// - Default constructor
/// - Empty constructor
/// - String schema (with optional format)
/// - Number schema
/// - Integer schema
/// - Boolean schema
/// - Map schema (with options for additional properties)
/// - Array schema
/// - Object schema (with properties)
/// - File schema
/// - Free-form schema
///
/// It also includes methods for encoding and decoding schema objects to and from
/// a [KeyedArchive], allowing for serialization and deserialization of schema definitions.
class APISchemaObject extends APIObject {
  /// Default constructor for APISchemaObject.
  ///
  /// Creates a new instance of APISchemaObject with default values.
  /// This constructor allows for flexible initialization of the schema object,
  /// where properties can be set after instantiation.
  APISchemaObject();

  /// Creates an empty [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] without setting any specific properties.
  /// It can be used as a starting point for building a schema object, where properties
  /// can be added or modified after instantiation.
  APISchemaObject.empty();

  /// Creates a string [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.string].
  /// It also allows specifying an optional [format] for the string schema.
  ///
  /// Parameters:
  ///   [format]: An optional string that specifies the format of the string schema.
  ///             Common formats include 'date-time', 'email', 'hostname', etc.
  APISchemaObject.string({this.format}) : type = APIType.string;

  /// Creates a number [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.number].
  /// It's used to define a schema for numeric values, which can include both integers and floating-point numbers.
  APISchemaObject.number() : type = APIType.number;

  /// Creates an integer [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.integer].
  /// It's used to define a schema for integer values, which are whole numbers without fractional components.
  APISchemaObject.integer() : type = APIType.integer;

  /// Creates a boolean [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.boolean].
  /// It's used to define a schema for boolean values, which can only be true or false.
  APISchemaObject.boolean() : type = APIType.boolean;

  /// Creates a map [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.object],
  /// representing a map-like structure. It allows specifying the type or schema of the
  /// additional properties in the map.
  ///
  /// Parameters:
  ///   [ofType]: An optional [APIType] that specifies the type of values in the map.
  ///   [ofSchema]: An optional [APISchemaObject] that defines the schema for values in the map.
  ///   [any]: A boolean flag that, when true, allows any type of additional properties.
  ///
  /// Throws:
  ///   [ArgumentError] if neither [ofType], [ofSchema], nor [any] is specified.
  ///
  /// The constructor sets [additionalPropertySchema] based on the provided parameters:
  /// - If [ofType] is provided, it creates a new [APISchemaObject] with that type.
  /// - If [ofSchema] is provided, it uses that schema directly.
  /// - If [any] is true, it allows any additional properties without restrictions.
  /// - If none of the above are specified, it throws an [ArgumentError].
  APISchemaObject.map({
    APIType? ofType,
    APISchemaObject? ofSchema,
    bool any = false,
  }) : type = APIType.object {
    if (ofType != null) {
      additionalPropertySchema = APISchemaObject()..type = ofType;
    } else if (ofSchema != null) {
      additionalPropertySchema = ofSchema;
    } else if (any) {
    } else {
      throw ArgumentError(
        "Invalid 'APISchemaObject.map' with neither 'ofType', 'any' or 'ofSchema' specified.",
      );
    }
  }

  /// Creates an array [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.array].
  /// It allows specifying the type or schema of the items in the array.
  ///
  /// Parameters:
  ///   [ofType]: An optional [APIType] that specifies the type of items in the array.
  ///   [ofSchema]: An optional [APISchemaObject] that defines the schema for items in the array.
  ///
  /// Throws:
  ///   [ArgumentError] if neither [ofType] nor [ofSchema] is specified.
  ///
  /// The constructor sets [items] based on the provided parameters:
  /// - If [ofType] is provided, it creates a new [APISchemaObject] with that type.
  /// - If [ofSchema] is provided, it uses that schema directly.
  /// - If neither is specified, it throws an [ArgumentError].
  APISchemaObject.array({APIType? ofType, APISchemaObject? ofSchema})
      : type = APIType.array {
    if (ofType != null) {
      items = APISchemaObject()..type = ofType;
    } else if (ofSchema != null) {
      items = ofSchema;
    } else {
      throw ArgumentError(
        "Invalid 'APISchemaObject.array' with neither 'ofType' or 'ofSchema' specified.",
      );
    }
  }

  /// Creates an object [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.object].
  /// It allows specifying the properties of the object schema.
  ///
  /// Parameters:
  ///   [properties]: A map of property names to their corresponding [APISchemaObject]s.
  ///                 This defines the structure of the object schema.
  APISchemaObject.object(this.properties) : type = APIType.object;

  /// Creates a file [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.string]
  /// and [format] set based on the [isBase64Encoded] parameter.
  ///
  /// Parameters:
  ///   [isBase64Encoded]: A boolean flag that determines the format of the file schema.
  ///     - If true, sets the format to "byte" (for base64-encoded strings).
  ///     - If false, sets the format to "binary" (for raw binary data).
  ///
  /// The resulting schema object represents either a base64-encoded string (when [isBase64Encoded] is true)
  /// or raw binary data (when [isBase64Encoded] is false), both of which are suitable for file content.
  APISchemaObject.file({bool isBase64Encoded = false})
      : type = APIType.string,
        format = isBase64Encoded ? "byte" : "binary";

  /// Creates a free-form [APISchemaObject] instance.
  ///
  /// This constructor initializes an [APISchemaObject] with [type] set to [APIType.object]
  /// and [additionalPropertyPolicy] set to [APISchemaAdditionalPropertyPolicy.freeForm].
  /// It represents a schema that allows any additional properties without restrictions.
  ///
  /// This is useful for scenarios where the object structure is not strictly defined
  /// and can contain arbitrary key-value pairs.
  APISchemaObject.freeForm()
      : type = APIType.object,
        additionalPropertyPolicy = APISchemaAdditionalPropertyPolicy.freeForm;

  /// A title for the object.
  ///
  /// This property allows you to specify a human-readable title for the schema object.
  /// It can be used to provide a brief, descriptive name for the schema, which can be
  /// helpful for documentation and user interfaces. The title is optional and does not
  /// affect the validation of data against the schema.
  String? title;

  /// The maximum value for a numeric instance.
  ///
  /// If the instance is a number, then this keyword validates if
  /// "exclusiveMaximum" is true and instance is less than the provided
  /// value, or else if the instance is less than or exactly equal to the
  /// provided value.
  num? maximum;

  /// Determines whether the maximum value is exclusive.
  ///
  ///  An undefined value is the same as false.
  ///
  ///  If "exclusiveMaximum" is true, then a numeric instance SHOULD NOT be
  ///  equal to the value specified in "maximum".  If "exclusiveMaximum" is
  ///  false (or not specified), then a numeric instance MAY be equal to the
  ///  value of "maximum".
  bool? exclusiveMaximum;

  /// The minimum value for a numeric instance.
  ///
  /// This property sets the lower limit for a numeric instance in the schema.
  /// The value of "minimum" MUST be a number.
  ///
  /// If the instance is a number, this keyword validates in two ways:
  /// 1. If "exclusiveMinimum" is true, the instance must be greater than the provided value.
  /// 2. If "exclusiveMinimum" is false or not specified, the instance must be greater than or exactly equal to the provided value.
  ///
  /// This property works in conjunction with [exclusiveMinimum] to define the lower bound behavior.
  num? minimum;

  /// Determines whether the minimum value is exclusive.
  ///
  /// The value of "exclusiveMinimum" MUST be a boolean, representing
  /// whether the limit in "minimum" is exclusive or not.  An undefined
  /// value is the same as false.
  ///
  /// If "exclusiveMinimum" is true, then a numeric instance SHOULD NOT be
  /// equal to the value specified in "minimum".  If "exclusiveMinimum" is
  /// false (or not specified), then a numeric instance MAY be equal to the
  /// value of "minimum".
  bool? exclusiveMinimum;

  /// The maximum length allowed for a string instance.
  ///
  /// The value of this keyword MUST be an integer.  This integer MUST be
  /// greater than, or equal to, 0.
  ///
  /// A string instance is valid against this keyword if its length is less
  /// than, or equal to, the value of this keyword.
  ///
  /// The length of a string instance is defined as the number of its
  /// characters as defined by RFC 7159 [RFC7159].
  int? maxLength;

  /// The minimum length allowed for a string instance.
  ///
  /// The length of a string instance is defined as the number of its
  /// characters as defined by RFC 7159 [RFC7159].
  ///
  /// The value of this keyword MUST be an integer.  This integer MUST be
  /// greater than, or equal to, 0.
  ///
  /// "minLength", if absent, may be considered as being present with
  /// integer value 0.
  int? minLength;

  /// The regular expression pattern that a string instance must match.
  ///
  /// A string instance is considered valid if the regular expression
  /// matches the instance successfully.  Recall: regular expressions are
  /// not implicitly anchored.
  String? pattern;

  /// The maximum number of items allowed in an array instance.
  ///
  /// An array instance is valid against "maxItems" if its size is less
  /// than, or equal to, the value of this keyword.
  int? maxItems;

  /// The minimum number of items allowed in an array instance.
  ///
  /// An array instance is valid against "minItems" if its size is greater
  /// than, or equal to, the value of this keyword.
  ///
  /// If this keyword is not present, it may be considered present with a
  /// value of 0.
  int? minItems;

  /// Specifies whether the items in an array instance must be unique.
  ///
  /// If this keyword has boolean value false, the instance validates
  /// successfully.  If it has boolean value true, the instance validates
  /// successfully if all of its elements are unique.
  ///
  /// If not present, this keyword may be considered present with boolean
  /// value false.
  bool? uniqueItems;

  /// Specifies a value that numeric instances must be divisible by.
  ///
  /// The value of "multipleOf" MUST be a number, strictly greater than 0.
  ///
  /// A numeric instance is only valid if division by this keyword's value
  /// results in an integer.
  num? multipleOf;

  /// The maximum number of properties allowed in an object instance.
  ///
  /// An object instance is valid against "maxProperties" if its number of
  /// properties is less than, or equal to, the value of this keyword.
  int? maxProperties;

  /// The minimum number of properties allowed in an object instance.
  ///
  /// An object instance is valid against "minProperties" if its number of
  /// properties is greater than, or equal to, the value of this keyword.
  ///
  /// If this keyword is not present, it may be considered present with a
  /// value of 0.
  int? minProperties;

  /// A list of required property names for the schema object.
  ///
  /// An object instance is valid against this keyword if its property set
  /// contains all elements in this keyword's array value.
  List<String?>? isRequired;

  /// Specifies a list of allowed values for the schema instance.
  ///
  /// Elements in the array MAY be of any type, including null.
  ///
  /// An instance validates successfully against this keyword if its value
  /// is equal to one of the elements in this keyword's array value.
  List<dynamic>? enumerated;

  /* Modified JSON Schema for OpenAPI */

  /// Represents the type of the API schema object.
  ///
  /// This property defines the data type of the schema. It can be any of the
  /// values defined in the [APIType] enum, such as string, number, integer,
  /// boolean, array, or object.
  ///
  /// The type is a fundamental property of the schema as it determines the
  /// basic structure and validation rules for the data that the schema represents.
  ///
  /// If null, it indicates that the type is not specified, which might be the case
  /// for schemas that use composition keywords like allOf, anyOf, or oneOf.
  APIType? type;

  /// A list of schema objects that this schema object composes.
  ///
  /// This property allows for the composition of schema objects through the 'allOf' keyword.
  /// The instance data must be valid against all of the schemas in this list.
  /// This is ANDing the constraints specified by each schema in the list.
  ///
  /// If null, it indicates that no composition is specified for this schema object.
  List<APISchemaObject?>? allOf;

  /// A list of schema objects that this schema object can be any of.
  ///
  /// This property allows for the composition of schema objects through the 'anyOf' keyword.
  /// The instance data must be valid against at least one of the schemas in this list.
  /// This is ORing the constraints specified by each schema in the list.
  ///
  /// If null, it indicates that no 'anyOf' composition is specified for this schema object.
  List<APISchemaObject?>? anyOf;

  /// A list of schema objects that this schema object can be one of.
  ///
  /// This property allows for the composition of schema objects through the 'oneOf' keyword.
  /// The instance data must be valid against exactly one of the schemas in this list.
  /// This represents an exclusive OR (XOR) relationship between the schemas.
  ///
  /// If null, it indicates that no 'oneOf' composition is specified for this schema object.
  List<APISchemaObject?>? oneOf;

  /// A schema object that this schema object must not match.
  ///
  /// This property allows for the negation of a schema through the 'not' keyword.
  /// The instance data must NOT be valid against the schema defined in this property.
  /// This is useful for expressing constraints that are the opposite of a given schema.
  ///
  /// If null, it indicates that no 'not' constraint is specified for this schema object.
  APISchemaObject? not;

  /// Defines the schema for items in an array.
  ///
  /// This property is only applicable when the [type] is set to [APIType.array].
  /// It specifies the schema that all items in the array must conform to.
  ///
  /// If null, it indicates that the schema for array items is not specified,
  /// allowing items of any type in the array.
  APISchemaObject? items;

  /// A map of property names to their corresponding schema objects.
  ///
  /// This property defines the structure of an object schema by specifying
  /// the schemas for its properties. Each key in the map is the name of a
  /// property, and its corresponding value is an [APISchemaObject] that
  /// defines the schema for that property.
  ///
  /// If null, it indicates that no properties are defined for this schema object.
  /// This could be the case for non-object schemas or for object schemas where
  /// properties are not explicitly defined (e.g., when using additionalProperties).
  Map<String, APISchemaObject?>? properties;

  /// Defines the schema for additional properties in an object.
  ///
  /// This property is used in conjunction with [additionalPropertyPolicy] to specify
  /// the schema for additional properties when [additionalPropertyPolicy] is set to
  /// [APISchemaAdditionalPropertyPolicy.restricted].
  ///
  /// If null, it indicates that no specific schema is defined for additional properties,
  /// which could mean either that additional properties are not allowed or that they
  /// can be of any type, depending on the [additionalPropertyPolicy].
  APISchemaObject? additionalPropertySchema;

  /// Specifies the policy for handling additional properties in the schema object.
  ///
  /// This property determines how the schema should treat properties that are not
  /// explicitly defined in the [properties] map. It can have one of three values:
  ///
  /// - [APISchemaAdditionalPropertyPolicy.disallowed]: No additional properties are allowed.
  /// - [APISchemaAdditionalPropertyPolicy.freeForm]: Any additional properties are allowed without restrictions.
  /// - [APISchemaAdditionalPropertyPolicy.restricted]: Additional properties are allowed, but must conform to the schema defined in [additionalPropertySchema].
  ///
  /// If null, the additional property policy is not explicitly set, and the behavior
  /// may depend on the context or default to a specific policy (often 'disallowed' in strict schemas).
  APISchemaAdditionalPropertyPolicy? additionalPropertyPolicy;

  /// A description of the schema object.
  ///
  /// This property provides a detailed explanation of the purpose, structure,
  /// or constraints of the schema. It can be used to give more context to API
  /// consumers about what this schema represents or how it should be used.
  ///
  /// If null, it indicates that no description has been provided for this schema.
  String? description;

  /// Specifies the format of the data.
  ///
  /// This property is a string that further defines the specific format of the data
  /// described by the schema. It is often used in conjunction with the [type] property
  /// to provide more detailed type information.
  ///
  /// Common formats include:
  /// - For strings: 'date-time', 'date', 'email', 'hostname', 'ipv4', 'ipv6', 'uri', etc.
  /// - For numbers: 'float', 'double'
  /// - For integers: 'int32', 'int64'
  ///
  /// The interpretation and validation of the format may depend on the data type
  /// and the specific OpenAPI tooling being used.
  ///
  /// If null, it indicates that no specific format is defined for this schema property.
  String? format;

  /// The default value for this schema object.
  ///
  /// This property specifies the default value to be used if the instance value is not supplied.
  /// The value SHOULD be valid against the schema.
  ///
  /// The type of this property is dynamic, allowing for default values of any type
  /// that matches the schema's type. For example:
  /// - For string schemas, it could be a String.
  /// - For number schemas, it could be a num.
  /// - For boolean schemas, it could be a bool.
  /// - For array schemas, it could be a List.
  /// - For object schemas, it could be a Map.
  ///
  /// If null, it indicates that no default value is specified for this schema property.
  dynamic defaultValue;

  /// Determines whether the schema allows null values.
  ///
  /// This getter returns a boolean value indicating if the schema permits null values.
  /// It returns true if the schema explicitly allows null values, and false otherwise.
  ///
  /// The getter uses the nullish coalescing operator (??) to provide a default value of false
  /// if the internal [_nullable] property is null.
  ///
  /// Returns:
  ///   A boolean value: true if the schema allows null values, false otherwise.
  bool? get isNullable => _nullable ?? false;

  /// Sets whether the schema allows null values.
  ///
  /// This setter allows you to specify if the schema should permit null values.
  /// Setting it to true means the schema will allow null, while false means it won't.
  ///
  /// Parameters:
  ///   [n]: A boolean value indicating whether null is allowed (true) or not (false).
  ///        Can be null, in which case it will clear any previously set value.
  set isNullable(bool? n) {
    _nullable = n;
  }

  // APIDiscriminator discriminator;

  /// Determines whether the schema is read-only.
  ///
  /// This getter returns a boolean value indicating if the schema is marked as read-only.
  /// It returns true if the schema is explicitly set as read-only, and false otherwise.
  ///
  /// The getter uses the nullish coalescing operator (??) to provide a default value of false
  /// if the internal [_readOnly] property is null.
  ///
  /// Returns:
  ///   A boolean value: true if the schema is read-only, false otherwise.
  bool? get isReadOnly => _readOnly ?? false;

  /// Sets whether the schema is read-only.
  ///
  /// This setter allows you to specify if the schema should be considered read-only.
  /// Setting it to true means the schema is read-only, while false means it's not.
  ///
  /// Parameters:
  ///   [n]: A boolean value indicating whether the schema is read-only (true) or not (false).
  ///        Can be null, in which case it will clear any previously set value.
  set isReadOnly(bool? n) {
    _readOnly = n;
  }

  /// Determines whether the schema is write-only.
  ///
  /// This getter returns a boolean value indicating if the schema is marked as write-only.
  /// It returns true if the schema is explicitly set as write-only, and false otherwise.
  ///
  /// The getter uses the nullish coalescing operator (??) to provide a default value of false
  /// if the internal [_writeOnly] property is null.
  ///
  /// Returns:
  ///   A boolean value: true if the schema is write-only, false otherwise.
  bool? get isWriteOnly => _writeOnly ?? false;

  set isWriteOnly(bool? n) {
    _writeOnly = n;
  }

  /// Internal boolean flag to determine if the schema allows null values.
  ///
  /// This private property is used to store the nullable state of the schema.
  /// It's accessed and modified through the public [isNullable] getter and setter.
  ///
  /// - If true, the schema allows null values.
  /// - If false, the schema does not allow null values.
  /// - If null, the nullable state is not explicitly set, defaulting to false in the getter.
  bool? _nullable;

  /// Internal boolean flag to determine if the schema is read-only.
  ///
  /// This private property is used to store the read-only state of the schema.
  /// It's accessed and modified through the public [isReadOnly] getter and setter.
  ///
  /// - If true, the schema is read-only.
  /// - If false, the schema is not read-only.
  /// - If null, the read-only state is not explicitly set, defaulting to false in the getter.
  bool? _readOnly;

  /// Internal boolean flag to determine if the schema is write-only.
  ///
  /// This private property is used to store the write-only state of the schema.
  /// It's accessed and modified through the public [isWriteOnly] getter and setter.
  ///
  /// - If true, the schema is write-only.
  /// - If false, the schema is not write-only.
  /// - If null, the write-only state is not explicitly set, defaulting to false in the getter.
  bool? _writeOnly;

  /// Indicates whether the schema is deprecated.
  ///
  /// This property specifies if the schema has been deprecated and should be avoided in new implementations.
  ///
  /// - If true, the schema is considered deprecated.
  /// - If false, the schema is not deprecated.
  /// - If null, the deprecation status is not explicitly set.
  ///
  /// Deprecated schemas may still be used but are typically discouraged in favor of newer alternatives.
  bool? deprecated;

  /// Provides a map of property names to their corresponding cast functions.
  ///
  /// This getter overrides the base implementation to specify custom casting
  /// behavior for certain properties of the APISchemaObject.
  ///
  /// Returns:
  ///   A Map<String, cast.Cast> where:
  ///   - The key "required" is associated with a cast.List(cast.string) function,
  ///     which casts the "required" property to a List of Strings.
  ///
  /// This ensures that when decoding JSON data, the "required" field is properly
  /// cast to a List<String>, maintaining type safety and consistency in the object model.
  @override
  Map<String, cast.Cast> get castMap =>
      {"required": const cast.List(cast.string)};

  /// Decodes a [KeyedArchive] object into this [APISchemaObject] instance.
  ///
  /// This method populates the properties of the [APISchemaObject] by extracting
  /// values from the provided [KeyedArchive] object. It handles both simple properties
  /// and complex nested structures.
  ///
  /// The method decodes various schema properties including:
  /// - Basic properties like title, maximum, minimum, pattern, etc.
  /// - Numeric constraints (maxLength, minLength, maxItems, minItems, etc.)
  /// - Enumerated values and required fields
  /// - Complex structures like allOf, anyOf, oneOf, and nested schemas
  /// - Additional properties policy and schema
  /// - Metadata like description, format, and default value
  ///
  /// It also handles special cases like the 'additionalProperties' field, which
  /// can be a boolean or an object, affecting the [additionalPropertyPolicy] and
  /// [additionalPropertySchema] properties.
  ///
  /// Parameters:
  ///   [object]: A [KeyedArchive] containing the encoded schema data.
  ///
  /// Note: This method overrides the [decode] method from a superclass and
  /// calls the superclass implementation before proceeding with its own decoding.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    title = object.decode("title");
    maximum = object.decode("maximum");
    exclusiveMaximum = object.decode("exclusiveMaximum");
    minimum = object.decode("minimum");
    exclusiveMinimum = object.decode("exclusiveMinimum");
    maxLength = object.decode("maxLength");
    minLength = object.decode("minLength");
    pattern = object.decode("pattern");
    maxItems = object.decode("maxItems");
    minItems = object.decode("minItems");
    uniqueItems = object.decode("uniqueItems");
    multipleOf = object.decode("multipleOf");
    enumerated = object.decode("enum");
    minProperties = object.decode("minProperties");
    maxProperties = object.decode("maxProperties");
    isRequired = object.decode("required");

    //

    type = APITypeCodec.decode(object.decode("type"));
    allOf = object.decodeObjects("allOf", () => APISchemaObject());
    anyOf = object.decodeObjects("anyOf", () => APISchemaObject());
    oneOf = object.decodeObjects("oneOf", () => APISchemaObject());
    not = object.decodeObject("not", () => APISchemaObject());

    items = object.decodeObject("items", () => APISchemaObject());
    properties = object.decodeObjectMap("properties", () => APISchemaObject());

    final addlProps = object["additionalProperties"];
    if (addlProps is bool) {
      if (addlProps) {
        additionalPropertyPolicy = APISchemaAdditionalPropertyPolicy.freeForm;
      } else {
        additionalPropertyPolicy = APISchemaAdditionalPropertyPolicy.disallowed;
      }
    } else if (addlProps is KeyedArchive && addlProps.isEmpty) {
      additionalPropertyPolicy = APISchemaAdditionalPropertyPolicy.freeForm;
    } else {
      additionalPropertyPolicy = APISchemaAdditionalPropertyPolicy.restricted;
      additionalPropertySchema =
          object.decodeObject("additionalProperties", () => APISchemaObject());
    }

    description = object.decode("description");
    format = object.decode("format");
    defaultValue = object.decode("default");

    _nullable = object.decode("nullable");
    _readOnly = object.decode("readOnly");
    _writeOnly = object.decode("writeOnly");
    deprecated = object.decode("deprecated");
  }

  /// Encodes this [APISchemaObject] instance into a [KeyedArchive] object.
  ///
  /// This method serializes all properties of the [APISchemaObject] into the provided
  /// [KeyedArchive] object. It handles both simple properties and complex nested structures.
  ///
  /// The method encodes various schema properties including:
  /// - Basic properties like title, maximum, minimum, pattern, etc.
  /// - Numeric constraints (maxLength, minLength, maxItems, minItems, etc.)
  /// - Enumerated values and required fields
  /// - Complex structures like allOf, anyOf, oneOf, and nested schemas
  /// - Additional properties policy and schema
  /// - Metadata like description, format, and default value
  ///
  /// It also handles special cases like the 'additionalProperties' field, which
  /// is encoded differently based on the [additionalPropertyPolicy] and
  /// [additionalPropertySchema] properties.
  ///
  /// Parameters:
  ///   [object]: A [KeyedArchive] to store the encoded schema data.
  ///
  /// Note: This method overrides the [encode] method from a superclass and
  /// calls the superclass implementation before proceeding with its own encoding.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("title", title);
    object.encode("maximum", maximum);
    object.encode("exclusiveMaximum", exclusiveMaximum);
    object.encode("minimum", minimum);
    object.encode("exclusiveMinimum", exclusiveMinimum);
    object.encode("maxLength", maxLength);
    object.encode("minLength", minLength);
    object.encode("pattern", pattern);
    object.encode("maxItems", maxItems);
    object.encode("minItems", minItems);
    object.encode("uniqueItems", uniqueItems);
    object.encode("multipleOf", multipleOf);
    object.encode("enum", enumerated);
    object.encode("minProperties", minProperties);
    object.encode("maxProperties", maxProperties);
    object.encode("required", isRequired);

    //

    object.encode("type", APITypeCodec.encode(type));
    object.encodeObjects("allOf", allOf);
    object.encodeObjects("anyOf", anyOf);
    object.encodeObjects("oneOf", oneOf);
    object.encodeObject("not", not);

    object.encodeObject("items", items);
    if (additionalPropertyPolicy != null || additionalPropertySchema != null) {
      if (additionalPropertyPolicy ==
          APISchemaAdditionalPropertyPolicy.disallowed) {
        object.encode("additionalProperties", false);
      } else if (additionalPropertyPolicy ==
          APISchemaAdditionalPropertyPolicy.freeForm) {
        object.encode("additionalProperties", true);
      } else {
        object.encodeObject("additionalProperties", additionalPropertySchema);
      }
    }
    object.encodeObjectMap("properties", properties);

    object.encode("description", description);
    object.encode("format", format);
    object.encode("default", defaultValue);

    object.encode("nullable", _nullable);
    object.encode("readOnly", _readOnly);
    object.encode("writeOnly", _writeOnly);
    object.encode("deprecated", deprecated);
  }
}
