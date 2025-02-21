/// The View Package for the Protevus Platform.
///
/// This package provides a flexible and powerful templating system
/// inspired by Laravel's View system, adapted for Dart.
library illuminate_view;

import 'src/contracts/view.dart';
import 'src/engines/engine_resolver.dart';
import 'src/factory.dart';

export 'src/view.barrel.dart';

/// Create a new view factory instance with default configuration.
ViewFactory createViewFactory() {
  final engines = EngineResolver();
  final finder = FileViewFinder();
  return ViewFactoryImpl(engines, finder);
}
