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

/// Represents metadata for an API in the OpenAPI specification.
///
/// This class contains information about the API such as its title, description,
/// version, terms of service, contact information, and license details.
///
/// The [APIInfo] class extends [APIObject] and provides methods to decode from
/// and encode to a [KeyedArchive] object, which is useful for serialization and
/// deserialization of API metadata.
///
/// Properties:
/// - [title]: The title of the API (required).
/// - [description]: A brief description of the API (optional).
/// - [version]: The version of the API (optional).
/// - [termsOfServiceURL]: The URL to the Terms of Service for the API (optional).
/// - [contact]: The contact information for the API (optional).
/// - [license]: The license information for the API (optional).
///
/// The class provides a default constructor [APIInfo()] that initializes all
/// properties with default values. It also overrides [decode] and [encode] methods
/// to handle serialization and deserialization of the API metadata.
class APIInfo extends APIObject {
  /// Creates a new instance of APIInfo with default values.
  ///
  /// This constructor initializes an APIInfo object with predefined default
  /// values for its properties. These include a default title, description,
  /// version, terms of service URL, contact information, and license details.
  APIInfo();

  /// The title of the API.
  ///
  /// This property represents the name or title of the API as defined in the OpenAPI specification.
  /// It is a required field and provides a concise, meaningful name to the API.
  String title = "API";

  /// A brief description of the API.
  ///
  /// This property provides a more detailed explanation of the API's purpose,
  /// functionality, or any other relevant information. It's optional and defaults
  /// to "Description" if not specified.
  String? description = "Description";

  /// The version of the API.
  ///
  /// This property represents the version number of the API as defined in the OpenAPI specification.
  /// It is typically a string in the format of "major.minor.patch" (e.g., "1.0.0").
  /// The default value is "1.0" if not specified.
  String? version = "1.0";

  /// The URL to the Terms of Service for the API.
  ///
  /// This property represents the URL where the Terms of Service for the API can be found.
  /// It's an optional field in the OpenAPI specification and defaults to an empty string if not specified.
  String? termsOfServiceURL = "";

  /// The contact information for the API.
  ///
  /// This property contains details about the contact person or organization
  /// responsible for the API. It includes information such as name, URL, and email.
  /// If not specified, it defaults to an instance of APIContact with default values.
  APIContact? contact = APIContact();

  /// The license information for the API.
  ///
  /// This property contains details about the license under which the API is provided.
  /// It includes information such as the license name and URL.
  /// If not specified, it defaults to an instance of APILicense with default values.
  APILicense? license = APILicense();

  /// Decodes the APIInfo object from a KeyedArchive.
  ///
  /// This method overrides the base decode method to populate the APIInfo
  /// properties from a KeyedArchive object. It decodes the following properties:
  /// - title: The API title (required, defaults to an empty string if not present)
  /// - description: A brief description of the API (optional)
  /// - termsOfServiceURL: URL to the terms of service (optional)
  /// - contact: Contact information, decoded as an APIContact object (optional)
  /// - license: License information, decoded as an APILicense object (optional)
  /// - version: The API version (optional)
  ///
  /// The method first calls the superclass decode method, then decodes each
  /// specific property of the APIInfo class.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    title = object.decode<String>("title") ?? '';
    description = object.decode("description");
    termsOfServiceURL = object.decode("termsOfService");
    contact = object.decodeObject("contact", () => APIContact());
    license = object.decodeObject("license", () => APILicense());
    version = object.decode("version");
  }

  /// Encodes the APIInfo object into a KeyedArchive.
  ///
  /// This method overrides the base encode method to serialize the APIInfo
  /// properties into a KeyedArchive object. It encodes the following properties:
  /// - title: The API title
  /// - description: A brief description of the API
  /// - version: The API version
  /// - termsOfService: URL to the terms of service
  /// - contact: Contact information, encoded as an APIContact object
  /// - license: License information, encoded as an APILicense object
  ///
  /// The method first calls the superclass encode method, then encodes each
  /// specific property of the APIInfo class.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("title", title);
    object.encode("description", description);
    object.encode("version", version);
    object.encode("termsOfService", termsOfServiceURL);
    object.encodeObject("contact", contact);
    object.encodeObject("license", license);
  }
}

/// Represents contact information in the OpenAPI specification.
///
/// This class extends [APIObject] and provides properties and methods to
/// handle contact details for an API, including name, URL, and email.
///
/// Properties:
/// - [name]: The name of the contact person or organization.
/// - [url]: The URL pointing to the contact information.
/// - [email]: The email address of the contact person or organization.
///
/// The class provides methods to decode from and encode to a [KeyedArchive] object,
/// which is useful for serialization and deserialization of contact information.
class APIContact extends APIObject {
  /// Creates a new instance of APIContact with default values.
  ///
  /// This constructor initializes an APIContact object with predefined default
  /// values for its properties. These include a default name, URL, and email address.
  APIContact();

  /// Decodes the APIContact object from a KeyedArchive.
  ///
  /// This method overrides the base decode method to populate the APIContact
  /// properties from a KeyedArchive object. It decodes the following properties:
  /// - name: The name of the contact person or organization (defaults to "default" if not present)
  /// - url: The URL pointing to the contact information (defaults to "http://localhost" if not present)
  /// - email: The email address of the contact person or organization (defaults to "default" if not present)
  ///
  /// The method first calls the superclass decode method, then decodes each
  /// specific property of the APIContact class, providing default values if
  /// the properties are not present in the KeyedArchive.
  ///
  /// Parameters:
  ///   object: The KeyedArchive containing the encoded APIContact data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    name = object.decode("name") ?? "default";
    url = object.decode("url") ?? "http://localhost";
    email = object.decode("email") ?? "default";
  }

  /// The name of the contact person or organization.
  ///
  /// This property represents the name associated with the API contact information.
  /// It defaults to "default" if not specified.
  String name = "default";

  /// The URL pointing to the contact information.
  ///
  /// This property represents the URL associated with the API contact information.
  /// It provides a web address where users can find more details about the contact.
  /// The default value is "http://localhost" if not specified.
  String url = "http://localhost";

  /// The email address of the contact person or organization.
  ///
  /// This property represents the email address associated with the API contact information.
  /// It provides a means of electronic communication for users or developers who need to
  /// reach out regarding the API. The default value is "default" if not specified.
  String email = "default";

  /// Encodes the APIContact object into a KeyedArchive.
  ///
  /// This method overrides the base encode method to serialize the APIContact
  /// properties into a KeyedArchive object. It encodes the following properties:
  /// - name: The name of the contact person or organization
  /// - url: The URL pointing to the contact information
  /// - email: The email address of the contact person or organization
  ///
  /// The method first calls the superclass encode method, then encodes each
  /// specific property of the APIContact class.
  ///
  /// Parameters:
  ///   object: The KeyedArchive to encode the APIContact data into.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("name", name);
    object.encode("url", url);
    object.encode("email", email);
  }
}

/// Represents a copyright/open source license in the OpenAPI specification.
///
/// This class extends [APIObject] and provides properties and methods to
/// handle license information for an API, including the license name and URL.
///
/// Properties:
/// - [name]: The name of the license.
/// - [url]: The URL where the license can be viewed.
///
/// The class provides methods to decode from and encode to a [KeyedArchive] object,
/// which is useful for serialization and deserialization of license information.
class APILicense extends APIObject {
  /// Creates a new instance of APILicense with default values.
  ///
  /// This constructor initializes an APILicense object with predefined default
  /// values for its properties. These include a default name and URL for the license.
  APILicense();

  /// Decodes the APILicense object from a KeyedArchive.
  ///
  /// This method overrides the base decode method to populate the APILicense
  /// properties from a KeyedArchive object. It decodes the following properties:
  /// - name: The name of the license (defaults to "default" if not present)
  /// - url: The URL where the license can be viewed (defaults to "http://localhost" if not present)
  ///
  /// The method first calls the superclass decode method, then decodes each
  /// specific property of the APILicense class, providing default values if
  /// the properties are not present in the KeyedArchive.
  ///
  /// Parameters:
  ///   object: The KeyedArchive containing the encoded APILicense data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    name = object.decode("name") ?? "default";
    url = object.decode("url") ?? "http://localhost";
  }

  /// The name of the license.
  ///
  /// This property represents the name of the license associated with the API.
  /// It provides a short identifier for the license type, such as "MIT", "Apache 2.0", etc.
  /// The default value is "default" if not specified.
  String name = "default";

  /// The URL where the license can be viewed.
  ///
  /// This property represents the URL associated with the API license information.
  /// It provides a web address where users can find the full text or details of the license.
  /// The default value is "http://localhost" if not specified.
  String url = "http://localhost";

  /// Encodes the APILicense object into a KeyedArchive.
  ///
  /// This method overrides the base encode method to serialize the APILicense
  /// properties into a KeyedArchive object. It encodes the following properties:
  /// - name: The name of the license
  /// - url: The URL where the license can be viewed
  ///
  /// The method first calls the superclass encode method, then encodes each
  /// specific property of the APILicense class.
  ///
  /// Parameters:
  ///   object: The KeyedArchive to encode the APILicense data into.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("name", name);
    object.encode("url", url);
  }
}

/// Represents a tag in the OpenAPI specification.
///
/// This class extends [APIObject] and provides properties and methods to
/// handle tag information for an API, including the tag name and description.
///
/// Properties:
/// - [name]: The name of the tag.
/// - [description]: A short description of the tag.
///
/// The class provides methods to decode from and encode to a [KeyedArchive] object,
/// which is useful for serialization and deserialization of tag information.
class APITag extends APIObject {
  /// Creates a new instance of APITag.
  ///
  /// This constructor initializes an APITag object without setting any default values.
  /// The [name] and [description] properties will be null until explicitly set or
  /// populated through the [decode] method.
  APITag();

  /// Decodes the APITag object from a KeyedArchive.
  ///
  /// This method overrides the base decode method to populate the APITag
  /// properties from a KeyedArchive object. It decodes the following properties:
  /// - name: The name of the tag
  /// - description: A short description of the tag
  ///
  /// The method first calls the superclass decode method, then decodes each
  /// specific property of the APITag class.
  ///
  /// Parameters:
  ///   object: The KeyedArchive containing the encoded APITag data.
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    name = object.decode("name");
    description = object.decode("description");
  }

  /// The name of the tag.
  ///
  /// This property represents the name of the tag associated with the API.
  /// It is used to group operations in the API documentation.
  /// The value can be null if not specified.
  String? name;

  /// A short description of the tag.
  ///
  /// This property provides a brief explanation of the tag's purpose or meaning.
  /// It can be used to give more context about how the tag is used in the API.
  /// The value can be null if no description is provided.
  String? description;

  /// Encodes the APITag object into a KeyedArchive.
  ///
  /// This method overrides the base encode method to serialize the APITag
  /// properties into a KeyedArchive object. It encodes the following properties:
  /// - name: The name of the tag
  /// - description: A short description of the tag
  ///
  /// The method first calls the superclass encode method, then encodes each
  /// specific property of the APITag class.
  ///
  /// Parameters:
  ///   object: The KeyedArchive to encode the APITag data into.
  @override
  void encode(KeyedArchive object) {
    super.encode(object);

    object.encode("name", name);
    object.encode("description", description);
  }
}
