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

import 'package:protevus_config/config.dart';
import 'package:protevus_runtime/runtime.dart';

/// A compiler class for configurations in the Protevus Platform.
///
/// This class extends the [Compiler] class and provides functionality to
/// compile configuration-related data and modify package files.
///
/// The [compile] method creates a map of configuration names to their
/// corresponding [ConfigurationRuntimeImpl] instances by scanning for
/// subclasses of [Configuration] in the given [MirrorContext].
///
/// The [deflectPackage] method modifies the "conduit_config.dart" file in the
/// destination directory by removing a specific export statement.
class ConfigurationCompiler extends Compiler {
  /// Compiles configuration data from the given [MirrorContext].
  ///
  /// This method scans the [context] for all subclasses of [Configuration]
  /// and creates a map where:
  /// - The keys are the names of these subclasses (as strings)
  /// - The values are instances of [ConfigurationRuntimeImpl] created from
  ///   the corresponding subclass
  ///
  /// Returns a [Map<String, Object>] where each entry represents a
  /// configuration class and its runtime implementation.
  @override
  Map<String, Object> compile(MirrorContext context) {
    return Map.fromEntries(
      context.getSubclassesOf(Configuration).map((c) {
        return MapEntry(
          MirrorSystem.getName(c.simpleName),
          ConfigurationRuntimeImpl(c),
        );
      }),
    );
  }

  /// Modifies the package file by removing a specific export statement.
  ///
  /// This method performs the following steps:
  /// 1. Locates the "config.dart" file in the "lib/" directory of the [destinationDirectory].
  /// 2. Reads the contents of the file.
  /// 3. Removes the line "export 'package:protevus_config/src/compiler.dart';" from the file contents.
  /// 4. Writes the modified contents back to the file.
  ///
  /// This operation is typically used to adjust the exported modules in the compiled package.
  ///
  /// [destinationDirectory] is the directory where the package files are located.
  @override
  void deflectPackage(Directory destinationDirectory) {
    final libFile = File.fromUri(
      destinationDirectory.uri.resolve("lib/").resolve("config.dart"),
    );
    final contents = libFile.readAsStringSync();
    libFile.writeAsStringSync(
      contents.replaceFirst(
          "export 'package:protevus_config/src/compiler.dart';", ""),
    );
  }
}
