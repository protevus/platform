/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';

/// A class for resolving references within a document structure.
///
/// This class provides functionality to resolve references within a document
/// represented by a [KeyedArchive]. It allows for navigation through the
/// document structure using URI-style references.
///
/// The [ReferenceResolver] is particularly useful in scenarios where you need
/// to traverse complex, nested document structures and resolve references
/// to specific parts of the document.
///
/// Usage:
/// ```dart
/// final document = KeyedArchive(...);  // Your document structure
/// final resolver = ReferenceResolver(document);
/// final resolved = resolver.resolve(Uri.parse('#/definitions/child'));
/// ```
///
/// The [resolve] method is the primary way to use this class. It takes a [Uri]
/// reference and returns the corresponding [KeyedArchive] from the document,
/// or null if the reference cannot be resolved.
class ReferenceResolver {
  /// Creates a new [ReferenceResolver] instance.
  ///
  /// The [ReferenceResolver] is used to resolve references within a document
  /// structure represented by a [KeyedArchive].
  ///
  /// Parameters:
  ///   [document] - The document to resolve references within. This
  ///   [KeyedArchive] represents the entire document structure that will be
  ///   used to resolve references.
  ReferenceResolver(this.document);

  /// The document to resolve references within.
  ///
  /// This [KeyedArchive] represents the entire document structure
  /// that will be used to resolve references.
  final KeyedArchive document;

  /// Resolves a reference URI to a [KeyedArchive] within the document.
  ///
  /// This method takes a [Uri] [ref] and traverses the document structure
  /// to find the corresponding [KeyedArchive]. It uses the path segments
  /// of the URI to navigate through the nested structure of the document.
  ///
  /// Parameters:
  ///   [ref] - A [Uri] representing the reference to resolve.
  ///
  /// Returns:
  ///   A [KeyedArchive] corresponding to the resolved reference, or null
  ///   if the reference cannot be resolved within the document structure.
  ///
  /// Example:
  ///   If [ref] is '#/definitions/child', this method will attempt to
  ///   navigate to document['definitions']['child'] and return the
  ///   corresponding [KeyedArchive].
  KeyedArchive? resolve(Uri ref) {
    final folded = ref.pathSegments.fold<KeyedArchive?>(document,
        (KeyedArchive? objectPtr, pathSegment) {
      if (objectPtr != null) {
        return objectPtr[pathSegment] as KeyedArchive?;
      } else {
        return null;
      }
    });

    return folded;
  }
}
