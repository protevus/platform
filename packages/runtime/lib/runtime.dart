/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

library runtime;

import 'dart:io';

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

/// Compiler for the runtime package itself.
///
/// Removes dart:mirror from a replica of this package, and adds
/// a generated runtime to the replica's pubspec.
class RuntimePackageCompiler extends Compiler {
  @override
  Map<String, Object> compile(MirrorContext context) => {};

  @override
  void deflectPackage(Directory destinationDirectory) {
    final libraryFile = File.fromUri(
      destinationDirectory.uri.resolve("lib/").resolve("runtime.dart"),
    );
    libraryFile.writeAsStringSync(
      "library runtime;\nexport 'src/context.dart';\nexport 'src/exceptions.dart';",
    );

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

    final pubspecFile =
        File.fromUri(destinationDirectory.uri.resolve("pubspec.yaml"));
    final pubspecContents = pubspecFile.readAsStringSync().replaceFirst(
          "\ndependencies:",
          "\ndependencies:\n  generated_runtime:\n    path: ../../generated_runtime/",
        );
    pubspecFile.writeAsStringSync(pubspecContents);
  }
}
