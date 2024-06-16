import 'dart:async';

// TODO: Replace custom classes with dart equivalents.

abstract class ExceptionHandler {
  /// Report or log an exception.
  ///
  /// @param  Throwable  e
  /// @return void
  ///
  /// @throws Throwable
  Future<void> report(Exception e);

  /// Determine if the exception should be reported.
  ///
  /// @param  Throwable  e
  /// @return bool
  bool shouldReport(Exception e);

  /// Render an exception into an HTTP response.
  ///
  /// @param  Request  request
  /// @param  Throwable  e
  /// @return Response
  ///
  /// @throws Throwable
  Future<Response> render(Request request, Exception e);

  /// Render an exception to the console.
  ///
  /// @param  OutputInterface  output
  /// @param  Throwable  e
  /// @return void
  ///
  /// @internal This method is not meant to be used or overwritten outside the framework.
  void renderForConsole(OutputInterface output, Exception e);
}

class Request {
  // Add your request properties and methods here.
}

class Response {
  // Add your response properties and methods here.
}

class OutputInterface {
  // Add your output interface properties and methods here.
}
