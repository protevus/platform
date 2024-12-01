import '../foundation/application.dart';

/// Interface for HTTP kernel.
abstract class Kernel {
  /// Bootstrap the application for HTTP requests.
  void bootstrap();

  /// Handle an incoming HTTP request.
  dynamic handle(dynamic request);

  /// Perform any final actions for the request lifecycle.
  void terminate(dynamic request, dynamic response);

  /// Get the application instance.
  Application getApplication();
}
