import 'package:illuminate_translation/translation.dart';

void main() {
  // Reset any existing translator (useful when running examples multiple times)
  resetTranslator();

  // Set default locale
  setLocale('en');

  // Add translation files directory
  addJsonPath('translations');

  // Basic translation
  print(trans('messages.welcome')); // Hello!

  // Translation with replacements
  print(trans('messages.greeting', replace: {'name': 'John'})); // Hello, John!

  // Pluralization
  print(
      choice('messages.items', 1, replace: {'count': '1'})); // You have 1 item
  print(
      choice('messages.items', 2, replace: {'count': '2'})); // You have 2 items

  // Switch locale
  setLocale('es');
  print(trans('messages.welcome')); // ¡Hola!

  // With fallback
  setFallbackLocale('en');
  print(
      trans('messages.new_feature')); // Falls back to English if not in Spanish
}
