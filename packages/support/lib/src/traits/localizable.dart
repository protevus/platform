import 'package:illuminate_container/container.dart';
import 'package:illuminate_support/src/fluent.dart';

/// A mixin that provides localization functionality.
///
/// This mixin allows classes to execute code with a specific locale while ensuring
/// the original locale is restored afterward, similar to Laravel's Localizable trait.
mixin Localizable {
  /// Run the callback with the given locale.
  ///
  /// This method temporarily changes the application's locale, executes the callback,
  /// and then restores the original locale. This ensures that the locale change is
  /// localized to just the callback execution.
  ///
  /// If no locale is provided (null), the callback is executed with the current locale.
  ///
  /// Parameters:
  ///   - [locale]: The locale to use during callback execution
  ///   - [callback]: The function to execute with the specified locale
  ///
  /// Returns:
  ///   The result of executing the callback
  ///
  /// Example:
  /// ```dart
  /// withLocale('es', () {
  ///   // Code here runs with Spanish locale
  ///   return someValue;
  /// });
  /// ```
  T withLocale<T>(String? locale, T Function() callback) {
    if (locale == null) {
      return callback();
    }

    // Get the current locale
    final config = container.make<Fluent>();
    final original = config['locale'] as String;

    try {
      // Set the new locale
      config['locale'] = locale;
      return callback();
    } finally {
      // Restore the original locale
      config['locale'] = original;
    }
  }

  /// Get the container instance.
  ///
  /// This is a helper method to access the container. In a real application,
  /// you would typically get this from your application's service container.
  Container get container => throw UnimplementedError(
      'You must implement the container getter to use Localizable');
}
