import 'package:platform_core/core.dart';
import 'package:platform_core/http.dart';
import 'package:platform_support/providers.dart';

/// Example service that will be provided
class ExampleService {
  final String message;
  ExampleService(this.message);

  void printMessage() {
    print(message);
  }
}

/// Example service provider that demonstrates the basic features
class ExampleServiceProvider extends ServiceProvider {
  @override
  void register() {
    super.register();
    // Register a singleton service
    singleton(ExampleService('Hello from ExampleService!'));

    // Register an event listener
    listen('app.started', (req, res) {
      var service = make<ExampleService>();
      service.printMessage();
      return true;
    });
  }

  @override
  List<String> provides() => ['example-service'];
}

/// Example deferred service provider that demonstrates lazy loading
class DeferredExampleProvider extends DeferredServiceProvider {
  @override
  void register() {
    super.register();
    singleton(ExampleService('Hello from DeferredService!'));
  }

  @override
  List<String> provides() => ['deferred-service'];

  @override
  List<String> dependencies() => ['example-service'];
}

void main() async {
  // Create the application
  var app = Application();

  // Register the service providers
  app.registerProvider(ExampleServiceProvider());
  app.registerProvider(DeferredExampleProvider());

  // The ExampleServiceProvider will be booted immediately
  // The DeferredExampleProvider will only be booted when needed

  // Later, when we need the deferred service:
  await app.resolveProvider('deferred-service');

  // Create and start the HTTP server
  var http = PlatformHttp(app);
  await http.startServer('127.0.0.1', 3000);
}
