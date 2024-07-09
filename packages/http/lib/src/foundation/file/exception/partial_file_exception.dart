// This file is part of the Symfony package.
//
// (c) Fabien Potencier <fabien@symfony.com>
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

// Note: In Dart, we don't need to explicitly declare namespaces like in PHP.
// The package structure in Dart serves a similar purpose.

import 'package:protevus_http/foundation_file_exception.dart';

/// Thrown when an UPLOAD_ERR_PARTIAL error occurred with UploadedFile.
///
/// @author Florent Mata <florentmata@gmail.com>
class PartialFileException extends FileException {
  PartialFileException(super.message);
}
