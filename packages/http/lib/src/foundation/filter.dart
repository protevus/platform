/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:core';
import 'dart:io';
import 'package:sanitize_html/sanitize_html.dart';
import 'package:email_validator/email_validator.dart';
import 'package:validator_dart/validator_dart.dart';

/// A class that provides various filtering and validation methods for input data.
///
/// This class is designed to replicate the functionality of PHP's filter_var functions in Dart.
/// It includes methods for validating and sanitizing different types of data such as
/// integers, floats, booleans, emails, URLs, and IP addresses.
///
/// The class contains several constant values that are used as flags and filter types,
/// mirroring the constants used in PHP's filter_var functions.
///
/// Key methods:
/// - [filterHasVar]: Checks if a variable of a specified type exists.
/// - [filterId]: Returns the filter ID corresponding to a named filter.
/// - [filterVar]: Filters a variable with a specified filter and options.
///
/// The class also includes several private helper methods for specific filtering tasks.
///
/// Usage example:
/// ```dart
/// var result = Filter.filterVar('test@example.com', Filter.FILTER_VALIDATE_EMAIL);
/// print(result); // Outputs: test@example.com
/// ```
///
/// Note: This class is intended to be used as a direct replacement for PHP's filter_var
/// functions in Dart applications, particularly useful for porting PHP code to Dart.
class Filter {
  // Constants
  static const int INPUT_POST = 0;
  static const int INPUT_GET = 1;
  static const int INPUT_COOKIE = 2;
  static const int INPUT_ENV = 4;
  static const int INPUT_SERVER = 5;
  static const int INPUT_SESSION = 6;
  static const int INPUT_REQUEST = 99;
  static const int FILTER_FLAG_NONE = 0;
  static const int FILTER_REQUIRE_SCALAR = 33554432;
  static const int FILTER_REQUIRE_ARRAY = 16777216;
  static const int FILTER_FORCE_ARRAY = 67108864;
  static const int FILTER_NULL_ON_FAILURE = 134217728;
  static const int FILTER_VALIDATE_INT = 257;
  static const int FILTER_VALIDATE_BOOLEAN = 258;
  static const int FILTER_VALIDATE_FLOAT = 259;
  static const int FILTER_VALIDATE_REGEXP = 272;
  static const int FILTER_VALIDATE_URL = 273;
  static const int FILTER_VALIDATE_EMAIL = 274;
  static const int FILTER_VALIDATE_IP = 275;
  static const int FILTER_DEFAULT = 516;
  static const int FILTER_UNSAFE_RAW = 516;
  static const int FILTER_SANITIZE_STRING = 513;
  static const int FILTER_SANITIZE_STRIPPED = 513;
  static const int FILTER_SANITIZE_ENCODED = 514;
  static const int FILTER_SANITIZE_SPECIAL_CHARS = 515;
  static const int FILTER_SANITIZE_EMAIL = 517;
  static const int FILTER_SANITIZE_URL = 518;
  static const int FILTER_SANITIZE_NUMBER_INT = 519;
  static const int FILTER_SANITIZE_NUMBER_FLOAT = 520;
  static const int FILTER_SANITIZE_MAGIC_QUOTES = 521;
  static const int FILTER_CALLBACK = 1024;
  static const int FILTER_FLAG_ALLOW_OCTAL = 1;
  static const int FILTER_FLAG_ALLOW_HEX = 2;
  static const int FILTER_FLAG_STRIP_LOW = 4;
  static const int FILTER_FLAG_STRIP_HIGH = 8;
  static const int FILTER_FLAG_ENCODE_LOW = 16;
  static const int FILTER_FLAG_ENCODE_HIGH = 32;
  static const int FILTER_FLAG_ENCODE_AMP = 64;
  static const int FILTER_FLAG_NO_ENCODE_QUOTES = 128;
  static const int FILTER_FLAG_EMPTY_STRING_NULL = 256;
  static const int FILTER_FLAG_ALLOW_FRACTION = 4096;
  static const int FILTER_FLAG_ALLOW_THOUSAND = 8192;
  static const int FILTER_FLAG_ALLOW_SCIENTIFIC = 16384;
  static const int FILTER_FLAG_PATH_REQUIRED = 262144;
  static const int FILTER_FLAG_QUERY_REQUIRED = 524288;
  static const int FILTER_FLAG_IPV4 = 1048576;
  static const int FILTER_FLAG_IPV6 = 2097152;
  static const int FILTER_FLAG_NO_RES_RANGE = 4194304;
  static const int FILTER_FLAG_NO_PRIV_RANGE = 8388608;

  /// Checks if a variable of the specified type exists.
  ///
  /// This method determines whether a variable with the given [variableName]
  /// exists for the specified input [type]. The input types are defined by
  /// constants in the Filter class (e.g., INPUT_GET, INPUT_POST, etc.).
  ///
  /// Parameters:
  /// - [type]: An integer representing the input type to check.
  /// - [variableName]: The name of the variable to check for existence.
  ///
  /// Returns:
  /// - [bool]: true if the variable exists for the given input type, false otherwise.
  ///
  /// Note:
  /// - For INPUT_POST and INPUT_COOKIE, the implementation is not yet complete.
  /// - For INPUT_GET, INPUT_SERVER, and INPUT_ENV, it checks the Platform.environment.
  /// - For other input types, it always returns false.
  static bool filterHasVar(int type, String variableName) {
    switch (type) {
      case INPUT_GET:
        return Platform.environment.containsKey(variableName);
      case INPUT_POST:
        // TODO: Implement POST variable check
        return false;
      case INPUT_COOKIE:
        // TODO: Implement COOKIE variable check
        return false;
      case INPUT_SERVER:
        return Platform.environment.containsKey(variableName);
      case INPUT_ENV:
        return Platform.environment.containsKey(variableName);
      default:
        return false;
    }
  }

  /// Returns the filter ID corresponding to a named filter.
  ///
  /// This method takes a [filterName] as input and returns the corresponding
  /// filter constant value. If no matching filter is found, it returns null.
  ///
  /// Parameters:
  /// - [filterName]: A string representing the name of the filter.
  ///
  /// Returns:
  /// - An integer representing the filter constant, or null if no match is found.
  ///
  /// Example:
  /// ```dart
  /// int? emailFilterId = Filter.filterId('validate_email');
  /// print(emailFilterId); // Outputs: 274 (FILTER_VALIDATE_EMAIL)
  /// ```
  static int? filterId(String filterName) {
    switch (filterName) {
      case 'int':
        return FILTER_VALIDATE_INT;
      case 'boolean':
        return FILTER_VALIDATE_BOOLEAN;
      case 'float':
        return FILTER_VALIDATE_FLOAT;
      case 'validate_regexp':
        return FILTER_VALIDATE_REGEXP;
      case 'validate_url':
        return FILTER_VALIDATE_URL;
      case 'validate_email':
        return FILTER_VALIDATE_EMAIL;
      case 'validate_ip':
        return FILTER_VALIDATE_IP;
      case 'string':
        return FILTER_SANITIZE_STRING;
      case 'stripped':
        return FILTER_SANITIZE_STRIPPED;
      case 'encoded':
        return FILTER_SANITIZE_ENCODED;
      case 'special_chars':
        return FILTER_SANITIZE_SPECIAL_CHARS;
      case 'unsafe_raw':
        return FILTER_UNSAFE_RAW;
      case 'email':
        return FILTER_SANITIZE_EMAIL;
      case 'url':
        return FILTER_SANITIZE_URL;
      case 'number_int':
        return FILTER_SANITIZE_NUMBER_INT;
      case 'number_float':
        return FILTER_SANITIZE_NUMBER_FLOAT;
      case 'magic_quotes':
        return FILTER_SANITIZE_MAGIC_QUOTES;
      case 'callback':
        return FILTER_CALLBACK;
      default:
        return null;
    }
  }

  /// Filters a variable with a specified filter and options.
  ///
  /// This method applies various filtering and validation techniques to the input [variable]
  /// based on the specified [filter] and [options]. It supports both scalar and array inputs,
  /// and can handle different types of filters such as validation and sanitization.
  ///
  /// Parameters:
  /// - [variable]: The input to be filtered. Can be a scalar value or an array.
  /// - [filter]: An integer constant representing the filter to be applied. Defaults to [FILTER_DEFAULT].
  /// - [options]: Additional options for the filter. Can be an integer (flags) or a Map containing 'flags' and 'options'.
  ///
  /// Returns:
  /// - The filtered variable if successful.
  /// - `false` if the filter fails and [FILTER_NULL_ON_FAILURE] is not set.
  /// - `null` if the filter fails and [FILTER_NULL_ON_FAILURE] is set.
  /// - An array of filtered values if the input is an array and [FILTER_REQUIRE_ARRAY] or [FILTER_FORCE_ARRAY] is set.
  ///
  /// This method supports various filter types including boolean validation, email validation,
  /// float and integer validation, IP and URL validation, regular expression matching,
  /// and various sanitization filters for emails, URLs, numbers, and special characters.
  ///
  /// The behavior of the filter can be modified using flags such as [FILTER_REQUIRE_ARRAY],
  /// [FILTER_FORCE_ARRAY], [FILTER_NULL_ON_FAILURE], among others.
  static dynamic filterVar(dynamic variable,
      [int filter = FILTER_DEFAULT, dynamic options = 0]) {
    int flags = 0;
    Map<String, dynamic> opts = {};

    if (!((filter >= 0x0200 && filter <= 0x020a) ||
        (filter >= 0x0100 && filter <= 0x0114) ||
        filter == FILTER_CALLBACK)) {
      return false;
    }

    if (options is Map<String, dynamic>) {
      if (options.containsKey('flags')) {
        flags = options['flags'] as int;
      }
      if (options.containsKey('options')) {
        opts = options['options'] as Map<String, dynamic>;
      }
    } else {
      flags = options as int;
    }

    if (variable is List) {
      if (!(flags & FILTER_REQUIRE_ARRAY != 0 ||
              flags & FILTER_FORCE_ARRAY != 0) ||
          flags & FILTER_REQUIRE_SCALAR != 0) {
        return (flags & FILTER_NULL_ON_FAILURE != 0) ? null : false;
      }

      int subFlags = flags;
      if (subFlags & FILTER_FORCE_ARRAY != 0) {
        subFlags ^= FILTER_FORCE_ARRAY;
      }
      if (subFlags & FILTER_REQUIRE_ARRAY != 0) {
        subFlags ^= FILTER_REQUIRE_ARRAY;
      }

      for (int i = 0; i < variable.length; i++) {
        variable[i] = filterVar(
            variable[i], filter, {'flags': subFlags, 'options': opts});
      }

      return variable;
    }

    if (flags & FILTER_REQUIRE_ARRAY != 0) {
      return (flags & FILTER_NULL_ON_FAILURE != 0) ? null : false;
    }

    if (variable is! String) {
      return (flags & FILTER_FORCE_ARRAY != 0) ? [false] : false;
    }

    String variableString = variable;

    switch (filter) {
      case FILTER_VALIDATE_BOOLEAN:
        return _filterBoolean(variableString, flags);
      case FILTER_VALIDATE_EMAIL:
        return _filterEmail(variableString, flags);
      case FILTER_VALIDATE_FLOAT:
        return _filterFloat(variableString, flags);
      case FILTER_VALIDATE_INT:
        return _filterInt(variableString, flags, opts);
      case FILTER_VALIDATE_IP:
        return _filterIp(variableString, flags);
      case FILTER_VALIDATE_URL:
        return _filterUrl(variableString, flags);
      case FILTER_VALIDATE_REGEXP:
        return _filterRegexp(variableString, flags, opts);
      case FILTER_SANITIZE_EMAIL:
        return _sanitizeEmail(variableString);
      case FILTER_SANITIZE_ENCODED:
        return Uri.encodeComponent(variableString);
      case FILTER_SANITIZE_MAGIC_QUOTES:
        return variableString
            .replaceAll("'", "\\'")
            .replaceAll('"', '\\"')
            .replaceAll('\\', '\\\\');
      case FILTER_SANITIZE_NUMBER_FLOAT:
        return _sanitizeNumberFloat(variableString, flags);
      case FILTER_SANITIZE_NUMBER_INT:
        return variableString.replaceAll(RegExp(r'[^\d-]'), '');
      case FILTER_SANITIZE_SPECIAL_CHARS:
        return _sanitizeSpecialChars(variableString, flags);
      // FILTER_SANITIZE_STRING and FILTER_SANITIZE_STRIPPED are equivalent
      case FILTER_SANITIZE_STRIPPED:
        return sanitizeHtml(variableString);
      case FILTER_SANITIZE_URL:
        return _sanitizeUrl(variableString);
      case FILTER_UNSAFE_RAW:
      default:
        return variableString;
    }
  }

  /// Filters a string variable to determine its boolean value.
  ///
  /// This method takes a string [variable] and optional [flags] as input. It
  /// checks if the string represents a valid boolean value using the
  /// [Validator.isBoolean] method. If the string is a valid boolean, it returns
  /// `true` for values like 'true', '1', 'on', or 'yes' (case-insensitive), and
  /// `false` otherwise. If the string is not a valid boolean and the
  /// [FILTER_NULL_ON_FAILURE] flag is set, it returns `null`. If the flag is not
  /// set, it returns `false`.
  ///
  /// Parameters:
  /// - [variable]: The string variable to filter as a boolean.
  /// - [flags]: Optional flags to modify the behavior of the filter.
  ///
  /// Returns:
  /// - [bool]: The boolean value of the string, or `null` if the string is not a
  ///   valid boolean and the [FILTER_NULL_ON_FAILURE] flag is set.
  static dynamic _filterBoolean(String variable, int flags) {
    if (Validator.isBoolean(variable)) {
      return ['true', '1', 'on', 'yes'].contains(variable.toLowerCase());
    } else if (flags & FILTER_NULL_ON_FAILURE != 0) {
      return null;
    } else {
      return false;
    }
  }

  /// Filters and validates an email address string.
  ///
  /// This method takes a string [variable] representing an email address and
  /// optional [flags] as input. It uses the [EmailValidator] to check if the
  /// provided string is a valid email address.
  ///
  /// Parameters:
  /// - [variable]: The string to be validated as an email address.
  /// - [flags]: Optional flags to modify the behavior of the filter.
  ///
  /// Returns:
  /// - If the email is valid, it returns the original [variable].
  /// - If the email is invalid and the [FILTER_NULL_ON_FAILURE] flag is set,
  ///   it returns `null`.
  /// - If the email is invalid and the [FILTER_NULL_ON_FAILURE] flag is not set,
  ///   it returns `false`.
  ///
  /// The method uses the [EmailValidator.validate] function to perform the
  /// email validation.
  static dynamic _filterEmail(String variable, int flags) {
    if (EmailValidator.validate(variable)) {
      return variable;
    } else if (flags & FILTER_NULL_ON_FAILURE != 0) {
      return null;
    } else {
      return false;
    }
  }

  /// Filters and validates a string variable as a float.
  ///
  /// This method takes a string [variable] and optional [flags] as input.
  /// It attempts to parse the string as a float value, considering the
  /// provided flags.
  ///
  /// Parameters:
  /// - [variable]: The string to be filtered and validated as a float.
  /// - [flags]: Optional flags to modify the behavior of the filter.
  ///
  /// Returns:
  /// - If the string is a valid float, it returns the parsed [double] value.
  /// - If the string is not a valid float and the [FILTER_NULL_ON_FAILURE] flag
  ///   is set, it returns `null`.
  /// - If the string is not a valid float and the [FILTER_NULL_ON_FAILURE] flag
  ///   is not set, it returns `false`.
  ///
  /// The method trims the input string and, if [FILTER_FLAG_ALLOW_THOUSAND] is set,
  /// removes commas from the string before parsing. It uses [Validator.isFloat]
  /// to check if the string represents a valid float.
  static dynamic _filterFloat(String variable, int flags) {
    variable = variable.trim();
    if (flags & FILTER_FLAG_ALLOW_THOUSAND != 0) {
      variable = variable.replaceAll(',', '');
    }
    if (Validator.isFloat(variable)) {
      return double.parse(variable);
    } else if (flags & FILTER_NULL_ON_FAILURE != 0) {
      return null;
    } else {
      return false;
    }
  }

  /// Filters and validates a string variable as an integer.
  ///
  /// This method takes a string [variable], optional [flags], and [opts] as input.
  /// It attempts to parse the string as an integer value, considering the
  /// provided flags and options.
  ///
  /// Parameters:
  /// - [variable]: The string to be filtered and validated as an integer.
  /// - [flags]: Optional flags to modify the behavior of the filter.
  /// - [opts]: A map of additional options, such as 'min_range' and 'max_range'.
  ///
  /// Returns:
  /// - If the string is a valid integer within the specified range (if any),
  ///   it returns the parsed [int] value.
  /// - If the string is not a valid integer or is out of the specified range,
  ///   and the [FILTER_NULL_ON_FAILURE] flag is set, it returns `null`.
  /// - If the string is not a valid integer or is out of the specified range,
  ///   and the [FILTER_NULL_ON_FAILURE] flag is not set, it returns `false`.
  ///
  /// The method supports parsing hexadecimal (with '0x' prefix) and octal
  /// (with '0' prefix) numbers if the corresponding flags are set.
  static dynamic _filterInt(
      String variable, int flags, Map<String, dynamic> opts) {
    variable = variable.trim();
    int? value;

    if (flags & FILTER_FLAG_ALLOW_HEX != 0 &&
        RegExp(r'^0x[0-9a-f]+$', caseSensitive: false).hasMatch(variable)) {
      value = int.tryParse(variable.substring(2), radix: 16);
    } else if (flags & FILTER_FLAG_ALLOW_OCTAL != 0 &&
        RegExp(r'^0[0-7]+$').hasMatch(variable)) {
      value = int.tryParse(variable.substring(1), radix: 8);
    } else {
      value = int.tryParse(variable);
    }

    if (value != null) {
      if (opts.containsKey('min_range') && value < opts['min_range']) {
        return (flags & FILTER_NULL_ON_FAILURE != 0) ? null : false;
      }
      if (opts.containsKey('max_range') && value > opts['max_range']) {
        return (flags & FILTER_NULL_ON_FAILURE != 0) ? null : false;
      }
      return value;
    } else if (flags & FILTER_NULL_ON_FAILURE != 0) {
      return null;
    } else {
      return false;
    }
  }

  /// Filters and validates an IP address string.
  ///
  /// This method takes a string [variable] representing an IP address and
  /// [flags] as input. It validates the IP address based on the provided flags
  /// and returns the result.
  ///
  /// Parameters:
  /// - [variable]: The string to be validated as an IP address.
  /// - [flags]: Flags to modify the behavior of the filter.
  ///
  /// Returns:
  /// - If the IP is valid and passes all flag checks, it returns the original [variable].
  /// - If the IP is invalid or fails flag checks, and the [FILTER_NULL_ON_FAILURE] flag is set,
  ///   it returns `null`.
  /// - If the IP is invalid or fails flag checks, and the [FILTER_NULL_ON_FAILURE] flag is not set,
  ///   it returns `false`.
  ///
  /// The method supports IPv4 and IPv6 validation, and can check for private and reserved IP ranges.
  /// Use [FILTER_FLAG_IPV4] and [FILTER_FLAG_IPV6] flags to specify IP version(s) to validate.
  /// Use [FILTER_FLAG_NO_PRIV_RANGE] to disallow private IP ranges.
  /// Use [FILTER_FLAG_NO_RES_RANGE] to disallow reserved IP ranges.
  static dynamic _filterIp(String variable, int flags) {
    bool isIPv4 = flags & FILTER_FLAG_IPV4 != 0;
    bool isIPv6 = flags & FILTER_FLAG_IPV6 != 0;

    if ((isIPv4 && _isIPv4(variable)) || (isIPv6 && _isIPv6(variable))) {
      if (flags & FILTER_FLAG_NO_PRIV_RANGE != 0 && _isPrivateIP(variable)) {
        return (flags & FILTER_NULL_ON_FAILURE != 0) ? null : false;
      }
      if (flags & FILTER_FLAG_NO_RES_RANGE != 0 && _isReservedIP(variable)) {
        return (flags & FILTER_NULL_ON_FAILURE != 0) ? null : false;
      }
      return variable;
    } else if (flags & FILTER_NULL_ON_FAILURE != 0) {
      return null;
    } else {
      return false;
    }
  }

  /// Checks if the given string is a valid IPv4 address.
  ///
  /// This method uses the [Validator.isIP] function to validate the IP address
  /// and additionally checks if it contains a dot (.) to ensure it's IPv4.
  ///
  /// Parameters:
  /// - [ip]: A string representing the IP address to check.
  ///
  /// Returns:
  /// - [bool]: true if the string is a valid IPv4 address, false otherwise.
  static bool _isIPv4(String ip) {
    return Validator.isIP(ip) && ip.contains('.');
  }

  /// Checks if the given string is a valid IPv6 address.
  ///
  /// This method uses the [Validator.isIP] function to validate the IP address
  /// and additionally checks if it contains a colon (:) to ensure it's IPv6.
  ///
  /// Parameters:
  /// - [ip]: A string representing the IP address to check.
  ///
  /// Returns:
  /// - [bool]: true if the string is a valid IPv6 address, false otherwise.
  static bool _isIPv6(String ip) {
    return Validator.isIP(ip) && ip.contains(':');
  }

  /// Checks if the given IP address is a private IP address.
  ///
  /// This method determines whether the provided IP address falls within
  /// the ranges reserved for private networks as defined by RFC 1918 for IPv4
  /// and RFC 4193 for IPv6.
  ///
  /// For IPv4, it checks the following private ranges:
  /// - 10.0.0.0 to 10.255.255.255
  /// - 172.16.0.0 to 172.31.255.255
  /// - 192.168.0.0 to 192.168.255.255
  ///
  /// For IPv6, it checks if the address starts with 'FD' or 'FC' (case-insensitive),
  /// which indicates a Unique Local Address (ULA).
  ///
  /// Parameters:
  /// - [ip]: A string representing the IP address to check.
  ///
  /// Returns:
  /// - [bool]: true if the IP address is private, false otherwise.
  ///
  /// Note: This method assumes that the input has already been validated as a
  /// valid IP address using [_isIPv4] or [_isIPv6].
  static bool _isPrivateIP(String ip) {
    if (_isIPv4(ip)) {
      List<String> octets = ip.split('.');
      int first = int.parse(octets[0]);
      int second = int.parse(octets[1]);
      return (first == 10) ||
          (first == 172 && second >= 16 && second <= 31) ||
          (first == 192 && second == 168);
    } else if (_isIPv6(ip)) {
      // For IPv6, we'll check if it starts with FD or FC
      return ip.toLowerCase().startsWith('fd') ||
          ip.toLowerCase().startsWith('fc');
    }
    return false;
  }

  /// Checks if the given IP address is a reserved IP address.
  ///
  /// This method determines whether the provided IP address falls within
  /// the ranges reserved for special use as defined by various RFCs.
  ///
  /// For IPv4, it checks the following reserved ranges:
  /// - 0.0.0.0 to 0.255.255.255 (Current network)
  /// - 127.0.0.0 to 127.255.255.255 (Loopback)
  /// - 224.0.0.0 to 255.255.255.255 (Multicast and Reserved)
  ///
  /// For IPv6, it checks:
  /// - Addresses starting with 'FF' (Multicast)
  /// - The loopback address '::1'
  ///
  /// Parameters:
  /// - [ip]: A string representing the IP address to check.
  ///
  /// Returns:
  /// - [bool]: true if the IP address is reserved, false otherwise.
  ///
  /// Note: This method assumes that the input has already been validated as a
  /// valid IP address using [_isIPv4] or [_isIPv6].
  static bool _isReservedIP(String ip) {
    if (_isIPv4(ip)) {
      List<String> octets = ip.split('.');
      int first = int.parse(octets[0]);
      return (first == 0) || (first == 127) || (first >= 224 && first <= 255);
    } else if (_isIPv6(ip)) {
      return ip.toLowerCase().startsWith('ff') || ip == '::1';
    }
    return false;
  }

  /// Filters and validates a URL string.
  ///
  /// This method takes a string [variable] representing a URL and optional [flags]
  /// as input. It uses the [Validator.isURL] method to check if the provided string
  /// is a valid URL. If the URL is valid, it further checks for specific path and
  /// query requirements based on the provided flags.
  ///
  /// Parameters:
  /// - [variable]: The string to be validated as a URL.
  /// - [flags]: Optional flags to modify the behavior of the filter.
  ///
  /// Returns:
  /// - If the URL is valid and meets all flag requirements, it returns the original [variable].
  /// - If the URL is invalid or doesn't meet flag requirements, and the [FILTER_NULL_ON_FAILURE]
  ///   flag is set, it returns `null`.
  /// - If the URL is invalid or doesn't meet flag requirements, and the [FILTER_NULL_ON_FAILURE]
  ///   flag is not set, it returns `false`.
  ///
  /// The method supports the following flags:
  /// - [FILTER_FLAG_PATH_REQUIRED]: Requires the URL to have a non-empty path.
  /// - [FILTER_FLAG_QUERY_REQUIRED]: Requires the URL to have a non-empty query string.
  /// - [FILTER_NULL_ON_FAILURE]: Returns null instead of false on failure.
  static dynamic _filterUrl(String variable, int flags) {
    if (Validator.isURL(variable)) {
      Uri parsedUrl = Uri.parse(variable);
      if ((flags & FILTER_FLAG_PATH_REQUIRED != 0 && parsedUrl.path.isEmpty) ||
          (flags & FILTER_FLAG_QUERY_REQUIRED != 0 &&
              parsedUrl.query.isEmpty)) {
        return (flags & FILTER_NULL_ON_FAILURE != 0) ? null : false;
      }
      return variable;
    } else if (flags & FILTER_NULL_ON_FAILURE != 0) {
      return null;
    } else {
      return false;
    }
  }

  /// Filters a string variable using a regular expression.
  ///
  /// This method takes a string [variable], [flags], and [opts] as input.
  /// It attempts to match the [variable] against a regular expression
  /// provided in the [opts] map.
  ///
  /// Parameters:
  /// - [variable]: The string to be filtered using the regular expression.
  /// - [flags]: Optional flags to modify the behavior of the filter.
  /// - [opts]: A map of options, which should include a 'regexp' key with
  ///   a non-empty regular expression string as its value.
  ///
  /// Returns:
  /// - If the regular expression matches the [variable], it returns the original [variable].
  /// - If the regular expression doesn't match, or if 'regexp' is missing from [opts],
  ///   and the [FILTER_NULL_ON_FAILURE] flag is set, it returns `null`.
  /// - If the regular expression doesn't match, or if 'regexp' is missing from [opts],
  ///   and the [FILTER_NULL_ON_FAILURE] flag is not set, it returns `false`.
  ///
  /// The method prints a warning if the 'regexp' option is missing from [opts].
  static dynamic _filterRegexp(
      String variable, int flags, Map<String, dynamic> opts) {
    if (opts.containsKey('regexp') && opts['regexp'].isNotEmpty) {
      if (RegExp(opts['regexp']).hasMatch(variable)) {
        return variable;
      }
    } else {
      print("Warning: 'regexp' option missing");
    }
    return (flags & FILTER_NULL_ON_FAILURE != 0) ? null : false;
  }

  /// Sanitizes an email address string by removing invalid characters.
  ///
  /// This method takes a [variable] string representing an email address and
  /// filters out any characters that are not typically allowed in email addresses.
  ///
  /// Parameters:
  /// - [variable]: The string to be sanitized as an email address.
  ///
  /// Returns:
  /// - A sanitized string containing only valid email address characters.
  ///
  /// The method uses a predefined set of valid characters including:
  /// - Lowercase and uppercase letters (a-z, A-Z)
  /// - Numbers (0-9)
  /// - Special characters commonly allowed in email addresses:
  ///   !#$%&'*+-/=?^_`{|}~@.[]
  ///
  /// Any character not in this set is removed from the input string.
  static String _sanitizeEmail(String variable) {
    const validChars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#\$%&\'*+-/=?^_`{|}~@.[]';
    return variable
        .split('')
        .where((char) => validChars.contains(char))
        .join('');
  }

  /// Sanitizes a string representation of a floating-point number.
  ///
  /// This method takes a [variable] string representing a number and [flags] to
  /// control the sanitization process. It removes all characters that are not
  /// typically part of a floating-point number representation.
  ///
  /// Parameters:
  /// - [variable]: The string to be sanitized as a floating-point number.
  /// - [flags]: Integer flags to control which parts of the number to allow.
  ///
  /// Returns:
  /// - A sanitized string containing only characters valid for the specified
  ///   floating-point number format.
  ///
  /// The method supports the following flags:
  /// - [FILTER_FLAG_ALLOW_FRACTION]: If set, allows decimal points in the result.
  /// - [FILTER_FLAG_ALLOW_THOUSAND]: If set, allows comma as a thousand separator.
  /// - [FILTER_FLAG_ALLOW_SCIENTIFIC]: If set, allows 'e' or 'E' for scientific notation.
  ///
  /// If a flag is not set, the corresponding feature (fraction, thousand separator,
  /// or scientific notation) will be removed from the result.
  static String _sanitizeNumberFloat(String variable, int flags) {
    String result = variable.replaceAll(RegExp(r'[^\d+\-.,eE]'), '');
    if (flags & FILTER_FLAG_ALLOW_FRACTION == 0) {
      result = result.replaceAll('.', '');
    }
    if (flags & FILTER_FLAG_ALLOW_THOUSAND == 0) {
      result = result.replaceAll(',', '');
    }
    if (flags & FILTER_FLAG_ALLOW_SCIENTIFIC == 0) {
      result = result.replaceAll(RegExp(r'[eE]'), '');
    }
    return result;
  }

  /// Sanitizes a string by handling special characters based on provided flags.
  ///
  /// This method takes a [variable] string and a set of [flags] to control
  /// how special characters should be handled. It uses [sanitizeHtml] as an
  /// initial sanitization step and then applies additional transformations
  /// based on the provided flags.
  ///
  /// Parameters:
  /// - [variable]: The string to be sanitized.
  /// - [flags]: An integer representing bitwise flags to control sanitization.
  ///
  /// Returns:
  /// - A sanitized string with special characters handled according to the flags.
  ///
  /// The method supports the following flags:
  /// - [FILTER_FLAG_STRIP_LOW]: Removes characters with ASCII values 0-31.
  /// - [FILTER_FLAG_STRIP_HIGH]: Removes characters with ASCII values 127-255.
  /// - [FILTER_FLAG_ENCODE_LOW]: Encodes characters with ASCII values 0-31 to HTML entities.
  /// - [FILTER_FLAG_ENCODE_HIGH]: Encodes characters with ASCII values 127-255 to HTML entities.
  /// - [FILTER_FLAG_ENCODE_AMP]: Encodes ampersands to '&#38;'.
  /// - [FILTER_FLAG_NO_ENCODE_QUOTES]: Prevents encoding of single and double quotes.
  ///
  /// Note: This method first applies [sanitizeHtml] and then processes the result
  /// based on the provided flags.
  static String _sanitizeSpecialChars(String variable, int flags) {
    String result = sanitizeHtml(variable);
    if (flags & FILTER_FLAG_STRIP_LOW != 0) {
      result = result.replaceAll(RegExp(r'[\x00-\x1F]'), '');
    }
    if (flags & FILTER_FLAG_STRIP_HIGH != 0) {
      result = result.replaceAll(RegExp(r'[\x7F-\xFF]'), '');
    }
    if (flags & FILTER_FLAG_ENCODE_LOW != 0) {
      result = result.replaceAllMapped(
          RegExp(r'[\x00-\x1F]'), (Match m) => '&#${m[0]!.codeUnitAt(0)};');
    }
    if (flags & FILTER_FLAG_ENCODE_HIGH != 0) {
      result = result.replaceAllMapped(
          RegExp(r'[\x7F-\xFF]'), (Match m) => '&#${m[0]!.codeUnitAt(0)};');
    }
    if (flags & FILTER_FLAG_ENCODE_AMP != 0) {
      result = result.replaceAll('&', '&#38;');
    }
    if (flags & FILTER_FLAG_NO_ENCODE_QUOTES != 0) {
      result = result.replaceAll('&#39;', "'").replaceAll('&#34;', '"');
    }
    return result;
  }

  /// Sanitizes a URL string by removing invalid characters.
  ///
  /// This method takes a [variable] string representing a URL and filters out
  /// any characters that are not typically allowed in URLs according to RFC 3986.
  ///
  /// Parameters:
  /// - [variable]: The string to be sanitized as a URL.
  ///
  /// Returns:
  /// - A sanitized string containing only valid URL characters.
  ///
  /// The method uses a predefined set of valid characters including:
  /// - Lowercase and uppercase letters (a-z, A-Z)
  /// - Numbers (0-9)
  /// - Special characters allowed in URLs: -._~:/?#[]@!$&'()*+,;=
  ///
  /// Any character not in this set is removed from the input string.
  static String _sanitizeUrl(String variable) {
    const validChars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~:/?#[]@!\$&\'()*+,;=';
    return variable
        .split('')
        .where((char) => validChars.contains(char))
        .join('');
  }
}
