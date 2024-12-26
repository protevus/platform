import 'parser.dart';
import 'base_parser.dart';

/// Represents a parsed type with its generic type arguments.
class ParsedType {
  /// The base type name.
  final String name;

  /// The type arguments if this is a generic type.
  final List<ParsedType> typeArguments;

  /// Whether this type is nullable.
  final bool isNullable;

  /// The full type string including generics and nullability.
  String get fullName {
    final buffer = StringBuffer(name);
    if (typeArguments.isNotEmpty) {
      buffer.write('<');
      buffer.write(typeArguments.map((t) => t.fullName).join(', '));
      buffer.write('>');
    }
    if (isNullable) buffer.write('?');
    return buffer.toString();
  }

  ParsedType({
    required this.name,
    this.typeArguments = const [],
    this.isNullable = false,
  });
}

/// Parser for Dart type declarations.
class TypeParser extends BaseParser {
  @override
  bool canParse(String source) {
    init(source);
    skipWhitespace();
    return _isIdentifierStart(peek() ?? '');
  }

  @override
  ParseResult<ParsedType> parse(String source) {
    init(source);

    try {
      // Parse type declaration
      final type = _parseType();
      if (type == null) {
        return ParseResult.failure(['Failed to parse type declaration']);
      }

      return ParseResult.success(type);
    } catch (e) {
      return ParseResult.failure(['Error parsing type: $e']);
    }
  }

  /// Parses a type declaration.
  ParsedType? _parseType() {
    skipWhitespace();

    // Parse base type name
    final name = _parseIdentifier();
    if (name == null) {
      addError('Expected type name');
      return null;
    }

    skipWhitespace();

    // Parse type arguments if present
    final typeArguments = <ParsedType>[];
    if (match('<')) {
      while (!isAtEnd() && !lookAhead('>')) {
        skipWhitespace();

        final typeArg = _parseType();
        if (typeArg == null) {
          addError('Invalid type argument');
          return null;
        }

        typeArguments.add(typeArg);

        skipWhitespace();
        if (!match(',')) break;
      }

      if (!match('>')) {
        addError("Expected '>' to close type arguments");
        return null;
      }
    }

    skipWhitespace();

    // Check for nullable type
    final isNullable = match('?');

    return ParsedType(
      name: name,
      typeArguments: typeArguments,
      isNullable: isNullable,
    );
  }

  /// Parses an identifier (e.g., type name).
  String? _parseIdentifier() {
    skipWhitespace();

    if (isAtEnd()) return null;

    final char = peek();
    if (char == null || !_isIdentifierStart(char)) return null;

    return consumeWhile(_isIdentifierPart);
  }

  /// Returns true if the character can start an identifier.
  bool _isIdentifierStart(String char) {
    return char == '_' || char.toLowerCase() != char.toUpperCase();
  }

  /// Returns true if the character can be part of an identifier.
  bool _isIdentifierPart(String char) {
    return _isIdentifierStart(char) ||
        char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }

  /// Gets the Type instance for a ParsedType.
  Type getTypeForParsedType(ParsedType parsedType) {
    // Remove any generic type parameters and whitespace
    final name = parsedType.name.trim();

    // For built-in types, return the actual type
    switch (name) {
      case 'String':
        return String;
      case 'int':
        return int;
      case 'double':
        return double;
      case 'bool':
        return bool;
      case 'List':
        return List;
      case 'Map':
        return Map;
      case 'Set':
        return Set;
      case 'Object':
        return Object;
      case 'dynamic':
        return Object; // Use Object as fallback for dynamic
      case 'void':
        return Object; // Use Object as fallback for void
      case 'Null':
        return Object; // Use Object as fallback for Null
      default:
        // For user-defined types, create a proxy type
        return Object; // TODO: Handle custom types properly
    }
  }

  /// Parses a type string and returns its Type instance.
  Type parseAndGetType(String typeStr) {
    final result = parse(typeStr);
    if (!result.isSuccess) {
      return Object; // Return Object as fallback for invalid types
    }
    return getTypeForParsedType(result.result!);
  }
}
