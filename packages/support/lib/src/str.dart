import 'dart:convert';
import 'dart:math';
import 'package:platform_macroable/platform_macroable.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// A class for string manipulation.
class Str with Macroable {
  /// The random number generator.
  static final Random _random = Random.secure();

  /// The UUID generator.
  static final Uuid _uuid = Uuid();

  /// Convert a value to camel case.
  static String camel(String value) {
    if (value.isEmpty) return value;

    // First convert to snake case to handle camelCase input
    value = snake(value);

    // Split by underscores and filter out empty strings
    final words = value.split('_').where((word) => word.isNotEmpty).toList();

    if (words.isEmpty) return '';

    // Convert first word to lowercase
    final firstWord = words.first.toLowerCase();

    // Convert remaining words to title case
    final remainingWords = words
        .skip(1)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');

    return firstWord + remainingWords;
  }

  /// Convert a value to studly caps case.
  static String studly(String value) {
    if (value.isEmpty) return value;

    // First convert to snake case to handle camelCase input
    value = snake(value);

    // Split by underscores and filter out empty strings
    final words = value.split('_').where((word) => word.isNotEmpty).toList();

    // Convert each word to title case
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');
  }

  /// Convert a string to snake case.
  static String snake(String value, [String separator = '_']) {
    if (value.isEmpty) return value;

    // Handle already snake_case strings
    if (value.contains(RegExp(r'[-_\s]'))) {
      return value.replaceAll(RegExp(r'[-\s]+'), separator).toLowerCase();
    }

    // Convert camelCase to snake_case
    value = value.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => '${separator}${match[0]!.toLowerCase()}');

    // Remove leading separator if present
    if (value.startsWith(separator)) {
      value = value.substring(1);
    }

    return value.toLowerCase();
  }

  /// Convert a string to kebab case.
  static String kebab(String value) {
    if (value.isEmpty) return value;

    // First convert to snake case with hyphen separator
    value = snake(value, '-');

    // Replace any remaining underscores with hyphens
    return value.replaceAll('_', '-');
  }

  /// Generate a random string.
  static String random([int length = 16]) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        length, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Convert the given string to title case.
  static String title(String value) {
    if (value.isEmpty) return value;

    // First convert to snake case to handle camelCase input
    value = snake(value);

    // Split by underscores and filter out empty strings
    final words = value.split('_').where((word) => word.isNotEmpty).toList();

    // Convert each word to title case and join with spaces
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Convert the given string to lower case.
  static String lower(String value) {
    return value.toLowerCase();
  }

  /// Convert the given string to upper case.
  static String upper(String value) {
    return value.toUpperCase();
  }

  /// Generate a URL friendly "slug" from a given string.
  static String slug(String value, {String separator = '-'}) {
    // Convert to ASCII and lowercase
    value = ascii(value).toLowerCase();

    // Remove all characters that are not alphanumeric or whitespace
    value = value.replaceAll(RegExp(r'[^\w\s-]'), '');

    // Replace whitespace and repeated separators with a single separator
    value = value.replaceAll(RegExp(r'[-\s_]+'), separator);

    // Remove leading/trailing separators
    return value.trim().replaceAll(RegExp('^-+|-+\$'), '');
  }

  /// Convert a string to its ASCII representation.
  static String ascii(String value) {
    // Basic Latin character mappings
    const Map<String, String> charMap = {
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'Å': 'A',
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'Ý': 'Y',
      'ý': 'y',
      'ÿ': 'y',
      'Ñ': 'N',
      'ñ': 'n',
      'Ç': 'C',
      'ç': 'c',
      'ß': 'ss',
      '©': '(c)',
      '®': '(r)',
      '™': '(tm)',
    };

    return value.replaceAllMapped(RegExp(r'[^\x00-\x7F]'), (match) {
      final char = match.group(0)!;
      return charMap[char] ?? '';
    });
  }

  /// Determine if a given string starts with a given substring.
  static bool startsWith(String haystack, dynamic needles) {
    if (needles is String) {
      return haystack.startsWith(needles);
    }

    if (needles is List<String>) {
      return needles.any((needle) => haystack.startsWith(needle));
    }

    return false;
  }

  /// Determine if a given string ends with a given substring.
  static bool endsWith(String haystack, dynamic needles) {
    if (needles is String) {
      return haystack.endsWith(needles);
    }

    if (needles is List<String>) {
      return needles.any((needle) => haystack.endsWith(needle));
    }

    return false;
  }

  /// Cap a string with a single instance of a given value.
  static String finish(String value, String cap) {
    return value.endsWith(cap) ? value : value + cap;
  }

  /// Begin a string with a single instance of a given value.
  static String start(String value, String prefix) {
    return value.startsWith(prefix) ? value : prefix + value;
  }

  /// Determine if a given string contains a given substring.
  static bool contains(String haystack, dynamic needles) {
    if (needles is String) {
      return haystack.contains(needles);
    }

    if (needles is List<String>) {
      return needles.any((needle) => haystack.contains(needle));
    }

    return false;
  }

  /// Return the length of the given string.
  static int length(String value) {
    return value.length;
  }

  /// Limit the number of characters in a string.
  static String limit(String value, int limit, [String end = '...']) {
    if (value.length <= limit) {
      return value;
    }

    return value.substring(0, limit) + end;
  }

  /// Convert the given string to base64.
  static String toBase64(String value) {
    return base64.encode(utf8.encode(value));
  }

  /// Convert the given base64 string back to a normal string.
  static String fromBase64(String value) {
    return utf8.decode(base64.decode(value));
  }

  /// Parse a Class[@]method style callback string into class and method.
  static List<String>? parseCallback(String callback,
      [String separator = '@']) {
    final segments = callback.split(separator);
    return segments.length == 2 ? segments : null;
  }

  /// Generate a UUID v4 string.
  static String uuid() {
    return _uuid.v4();
  }

  /// Format a string using named parameters.
  static String format(String value, Map<String, dynamic> params) {
    return value.replaceAllMapped(RegExp(r':(\w+)'), (match) {
      final key = match.group(1)!;
      return params[key]?.toString() ?? match.group(0)!;
    });
  }

  /// Mask a portion of a string with a repeated character.
  static String mask(String value, int start,
      [int? length, String mask = '*']) {
    if (value.isEmpty || start >= value.length) return value;

    final startIndex = start < 0 ? value.length + start : start;
    final endIndex = length != null ? startIndex + length : value.length;
    final maskLength = endIndex - startIndex;

    if (maskLength <= 0) return value;

    return value.substring(0, startIndex) +
        mask * maskLength +
        value.substring(endIndex);
  }

  /// Pad both sides of a string with another.
  static String padBoth(String value, int length, [String pad = ' ']) {
    final diff = length - value.length;
    if (diff <= 0) return value;

    final leftPad = (diff / 2).floor();
    final rightPad = diff - leftPad;

    return pad * leftPad + value + pad * rightPad;
  }

  /// Pad the left side of a string with another.
  static String padLeft(String value, int length, [String pad = ' ']) {
    final diff = length - value.length;
    if (diff <= 0) return value;

    return pad * diff + value;
  }

  /// Pad the right side of a string with another.
  static String padRight(String value, int length, [String pad = ' ']) {
    final diff = length - value.length;
    if (diff <= 0) return value;

    return value + pad * diff;
  }
}
