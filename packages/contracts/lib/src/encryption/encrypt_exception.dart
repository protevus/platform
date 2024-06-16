
class EncryptException implements Exception {
  final String message;

  EncryptException([this.message = '']);

  @override
  String toString() => 'EncryptException: $message';
}
