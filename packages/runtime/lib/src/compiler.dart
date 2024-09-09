/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';
import 'package:protevus_runtime/runtime.dart';

/// An abstract class that defines the interface for compilers in the Protevus Platform.
///
/// This class provides methods for modifying packages, compiling runtime objects,
/// and handling post-generation tasks. Implementations of this class are used to
/// remove dart:mirrors usage from packages and prepare them for runtime execution.
abstract class Compiler {
  /// Modifies a package on the filesystem to remove dart:mirrors usage.
  ///
  /// This method creates a copy of the compiler's package in the [destinationDirectory]
  /// and modifies its contents to remove all uses of dart:mirrors. This is crucial for
  /// preparing packages for environments where reflection is not available or desired.
  ///
  /// Packages should export their [Compiler] in their main library file and only
  /// import mirrors in files directly or transitively imported by the Compiler file.
  /// This method should remove that export statement and therefore remove all transitive mirror imports.
  ///
  /// [destinationDirectory] The directory where the modified package will be written.
  void deflectPackage(Directory destinationDirectory);

  /// Compiles and returns a map of runtime objects for use in mirrored mode.
  ///
  /// This method is responsible for creating runtime representations of objects
  /// that can be used when the application is running in mirrored mode.
  ///
  /// [context] The [MirrorContext] providing reflection capabilities for compilation.
  ///
  /// Returns a [Map] where keys are String identifiers and values are compiled Objects.
  Map<String, Object> compile(MirrorContext context);

  /// A hook method called after package generation is complete.
  ///
  /// This method can be overridden to perform any necessary cleanup or additional
  /// tasks after the package has been generated.
  ///
  /// [context] The [BuildContext] containing information about the build process.
  void didFinishPackageGeneration(BuildContext context) {}

  /// Returns a list of URIs that need to be resolved during the build process.
  ///
  /// This method can be overridden to specify additional URIs that should be
  /// resolved as part of the compilation process.
  ///
  /// [context] The [BuildContext] containing information about the build process.
  ///
  /// Returns a [List] of [Uri] objects to be resolved.
  List<Uri> getUrisToResolve(BuildContext context) => [];
}

/// An abstract class for compilers that generate source code.
///
/// This class extends the functionality of [Compiler] to include
/// the ability to generate source code that represents the runtime behavior.
abstract class SourceCompiler {
  /// Generates source code that declares a class equivalent in behavior to this runtime.
  ///
  /// This method should be implemented to produce a string of Dart source code
  /// that includes all necessary directives and class declarations to replicate
  /// the behavior of the runtime in a static context.
  ///
  /// [ctx] The [BuildContext] containing information about the build process.
  ///
  /// Returns a [Future] that resolves to a [String] containing the generated source code.
  Future<String> compile(BuildContext ctx) async {
    throw UnimplementedError();
  }
}
