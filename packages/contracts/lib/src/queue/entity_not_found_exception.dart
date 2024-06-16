import 'dart:core';

class EntityNotFoundException implements Exception {
  final String message;

  EntityNotFoundException(String type, dynamic id)
      : message = "Queueable entity [$type] not found for ID [${id.toString()}].";

  @override
  String toString() => 'EntityNotFoundException: $message';
}
