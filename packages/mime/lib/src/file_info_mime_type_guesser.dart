import 'dart:io';
import 'package:mime/mime.dart' as mime;

import 'package:protevus_mime/mime_exception.dart';
import 'package:protevus_mime/mime.dart';

/// Guesses the MIME type using the MIME package, which is similar to PHP's FileInfo.
///
/// @author Bernhard Schussek <bschussek@gmail.com>
/// Ported to Dart by [Your Name]
class FileInfoMimeTypeGuesser implements MimeTypeGuesserInterface {
  /// Constructs a new FileinfoMimeTypeGuesser.
  FileInfoMimeTypeGuesser();

  @override
  bool isGuesserSupported() {
    // In Dart, we're using the mime package which is always available if imported
    return true;
  }

  @override
  Future<String?> guessMimeType(String path) async {
    final file = File(path);

    if (!await file.exists() ||
        !(await file.stat()).type.toString().contains('file')) {
      throw InvalidArgumentException(
          'The "$path" file does not exist or is not readable.');
    }

    if (!isGuesserSupported()) {
      throw LogicException(
          'The "${runtimeType.toString()}" guesser is not supported.');
    }

    String? mimeType;
    try {
      // Using the mime package to guess the MIME type
      final bytes = await file.openRead(0, 12).first;
      mimeType = mime.lookupMimeType(path, headerBytes: bytes);
    } catch (e) {
      print('Error guessing MIME type: $e');
      return null;
    }

    if (mimeType != null && mimeType.length % 2 == 0) {
      final mimeStart = mimeType.substring(0, mimeType.length ~/ 2);
      if (mimeStart + mimeStart == mimeType) {
        mimeType = mimeStart;
      }
    }

    return mimeType;
  }
}
