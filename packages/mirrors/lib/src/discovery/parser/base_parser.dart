import 'parser.dart';

/// Base class for all parsers that provides common functionality.
abstract class BaseParser implements Parser {
  String _source = '';
  int _position = 0;
  int _line = 1;
  int _column = 1;
  final List<String> _errors = [];
  final List<String> _warnings = [];

  @override
  int get position => _position;

  @override
  set position(int value) {
    if (value < 0) value = 0;
    if (value > _source.length) value = _source.length;

    if (value < _position) {
      // Moving backwards, recalculate line and column
      var text = _source.substring(0, value);
      _line = '\n'.allMatches(text).length + 1;
      var lastNewline = text.lastIndexOf('\n');
      _column = lastNewline == -1 ? value + 1 : value - lastNewline;
    } else {
      // Moving forwards, update line and column
      var text = _source.substring(_position, value);
      var newlines = '\n'.allMatches(text).length;
      if (newlines > 0) {
        _line += newlines;
        var lastNewline = text.lastIndexOf('\n');
        _column = text.length - lastNewline;
      } else {
        _column += text.length;
      }
    }

    _position = value;
  }

  @override
  int get line => _line;

  @override
  int get column => _column;

  @override
  List<String> get errors => List.unmodifiable(_errors);

  @override
  List<String> get warnings => List.unmodifiable(_warnings);

  /// Initializes the parser with the given source code.
  void init(String source) {
    _source = source;
    _position = 0;
    _line = 1;
    _column = 1;
    _errors.clear();
    _warnings.clear();
  }

  /// Gets the current character without advancing the position.
  String? peek() {
    if (_position >= _source.length) return null;
    return _source[_position];
  }

  /// Gets the character at the given offset from current position without advancing.
  String? peekAhead(int offset) {
    final pos = _position + offset;
    if (pos >= _source.length) return null;
    return _source[pos];
  }

  /// Advances the position by one and returns the character.
  String? advance() {
    if (_position >= _source.length) return null;
    final char = _source[_position];
    position = _position + 1;
    return char;
  }

  /// Returns true if the current position is at the end of the source.
  bool isAtEnd() => _position >= _source.length;

  /// Adds an error message with the current position information.
  void addError(String message) {
    _errors.add('$message at line $_line, column $_column');
  }

  /// Adds a warning message with the current position information.
  void addWarning(String message) {
    _warnings.add('$message at line $_line, column $_column');
  }

  /// Skips whitespace characters.
  void skipWhitespace() {
    while (!isAtEnd()) {
      final char = peek();
      if (char == ' ' || char == '\t' || char == '\r' || char == '\n') {
        advance();
      } else {
        break;
      }
    }
  }

  /// Matches and consumes the given string if it exists at the current position.
  /// Returns true if matched, false otherwise.
  bool match(String text) {
    if (_position + text.length > _source.length) return false;

    if (_source.substring(_position, _position + text.length) == text) {
      position = _position + text.length;
      return true;
    }

    return false;
  }

  /// Looks ahead for the given string without consuming it.
  /// Returns true if found, false otherwise.
  bool lookAhead(String text) {
    if (_position + text.length > _source.length) return false;
    return _source.substring(_position, _position + text.length) == text;
  }

  /// Consumes characters until the given predicate returns false.
  String consumeWhile(bool Function(String) predicate) {
    final buffer = StringBuffer();
    while (!isAtEnd()) {
      final char = peek();
      if (char == null || !predicate(char)) break;
      buffer.write(advance());
    }
    return buffer.toString();
  }

  /// Consumes characters until the given string is found.
  /// Returns the consumed characters not including the delimiter.
  /// If includeDelimiter is true, advances past the delimiter.
  String consumeUntil(String delimiter, {bool includeDelimiter = false}) {
    final buffer = StringBuffer();
    while (!isAtEnd()) {
      if (lookAhead(delimiter)) {
        if (includeDelimiter) {
          position = _position + delimiter.length;
        }
        break;
      }
      buffer.write(advance());
    }
    return buffer.toString();
  }
}
