abstract class BindingRegistrar {
  /// Add a new route parameter binder.
  ///
  /// @param  String  key
  /// @param  String or Function  binder
  /// @return void
  void bind(String key, dynamic binder);

  /// Get the binding callback for a given binding.
  ///
  /// @param  String  key
  /// @return Function
  Function getBindingCallback(String key);
}
