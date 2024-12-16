/// Factory interface for creating PSR-7 Stream instances.
abstract class StreamFactoryInterface {
  /// Creates a new PSR-7 Stream instance from a string.
  ///
  /// [content] The content with which to populate the stream.
  ///
  /// Returns a new PSR-7 Stream instance.
  dynamic createStream([String content = '']);

  /// Creates a new PSR-7 Stream instance from an existing file.
  ///
  /// [filename] The filename or stream URI to use as basis of stream.
  /// [mode] The mode with which to open the underlying filename/stream.
  ///
  /// Returns a new PSR-7 Stream instance.
  dynamic createStreamFromFile(String filename, [String mode = 'r']);

  /// Creates a new PSR-7 Stream instance from an existing resource.
  ///
  /// [resource] The PHP resource to use as the basis for the stream.
  ///
  /// Returns a new PSR-7 Stream instance.
  dynamic createStreamFromResource(dynamic resource);
}

/// Factory interface for creating PSR-7 UploadedFile instances.
abstract class UploadedFileFactoryInterface {
  /// Creates a new PSR-7 UploadedFile instance.
  ///
  /// [stream] The underlying stream representing the uploaded file content.
  /// [size] The size of the file in bytes.
  /// [errorStatus] The PHP upload error status.
  /// [clientFilename] The filename as provided by the client.
  /// [clientMediaType] The media type as provided by the client.
  ///
  /// Returns a new PSR-7 UploadedFile instance.
  dynamic createUploadedFile(
    dynamic stream, [
    int? size,
    int errorStatus = 0,
    String? clientFilename,
    String? clientMediaType,
  ]);
}
