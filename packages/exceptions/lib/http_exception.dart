library platform_http_exception;

//import 'package:dart2_constant/convert.dart';
import 'dart:convert';

/// Exception class that can be serialized to JSON and serialized to clients.
/// Carries HTTP-specific metadata, like [statusCode].
///
/// Originally inspired by
/// [feathers-errors](https://github.com/feathersjs/feathers-errors).
class PlatformHttpException implements Exception {
  /// A list of errors that occurred when this exception was thrown.
  final List<String> errors = [];

  /// The error throw by exception.
  dynamic error;

  /// The cause of this exception.
  String message;

  /// The [StackTrace] associated with this error.
  StackTrace? stackTrace;

  /// An HTTP status code this exception will throw.
  int statusCode;

  PlatformHttpException(
      {this.message = '500 Internal Server Error',
      this.stackTrace,
      this.statusCode = 500,
      this.error,
      List<String> errors = const []}) {
    this.errors.addAll(errors);
  }

  Map toJson() {
    return {
      'is_error': true,
      'status_code': statusCode,
      'message': message,
      'errors': errors
    };
  }

  Map toMap() => toJson();

  @override
  String toString() {
    return '$statusCode: $message';
  }

  factory PlatformHttpException.fromMap(Map data) {
    return PlatformHttpException(
      statusCode: (data['status_code'] ?? data['statusCode'] ?? 500) as int,
      message: data['message']?.toString() ?? 'Internal Server Error',
      errors: data['errors'] is Iterable
          ? ((data['errors'] as Iterable).map((x) => x.toString()).toList())
          : <String>[],
    );
  }

  factory PlatformHttpException.fromJson(String str) =>
      PlatformHttpException.fromMap(json.decode(str) as Map);

  /// Throws a 400 Bad Request error, including an optional arrray of (validation?)
  /// errors you specify.
  factory PlatformHttpException.badRequest(
          {String message = '400 Bad Request',
          List<String> errors = const []}) =>
      PlatformHttpException(message: message, errors: errors, statusCode: 400);

  /// Throws a 401 Not Authenticated error.
  factory PlatformHttpException.notAuthenticated(
          {String message = '401 Not Authenticated'}) =>
      PlatformHttpException(message: message, statusCode: 401);

  /// Throws a 402 Payment Required error.
  factory PlatformHttpException.paymentRequired(
          {String message = '402 Payment Required'}) =>
      PlatformHttpException(message: message, statusCode: 402);

  /// Throws a 403 Forbidden error.
  factory PlatformHttpException.forbidden({String message = '403 Forbidden'}) =>
      PlatformHttpException(message: message, statusCode: 403);

  /// Throws a 404 Not Found error.
  factory PlatformHttpException.notFound({String message = '404 Not Found'}) =>
      PlatformHttpException(message: message, statusCode: 404);

  /// Throws a 405 Method Not Allowed error.
  factory PlatformHttpException.methodNotAllowed(
          {String message = '405 Method Not Allowed'}) =>
      PlatformHttpException(message: message, statusCode: 405);

  /// Throws a 406 Not Acceptable error.
  factory PlatformHttpException.notAcceptable(
          {String message = '406 Not Acceptable'}) =>
      PlatformHttpException(message: message, statusCode: 406);

  /// Throws a 408 Timeout error.
  factory PlatformHttpException.methodTimeout(
          {String message = '408 Timeout'}) =>
      PlatformHttpException(message: message, statusCode: 408);

  /// Throws a 409 Conflict error.
  factory PlatformHttpException.conflict({String message = '409 Conflict'}) =>
      PlatformHttpException(message: message, statusCode: 409);

  /// Throws a 422 Not Processable error.
  factory PlatformHttpException.notProcessable(
          {String message = '422 Not Processable'}) =>
      PlatformHttpException(message: message, statusCode: 422);

  /// Throws a 501 Not Implemented error.
  factory PlatformHttpException.notImplemented(
          {String message = '501 Not Implemented'}) =>
      PlatformHttpException(message: message, statusCode: 501);

  /// Throws a 503 Unavailable error.
  factory PlatformHttpException.unavailable(
          {String message = '503 Unavailable'}) =>
      PlatformHttpException(message: message, statusCode: 503);
}
