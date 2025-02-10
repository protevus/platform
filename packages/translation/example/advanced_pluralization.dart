import 'package:illuminate_translation/translation.dart';

void main() {
  // Reset any existing translator
  resetTranslator();

  // Set initial locale
  setLocale('en');

  // Add translations directly for English
  addLines({
    // Basic pluralization
    'apples': 'apple|apples',

    // With explicit numbers
    'minutes': '{1} minute|[2,4] minutes|[5,*] many minutes',

    // With ranges
    'progress':
        '[0,20] Just started|[21,50] Getting there|[51,80] Almost done|[81,*] Nearly finished',

    // With replacements
    'cart':
        'You have :count item in your cart|You have :count items in your cart',
  }, 'en');

  // Russian pluralization example (1, 2-4, 5+)
  addLines({
    'files': 'файл|файла|файлов',
  }, 'ru');

  // Test basic pluralization
  print('\nBasic pluralization:');
  print(choice('apples', 1)); // apple
  print(choice('apples', 2)); // apples

  // Test explicit numbers and ranges
  print('\nExplicit numbers and ranges:');
  print(choice('minutes', 1)); // 1 minute
  print(choice('minutes', 3)); // minutes
  print(choice('minutes', 6)); // many minutes

  // Test progress ranges
  print('\nProgress ranges:');
  print(choice('progress', 15)); // Just started
  print(choice('progress', 35)); // Getting there
  print(choice('progress', 75)); // Almost done
  print(choice('progress', 90)); // Nearly finished

  // Test replacements with pluralization
  print('\nReplacements with pluralization:');
  print(choice('cart', 1,
      replace: {'count': '1'})); // You have 1 item in your cart
  print(choice('cart', 3,
      replace: {'count': '3'})); // You have 3 items in your cart

  // Test Russian pluralization
  print('\nRussian pluralization:');
  setLocale('ru');
  print(choice('files', 1)); // файл
  print(choice('files', 2)); // файла
  print(choice('files', 5)); // файлов
  print(choice('files', 21)); // файл
}
