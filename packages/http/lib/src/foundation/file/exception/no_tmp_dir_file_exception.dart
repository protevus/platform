import 'package:protevus_http/foundation_file_exception.dart';

/// Thrown when an UPLOAD_ERR_NO_TMP_DIR error occurred with UploadedFile.
///
/// @author Florent Mata <florentmata@gmail.com>
class NoTmpDirFileException extends FileException {
  NoTmpDirFileException(super.message);
}
