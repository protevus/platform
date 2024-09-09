/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';
import 'dart:mirrors';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:protevus_runtime/runtime.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

/// BuildContext provides configuration and context values used during the build process.
/// It encapsulates information about the application being compiled, build artifacts,
/// and provides utility methods for file and package management.
class BuildContext {
  /// Constructs a new BuildContext instance.
  ///
  /// [rootLibraryFileUri]: The URI of the root library file of the application being compiled.
  /// [buildDirectoryUri]: The URI of the directory where build artifacts will be stored.
  /// [executableUri]: The URI of the executable build product file.
  /// [source]: The source script for the executable.
  /// [environment]: Optional map of environment variables.
  /// [forTests]: Boolean flag indicating whether this context is for tests (includes dev dependencies).
  BuildContext(
    this.rootLibraryFileUri,
    this.buildDirectoryUri,
    this.executableUri,
    this.source, {
    this.environment,
    this.forTests = false,
  }) {
    analyzer = CodeAnalyzer(sourceApplicationDirectory.uri);
  }

  /// Creates a BuildContext instance from a map of values.
  ///
  /// This factory constructor allows for easy serialization and deserialization of BuildContext objects.
  ///
  /// [map]: A map containing the necessary values to construct a BuildContext.
  /// Returns: A new BuildContext instance.
  factory BuildContext.fromMap(Map<String, dynamic> map) {
    return BuildContext(
      Uri.parse(map['rootLibraryFileUri']),
      Uri.parse(map['buildDirectoryUri']),
      Uri.parse(map['executableUri']),
      map['source'],
      environment: map['environment'],
      forTests: map['forTests'] ?? false,
    );
  }

  /// Returns a map representation of the BuildContext with safe-to-serialize values.
  ///
  /// This getter is useful for serialization purposes, ensuring that all values are
  /// in a format that can be easily serialized (e.g., converting URIs to strings).
  Map<String, dynamic> get safeMap => {
        'rootLibraryFileUri': sourceLibraryFile.uri.toString(),
        'buildDirectoryUri': buildDirectoryUri.toString(),
        'source': source,
        'executableUri': executableUri.toString(),
        'environment': environment,
        'forTests': forTests
      };

  /// The CodeAnalyzer instance used for analyzing Dart code.
  late final CodeAnalyzer analyzer;

  /// The URI of the root library file of the application being compiled.
  final Uri rootLibraryFileUri;

  /// The URI of the executable build product file.
  final Uri executableUri;

  /// The URI of the directory where build artifacts are stored during the build process.
  final Uri buildDirectoryUri;

  /// The source script for the executable.
  final String source;

  /// Indicates whether dev dependencies of the application package should be included
  /// in the dependencies of the compiled executable.
  final bool forTests;

  /// Cached PackageConfig instance.
  PackageConfig? _packageConfig;

  /// Optional map of environment variables.
  final Map<String, String>? environment;

  /// The current RuntimeContext, cast as a MirrorContext.
  ///
  /// This getter provides access to the runtime context available during the build process.
  MirrorContext get context => RuntimeContext.current as MirrorContext;

  /// The URI of the target script file.
  ///
  /// If [forTests] is true, this will be a test file, otherwise it will be the main application file.
  Uri get targetScriptFileUri => forTests
      ? getDirectory(buildDirectoryUri.resolve("test/"))
          .uri
          .resolve("main_test.dart")
      : buildDirectoryUri.resolve("main.dart");

  /// The Pubspec of the source application.
  ///
  /// This getter parses and returns the pubspec.yaml file of the application being compiled.
  Pubspec get sourceApplicationPubspec => Pubspec.parse(
        File.fromUri(sourceApplicationDirectory.uri.resolve("pubspec.yaml"))
            .readAsStringSync(),
      );

  /// The pubspec of the source application as a map.
  ///
  /// This getter loads and returns the pubspec.yaml file as a YAML map.
  Map<dynamic, dynamic> get sourceApplicationPubspecMap => loadYaml(
        File.fromUri(
          sourceApplicationDirectory.uri.resolve("pubspec.yaml"),
        ).readAsStringSync(),
      ) as Map<dynamic, dynamic>;

  /// The directory of the application being compiled.
  Directory get sourceApplicationDirectory =>
      getDirectory(rootLibraryFileUri.resolve("../"));

  /// The library file of the application being compiled.
  File get sourceLibraryFile => getFile(rootLibraryFileUri);

  /// The directory where build artifacts are stored.
  Directory get buildDirectory => getDirectory(buildDirectoryUri);

  /// The generated runtime directory.
  Directory get buildRuntimeDirectory =>
      getDirectory(buildDirectoryUri.resolve("generated_runtime/"));

  /// Directory for compiled packages.
  Directory get buildPackagesDirectory =>
      getDirectory(buildDirectoryUri.resolve("packages/"));

  /// Directory for the compiled application.
  Directory get buildApplicationDirectory => getDirectory(
        buildPackagesDirectory.uri.resolve("${sourceApplicationPubspec.name}/"),
      );

  /// Gets the dependency package configuration relative to [sourceApplicationDirectory].
  ///
  /// This getter lazily loads and caches the package configuration.
  /// Returns: A Future that resolves to a PackageConfig instance.
  Future<PackageConfig> get packageConfig async {
    return _packageConfig ??=
        (await findPackageConfig(sourceApplicationDirectory))!;
  }

  /// Returns a [Directory] at the specified [uri], creating it recursively if it doesn't exist.
  ///
  /// [uri]: The URI of the directory.
  /// Returns: A Directory instance.
  Directory getDirectory(Uri uri) {
    final dir = Directory.fromUri(uri);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  /// Returns a [File] at the specified [uri], creating all parent directories recursively if necessary.
  ///
  /// [uri]: The URI of the file.
  /// Returns: A File instance.
  File getFile(Uri uri) {
    final file = File.fromUri(uri);
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }

    return file;
  }

  /// Retrieves a Package instance from a given URI.
  ///
  /// [uri]: The URI to resolve to a package.
  /// Returns: A Future that resolves to a Package instance, or null if not found.
  /// Throws: ArgumentError if the URI is not absolute or a package URI.
  Future<Package?> getPackageFromUri(Uri? uri) async {
    if (uri == null) {
      return null;
    }
    if (uri.scheme == "package") {
      final segments = uri.pathSegments;
      return (await packageConfig)[segments.first]!;
    } else if (!uri.isAbsolute) {
      throw ArgumentError("'uri' must be absolute or a package URI");
    }
    return null;
  }

  /// Retrieves import directives from a URI or source code.
  ///
  /// [uri]: The URI of the file to analyze.
  /// [source]: The source code to analyze.
  /// [alsoImportOriginalFile]: Whether to include an import for the original file.
  /// Returns: A Future that resolves to a list of import directive strings.
  /// Throws: ArgumentError for invalid combinations of parameters.
  Future<List<String>> getImportDirectives({
    Uri? uri,
    String? source,
    bool alsoImportOriginalFile = false,
  }) async {
    if (uri != null && source != null) {
      throw ArgumentError(
        "either uri or source must be non-null, but not both",
      );
    }

    if (uri == null && source == null) {
      throw ArgumentError(
        "either uri or source must be non-null, but not both",
      );
    }

    if (alsoImportOriginalFile == true && uri == null) {
      throw ArgumentError(
        "flag 'alsoImportOriginalFile' may only be set if 'uri' is also set",
      );
    }
    final Package? package = await getPackageFromUri(uri);
    final String? trailingSegments = uri?.pathSegments.sublist(1).join('/');
    final fileUri =
        package?.packageUriRoot.resolve(trailingSegments ?? '') ?? uri;
    final text = source ?? File.fromUri(fileUri!).readAsStringSync();
    final importRegex = RegExp("import [\\'\\\"]([^\\'\\\"]*)[\\'\\\"];");

    final imports = importRegex.allMatches(text).map((m) {
      final importedUri = Uri.parse(m.group(1)!);

      if (!importedUri.isAbsolute) {
        final path = fileUri
            ?.resolve(importedUri.path)
            .toFilePath(windows: Platform.isWindows);
        return "import 'file:${absolute(path!)}';";
      }

      return text.substring(m.start, m.end);
    }).toList();

    if (alsoImportOriginalFile) {
      imports.add("import '$uri';");
    }

    return imports;
  }

  /// Retrieves a ClassDeclaration from a given Type.
  ///
  /// [type]: The Type to analyze.
  /// Returns: A Future that resolves to a ClassDeclaration, or null if not found.
  Future<ClassDeclaration?> getClassDeclarationFromType(Type type) async {
    final classMirror = reflectType(type);
    Uri uri = classMirror.location!.sourceUri;
    if (!classMirror.location!.sourceUri.isAbsolute) {
      final Package? package = await getPackageFromUri(uri);
      uri = package!.packageUriRoot;
    }
    return analyzer.getClassFromFile(
      MirrorSystem.getName(classMirror.simpleName),
      uri,
    );
  }

  /// Retrieves a FieldDeclaration from a ClassMirror and property name.
  ///
  /// [type]: The ClassMirror to analyze.
  /// [propertyName]: The name of the property to find.
  /// Returns: A Future that resolves to a FieldDeclaration, or null if not found.
  Future<FieldDeclaration?> _getField(ClassMirror type, String propertyName) {
    return getClassDeclarationFromType(type.reflectedType).then((cd) {
      try {
        return cd!.members.firstWhere(
          (m) => (m as FieldDeclaration)
              .fields
              .variables
              .any((v) => v.name.value() == propertyName),
        ) as FieldDeclaration;
      } catch (e) {
        return null;
      }
    });
  }

  /// Retrieves annotations from a field of a given Type.
  ///
  /// This method searches for the field in the given type and its superclasses.
  ///
  /// [type1]: The Type to analyze.
  /// [propertyName]: The name of the property to find.
  /// Returns: A Future that resolves to a list of Annotations.
  Future<List<Annotation>> getAnnotationsFromField(
    Type type1,
    String propertyName,
  ) async {
    var type = reflectClass(type1);
    FieldDeclaration? field = await _getField(type, propertyName);
    while (field == null) {
      type = type.superclass!;
      if (type.reflectedType == Object) {
        break;
      }
      field = await _getField(type, propertyName);
    }

    if (field == null) {
      return [];
    }

    return field.metadata;
  }
}
