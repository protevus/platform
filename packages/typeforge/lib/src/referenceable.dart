/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';

/// This abstract class serves as a contract for objects that need to be
/// resolved based on references. It defines a common interface for resolution
/// operations, allowing for consistent handling of referenceable objects
/// throughout the system.
///
/// Implementations of this class should ensure that:
/// - They provide a meaningful implementation of [resolveOrThrow].
/// - They handle potential errors during resolution and throw appropriate exceptions.
/// - They interact correctly with the provided [ReferenceResolver].
///
/// Example usage:
/// ```dart
/// class ConcreteReferenceable implements Referenceable {
///   @override
///   void resolveOrThrow(ReferenceResolver resolver) {
///     // Implementation of reference resolution
///   }
/// }
abstract class Referenceable {
  /// Resolves the references within this object using the provided [resolver].
  ///
  /// This method is responsible for resolving any references or dependencies
  /// that this object might have. It should use the [resolver] to look up and
  /// resolve these references.
  ///
  /// If the resolution process encounters any errors or fails to resolve
  /// necessary references, this method should throw an appropriate exception.
  ///
  /// Parameters:
  ///   [resolver]: The [ReferenceResolver] instance to use for resolving references.
  ///
  /// Throws:
  ///   An exception if the resolution process fails or encounters errors.
  void resolveOrThrow(ReferenceResolver resolver);
}
