/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:protevus_isolate/isolate.dart';
import 'package:protevus_runtime/runtime.dart';
import 'package:io/io.dart';

/// A class that represents an executable build process.
///
/// This class extends the [Executable] class and is responsible for
/// executing a build process based on the provided build context.
class BuildExecutable extends Executable {
  /// Constructs a new [BuildExecutable] instance.
  ///
  /// [message] is a map containing the build context information.
  BuildExecutable(Map<String, dynamic> message) : super(message) {
    context = BuildContext.fromMap(message);
  }

  /// The build context for this executable.
  late final BuildContext context;

  /// Executes the build process.
  ///
  /// This method creates a new [Build] instance with the current context
  /// and calls its execute method.
  @override
  Future execute() async {
    final build = Build(context);
    await build.execute();
  }
}

/// A class that manages the build process for non-mirrored builds.
class BuildManager {
  /// Creates a new [BuildManager] instance.
  ///
  /// [context] is the [BuildContext] for this build manager.
  BuildManager(this.context);

  /// The build context for this manager.
  final BuildContext context;

  /// Gets the URI of the source directory.
  Uri get sourceDirectoryUri => context.sourceApplicationDirectory.uri;

  /// Performs the build process.
  ///
  /// This method handles the following steps:
  /// 1. Creates the build directory if it doesn't exist.
  /// 2. Creates a temporary copy of the script file with the main function stripped.
  /// 3. Analyzes the script file and removes all main functions.
  /// 4. Copies the 'not_tests' directory if it exists.
  /// 5. Runs the build executable in an isolate.
  Future build() async {
    if (!context.buildDirectory.existsSync()) {
      context.buildDirectory.createSync();
    }

    // Create a temporary copy of the script file with the main function stripped
    var scriptSource = context.source;
    final strippedScriptFile = File.fromUri(context.targetScriptFileUri)
      ..writeAsStringSync(scriptSource);
    final analyzer = CodeAnalyzer(strippedScriptFile.absolute.uri);
    final analyzerContext = analyzer.contexts.contextFor(analyzer.path);
    final parsedUnit = analyzerContext.currentSession
        .getParsedUnit(analyzer.path) as ParsedUnitResult;

    // Find and remove all main functions
    final mainFunctions = parsedUnit.unit.declarations
        .whereType<FunctionDeclaration>()
        .where((f) => f.name.value() == "main")
        .toList();

    for (final f in mainFunctions.reversed) {
      scriptSource = scriptSource.replaceRange(f.offset, f.end, "");
    }

    strippedScriptFile.writeAsStringSync(scriptSource);

    // Copy the 'not_tests' directory if it exists
    try {
      await copyPath(
          context.sourceApplicationDirectory.uri.resolve('test/not_tests').path,
          context.buildDirectoryUri.resolve('not_tests').path);
    } catch (_) {}

    // Run the build executable in an isolate
    await IsolateExecutor.run(
      BuildExecutable(context.safeMap),
      packageConfigURI:
          sourceDirectoryUri.resolve('.dart_tool/package_config.json'),
      imports: [
        "package:conduit_runtime/runtime.dart",
        context.targetScriptFileUri.toString()
      ],
      logHandler: (s) => print(s), //ignore: avoid_print
    );
  }

  /// Cleans up the build directory.
  ///
  /// This method deletes the build directory and its contents if it exists.
  Future clean() async {
    if (context.buildDirectory.existsSync()) {
      context.buildDirectory.deleteSync(recursive: true);
    }
  }
}
