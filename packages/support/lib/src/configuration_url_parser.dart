/// A class to parse configuration URLs into their components.
class ConfigurationUrlParser {
  /// Parse a configuration URL into its components.
  static Map<String, dynamic> parse(String url) {
    final result = <String, dynamic>{
      'driver': null,
      'host': null,
      'port': null,
      'database': null,
      'username': null,
      'password': null,
      'options': <String, dynamic>{},
    };

    // Handle empty or null URLs
    if (url.isEmpty) {
      return result;
    }

    // Split URL into scheme and the rest
    final parts = url.split('://');
    if (parts.isEmpty || parts[0].isEmpty) {
      return result;
    }

    // Get the driver/scheme
    result['driver'] = parts[0];

    // If only scheme is provided, return early
    if (parts.length == 1) {
      return result;
    }

    // Parse the rest of the URL
    var rest = parts[1];

    // Extract credentials if present
    if (rest.contains('@')) {
      final credentialsParts = rest.split('@');
      final credentials = credentialsParts[0];
      rest = credentialsParts[1];

      // Parse username and password
      if (credentials.contains(':')) {
        final credentialParts = credentials.split(':');
        result['username'] = _decodeComponent(credentialParts[0]);
        result['password'] = _decodeComponent(credentialParts[1]);
      } else {
        result['username'] = _decodeComponent(credentials);
      }
    }

    // Parse host and port
    if (rest.contains('/')) {
      final hostParts = rest.split('/');
      _parseHostAndPort(hostParts[0], result);
      rest = hostParts.sublist(1).join('/');
    } else {
      _parseHostAndPort(rest, result);
      rest = '';
    }

    // Parse database and options
    if (rest.isNotEmpty) {
      final databaseAndOptions = rest.split('?');
      result['database'] = _decodeComponent(databaseAndOptions[0]);

      // Parse options if present
      if (databaseAndOptions.length > 1) {
        result['options'] = _parseOptions(databaseAndOptions[1]);
      }
    }

    return result;
  }

  /// Parse host and port from a string.
  static void _parseHostAndPort(
      String hostString, Map<String, dynamic> result) {
    if (hostString.isEmpty) return;

    if (hostString.contains(':')) {
      final hostParts = hostString.split(':');
      result['host'] = hostParts[0].isEmpty ? null : hostParts[0];
      result['port'] = hostParts[1].isEmpty ? null : int.tryParse(hostParts[1]);
    } else {
      result['host'] = hostString;
    }
  }

  /// Parse options string into a map.
  static Map<String, dynamic> _parseOptions(String optionsString) {
    final options = <String, dynamic>{};
    final pairs = optionsString.split('&');

    for (final pair in pairs) {
      if (pair.isEmpty) continue;

      final keyValue = pair.split('=');
      final key = _decodeComponent(keyValue[0]);

      if (keyValue.length > 1) {
        final value = _decodeComponent(keyValue[1]);

        // Handle array values
        if (key.endsWith('[]')) {
          final arrayKey = key.substring(0, key.length - 2);
          options[arrayKey] ??= <String>[];
          (options[arrayKey] as List<String>).add(value);
        } else {
          // Handle boolean values
          if (value.toLowerCase() == 'true') {
            options[key] = true;
          } else if (value.toLowerCase() == 'false') {
            options[key] = false;
          } else if (value == '1') {
            options[key] = true;
          } else if (value == '0') {
            options[key] = false;
          } else {
            // Try to parse as number if possible
            final number = num.tryParse(value);
            options[key] = number ?? value;
          }
        }
      } else {
        options[key] = true;
      }
    }

    return options;
  }

  /// Format a configuration array into a URL string.
  static String format(Map<String, dynamic> config) {
    final buffer = StringBuffer();

    // Add driver/scheme
    if (config['driver'] != null) {
      buffer.write('${config['driver']}://');
    }

    // Add credentials if present
    if (config['username'] != null) {
      buffer.write(_encodeComponent(config['username'].toString()));
      if (config['password'] != null) {
        buffer.write(':${_encodeComponent(config['password'].toString())}');
      }
      buffer.write('@');
    }

    // Add host and port
    if (config['host'] != null) {
      buffer.write(config['host']);
      if (config['port'] != null) {
        buffer.write(':${config['port']}');
      }
    }

    // Add database
    if (config['database'] != null) {
      buffer.write('/${_encodeComponent(config['database'].toString())}');
    }

    // Add options
    final options = config['options'] as Map<String, dynamic>?;
    if (options != null && options.isNotEmpty) {
      buffer.write('?');
      var first = true;
      for (final entry in options.entries) {
        if (!first) buffer.write('&');
        first = false;

        if (entry.value is List) {
          var firstItem = true;
          for (final item in entry.value as List) {
            if (!firstItem) buffer.write('&');
            firstItem = false;
            buffer.write(
                '${_encodeComponent(entry.key)}[]=${_encodeComponent(item.toString())}');
          }
        } else {
          buffer.write(
              '${_encodeComponent(entry.key)}=${_encodeComponent(entry.value.toString())}');
        }
      }
    }

    return buffer.toString();
  }

  /// Decode a URL component.
  static String _decodeComponent(String component) {
    return Uri.decodeComponent(component.replaceAll('+', ' '));
  }

  /// Encode a URL component.
  static String _encodeComponent(String component) {
    return Uri.encodeComponent(component)
        .replaceAll('%20', '+')
        .replaceAll('!', '%21')
        .replaceAll('\'', '%27')
        .replaceAll('(', '%28')
        .replaceAll(')', '%29')
        .replaceAll('*', '%2A');
  }
}
