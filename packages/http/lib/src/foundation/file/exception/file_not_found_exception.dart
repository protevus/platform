// This file is part of the Symfony package.
//
// (c) Fabien Potencier <fabien@symfony.com>
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'package:protevus_http/foundation_file_exception.dart';

/// Thrown when a file was not found.
///
/// @author Bernhard Schussek <bschussek@gmail.com>
class FileNotFoundException extends FileException {
  /// Creates a new [FileNotFoundException] with the given file path.
  ///
  /// [path] The path to the file that was not found.
  FileNotFoundException(String path) : super('The file "$path" does not exist');
}
