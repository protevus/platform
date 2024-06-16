import 'package:symfony_http/symfony_http.dart' as symfony;
import 'package:illuminate_foundation/illuminate_foundation.dart';

// TODO: Find replacements for missing imports.

abstract class Kernel {
  /// Bootstrap the application for HTTP requests.
  void bootstrap();

  /// Handle an incoming HTTP request.
  ///
  /// @param symfony.Request request
  /// @return symfony.Response
  symfony.Response handle(symfony.Request request);

  /// Perform any final actions for the request lifecycle.
  ///
  /// @param symfony.Request request
  /// @param symfony.Response response
  void terminate(symfony.Request request, symfony.Response response);

  /// Get the application instance.
  ///
  /// @return Application
  Application getApplication();
}
