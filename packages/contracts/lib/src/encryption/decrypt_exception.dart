import 'dart:core';

class DecryptException implements Exception {
  final String message;

  DecryptException([this.message = '']);

  @override
  String toString() {
    return message.isEmpty ? 'DecryptException' : 'DecryptException: $message';
  }
}
