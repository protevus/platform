/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';

import 'package:args/args.dart';
import 'package:protevus_application/application.dart';

/// An object that contains configuration values for an [Application].
///
/// This class provides a set of options that can be used to configure an application,
/// including network settings, SSL configuration, and custom context values.
/// It also includes a static [ArgParser] for parsing command-line arguments.
///
/// Key features:
/// - Configurable address and port for HTTP requests
/// - IPv6 support
/// - SSL/HTTPS configuration options
/// - Client-side certificate usage flag
/// - Custom context for application-specific configuration
/// - Command-line argument parsing for easy configuration
///
/// Usage:
/// This class is typically used in conjunction with [ApplicationChannel] to set up
/// and configure an application based on external inputs or command-line arguments.
class ApplicationOptions {
  /// The absolute path of the configuration file for this application.
  ///
  /// This property stores the file path of the configuration file used by the application.
  /// The path is typically set when the application is started using the `--config-path` option
  /// with the `conduit serve` command.
  ///
  /// The configuration file can contain application-specific settings and can be loaded
  /// in the [ApplicationChannel] to access these configuration values.
  ///
  /// This property may be null if no configuration file path was specified when starting the application.
  ///
  /// Usage:
  /// - Access this property to get the path of the configuration file.
  /// - Use the path to load and parse the configuration file in your application logic.
  /// - Ensure to handle cases where this property might be null.
  String? configurationFilePath;

  /// The address to listen for HTTP requests on.
  ///
  /// This property specifies the network address on which the application will listen for incoming HTTP requests.
  ///
  /// This value may be an [InternetAddress] or a [String].
  dynamic address;

  /// The port number on which the application will listen for HTTP requests.
  ///
  /// Defaults to 8888.
  int port = 8888;

  /// Whether or not the application should only receive connections over IPv6.
  ///
  /// This flag determines if the application should exclusively use IPv6 for incoming connections.
  /// When set to true, the application will only accept IPv6 connections and reject IPv4 connections.
  /// This setting can be useful in environments that require IPv6-only communication.
  ///
  /// Defaults to false. This flag impacts the default value of the [address] property.
  bool isIpv6Only = false;

  /// Indicates whether the application's request controllers should use client-side HTTPS certificates.
  ///
  /// Defaults to false.
  bool isUsingClientCertificate = false;

  /// The path to a SSL certificate file.
  ///
  /// If specified - along with [privateKeyFilePath] - an [Application] will only allow secure connections over HTTPS.
  /// This value is often set through the `--ssl-certificate-path` command line option of `conduit serve`. For finer control
  /// over how HTTPS is configured for an application, see [ApplicationChannel.securityContext].
  String? certificateFilePath;

  /// The path to a private key file for SSL/TLS encryption.
  ///
  /// If specified - along with [certificateFilePath] - an [Application] will only allow secure connections over HTTPS.
  /// This value is often set through the `--ssl-key-path` command line option of `conduit serve`. For finer control
  /// over how HTTPS is configured for an application, see [ApplicationChannel.securityContext].
  String? privateKeyFilePath;

  /// Contextual configuration values for each [ApplicationChannel].
  ///
  /// This is a user-specific set of configuration options provided by [ApplicationChannel.initializeApplication].
  /// Each instance of [ApplicationChannel] has access to these values if set.
  ///
  /// This map allows for storing and retrieving custom configuration values that can be used
  /// throughout the application. It provides a flexible way to pass application-specific
  /// settings to different parts of the system.
  ///
  /// The context can be populated during the application's initialization phase and
  /// can contain any type of data that adheres to the dynamic type.
  ///
  /// Usage:
  /// - Add configuration values: `context['databaseUrl'] = 'postgres://...';`
  /// - Retrieve values: `final dbUrl = options.context['databaseUrl'];`
  ///
  /// Note: It's important to ensure type safety when retrieving values from this map,
  /// as it uses dynamic typing.
  final Map<String, dynamic> context = {};

  /// A static [ArgParser] for parsing command-line arguments for the application.
  ///
  /// This parser defines several options and flags that can be used to configure
  /// the application when it is launched from the command line. The available
  /// options include:
  ///
  /// - address: The address to listen on for HTTP requests.
  /// - config-path: The path to a configuration file.
  /// - isolates: Number of isolates for handling requests.
  /// - port: The port number to listen for HTTP requests on.
  /// - ipv6-only: Flag to limit listening to IPv6 connections only.
  /// - ssl-certificate-path: The path to an SSL certificate file.
  /// - ssl-key-path: The path to an SSL private key file.
  /// - timeout: Number of seconds to wait to ensure startup succeeded.
  /// - help: Flag to display help information.
  ///
  /// Each option is configured with a description, and some include default values
  /// or abbreviations for easier command-line usage.
  static final parser = ArgParser()
    ..addOption(
      "address",
      abbr: "a",
      help: "The address to listen on. See HttpServer.bind for more details."
          " Using the default will listen on any address.",
    )
    ..addOption(
      "config-path",
      abbr: "c",
      help:
          "The path to a configuration file. This File is available in the ApplicationOptions "
          "for a ApplicationChannel to use to read application-specific configuration values. Relative paths are relative to [directory].",
      defaultsTo: "config.yaml",
    )
    ..addOption(
      "isolates",
      abbr: "n",
      help: "Number of isolates handling requests.",
    )
    ..addOption(
      "port",
      abbr: "p",
      help: "The port number to listen for HTTP requests on.",
      defaultsTo: "8888",
    )
    ..addFlag(
      "ipv6-only",
      help: "Limits listening to IPv6 connections only.",
      negatable: false,
    )
    ..addOption(
      "ssl-certificate-path",
      help:
          "The path to an SSL certicate file. If provided along with --ssl-certificate-path, the application will be HTTPS-enabled.",
    )
    ..addOption(
      "ssl-key-path",
      help:
          "The path to an SSL private key file. If provided along with --ssl-certificate-path, the application will be HTTPS-enabled.",
    )
    ..addOption(
      "timeout",
      help: "Number of seconds to wait to ensure startup succeeded.",
      defaultsTo: "45",
    )
    ..addFlag("help");
}
