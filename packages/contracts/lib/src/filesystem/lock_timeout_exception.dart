import 'dart:io';

class LockTimeoutException implements IOException {
  final String message;

  LockTimeoutException([this.message = '']);

  @override
  String toString() {
    return 'LockTimeoutException: $message';
  }
}
