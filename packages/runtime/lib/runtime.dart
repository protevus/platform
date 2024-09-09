/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// The main library for the Protevus runtime package.
///
/// This library provides core functionality for the Protevus Platform,
/// including compilation, analysis, and runtime management.
library runtime;

import 'dart:io';

// Export statements for various components of the runtime package
export 'package:protevus_runtime/src/analyzer.dart';
export 'package:protevus_runtime/src/build.dart';
export 'package:protevus_runtime/src/build_context.dart';
export 'package:protevus_runtime/src/build_manager.dart';
export 'package:protevus_runtime/src/compiler.dart';
export 'package:protevus_runtime/src/context.dart';
export 'package:protevus_runtime/src/exceptions.dart';
export 'package:protevus_runtime/src/generator.dart';
export 'package:protevus_runtime/src/mirror_coerce.dart';
export 'package:protevus_runtime/src/mirror_context.dart';
import 'package:protevus_runtime/runtime.dart';

/// A specialized compiler for the runtime package itself.
///
/// This compiler is responsible for creating a mirror-free version of the
/// runtime package. It removes dart:mirror dependencies and adds a generated
/// runtime to the package's pubspec.
class RuntimePackageCompiler extends Compiler {
  /// Compiles the runtime package.
  ///
  /// This method is currently a no-op, returning an empty map. It may be
  /// extended in the future to perform actual compilation tasks.
  ///
  /// [context] - The mirror context for compilation (unused in this implementation).
  ///
  /// Returns an empty map, as no compilation is currently performed.
  @override
  Map<String, Object> compile(MirrorContext context) => {};

  /// Modifies the package structure to remove mirror dependencies.
  ///
  /// This method performs the following tasks:
  /// 1. Rewrites the main library file to remove mirror-related exports.
  /// 2. Updates the context file to use the generated runtime instead of mirror context.
  /// 3. Modifies the pubspec.yaml to include the generated runtime as a dependency.
  ///
  /// [destinationDirectory] - The directory where the modified package will be created.
  @override
  void deflectPackage(Directory destinationDirectory) {
    // Rewrite the main library file
    final libraryFile = File.fromUri(
      destinationDirectory.uri.resolve("lib/").resolve("runtime.dart"),
    );
    libraryFile.writeAsStringSync(
      "library runtime;\nexport 'src/context.dart';\nexport 'src/exceptions.dart';",
    );

    // Update the context file
    final contextFile = File.fromUri(
      destinationDirectory.uri
          .resolve("lib/")
          .resolve("src/")
          .resolve("context.dart"),
    );
    final contextFileContents = contextFile.readAsStringSync().replaceFirst(
          "import 'package:protevus_runtime/src/mirror_context.dart';",
          "import 'package:generated_runtime/generated_runtime.dart';",
        );
    contextFile.writeAsStringSync(contextFileContents);

    // Modify the pubspec.yaml
    final pubspecFile =
        File.fromUri(destinationDirectory.uri.resolve("pubspec.yaml"));
    final pubspecContents = pubspecFile.readAsStringSync().replaceFirst(
          "\ndependencies:",
          "\ndependencies:\n  generated_runtime:\n    path: ../../generated_runtime/",
        );
    pubspecFile.writeAsStringSync(pubspecContents);
  }
}
