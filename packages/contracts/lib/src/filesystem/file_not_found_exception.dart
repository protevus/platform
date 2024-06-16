
class FileNotFoundException implements Exception {
  final String message;

  FileNotFoundException([this.message = 'File not found']);

  @override
  String toString() => 'FileNotFoundException: $message';
}
