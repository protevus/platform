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
import 'package:protevus_openapi/v3.dart';

/// The object provides metadata about the API.
///
/// The metadata MAY be used by the clients if needed, and MAY be presented in editing or documentation generation tools for convenience.
///
/// This class represents the OpenAPI Info Object, which contains basic information about the API.
/// It includes required fields like 'title' and 'version', as well as optional fields such as
/// 'description', 'termsOfServiceURL', 'contact', and 'license'.
///
/// The [APIInfo] class provides methods to encode and decode the information to and from a [KeyedArchive],
/// which is useful for serialization and deserialization of the API metadata.
///
/// Usage:
/// ```dart
/// var info = APIInfo('My API', '1.0.0',
///   description: 'This is a sample API',
///   termsOfServiceURL: Uri.parse('https://example.com/terms'),
///   contact: APIContact(name: 'API Support', email: 'support@example.com'),
///   license: APILicense('Apache 2.0', url: Uri.parse('https://www.apache.org/licenses/LICENSE-2.0.html'))
/// );
/// ```
///
/// The [isValid] getter can be used to check if the required fields are non-null.
class APIInfo extends APIObject {
  /// Creates an [APIInfo] instance with the required fields and optional metadata.
  ///
  /// [title] and [version] are required parameters.
  ///
  /// Optional parameters include:
  /// - [description]: A short description of the API.
  /// - [termsOfServiceURL]: A URL to the Terms of Service for the API.
  /// - [license]: The license information for the exposed API.
  /// - [contact]: The contact information for the exposed API.
  ///
  /// Example:
  /// ```dart
  /// var info = APIInfo(
  ///   'My API',
  ///   '1.0.0',
  ///   description: 'This is a sample API',
  ///   termsOfServiceURL: Uri.parse('https://example.com/terms'),
  ///   license: APILicense('Apache 2.0'),
  ///   contact: APIContact(name: 'API Support', email: 'support@example.com')
  /// );
  /// ```
  APIInfo(
    this.title,
    this.version, {
    this.description,
    this.termsOfServiceURL,
    this.license,
    this.contact,
  });

  /// Creates an empty [APIInfo] instance.
  ///
  /// This constructor initializes an [APIInfo] object without setting any of its properties.
  /// It can be useful when you need to create an instance of [APIInfo] and populate its
  /// properties later, or when decoding from a serialized format.
  APIInfo.empty();

  /// The title of the application.
  ///
  /// This field is REQUIRED according to the OpenAPI Specification.
  /// It provides the name of the API or application that this [APIInfo] object describes.
  ///
  /// Example:
  /// ```dart
  /// var info = APIInfo('My Amazing API', '1.0.0');
  /// print(info.title); // Output: My Amazing API
  /// ```
  ///
  /// Note: Despite being marked as required in the specification, this field is nullable
  /// to allow for deserialization of incomplete data. Always ensure this field is set
  /// before using the [APIInfo] object in production.
  String? title;

  /// A short description of the application.
  ///
  /// This field provides a brief summary of the API or application that this [APIInfo] object describes.
  /// It's an optional field that can be used to give users a quick understanding of the API's purpose.
  ///
  /// The OpenAPI Specification allows for CommonMark syntax to be used in this field,
  /// enabling rich text representation for more detailed or formatted descriptions.
  ///
  /// Example:
  /// ```dart
  /// var info = APIInfo('My API', '1.0.0',
  ///   description: 'This API provides access to our product catalog and order management system.'
  /// );
  /// ```
  ///
  /// Note: This field is nullable, as it's not a required field in the OpenAPI Specification.
  String? description;

  /// The version of the OpenAPI document.
  ///
  /// REQUIRED.
  String? version;

  /// A URL to the Terms of Service for the API.
  ///
  /// This field provides a link to the Terms of Service for the API, if available.
  /// It must be in the format of a valid URL.
  ///
  /// According to the OpenAPI Specification, if provided, this field MUST be a URL.
  /// It's an optional field, so it can be null if no Terms of Service URL is specified.
  ///
  /// Example:
  /// ```dart
  /// var info = APIInfo('My API', '1.0.0',
  ///   termsOfServiceURL: Uri.parse('https://example.com/terms')
  /// );
  /// ```
  ///
  /// Note: When setting this field, ensure that the provided URI is valid and accessible.
  Uri? termsOfServiceURL;

  /// The contact information for the exposed API.
  ///
  /// This field contains an [APIContact] object that provides contact information
  /// for the API. It can include details such as the name of the contact person or
  /// organization, a URL for contact information, and an email address.
  ///
  /// This field is optional according to the OpenAPI Specification, so it can be null
  /// if no contact information is provided.
  ///
  /// Example:
  /// ```dart
  /// var info = APIInfo('My API', '1.0.0',
  ///   contact: APIContact(
  ///     name: 'API Support',
  ///     url: Uri.parse('https://www.example.com/support'),
  ///     email: 'support@example.com'
  ///   )
  /// );
  /// ```
  APIContact? contact;

  /// The license information for the exposed API.
  ///
  /// This field contains an [APILicense] object that provides license information
  /// for the API. It typically includes the name of the license and optionally
  /// a URL where the full license text can be found.
  ///
  /// This field is optional according to the OpenAPI Specification, so it can be null
  /// if no license information is provided.
  ///
  /// Example:
  /// ```dart
  /// var info = APIInfo('My API', '1.0.0',
  ///   license: APILicense('Apache 2.0', url: Uri.parse('https://www.apache.org/licenses/LICENSE-2.0.html'))
  /// );
  /// ```
  APILicense? license;

  /// Checks if the [APIInfo] object is valid according to the OpenAPI Specification.
  ///
  /// This getter returns `true` if both the [title] and [version] fields are non-null,
  /// as these are required fields in the OpenAPI Specification for the Info Object.
  ///
  /// Returns:
  ///   A boolean value: `true` if both [title] and [version] are non-null, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// var info = APIInfo('My API', '1.0.0');
  /// print(info.isValid); // Output: true
  ///
  /// var incompleteInfo = APIInfo.empty();
  /// print(incompleteInfo.isValid); // Output: false
  /// ```
  bool get isValid => title != null && version != null;

  /// Decodes the [APIInfo] object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the properties of the [APIInfo] object
  /// from a [KeyedArchive]. It decodes the following fields:
  /// - 'title': The title of the API (String)
  /// - 'description': A short description of the API (String)
  /// - 'termsOfService': URL to the Terms of Service (Uri)
  /// - 'contact': Contact information (APIContact)
  /// - 'license': License information (APILicense)
  /// - 'version': The version of the API (String)
  ///
  /// The 'contact' and 'license' fields are decoded as objects of their respective types.
  ///
  /// This method overrides the [decode] method from the superclass and calls it before
  /// performing its own decoding operations.
  ///
  /// @param object The [KeyedArchive] containing the encoded [APIInfo] data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    title = object.decode("title");
    description = object.decode("description");
    termsOfServiceURL = object.decode("termsOfService");
    contact = object.decodeObject("contact", () => APIContact());
    license = object.decodeObject("license", () => APILicense.empty());
    version = object.decode("version");
  }

  /// Encodes the [APIInfo] object into a [KeyedArchive].
  ///
  /// This method is responsible for serializing the properties of the [APIInfo] object
  /// into a [KeyedArchive]. It encodes the following fields:
  /// - 'title': The title of the API (String)
  /// - 'description': A short description of the API (String)
  /// - 'version': The version of the API (String)
  /// - 'termsOfService': URL to the Terms of Service (Uri)
  /// - 'contact': Contact information (APIContact)
  /// - 'license': License information (APILicense)
  ///
  /// The method first checks if the required fields 'title' and 'version' are non-null.
  /// If either is null, it throws an [ArgumentError].
  ///
  /// This method overrides the [encode] method from the superclass and calls it before
  /// performing its own encoding operations.
  ///
  /// @param object The [KeyedArchive] to encode the [APIInfo] data into.
  /// @throws ArgumentError if 'title' or 'version' is null.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (title == null || version == null) {
      throw ArgumentError(
        "APIInfo must have non-null values for: 'title', 'version'.",
      );
    }

    object.encode("title", title);
    object.encode("description", description);
    object.encode("version", version);
    object.encode("termsOfService", termsOfServiceURL);
    object.encodeObject("contact", contact);
    object.encodeObject("license", license);
  }
}

/// Contact information for the exposed API.
///
/// This class represents the Contact Object as defined in the OpenAPI Specification.
/// It provides optional fields for the name, URL, and email of the contact person or organization
/// responsible for the API.
///
/// The [APIContact] class extends [APIObject] and provides methods to encode and decode
/// the contact information to and from a [KeyedArchive], which is useful for serialization
/// and deserialization of the API metadata.
///
/// Usage:
/// ```dart
/// var contact = APIContact(
///   name: 'API Support',
///   url: Uri.parse('https://www.example.com/support'),
///   email: 'support@example.com'
/// );
/// ```
class APIContact extends APIObject {
  /// Creates an [APIContact] instance with optional name, URL, and email.
  ///
  /// This constructor allows you to create an [APIContact] object by providing
  /// optional parameters for the contact's name, URL, and email address.
  ///
  /// Parameters:
  /// - [name]: The identifying name of the contact person/organization.
  /// - [url]: The URL pointing to the contact information. Must be a valid URI.
  /// - [email]: The email address of the contact person/organization.
  ///
  /// Example:
  /// ```dart
  /// var contact = APIContact(
  ///   name: 'API Support',
  ///   url: Uri.parse('https://www.example.com/support'),
  ///   email: 'support@example.com'
  /// );
  /// ```
  APIContact({this.name, this.url, this.email});

  /// Creates an empty [APIContact] instance.
  ///
  /// This constructor initializes an [APIContact] object without setting any of its properties.
  /// It can be useful when you need to create an instance of [APIContact] and populate its
  /// properties later, or when decoding from a serialized format.
  APIContact.empty();

  /// The identifying name of the contact person/organization.
  ///
  /// This property represents the name of the individual or organization
  /// responsible for the API. It's an optional field in the OpenAPI Specification,
  /// so it can be null if no contact name is provided.
  ///
  /// Example:
  /// ```dart
  /// var contact = APIContact(name: 'API Support Team');
  /// ```
  String? name;

  /// The URL pointing to the contact information.
  ///
  /// This property represents a URL that provides additional contact information
  /// for the API. According to the OpenAPI Specification, if provided, this field
  /// MUST be in the format of a valid URL.
  ///
  /// This field is optional and can be null if no contact URL is specified.
  ///
  /// Example:
  /// ```dart
  /// var contact = APIContact(
  ///   url: Uri.parse('https://www.example.com/api-support')
  /// );
  /// ```
  ///
  /// Note: When setting this field, ensure that the provided URI is valid and accessible.
  Uri? url;

  /// The email address of the contact person/organization.
  ///
  /// This property represents the email address for contacting the individual or organization
  /// responsible for the API. According to the OpenAPI Specification, if provided, this field
  /// MUST be in the format of a valid email address.
  ///
  /// This field is optional and can be null if no contact email is specified.
  ///
  /// Example:
  /// ```dart
  /// var contact = APIContact(email: 'support@example.com');
  /// ```
  ///
  /// Note: When setting this field, ensure that the provided email address is valid and follows
  /// the standard email format (e.g., username@domain.com).
  ///
  /// MUST be in the format of an email address.
  String? email;

  /// Decodes the [APIContact] object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the properties of the [APIContact] object
  /// from a [KeyedArchive]. It decodes the following fields:
  /// - 'name': The identifying name of the contact person/organization (String)
  /// - 'url': The URL pointing to the contact information (Uri)
  /// - 'email': The email address of the contact person/organization (String)
  ///
  /// This method overrides the [decode] method from the superclass and calls it before
  /// performing its own decoding operations.
  ///
  /// @param object The [KeyedArchive] containing the encoded [APIContact] data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    name = object.decode("name");
    url = object.decode("url");
    email = object.decode("email");
  }

  /// Encodes the [APIContact] object into a [KeyedArchive].
  ///
  /// This method is responsible for serializing the properties of the [APIContact] object
  /// into a [KeyedArchive]. It encodes the following fields:
  /// - 'name': The identifying name of the contact person/organization (String)
  /// - 'url': The URL pointing to the contact information (Uri)
  /// - 'email': The email address of the contact person/organization (String)
  ///
  /// This method overrides the [encode] method from the superclass and calls it before
  /// performing its own encoding operations.
  ///
  /// @param object The [KeyedArchive] to encode the [APIContact] data into.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("name", name);
    object.encode("url", url);
    object.encode("email", email);
  }
}

/// License information for the exposed API.
///
/// This class represents the License Object as defined in the OpenAPI Specification.
/// It provides information about the license under which the API is made available.
///
/// The [APILicense] class extends [APIObject] and provides methods to encode and decode
/// the license information to and from a [KeyedArchive], which is useful for serialization
/// and deserialization of the API metadata.
///
/// Usage:
/// ```dart
/// var license = APILicense('Apache 2.0', url: Uri.parse('https://www.apache.org/licenses/LICENSE-2.0.html'));
/// ```
class APILicense extends APIObject {
  /// Creates an [APILicense] instance with a required name and an optional URL.
  ///
  /// This constructor initializes an [APILicense] object with the provided license name
  /// and an optional URL to the full license text.
  ///
  /// Parameters:
  /// - [name]: The name of the license. This parameter is required.
  /// - [url]: An optional URL pointing to the full text of the license.
  ///
  /// Example:
  /// ```dart
  /// var license = APILicense('Apache 2.0', url: Uri.parse('https://www.apache.org/licenses/LICENSE-2.0.html'));
  /// ```
  APILicense(this.name, {this.url});

  /// Creates an empty [APILicense] instance.
  ///
  /// This constructor initializes an [APILicense] object without setting any of its properties.
  /// It can be useful when you need to create an instance of [APILicense] and populate its
  /// properties later, or when decoding from a serialized format.
  APILicense.empty();

  /// The license name used for the API.
  ///
  /// This property represents the name of the license under which the API is made available.
  /// According to the OpenAPI Specification, this field is REQUIRED for the License Object.
  ///
  /// Despite being marked as required in the specification, this field is nullable
  /// to allow for deserialization of incomplete data. Always ensure this field is set
  /// before using the [APILicense] object in production.
  ///
  /// Example:
  /// ```dart
  /// var license = APILicense('Apache 2.0');
  /// print(license.name); // Output: Apache 2.0
  /// ```
  ///
  /// REQUIRED.
  String? name;

  /// A URL to the license used for the API.
  ///
  /// This property represents a URL pointing to the full text of the license
  /// under which the API is made available. According to the OpenAPI Specification,
  /// if provided, this field MUST be in the format of a valid URL.
  ///
  /// This field is optional and can be null if no license URL is specified.
  ///
  /// Example:
  /// ```dart
  /// var license = APILicense('Apache 2.0',
  ///   url: Uri.parse('https://www.apache.org/licenses/LICENSE-2.0.html')
  /// );
  /// ```
  ///
  /// Note: When setting this field, ensure that the provided URI is valid and accessible.
  ///
  /// MUST be in the format of a URL.
  Uri? url;

  /// Decodes the [APILicense] object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the properties of the [APILicense] object
  /// from a [KeyedArchive]. It decodes the following fields:
  /// - 'name': The name of the license used for the API (String)
  /// - 'url': A URL to the license used for the API (Uri)
  ///
  /// This method overrides the [decode] method from the superclass and calls it before
  /// performing its own decoding operations.
  ///
  /// @param object The [KeyedArchive] containing the encoded [APILicense] data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    name = object.decode("name");
    url = object.decode("url");
  }

  /// Encodes the [APILicense] object into a [KeyedArchive].
  ///
  /// This method is responsible for serializing the properties of the [APILicense] object
  /// into a [KeyedArchive]. It encodes the following fields:
  /// - 'name': The name of the license used for the API (String)
  /// - 'url': A URL to the license used for the API (Uri)
  ///
  /// This method first calls the superclass's encode method, then checks if the required
  /// 'name' field is non-null. If 'name' is null, it throws an [ArgumentError].
  ///
  /// @param object The [KeyedArchive] to encode the [APILicense] data into.
  /// @throws ArgumentError if 'name' is null.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (name == null) {
      throw ArgumentError("APILicense must have non-null values for: 'name'.");
    }

    object.encode("name", name);
    object.encode("url", url);
  }
}

/// Adds metadata to a single tag that is used by the [APIOperation].
///
/// It is not mandatory to have a [APITag] per tag defined in the [APIOperation] instances.
///
/// The [APITag] class extends [APIObject] and provides methods to encode and decode
/// the tag information to and from a [KeyedArchive], which is useful for serialization
/// and deserialization of the API metadata.
///
/// Usage:
/// ```dart
/// var tag = APITag('user', description: 'User-related operations');
/// ```
class APITag extends APIObject {
  /// Creates an [APITag] instance with a required name and an optional description.
  ///
  /// Parameters:
  /// - [name]: The name of the tag. This parameter is required.
  /// - [description]: An optional short description for the tag.
  ///
  /// Example:
  /// ```dart
  /// var tag = APITag('user', description: 'User-related operations');
  /// ```
  APITag(this.name, {this.description});

  /// Creates an empty [APITag] instance.
  ///
  /// This constructor initializes an [APITag] object without setting any of its properties.
  /// It can be useful when you need to create an instance of [APITag] and populate its
  /// properties later, or when decoding from a serialized format.
  APITag.empty();

  /// The name of the tag.
  ///
  /// This property represents the name of the tag used to group operations.
  /// According to the OpenAPI Specification, this field is REQUIRED for the Tag Object.
  ///
  /// Despite being marked as required in the specification, this field is nullable
  /// to allow for deserialization of incomplete data. Always ensure this field is set
  /// before using the [APITag] object in production.
  ///
  /// REQUIRED.
  String? name;

  /// A short description for the tag.
  ///
  /// This property provides a brief description of the tag's purpose or the operations it groups.
  /// According to the OpenAPI Specification, CommonMark syntax MAY be used for rich text representation.
  ///
  /// This field is optional and can be null if no description is provided.
  ///
  /// CommonMark syntax MAY be used for rich text representation.
  String? description;

  /// Decodes the [APITag] object from a [KeyedArchive].
  ///
  /// This method is responsible for populating the properties of the [APITag] object
  /// from a [KeyedArchive]. It decodes the following fields:
  /// - 'name': The name of the tag (String)
  /// - 'description': A short description for the tag (String)
  ///
  /// This method overrides the [decode] method from the superclass and calls it before
  /// performing its own decoding operations.
  ///
  /// @param object The [KeyedArchive] containing the encoded [APITag] data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    name = object.decode("name");
    description = object.decode("description");
  }

  /// Encodes the [APITag] object into a [KeyedArchive].
  ///
  /// This method is responsible for serializing the properties of the [APITag] object
  /// into a [KeyedArchive]. It encodes the following fields:
  /// - 'name': The name of the tag (String)
  /// - 'description': A short description for the tag (String)
  ///
  /// This method first calls the superclass's encode method, then checks if the required
  /// 'name' field is non-null. If 'name' is null, it throws an [ArgumentError].
  ///
  /// @param object The [KeyedArchive] to encode the [APITag] data into.
  /// @throws ArgumentError if 'name' is null.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    if (name == null) {
      throw ArgumentError("APITag must have non-null values for: 'name'.");
    }
    object.encode("name", name);
    object.encode("description", description);
  }
}
