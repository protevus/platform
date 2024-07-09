// This file is part of the Symfony package.
//
// (c) Fabien Potencier <fabien@symfony.com>
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'package:protevus_http/foundation_file_exception.dart';

/// Thrown when an UPLOAD_ERR_NO_FILE error occurred with UploadedFile.
///
/// @author Florent Mata <florentmata@gmail.com>
class NoFileException extends FileException {
  NoFileException(super.message);
}
