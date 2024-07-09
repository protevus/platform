import 'package:path/path.dart' as p;

import 'package:protevus_http/foundation_file_exception.dart';
import 'package:protevus_http/foundation_file.dart';
import 'package:protevus_mime/mime.dart';

/// A file uploaded through a form.
class UploadedFile extends File {
  late String _originalName;
  late String _mimeType;
  late int _error;
  late String _originalPath;
  late bool _test;

  UploadedFile(
    super.path,
    String originalName,
    String? mimeType,
    int? error,
    bool test,
  ) {
    _originalName = _getName(originalName);
    _originalPath = originalName.replaceAll('\\', '/');
    _mimeType = mimeType ?? 'application/octet-stream';
    _error = error ?? 0; // UPLOAD_ERR_OK
    _test = test;
  }

  String getClientOriginalName() {
    return _originalName;
  }

  String getClientOriginalExtension() {
    return p.extension(_originalName);
  }

  String getClientOriginalPath() {
    return _originalPath;
  }

  String getClientMimeType() => _mimeType;

  String? guessClientExtension() {
    try {
      List<String> extensions =
          MimeTypes.getDefault().getExtensions(getClientMimeType());
      return extensions.isNotEmpty ? extensions[0] : null;
    } catch (e) {
      return null;
    }
  }

  int getError() {
    return _error;
  }

  bool isValid() {
    bool isOk = _error == 0; // UPLOAD_ERR_OK
    return _test ? isOk : isOk && File(path).existsSync();
  }

  @override
  File move(String directory, [String? name]) {
    if (isValid()) {
      if (_test) {
        return File(p.join(directory, name ?? p.basename(path)));
      }

      File target = _getTargetFile(directory, name);
      try {
        return super.move(target.path);
      } catch (e) {
        throw FileException(
            'Could not move the file "$path" to "${target.path}" ($e).');
      }
    }

    switch (_error) {
      case 1: // UPLOAD_ERR_INI_SIZE
        throw IniSizeFileException(_getErrorMessage());
      case 2: // UPLOAD_ERR_FORM_SIZE
        throw FormSizeFileException(_getErrorMessage());
      case 3: // UPLOAD_ERR_PARTIAL
        throw PartialFileException(_getErrorMessage());
      case 4: // UPLOAD_ERR_NO_FILE
        throw NoFileException(_getErrorMessage());
      case 6: // UPLOAD_ERR_NO_TMP_DIR
        throw NoTmpDirFileException(_getErrorMessage());
      case 7: // UPLOAD_ERR_CANT_WRITE
        throw CannotWriteFileException(_getErrorMessage());
      case 8: // UPLOAD_ERR_EXTENSION
        throw ExtensionFileException(_getErrorMessage());
      default:
        throw FileException(_getErrorMessage());
    }
  }

  static int getMaxFilesize() {
    // Note: This is a placeholder. Implement according to your needs.
    return 2 * 1024 * 1024; // 2MB as an example
  }

  String _getErrorMessage() {
    Map<int, String> errors = {
      1: 'The file "%s" exceeds your upload_max_filesize ini directive (limit is %d KiB).',
      2: 'The file "%s" exceeds the upload limit defined in your form.',
      3: 'The file "%s" was only partially uploaded.',
      4: 'No file was uploaded.',
      6: 'File could not be uploaded: missing temporary directory.',
      7: 'The file "%s" could not be written on disk.',
      8: 'File upload was stopped by a PHP extension.',
    };

    int maxFilesize = _error == 1 ? getMaxFilesize() ~/ 1024 : 0;
    String message = errors[_error] ??
        'The file "%s" was not uploaded due to an unknown error.';

    return message
        .replaceAll('%s', _originalName)
        .replaceAll('%d', maxFilesize.toString());
  }

  String _getName(String name) {
    return p.basename(name);
  }

  File _getTargetFile(String directory, String? name) {
    name ??= p.basename(path);
    return File(p.join(directory, name));
  }
}
