import 'package:psr_container/psr_container.dart';

// TODO: find packages to replace missing imports.

class BindingResolutionException implements Exception, ContainerException {
  final String message;

  BindingResolutionException([this.message = '']);

  @override
  String toString() => 'BindingResolutionException: $message';
}
