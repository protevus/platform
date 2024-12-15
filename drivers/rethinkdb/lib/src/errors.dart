part of '../platform_driver_rethinkdb.dart';

class RqlError implements Exception {
  String message;
  dynamic term;
  dynamic frames;

  RqlError(this.message, this.term, this.frames);

  @override
  toString() => "$runtimeType\n\n$message\n\n$term\n\n$frames";
}

class RqlClientError extends RqlError {
  RqlClientError(super.message, super.term, super.frames);
}

class RqlCompileError extends RqlError {
  RqlCompileError(super.message, super.term, super.frames);
}

class RqlRuntimeError extends RqlError {
  RqlRuntimeError(super.message, super.term, super.frames);
}

class RqlDriverError implements Exception {
  String message;
  RqlDriverError(this.message);

  @override
  toString() => message;
}

class ReqlInternalError extends RqlRuntimeError {
  ReqlInternalError(super.message, super.term, super.frames);
}

class ReqlResourceLimitError extends RqlRuntimeError {
  ReqlResourceLimitError(super.message, super.term, super.frames);
}

class ReqlQueryLogicError extends RqlRuntimeError {
  ReqlQueryLogicError(super.message, super.term, super.frames);
}

class ReqlNonExistenceError extends RqlRuntimeError {
  ReqlNonExistenceError(super.message, super.term, super.frames);
}

class ReqlOpFailedError extends RqlRuntimeError {
  ReqlOpFailedError(super.message, super.term, super.frames);
}

class ReqlOpIndeterminateError extends RqlRuntimeError {
  ReqlOpIndeterminateError(super.message, super.term, super.frames);
}

class ReqlUserError extends RqlRuntimeError {
  ReqlUserError(super.message, super.term, super.frames);
}

class ReqlPermissionError extends RqlRuntimeError {
  ReqlPermissionError(super.message, super.term, super.frames);
}
