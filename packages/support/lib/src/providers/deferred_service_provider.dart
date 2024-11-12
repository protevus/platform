import 'service_provider.dart';
import 'contracts/service_provider.dart';

/// A service provider that is loaded only when needed.
///
/// Deferred service providers are not loaded during the initial application boot
/// process. Instead, they are loaded only when one of their provided services is
/// actually needed by the application.
///
/// This aligns with Laravel's DeferrableProvider interface which requires only
/// the provides() method to indicate which services should trigger loading of
/// the provider.
abstract class DeferredServiceProvider extends ServiceProvider
    implements DeferrableProviderContract {
  @override
  bool isDeferred() => true;

  @override
  List<String> provides();
}
