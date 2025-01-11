import 'dart:convert';
import 'package:test/test.dart';
import 'package:notifications/notifications.dart';

void main() {
  group('TranslationManager', () {
    late TranslationManager manager;

    setUp(() {
      manager = TranslationManager(fallbackLocale: 'en');
    });

    test('loads translations from JSON', () {
      final json = jsonEncode({
        'en': {
          'welcome': 'Welcome!',
          'goodbye': 'Goodbye!',
        },
        'es': {
          'welcome': '¡Bienvenido!',
          'goodbye': '¡Adiós!',
        },
      });

      manager.loadFromJson(json);

      expect(manager.get('welcome', 'en'), equals('Welcome!'));
      expect(manager.get('welcome', 'es'), equals('¡Bienvenido!'));
    });

    test('falls back to fallback locale', () {
      manager.add('en', {
        'welcome': 'Welcome!',
      });

      // Try to get Spanish translation, should fall back to English
      expect(manager.get('welcome', 'es'), equals('Welcome!'));
    });

    test('falls back to key if no translation found', () {
      manager.add('en', {
        'welcome': 'Welcome!',
      });

      // Try to get non-existent key
      expect(manager.get('missing_key', 'en'), equals('missing_key'));
    });

    test('uses custom fallback string', () {
      manager.add('en', {
        'welcome': 'Welcome!',
      });

      // Try to get non-existent key with custom fallback
      expect(
          manager.get('missing_key', 'en', 'Not found'), equals('Not found'));
    });

    test('manages locales', () {
      expect(manager.hasLocale('en'), isFalse);

      manager.add('en', {'welcome': 'Welcome!'});
      expect(manager.hasLocale('en'), isTrue);

      manager.remove('en');
      expect(manager.hasLocale('en'), isFalse);
    });

    test('clears all translations', () {
      manager.add('en', {'welcome': 'Welcome!'});
      manager.add('es', {'welcome': '¡Bienvenido!'});

      manager.clear();

      expect(manager.hasLocale('en'), isFalse);
      expect(manager.hasLocale('es'), isFalse);
      expect(manager.locales, isEmpty);
    });

    test('lists available locales', () {
      manager.add('en', {'welcome': 'Welcome!'});
      manager.add('es', {'welcome': '¡Bienvenido!'});

      expect(manager.locales, containsAll(['en', 'es']));
    });

    test('handles invalid JSON', () {
      expect(
        () => manager.loadFromJson('invalid json'),
        throwsFormatException,
      );
    });

    test('handles invalid translation data', () {
      final json = jsonEncode({
        'en': 'not a map', // Should be a map of strings
      });

      manager.loadFromJson(json);
      expect(manager.hasLocale('en'), isFalse);
    });
  });
}
