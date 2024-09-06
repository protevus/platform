/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_config/config.dart';

/// A [Configuration] to represent a database connection configuration.
///
/// This class extends [Configuration] and provides properties and methods
/// for managing database connection settings. It includes properties for
/// host, port, database name, username, password, and a flag for temporary
/// databases. The class supports initialization from various sources
/// (file, string, map) and provides a custom decoder for parsing connection
/// strings.
///
/// Properties:
/// - [host]: The host of the database to connect to (required).
/// - [port]: The port of the database to connect to (required).
/// - [databaseName]: The name of the database to connect to (required).
/// - [username]: A username for authenticating to the database (optional).
/// - [password]: A password for authenticating to the database (optional).
/// - [isTemporary]: A flag to represent permanence, used for test suites (optional).
///
/// The [decode] method allows parsing of connection strings or maps to
/// populate the configuration properties.
class DatabaseConfiguration extends Configuration {
  /// Default constructor for DatabaseConfiguration.
  ///
  /// Creates a new instance of DatabaseConfiguration without initializing any properties.
  /// Properties can be set manually or through the decode method after instantiation.
  DatabaseConfiguration();

  /// Creates a [DatabaseConfiguration] instance from a file.
  ///
  /// This named constructor initializes the configuration by reading from a file.
  /// The file path is passed to the superclass constructor [Configuration.fromFile].
  ///
  /// Parameters:
  ///   [file]: The path to the configuration file.
  DatabaseConfiguration.fromFile(super.file) : super.fromFile();

  /// Creates a [DatabaseConfiguration] instance from a YAML string.
  ///
  /// This named constructor initializes the configuration by parsing a YAML string.
  /// The YAML string is passed to the superclass constructor [Configuration.fromString].
  ///
  /// Parameters:
  ///   [yaml]: A string containing YAML-formatted configuration data.
  DatabaseConfiguration.fromString(super.yaml) : super.fromString();

  /// Creates a [DatabaseConfiguration] instance from a Map.
  ///
  /// This named constructor initializes the configuration using a Map of key-value pairs.
  /// The Map is passed to the superclass constructor [Configuration.fromMap].
  ///
  /// Parameters:
  ///   [yaml]: A Map containing configuration data.
  DatabaseConfiguration.fromMap(super.yaml) : super.fromMap();

  /// Creates a [DatabaseConfiguration] instance with all connection information provided.
  ///
  /// This named constructor allows for the direct initialization of all database connection
  /// properties in a single call. It sets both required and optional properties.
  ///
  /// Parameters:
  ///   [username]: The username for database authentication (optional).
  ///   [password]: The password for database authentication (optional).
  ///   [host]: The host address of the database server (required).
  ///   [port]: The port number on which the database server is listening (required).
  ///   [databaseName]: The name of the specific database to connect to (required).
  ///   [isTemporary]: A flag indicating if this is a temporary database connection (optional, defaults to false).
  ///
  /// This constructor provides a convenient way to create a fully configured
  /// [DatabaseConfiguration] object when all connection details are known in advance.
  DatabaseConfiguration.withConnectionInfo(
    this.username,
    this.password,
    this.host,
    this.port,
    this.databaseName, {
    this.isTemporary = false,
  });

  /// The host of the database to connect to.
  ///
  /// This property represents the hostname or IP address of the database server
  /// that this configuration will connect to. It is a required field and must be
  /// set before attempting to establish a database connection.
  ///
  /// The value should be a valid hostname (e.g., 'localhost', 'db.example.com')
  /// or an IP address (e.g., '192.168.1.100').
  ///
  /// This property is marked as 'late', which means it must be initialized
  /// before it's first used, but not necessarily in the constructor.
  late String host;

  /// The port of the database to connect to.
  ///
  /// This property represents the network port number on which the database server
  /// is listening for connections. It is a required field and must be set before
  /// attempting to establish a database connection.
  ///
  /// The value should be a valid port number, typically an integer between 0 and 65535.
  /// Common database port numbers include 5432 for PostgreSQL, 3306 for MySQL,
  /// and 1433 for SQL Server, but the actual port may vary depending on the specific
  /// database configuration.
  ///
  /// This property is marked as 'late', which means it must be initialized
  /// before it's first used, but not necessarily in the constructor.
  late int port;

  /// The name of the database to connect to.
  ///
  /// This property represents the specific database name within the database server
  /// that this configuration will target. It is a required field and must be set
  /// before attempting to establish a database connection.
  ///
  /// The value should be a valid database name as defined in your database server.
  /// For example, it could be 'myapp_database', 'users_db', or 'production_data'.
  ///
  /// This property is marked as 'late', which means it must be initialized
  /// before it's first used, but not necessarily in the constructor.
  late String databaseName;

  /// A username for authenticating to the database.
  ///
  /// This property represents the username used for authentication when connecting
  /// to the database. It is an optional field, meaning it can be null if authentication
  /// is not required or if other authentication methods are used.
  ///
  /// The value should be a string containing the username as configured in the
  /// database server for this particular connection. For example, it could be
  /// 'db_user', 'admin', or 'app_service_account'.
  ///
  /// If this property is set, it is typically used in conjunction with the [password]
  /// property to form a complete set of credentials for database authentication.
  String? username;

  /// A password for authenticating to the database.
  ///
  /// This property represents the password used for authentication when connecting
  /// to the database. It is an optional field, meaning it can be null if authentication
  /// is not required or if other authentication methods are used.
  ///
  /// The value should be a string containing the password that corresponds to the
  /// [username] for this database connection. For security reasons, it's important
  /// to handle this value carefully and avoid exposing it in logs or user interfaces.
  ///
  /// If this property is set, it is typically used in conjunction with the [username]
  /// property to form a complete set of credentials for database authentication.
  ///
  /// Note: In production environments, it's recommended to use secure methods of
  /// storing and retrieving passwords, such as environment variables or secure
  /// secret management systems, rather than hardcoding them in the configuration.
  String? password;

  /// A flag to represent permanence of the database.
  ///
  /// This flag is used for test suites that use a temporary database to run tests against,
  /// dropping it after the tests are complete.
  /// This property is optional.
  bool isTemporary = false;

  /// Decodes and populates the configuration from a given value.
  ///
  /// This method can handle two types of input:
  /// 1. A Map: In this case, it delegates to the superclass's decode method.
  /// 2. A String: It parses the string as a URI to extract database connection details.
  ///
  /// For string input, it extracts:
  /// - Host and port from the URI
  /// - Database name from the path (if present)
  /// - Username and password from the userInfo part of the URI (if present)
  ///
  /// After parsing, it calls the validate method to ensure all required fields are set.
  ///
  /// Parameters:
  ///   [value]: The input to decode. Can be a Map or a String.
  ///
  /// Throws:
  ///   [ConfigurationException]: If the input is neither a Map nor a String.
  @override
  void decode(dynamic value) {
    if (value is Map) {
      super.decode(value);
      return;
    }

    if (value is! String) {
      throw ConfigurationException(
        this,
        "'${value.runtimeType}' is not assignable; must be a object or string",
      );
    }

    final uri = Uri.parse(value);
    host = uri.host;
    port = uri.port;
    if (uri.pathSegments.length == 1) {
      databaseName = uri.pathSegments.first;
    }

    if (uri.userInfo == '') {
      validate();
      return;
    }

    final authority = uri.userInfo.split(":");
    if (authority.isNotEmpty) {
      username = Uri.decodeComponent(authority.first);
    }
    if (authority.length > 1) {
      password = Uri.decodeComponent(authority.last);
    }

    validate();
  }
}

/// A [Configuration] to represent an external HTTP API.
///
/// This class extends [Configuration] and provides properties for managing
/// external API connection settings. It includes properties for the base URL,
/// client ID, and client secret.
///
/// The class supports initialization from various sources (file, string, map)
/// through its constructors.
///
/// Properties:
/// - [baseURL]: The base URL of the described API (required).
/// - [clientID]: The client ID for API authentication (optional).
/// - [clientSecret]: The client secret for API authentication (optional).
///
/// Constructors:
/// - Default constructor: Creates an empty instance.
/// - [fromFile]: Initializes from a configuration file.
/// - [fromString]: Initializes from a YAML string.
/// - [fromMap]: Initializes from a Map.
class APIConfiguration extends Configuration {
  /// Default constructor for APIConfiguration.
  ///
  /// Creates a new instance of APIConfiguration without initializing any properties.
  /// Properties can be set manually or through the decode method after instantiation.
  APIConfiguration();

  /// Creates an [APIConfiguration] instance from a file.
  ///
  /// This named constructor initializes the configuration by reading from a file.
  /// The file path is passed to the superclass constructor [Configuration.fromFile].
  ///
  /// Parameters:
  ///   [file]: The path to the configuration file.
  APIConfiguration.fromFile(super.file) : super.fromFile();

  /// Creates an [APIConfiguration] instance from a YAML string.
  ///
  /// This named constructor initializes the configuration by parsing a YAML string.
  /// The YAML string is passed to the superclass constructor [Configuration.fromString].
  ///
  /// Parameters:
  ///   [yaml]: A string containing YAML-formatted configuration data.
  APIConfiguration.fromString(super.yaml) : super.fromString();

  /// Creates an [APIConfiguration] instance from a Map.
  ///
  /// This named constructor initializes the configuration using a Map of key-value pairs.
  /// The Map is passed to the superclass constructor [Configuration.fromMap].
  ///
  /// Parameters:
  ///   [yaml]: A Map containing configuration data.
  APIConfiguration.fromMap(super.yaml) : super.fromMap();

  /// The base URL of the described API.
  ///
  /// This property represents the root URL for the external API that this configuration
  /// is describing. It is a required field and must be set before using the API configuration.
  ///
  /// The value should be a complete URL, including the protocol (http or https),
  /// domain name, and optionally the port and base path. It serves as the foundation
  /// for constructing full URLs to specific API endpoints.
  ///
  /// This property is marked as 'late', which means it must be initialized
  /// before it's first used, but not necessarily in the constructor.
  ///
  /// This property is required.
  /// Example: https://external.api.com:80/resources
  late String baseURL;

  /// The client ID for API authentication.
  ///
  /// This property is optional.
  String? clientID;

  /// The client secret for API authentication.
  ///
  /// This property is optional.
  String? clientSecret;
}
