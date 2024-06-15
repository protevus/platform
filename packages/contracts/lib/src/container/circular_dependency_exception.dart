import 'package:psr/psr.dart';

// TODO: Find packages to replace missing imports.

class CircularDependencyException implements Exception, ContainerExceptionInterface {
  final String message;

  CircularDependencyException([this.message = '']);

  @override
  String toString() => 'CircularDependencyException: $message';
}
