import 'package:platform_core/core.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_core/src/provider/platform_with_providers.dart';

class TestSetup {
  late Application app;
  late PlatformWithProviders platformWithProviders;
  late Container _container;

  Container get container => _container;

  Future<void> initialize() async {
    app = Application();

    // Create a container with MirrorsReflector
    _container = Container(MirrorsReflector());

    // Initialize PlatformWithProviders
    platformWithProviders = PlatformWithProviders(app);

    // Configure the app to use our container
    app.configure((angel) {
      // Instead of registering the container, we'll replace Angel's container
      angel.container = _container;
    });

    // Allow some time for initialization
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> tearDown() async {
    await app.close();
  }
}
