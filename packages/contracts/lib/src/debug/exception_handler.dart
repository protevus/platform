import 'dart:async';
import 'package:meta/meta.dart';

/// Interface for handling exceptions.
abstract class ExceptionHandler {
  /// Report or log an exception.
  ///
  /// @throws Exception
  FutureOr<void> report(Object error, [StackTrace? stackTrace]);

  /// Determine if the exception should be reported.
  bool shouldReport(Object error);

  /// Render an exception into an HTTP response.
  ///
  /// @throws Exception
  FutureOr<dynamic> render(dynamic request, Object error,
      [StackTrace? stackTrace]);

  /// Render an exception to the console.
  ///
  /// This method is not meant to be used or overwritten outside the framework.
  @protected
  void renderForConsole(dynamic output, Object error, [StackTrace? stackTrace]);
}
