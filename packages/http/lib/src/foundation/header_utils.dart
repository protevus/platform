import 'dart:convert';

class HeaderUtils {
  static const String DISPOSITION_ATTACHMENT = 'attachment';
  static const String DISPOSITION_INLINE = 'inline';

  // This class should not be instantiated.
  HeaderUtils._();

  /// Splits an HTTP header by one or more separators.
  ///
  /// Example:
  ///
  ///     HeaderUtils.split('da, en-gb;q=0.8', ',;')
  ///     // => [['da'], ['en-gb', 'q=0.8']]
  ///
  /// @param String separators List of characters to split on, ordered by
  ///                           precedence, e.g. ',', ';=', or ',;='
  ///
  /// @return List<List<String>> Nested array with as many levels as there are characters in
  ///               separators
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
  /// Example:
  ///
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
  /// The key and value of each entry are joined with '=', and all entries
  /// are joined with the specified separator and an additional space (for
  /// readability). Values are quoted if necessary.
  ///
  /// Example:
  ///
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

  /// Encodes a string as a quoted string, if necessary.
  ///
  /// If a string contains characters not allowed by the "token" construct in
  /// the HTTP specification, it is backslash-escaped and enclosed in quotes
  /// to match the "quoted-string" construct.
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

static bool _isQuotingAllowed(String s) {
  final pattern = RegExp('^[a-zA-Z0-9!#\$%&\'*+\\-\\.^_`|~]+\$');
  return pattern.hasMatch(s);
}

  /// Decodes a quoted string.
  ///
  /// If passed an unquoted string that matches the "token" construct (as
  /// defined in the HTTP specification), it is passed through verbatim.
  static String unquote(String s) {
    return s.replaceAllMapped(RegExp(r'\\(.)|\"'), (match) => match[1] ?? '');
  }

  /// Generates an HTTP Content-Disposition field-value.
  ///
  /// @param String disposition      One of "inline" or "attachment"
  /// @param String filename         A unicode string
  /// @param String filenameFallback A string containing only ASCII characters that
  ///                                 is semantically equivalent to filename. If the filename is already ASCII,
  ///                                 it can be omitted, or just copied from filename
  ///
  /// @throws ArgumentError
  ///
  /// @see RFC 6266
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
