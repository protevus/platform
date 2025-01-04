/// Interface for representing a data stream.
abstract class StreamInterface {
  /// Reads all data from the stream into a string.
  ///
  /// Returns the data from the stream as a string.
  /// Throws Exception if an error occurs.
  String toString();

  /// Closes the stream and any underlying resources.
  void close();

  /// Separates any underlying resources from the stream.
  ///
  /// After the stream has been detached, the stream is in an unusable state.
  /// Returns underlying PHP stream if one is available.
  dynamic detach();

  /// Get the size of the stream if known.
  ///
  /// Returns the size in bytes if known, or null if unknown.
  int? getSize();

  /// Returns the current position of the file read/write pointer.
  ///
  /// Returns the position as int.
  /// Throws Exception on error.
  int tell();

  /// Returns true if the stream is at the end of the stream.
  bool isEof();

  /// Returns whether or not the stream is seekable.
  bool isSeekable();

  /// Seek to a position in the stream.
  ///
  /// [offset] Stream offset.
  /// [whence] Specifies how the cursor position will be calculated.
  ///
  /// Throws Exception on failure.
  void seek(int offset, [int whence = 0]);

  /// Seek to the beginning of the stream.
  ///
  /// If the stream is not seekable, this method will raise an exception;
  /// otherwise, it will perform a seek(0).
  ///
  /// Throws Exception on failure.
  void rewind();

  /// Returns whether or not the stream is writable.
  bool isWritable();

  /// Write data to the stream.
  ///
  /// [string] The string that is to be written.
  ///
  /// Returns the number of bytes written to the stream.
  /// Throws Exception on failure.
  int write(String string);

  /// Returns whether or not the stream is readable.
  bool isReadable();

  /// Read data from the stream.
  ///
  /// [length] Read up to [length] bytes from the object and return them.
  ///
  /// Returns the data read from the stream, or null if no bytes are available.
  /// Throws Exception if an error occurs.
  String? read(int length);

  /// Returns the remaining contents in a string.
  ///
  /// Returns the remaining contents of the stream.
  /// Throws Exception if unable to read or an error occurs while reading.
  String getContents();

  /// Get stream metadata as an associative array or retrieve a specific key.
  ///
  /// [key] Specific metadata to retrieve.
  ///
  /// Returns an associative array if no key is provided.
  /// Returns null if the key is not found or the metadata cannot be determined.
  dynamic getMetadata([String? key]);
}
