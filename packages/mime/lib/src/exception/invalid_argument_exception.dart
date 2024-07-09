import 'dart:core';
import 'exception_interface.dart';

/// @author Fabien Potencier <fabien@symfony.com>
class InvalidArgumentException implements Exception, ExceptionInterface {
  final String message;

  // Constructor in Dart
  InvalidArgumentException([this.message = '']);

  @override
  String toString() => 'InvalidArgumentException: $message';
}
