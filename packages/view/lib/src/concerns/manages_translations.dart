import 'package:illuminate_translation/translation.dart';

/// A mixin that provides translation management functionality.
mixin ManagesTranslations {
  /// The translator instance.
  Translator get translator;

  /// The translation replacements for the current translation.
  final Map<String, dynamic> _translationReplacements = {};

  /// Start a translation block.
  void startTranslation([Map<String, dynamic> replacements = const {}]) {
    _translationReplacements.clear();
    _translationReplacements.addAll(replacements);
  }

  /// Render the current translation.
  String renderTranslation(String key) {
    return translator.translate(
      key,
      replace: _translationReplacements,
    );
  }

  /// Render a translation choice.
  String renderTranslationChoice(String key, num number) {
    return translator.choice(
      key,
      number,
      replace: _translationReplacements,
    );
  }

  /// Get a translation for a given key.
  String trans(String key, [Map<String, dynamic> replace = const {}]) {
    return translator.translate(key, replace: replace);
  }

  /// Get a translation choice for a given key.
  String transChoice(String key, num number,
      [Map<String, dynamic> replace = const {}]) {
    return translator.choice(key, number, replace: replace);
  }
}
