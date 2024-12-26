/// Base interface for all parsers in the reflection system.
abstract class Parser {
  /// Parses the given source code and returns the result.
  ///
  /// The return type varies based on the specific parser implementation.
  dynamic parse(String source);

  /// Validates if the given source code can be parsed by this parser.
  ///
  /// Returns true if the source is valid for this parser, false otherwise.
  bool canParse(String source);

  /// Gets the current position in the source code.
  int get position;

  /// Sets the current position in the source code.
  set position(int value);

  /// Gets the current line number being parsed.
  int get line;

  /// Gets the current column number being parsed.
  int get column;

  /// Gets any error messages from the parsing process.
  List<String> get errors;

  /// Gets any warning messages from the parsing process.
  List<String> get warnings;
}

/// Result of a parsing operation.
class ParseResult<T> {
  /// The parsed result.
  final T? result;

  /// Any errors that occurred during parsing.
  final List<String> errors;

  /// Any warnings that occurred during parsing.
  final List<String> warnings;

  /// Whether the parsing was successful.
  bool get isSuccess => errors.isEmpty && result != null;

  ParseResult({
    this.result,
    this.errors = const [],
    this.warnings = const [],
  });

  /// Creates a successful parse result.
  factory ParseResult.success(T result, {List<String> warnings = const []}) {
    return ParseResult(result: result, warnings: warnings);
  }

  /// Creates a failed parse result.
  factory ParseResult.failure(List<String> errors,
      {List<String> warnings = const []}) {
    return ParseResult(errors: errors, warnings: warnings);
  }
}
