import 'package:platform_macroable/platform_macroable.dart';

/// A class for number manipulation.
class Number with Macroable {
  /// The underlying number value.
  final num _value;

  /// Static map to store macros
  static final Map<String, Function> _macros = {};

  /// Create a new number instance.
  Number(this._value);

  /// Register a custom macro.
  static void macro(String name, Function callback) {
    _macros[name] = callback;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString().split('"')[1];
    if (_macros.containsKey(name)) {
      return _macros[name]!(this);
    }
    return super.noSuchMethod(invocation);
  }

  /// Format a number with grouped thousands.
  ///
  /// Example:
  /// ```dart
  /// final number = Number(1234567.89);
  /// print(number.format()); // 1,234,567.89
  /// ```
  String format(
      [int decimals = 2,
      String decimalPoint = '.',
      String thousandsSeparator = ',']) {
    final parts = _value.toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousands separator
    final regex = RegExp(r'(\d{3})(?=\d)');
    var formatted = integerPart.split('').reversed.join();
    formatted = formatted.replaceAllMapped(
        regex, (match) => '${match.group(1)}$thousandsSeparator');
    formatted = formatted.split('').reversed.join();

    // Add decimal part if exists
    if (decimalPart.isNotEmpty) {
      formatted = '$formatted$decimalPoint$decimalPart';
    }

    return formatted;
  }

  /// Convert the number to its ordinal English form.
  ///
  /// Example:
  /// ```dart
  /// final number = Number(1);
  /// print(number.ordinal()); // 1st
  /// ```
  String ordinal() {
    final int number = _value.toInt();
    if ((number % 100) >= 11 && (number % 100) <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  /// Spell out a number in English.
  ///
  /// Example:
  /// ```dart
  /// final number = Number(123);
  /// print(number.spell()); // one hundred twenty-three
  /// ```
  String spell() {
    if (_value == 0) return 'zero';

    final units = [
      '',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'ten',
      'eleven',
      'twelve',
      'thirteen',
      'fourteen',
      'fifteen',
      'sixteen',
      'seventeen',
      'eighteen',
      'nineteen'
    ];
    final tens = [
      '',
      '',
      'twenty',
      'thirty',
      'forty',
      'fifty',
      'sixty',
      'seventy',
      'eighty',
      'ninety'
    ];
    final scales = ['', 'thousand', 'million', 'billion', 'trillion'];

    int number = _value.abs().toInt();
    if (number == 0) return 'zero';

    String words = '';
    int scaleIndex = 0;

    while (number > 0) {
      if (number % 1000 != 0) {
        final String space = words.isEmpty ? '' : ' ';
        words =
            '${_convertGroup(number % 1000, units, tens)}${scales[scaleIndex].isEmpty ? '' : ' ${scales[scaleIndex]}'}$space$words';
      }
      number ~/= 1000;
      scaleIndex++;
    }

    return (_value < 0 ? 'negative ' : '') + words.trim();
  }

  /// Convert a group of three digits to English words.
  String _convertGroup(int number, List<String> units, List<String> tens) {
    String groupWords = '';

    if (number >= 100) {
      groupWords += '${units[number ~/ 100]} hundred';
      number %= 100;
      if (number > 0) groupWords += ' ';
    }

    if (number >= 20) {
      groupWords += tens[number ~/ 10];
      if (number % 10 > 0) {
        groupWords += '-${units[number % 10]}';
      }
    } else if (number > 0) {
      groupWords += units[number];
    }

    return groupWords;
  }

  /// Format the number as currency.
  ///
  /// Example:
  /// ```dart
  /// final number = Number(1234.56);
  /// print(number.currency('\$')); // $1,234.56
  /// ```
  String currency(
      [String symbol = '\$',
      int decimals = 2,
      String decimalPoint = '.',
      String thousandsSeparator = ',']) {
    return '$symbol${format(decimals, decimalPoint, thousandsSeparator)}';
  }

  /// Format the number as percentage.
  ///
  /// Example:
  /// ```dart
  /// final number = Number(0.123);
  /// print(number.percentage()); // 12.30%
  /// ```
  String percentage(
      [int decimals = 2,
      String decimalPoint = '.',
      String thousandsSeparator = ',']) {
    return '${format(decimals, decimalPoint, thousandsSeparator)}%';
  }

  /// Format the number as file size.
  ///
  /// Example:
  /// ```dart
  /// final number = Number(1234567);
  /// print(number.fileSize()); // 1.18 MB
  /// ```
  String fileSize([int decimals = 2]) {
    final units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    var size = _value.abs().toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }

  /// Get the number value.
  num get value => _value;

  /// Create a new number instance from a value.
  static Number from(num value) => Number(value);

  @override
  String toString() => _value.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Number && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;
}
