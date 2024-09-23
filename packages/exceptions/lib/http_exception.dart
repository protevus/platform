library http_exception;

//import 'package:dart2_constant/convert.dart';
import 'dart:convert';

/// Exception class that can be serialized to JSON and serialized to clients.
/// Carries HTTP-specific metadata, like [statusCode].
///
/// Originally inspired by
/// [feathers-errors](https://github.com/feathersjs/feathers-errors).
class HttpException implements Exception {
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

  HttpException(
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

  factory HttpException.fromMap(Map data) {
    return HttpException(
      statusCode: (data['status_code'] ?? data['statusCode'] ?? 500) as int,
      message: data['message']?.toString() ?? 'Internal Server Error',
      errors: data['errors'] is Iterable
          ? ((data['errors'] as Iterable).map((x) => x.toString()).toList())
          : <String>[],
    );
  }

  factory HttpException.fromJson(String str) =>
      HttpException.fromMap(json.decode(str) as Map);

  /// Throws a 400 Bad Request error, including an optional arrray of (validation?)
  /// errors you specify.
  factory HttpException.badRequest(
          {String message = '400 Bad Request',
          List<String> errors = const []}) =>
      HttpException(message: message, errors: errors, statusCode: 400);

  /// Throws a 401 Not Authenticated error.
  factory HttpException.notAuthenticated(
          {String message = '401 Not Authenticated'}) =>
      HttpException(message: message, statusCode: 401);

  /// Throws a 402 Payment Required error.
  factory HttpException.paymentRequired(
          {String message = '402 Payment Required'}) =>
      HttpException(message: message, statusCode: 402);

  /// Throws a 403 Forbidden error.
  factory HttpException.forbidden({String message = '403 Forbidden'}) =>
      HttpException(message: message, statusCode: 403);

  /// Throws a 404 Not Found error.
  factory HttpException.notFound({String message = '404 Not Found'}) =>
      HttpException(message: message, statusCode: 404);

  /// Throws a 405 Method Not Allowed error.
  factory HttpException.methodNotAllowed(
          {String message = '405 Method Not Allowed'}) =>
      HttpException(message: message, statusCode: 405);

  /// Throws a 406 Not Acceptable error.
  factory HttpException.notAcceptable(
          {String message = '406 Not Acceptable'}) =>
      HttpException(message: message, statusCode: 406);

  /// Throws a 408 Timeout error.
  factory HttpException.methodTimeout({String message = '408 Timeout'}) =>
      HttpException(message: message, statusCode: 408);

  /// Throws a 409 Conflict error.
  factory HttpException.conflict({String message = '409 Conflict'}) =>
      HttpException(message: message, statusCode: 409);

  /// Throws a 422 Not Processable error.
  factory HttpException.notProcessable(
          {String message = '422 Not Processable'}) =>
      HttpException(message: message, statusCode: 422);

  /// Throws a 501 Not Implemented error.
  factory HttpException.notImplemented(
          {String message = '501 Not Implemented'}) =>
      HttpException(message: message, statusCode: 501);

  /// Throws a 503 Unavailable error.
  factory HttpException.unavailable({String message = '503 Unavailable'}) =>
      HttpException(message: message, statusCode: 503);
}
