// This file is part of the Symfony package.
//
// (c) Fabien Potencier <fabien@symfony.com>
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'dart:core';

/// Exception thrown when an error occurs during file operations.
///
/// This exception is used to handle various file-related errors in the component File.
///
/// Example usage:
/// ```dart
/// try {
///   // File operation that may throw an exception
/// } catch (e) {
///   if (e is FileException) {
///     print('A file error occurred: ${e.message}');
///   }
/// }
/// ```
class FileException implements Exception {
  final String message;

  /// Creates a new [FileException] with the given [message].
  FileException([this.message = '']);

  @override
  String toString() => 'FileException: $message';
}
