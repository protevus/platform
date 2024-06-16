import 'package:meta/meta.dart';

class ViewCompilationException implements Exception {
  final String? message;

  ViewCompilationException([this.message]);

  @override
  String toString() {
    return message ?? 'ViewCompilationException';
  }
}
