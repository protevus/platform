// This file is part of the Symfony package.
//
// (c) Fabien Potencier <fabien@symfony.com>
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'dart:io';

/// Guesses the MIME type of a file.
///
/// @author Fabien Potencier <fabien@symfony.com>
abstract class MimeTypeGuesserInterface {
  /// Returns true if this guesser is supported.
  bool isGuesserSupported();

  /// Guesses the MIME type of the file with the given path.
  ///
  /// Throws [UnsupportedError] if the guesser is not supported
  /// Throws [FileSystemException] if the file does not exist or is not readable
  Future<String?> guessMimeType(String path);
}
