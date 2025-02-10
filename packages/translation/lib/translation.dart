/// A Laravel-style translation package for Dart with full feature parity and API compatibility.
library platform_translation;

export 'src/contracts/loader.dart';
export 'src/loaders/file_loader.dart';
export 'src/loaders/web_loader.dart';
export 'src/message_selector.dart';
export 'src/translator.dart';

import 'package:meta/meta.dart';
import 'src/translator.dart';
import 'src/loaders/file_loader.dart';

/// Global translator instance.
Translator? _translator;

/// Get or create the global translator instance.
///
/// [paths] Optional paths to load translations from
/// [locale] Optional locale to use (defaults to 'en')
/// [fallback] Optional fallback locale
Translator translator({
  List<String> paths = const [],
  String locale = 'en',
  String? fallback,
}) {
  _translator ??= Translator(FileLoader(paths), locale)..fallback = fallback;
  return _translator!;
}

/// Set the global translator instance.
///
/// [newTranslator] The translator instance to use globally
void setTranslator(Translator newTranslator) {
  _translator = newTranslator;
}

/// Get the translation for the given key.
///
/// [key] The translation key to look up
/// [replace] Parameters to replace in the translation string
/// [locale] Optional locale to use instead of the default
/// [fallback] Whether to attempt fallback locales if translation is missing
String trans(
  String key, {
  Map<String, dynamic> replace = const {},
  String? locale,
  bool fallback = true,
}) =>
    translator()
        .translate(key, replace: replace, locale: locale, fallback: fallback);

/// Get a translation according to an integer value.
///
/// [key] The translation key containing plural forms
/// [number] The number to determine which plural form to use
/// [replace] Parameters to replace in the translation string
/// [locale] Optional locale to use instead of the default
String choice(
  String key,
  num number, {
  Map<String, dynamic> replace = const {},
  String? locale,
}) =>
    translator().choice(key, number, replace: replace, locale: locale);

/// Set the default locale.
///
/// [locale] The locale to use as default
void setLocale(String locale) => translator().locale = locale;

/// Set the fallback locale.
///
/// [locale] The locale to use as fallback
void setFallbackLocale(String? locale) => translator().fallback = locale;

/// Add a new namespace to the loader.
///
/// [namespace] The namespace name (e.g. 'package-name')
/// [hint] The path to the namespace translations
void addNamespace(String namespace, String hint) =>
    translator().addNamespace(namespace, hint);

/// Add a new JSON path to the loader.
///
/// [path] The path to JSON translation files
void addJsonPath(String path) => translator().addJsonPath(path);

/// Add translation lines to the given locale.
///
/// [lines] Map of translation keys to their values
/// [locale] The locale to add translations for
/// [namespace] Optional namespace (defaults to '*')
void addLines(
  Map<String, String> lines,
  String locale, [
  String namespace = '*',
]) =>
    translator().addLines(lines, locale, namespace);

/// Reset the global translator instance.
///
/// This is mainly useful for testing.
@visibleForTesting
void resetTranslator() => _translator = null;
