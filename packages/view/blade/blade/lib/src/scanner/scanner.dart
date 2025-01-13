import 'package:source_span/source_span.dart';
import '../ast/ast.dart';

/// Token types for the Blade lexer
enum TokenType {
  // Basic tokens
  text,
  whitespace,
  newline,
  eof,

  // Blade syntax
  at, // @
  openBrace, // {
  closeBrace, // }
  openParen, // (
  closeParen, // )
  equals, // =
  quote, // "
  singleQuote, // '
  dot, // .
  comma, // ,
  colon, // :
  semicolon, // ;
  pipe, // |
  arrow, // =>

  // Blade directives
  directive, // @if, @foreach, etc.
  expression, // {{ $var }}
  rawExpression, // {!! $var !!}
  comment, // {{-- comment --}}

  // HTML
  openTag, // <
  closeTag, // >
  slash, // /
  identifier, // tag names, attribute names
  string, // attribute values
}

/// A token in the Blade template
class Token {
  /// The type of token
  final TokenType type;

  /// The source span for this token
  final FileSpan span;

  /// The lexeme (actual text) of the token
  String get lexeme => span.text;

  const Token(this.type, this.span);

  @override
  String toString() => '${type.name}($lexeme)';
}

/// Scanner for Blade templates
class Scanner {
  /// The source file being scanned
  final SourceFile source;

  /// The current position in the source
  int _position = 0;

  /// The starting position of the current token
  int _start = 0;

  /// The list of tokens scanned so far
  final List<Token> _tokens = [];

  /// Any errors encountered during scanning
  final List<BladeError> _errors = [];

  /// Create a new scanner for the given source
  Scanner(this.source);

  /// Scan the entire source file and return the tokens
  List<Token> scan() {
    while (!_isAtEnd()) {
      _start = _position;
      _scanToken();
    }

    // Add EOF token
    _addToken(TokenType.eof);
    return _tokens;
  }

  /// Get any errors encountered during scanning
  List<BladeError> get errors => List.unmodifiable(_errors);

  /// Whether we've reached the end of the source
  bool _isAtEnd() => _position >= source.length;

  /// Get the current character
  String _current() => source.getText(_position, _position + 1);

  /// Advance to the next character
  String _advance() {
    var char = _current();
    _position++;
    return char;
  }

  /// Look at the next character without advancing
  String _peek() {
    if (_isAtEnd()) return '\0';
    return source.getText(_position, _position + 1);
  }

  /// Look at the character after next without advancing
  String _peekNext() {
    if (_position + 1 >= source.length) return '\0';
    return source.getText(_position + 1, _position + 2);
  }

  /// Add a token of the given type
  void _addToken(TokenType type) {
    var text = source.getText(_start, _position);
    var span = source.span(_start, _position);
    _tokens.add(Token(type, span));
  }

  /// Add an error at the current position
  void _error(String message) {
    var span = source.span(_start, _position);
    _errors.add(BladeError(BladeErrorSeverity.error, message, span));
  }

  /// Scan a single token
  void _scanToken() {
    var c = _advance();
    switch (c) {
      case '@':
        _scanDirective();
        break;
      case '{':
        if (_peek() == '{') {
          _advance();
          if (_peek() == '-' && _peekNext() == '-') {
            _scanComment();
          } else {
            _scanExpression();
          }
        } else if (_peek() == '!') {
          _advance();
          if (_peek() == '!') {
            _advance();
            _scanRawExpression();
          }
        } else {
          _addToken(TokenType.openBrace);
        }
        break;
      case '<':
        _scanTag();
        break;
      case ' ':
      case '\r':
      case '\t':
        _scanWhitespace();
        break;
      case '\n':
        _addToken(TokenType.newline);
        break;
      default:
        _scanText();
        break;
    }
  }

  /// Scan a Blade directive
  void _scanDirective() {
    while (_peek().isAlphaNumeric) {
      _advance();
    }
    _addToken(TokenType.directive);
  }

  /// Scan an expression {{ ... }}
  void _scanExpression() {
    while (!_isAtEnd()) {
      if (_peek() == '}' && _peekNext() == '}') {
        _advance();
        _advance();
        _addToken(TokenType.expression);
        return;
      }
      _advance();
    }
    _error("Unterminated expression");
  }

  /// Scan a raw expression {!! ... !!}
  void _scanRawExpression() {
    while (!_isAtEnd()) {
      if (_peek() == '!' && _peekNext() == '}') {
        _advance();
        _advance();
        _addToken(TokenType.rawExpression);
        return;
      }
      _advance();
    }
    _error("Unterminated raw expression");
  }

  /// Scan a comment {{-- ... --}}
  void _scanComment() {
    while (!_isAtEnd()) {
      if (_peek() == '-' && _peekNext() == '-') {
        _advance();
        _advance();
        if (_peek() == '}' && _peekNext() == '}') {
          _advance();
          _advance();
          _addToken(TokenType.comment);
          return;
        }
      }
      _advance();
    }
    _error("Unterminated comment");
  }

  /// Scan an HTML tag
  void _scanTag() {
    _addToken(TokenType.openTag);
    while (!_isAtEnd() && _peek() != '>') {
      if (_peek().isWhitespace) {
        _scanWhitespace();
      } else if (_peek() == '"' || _peek() == "'") {
        _scanString();
      } else if (_peek().isAlphaNumeric) {
        _scanIdentifier();
      } else {
        _advance();
      }
    }
    if (_peek() == '>') {
      _advance();
      _addToken(TokenType.closeTag);
    } else {
      _error("Unterminated tag");
    }
  }

  /// Scan whitespace
  void _scanWhitespace() {
    while (_peek().isWhitespace && _peek() != '\n') {
      _advance();
    }
    _addToken(TokenType.whitespace);
  }

  /// Scan a string literal
  void _scanString() {
    var quote = _advance(); // Get the opening quote
    while (!_isAtEnd() && _peek() != quote) {
      _advance();
    }
    if (_peek() == quote) {
      _advance();
      _addToken(TokenType.string);
    } else {
      _error("Unterminated string");
    }
  }

  /// Scan an identifier
  void _scanIdentifier() {
    while (_peek().isAlphaNumeric) {
      _advance();
    }
    _addToken(TokenType.identifier);
  }

  /// Scan plain text
  void _scanText() {
    while (!_isAtEnd() &&
        _peek() != '@' &&
        _peek() != '{' &&
        _peek() != '<' &&
        _peek() != '\n') {
      _advance();
    }
    _addToken(TokenType.text);
  }
}

/// Extensions for character classification
extension on String {
  bool get isAlpha => RegExp(r'[a-zA-Z_]').hasMatch(this);
  bool get isDigit => RegExp(r'[0-9]').hasMatch(this);
  bool get isAlphaNumeric => isAlpha || isDigit;
  bool get isWhitespace => this == ' ' || this == '\r' || this == '\t';
}
