/// Interface for route binding registration.
abstract class BindingRegistrar {
  /// Add a new route parameter binder.
  void bind(String key, dynamic binder);

  /// Get the binding callback for a given binding.
  Function getBindingCallback(String key);
}
