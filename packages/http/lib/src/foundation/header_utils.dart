/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony HeaderUtils.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:convert';

class HeaderUtils {

  /// A constant string representing the "attachment" disposition type.
  ///
  /// This value is used in HTTP headers, particularly in the Content-Disposition
  /// header, to indicate that the content is expected to be downloaded and saved
  /// locally by the user agent, rather than being displayed inline in the browser.
  static const String DISPOSITION_ATTACHMENT = 'attachment';

  /// A constant string representing the "inline" disposition type.
  ///
  /// This value is used in HTTP headers, particularly in the Content-Disposition
  /// header, to indicate that the content is expected to be displayed inline
  /// in the browser, rather than being downloaded and saved locally.
  static const String DISPOSITION_INLINE = 'inline';

  /// Private constructor to prevent instantiation of the HeaderUtils class.
  ///
  /// This class is intended to be used as a utility class with static methods only.
  /// The underscore before the constructor name makes it private to this library.
  HeaderUtils._();

  /// Splits an HTTP header by one or more separators.
  ///
  /// This method parses a given HTTP header string and splits it into parts
  /// based on the provided separators. It handles quoted strings and tokens
  /// according to HTTP header specifications.
  ///
  /// Parameters:
  /// - [header]: The HTTP header string to be split.
  /// - [separators]: A string containing one or more separator characters.
  ///
  /// Returns:
  /// A List of Lists of Strings, where each inner List represents a part of
  /// the header split by the separators.
  ///
  /// Throws:
  /// - [ArgumentError] if [separators] is empty.
  ///
  /// Example:
  ///   HeaderUtils.split('da, en-gb;q=0.8', ',;')
  ///   // => [['da'], ['en-gb', 'q=0.8']]
  ///
  /// The method uses regular expressions to handle complex cases such as
  /// quoted strings and multiple separators. It preserves the structure of
  /// the original header while splitting it into logical parts.
  static List<List<String>> split(String header, String separators) {
    if (separators.isEmpty) {
      throw ArgumentError('At least one separator must be specified.');
    }

    final quotedSeparators = RegExp.escape(separators);

    final pattern = '''
      (?!\\s)
      (?:
        # quoted-string
        "(?:[^"\\\\]|\\\\.)*(?:"|\\\\|)"
      |
        # token
        [^"$quotedSeparators]+
      )+
      (?<!\\s)
      |
      # separator
      \\s*
      (?<separator>[$quotedSeparators])
      \\s*
    ''';

    final matches = RegExp(pattern, multiLine: true, dotAll: true, caseSensitive: false)
        .allMatches(header.trim())
        .toList();

    return _groupParts(matches, separators);
  }

  /// Combines an array of arrays into one associative array.
  ///
  /// Each of the nested arrays should have one or two elements. The first
  /// value will be used as the keys in the associative array, and the second
  /// will be used as the values, or true if the nested array only contains one
  /// element. Array keys are lowercased.
  ///
  /// Parameters:
  /// - [parts]: A List of Lists of Strings, where each inner List represents a part
  ///   to be combined into the associative array.
  ///
  /// Returns:
  /// A Map<String, dynamic> where the keys are the lowercased first elements of each
  /// inner List, and the values are either the second elements or true if there's no
  /// second element.
  ///
  /// Example:
  ///     HeaderUtils.combine([['foo', 'abc'], ['bar']])
  ///     // => {'foo': 'abc', 'bar': true}
  static Map<String, dynamic> combine(List<List<String>> parts) {
    final assoc = <String, dynamic>{};
    for (var part in parts) {
      final name = part[0].toLowerCase();
      final value = part.length > 1 ? part[1] : true;
      assoc[name] = value;
    }
    return assoc;
  }

  /// Joins an associative array into a string for use in an HTTP header.
  ///
  /// This method takes a Map of key-value pairs and joins them into a single string,
  /// suitable for use in an HTTP header. Each key-value pair is formatted as follows:
  /// - If the value is `true`, only the key is included.
  /// - Otherwise, the pair is formatted as "key=value", where the value is quoted if necessary.
  ///
  /// The formatted pairs are then joined with the specified separator and an additional space.
  ///
  /// Parameters:
  /// - [assoc]: A Map<String, dynamic> containing the key-value pairs to be joined.
  /// - [separator]: A String used to separate the formatted pairs in the output.
  ///
  /// Returns:
  /// A String representing the joined key-value pairs, suitable for use in an HTTP header.
  ///
  /// Example:
  ///     HeaderUtils.headerToString({'foo': 'abc', 'bar': true, 'baz': 'a b c'}, ',')
  ///     // => 'foo=abc, bar, baz="a b c"'
  static String headerToString(Map<String, dynamic> assoc, String separator) {
    final parts = <String>[];
    assoc.forEach((name, value) {
      if (value == true) {
        parts.add(name);
      } else {
        parts.add('$name=${quote(value.toString())}');
      }
    });
    return parts.join('$separator ');
  }

  /// Quotes a string for use in HTTP headers if necessary.
  ///
  /// This method takes a string and determines whether it needs to be quoted
  /// for use in HTTP headers. If quoting is necessary, it encloses the string
  /// in double quotes and escapes any existing double quotes within the string.
  ///
  /// Parameters:
  /// - [s]: The input string to be quoted if necessary.
  ///
  /// Returns:
  /// A String that is either:
  /// - The original string if it doesn't need quoting
  /// - The string enclosed in double quotes with internal quotes escaped
  /// - An empty quoted string ('""') if the input is an empty string
  ///
  /// Throws:
  /// - [ArgumentError] if the input string is null.
  ///
  /// Example:
  ///     quote('simple') // => 'simple'
  ///     quote('needs "quotes"') // => '"needs \"quotes\""'
  ///     quote('') // => '""'
  static String quote(String? s) {
  if (s == null) {
    throw ArgumentError('Input string cannot be null');
  }

  if (s.isEmpty) {
    return '""';
  }

  final isQuotingAllowed = _isQuotingAllowed(s);

  if (!isQuotingAllowed) {
    return '"${s.replaceAll('"', '\\"')}"';
  }

  return s;
}

/// Determines if a string can be used unquoted in HTTP headers.
///
/// This method checks if the given string consists only of characters
/// that are allowed in unquoted header values according to HTTP specifications.
///
/// Parameters:
/// - [s]: The string to be checked.
///
/// Returns:
/// - `true` if the string can be used unquoted in HTTP headers.
/// - `false` if the string needs to be quoted for use in HTTP headers.
///
/// The allowed characters are:
/// - Alphanumeric characters (a-z, A-Z, 0-9)
/// - The following special characters: !#$%&'*+-\.^_`|~
///
/// This method is typically used internally by other header-related functions
/// to determine whether a value needs quoting before being included in an HTTP header.
static bool _isQuotingAllowed(String s) {
  final pattern = RegExp('^[a-zA-Z0-9!#\$%&\'*+\\-\\.^_`|~]+\$');
  return pattern.hasMatch(s);
}

  /// Removes quotes and unescapes characters in a string.
  ///
  /// This method processes a string that may have been quoted or contain
  /// escaped characters. It performs the following operations:
  /// 1. Removes surrounding double quotes if present.
  /// 2. Unescapes any escaped characters (i.e., removes the backslash).
  ///
  /// Parameters:
  /// - [s]: The input string to be unquoted and unescaped.
  ///
  /// Returns:
  /// A String with quotes removed and escaped characters processed.
  ///
  /// Example:
  ///     unquote('"Hello \\"World\\""') // => 'Hello "World"'
  ///     unquote('No \\"quotes\\"') // => 'No "quotes"'
  static String unquote(String s) {
    return s.replaceAllMapped(RegExp(r'\\(.)|\"'), (match) => match[1] ?? '');
  }

  /// Generates an HTTP Content-Disposition header value.
  ///
  /// This method creates a properly formatted Content-Disposition header value
  /// based on the given disposition type and filename. It supports both ASCII
  /// and non-ASCII filenames, providing a fallback for older user agents.
  ///
  /// Parameters:
  /// - [disposition]: The disposition type, must be either "attachment" or "inline".
  /// - [filename]: The filename to be used in the Content-Disposition header.
  /// - [filenameFallback]: An optional ASCII-only fallback filename for older user agents.
  ///   If not provided, it defaults to the same value as [filename].
  ///
  /// Returns:
  /// A String representing the formatted Content-Disposition header value.
  ///
  /// Throws:
  /// - [ArgumentError] if:
  ///   - The disposition is neither "attachment" nor "inline".
  ///   - The filename fallback contains non-ASCII characters.
  ///   - The filename fallback contains the "%" character.
  ///   - Either filename or fallback contains "/" or "\" characters.
  ///
  /// @see RFC 6266
  ///
  /// Example:
  ///     makeDisposition('attachment', 'example.pdf')
  ///     // => 'attachment; filename="example.pdf"'
  ///
  ///     makeDisposition('inline', 'résumé.pdf', 'resume.pdf')
  ///     // => 'inline; filename="resume.pdf"; filename*=utf-8\'\'r%C3%A9sum%C3%A9.pdf'
  static String makeDisposition(String disposition, String filename, [String filenameFallback = '']) {
    if (![DISPOSITION_ATTACHMENT, DISPOSITION_INLINE].contains(disposition)) {
      throw ArgumentError('The disposition must be either "$DISPOSITION_ATTACHMENT" or "$DISPOSITION_INLINE".');
    }

    filenameFallback = filenameFallback.isEmpty ? filename : filenameFallback;

    if (!RegExp(r'^[\x20-\x7e]*$').hasMatch(filenameFallback)) {
      throw ArgumentError('The filename fallback must only contain ASCII characters.');
    }

    if (filenameFallback.contains('%')) {
      throw ArgumentError('The filename fallback cannot contain the "%" character.');
    }

    if (filename.contains('/') || filename.contains('\\') || filenameFallback.contains('/') || filenameFallback.contains('\\')) {
      throw ArgumentError('The filename and the fallback cannot contain the "/" and "\\" characters.');
    }

    final params = {'filename': filenameFallback};
    if (filename != filenameFallback) {
      params['filename*'] = "utf-8''${Uri.encodeComponent(filename)}";
    }

    return '$disposition; ${headerToString(params, ';')}';
  }

/// Like parse_str(), but preserves dots in variable names.
/// Parses a query string into a Map of key-value pairs.
///
/// This method takes a query string and converts it into a Map where the keys
/// are the query parameters and the values are their corresponding values.
///
/// Parameters:
/// - [query]: The query string to parse.
/// - [ignoreBrackets]: If true, treats square brackets as part of the parameter name.
///   Defaults to false.
/// - [separator]: The character used to separate key-value pairs in the query string.
///   Defaults to '&'.
///
/// Returns:
/// A Map<String, dynamic> where keys are the parameter names and values are the
/// corresponding parameter values.
///
/// If [ignoreBrackets] is false (default), the method handles parameters with square
/// brackets specially, decoding them from base64 and including the bracket content
/// in the resulting key.
///
/// Example:
///   parseQuery('foo=bar&baz=qux')
///   // => {'foo': 'bar', 'baz': 'qux'}
///
///   parseQuery('foo[]=bar&foo[]=baz', false, '&')
///   // => {'foo[]': 'bar', 'foo[]': 'baz'}
///
/// Note: This method includes some specific handling for the character '0' in keys
/// and values, truncating strings at this character. It also trims whitespace from
/// the left side of keys. This is like parse_str(), but preserves dots in variable names.
static Map<String, dynamic> parseQuery(String query, [bool ignoreBrackets = false, String separator = '&']) {
  final result = <String, dynamic>{};

  if (ignoreBrackets) {
    for (var item in query.split(separator)) {
      var parts = item.split('=');
      result[parts[0]] = Uri.decodeComponent(parts[1]);
    }
    return result;
  }

  for (var v in query.split(separator)) {
    var i = v.indexOf('0');
    if (i != -1) {
      v = v.substring(0, i);
    }

    i = v.indexOf('=');
    String k;
    if (i == -1) {
      k = Uri.decodeComponent(v);
      v = '';
    } else {
      k = Uri.decodeComponent(v.substring(0, i));
      v = v.substring(i + 1);
    }

    i = k.indexOf('0');
    if (i != -1) {
      k = k.substring(0, i);
    }

    k = k.trimLeft();

    i = k.indexOf('[');
    if (i == -1) {
      result[utf8.decode(base64.decode(k))] = Uri.decodeComponent(v);
    } else {
      result['${utf8.decode(base64.decode(k.substring(0, i)))}[${Uri.decodeComponent(k.substring(i + 1))}]'] = Uri.decodeComponent(v);
    }
  }

  return result;
}

  /// Groups parts of a header string based on specified separators.
  ///
  /// This recursive method processes a list of [RegExpMatch] objects, grouping them
  /// based on the provided [separators]. It handles nested structures in header strings.
  ///
  /// Parameters:
  /// - [matches]: A list of [RegExpMatch] objects representing parts of the header.
  /// - [separators]: A string containing characters used as separators.
  /// - [first]: A boolean indicating if this is the first call in the recursion (default: true).
  ///
  /// Returns:
  /// A List of Lists of Strings, where each inner List represents a grouped part of the header.
  ///
  /// The method works by:
  /// 1. Splitting the parts based on the first separator in the [separators] string.
  /// 2. Recursively processing subgroups if more separators are available.
  /// 3. Handling special cases for the last separator and quoted strings.
  ///
  /// This method is typically used internally by the [split] method to process complex
  /// header structures with multiple levels of separators.
  static List<List<String>> _groupParts(List<RegExpMatch> matches, String separators, [bool first = true]) {
    final separator = separators[0];
    separators = separators.substring(1);
    var i = 0;

    if (separators.isEmpty && !first) {
      final parts = <String>[''];

      for (var match in matches) {
        if (i == 0 && match.namedGroup('separator') != null) {
          i = 1;
          parts.add('');
        } else {
          parts[i] += unquote(match[0]!);
        }
      }

      return [parts];
    }

    final parts = <List<String>>[];
    final partMatches = <int, List<RegExpMatch>>{};

    for (var match in matches) {
      if (match.namedGroup('separator') == separator) {
        i++;
      } else {
        partMatches.putIfAbsent(i, () => []).add(match);
      }
    }

    for (var subMatches in partMatches.values) {
      if (separators.isEmpty) {
        final unquoted = unquote(subMatches[0][0]!);
        if (unquoted.isNotEmpty) {
          parts.add([unquoted]);
        }
      } else {
        final groupedParts = _groupParts(subMatches, separators, false);
        if (groupedParts.isNotEmpty) {
          parts.add(groupedParts.expand((element) => element).toList());
        }
      }
    }

    return parts;
  }
}
