import 'stream_interface.dart';

/// Value object representing a file uploaded through an HTTP request.
abstract class UploadedFileInterface {
  /// Retrieve a stream representing the uploaded file.
  ///
  /// Returns a StreamInterface instance.
  /// Throws Exception if the upload was not successful.
  StreamInterface getStream();

  /// Move the uploaded file to a new location.
  ///
  /// [targetPath] Path to which to move the uploaded file.
  ///
  /// Throws Exception on any error during the move operation.
  /// Throws Exception on invalid [targetPath].
  void moveTo(String targetPath);

  /// Retrieve the file size.
  ///
  /// Returns the file size in bytes or null if unknown.
  int? getSize();

  /// Retrieve the error associated with the uploaded file.
  ///
  /// Returns one of the UPLOAD_ERR_XXX constants.
  /// Returns UPLOAD_ERR_OK if no error occurred.
  int getError();

  /// Retrieve the filename sent by the client.
  ///
  /// Returns the filename sent by the client or null if none
  /// was provided.
  String? getClientFilename();

  /// Retrieve the media type sent by the client.
  ///
  /// Returns the media type sent by the client or null if none
  /// was provided.
  String? getClientMediaType();
}
