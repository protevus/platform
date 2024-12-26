import '../../metadata/property_metadata.dart';
import 'parser.dart';
import 'base_parser.dart';

/// Parser for class properties, including fields and getters/setters.
class PropertyParser extends BaseParser {
  @override
  bool canParse(String source) {
    init(source);
    skipWhitespace();

    // Check for property modifiers
    if (lookAhead('static') || lookAhead('final') || lookAhead('const')) {
      return true;
    }

    // Check for getter/setter
    if (lookAhead('get') || lookAhead('set')) {
      return true;
    }

    // Check for type declaration
    return _isIdentifierStart(peek() ?? '');
  }

  @override
  ParseResult<PropertyMetadata> parse(String source) {
    init(source);

    try {
      // Parse property declaration
      final metadata = _parsePropertyDeclaration();
      if (metadata == null) {
        return ParseResult.failure(['Failed to parse property declaration']);
      }

      return ParseResult.success(metadata);
    } catch (e) {
      return ParseResult.failure(['Error parsing property: $e']);
    }
  }

  /// Parses a property declaration.
  PropertyMetadata? _parsePropertyDeclaration() {
    skipWhitespace();

    // Parse modifiers
    bool isStatic = false;
    bool isFinal = false;
    bool isConst = false;
    bool isLate = false;

    while (true) {
      if (match('static')) {
        if (isStatic) {
          addError("Duplicate 'static' modifier");
          return null;
        }
        isStatic = true;
      } else if (match('final')) {
        if (isFinal || isConst) {
          addError("Cannot have both 'final' and 'const'");
          return null;
        }
        isFinal = true;
      } else if (match('const')) {
        if (isConst || isFinal) {
          addError("Cannot have both 'const' and 'final'");
          return null;
        }
        isConst = true;
      } else if (match('late')) {
        if (isLate) {
          addError("Duplicate 'late' modifier");
          return null;
        }
        isLate = true;
      } else {
        break;
      }
      skipWhitespace();
    }

    // Check for getter/setter
    bool isGetter = false;
    bool isSetter = false;

    if (match('get')) {
      isGetter = true;
      skipWhitespace();
      return _parseAccessor(true);
    } else if (match('set')) {
      isSetter = true;
      skipWhitespace();
      return _parseAccessor(false);
    }

    // Parse type
    final typeStr = _parseType();
    if (typeStr == null) {
      addError('Expected type name');
      return null;
    }

    skipWhitespace();

    // Parse name
    final name = _parseIdentifier();
    if (name == null) {
      addError('Expected property name');
      return null;
    }

    skipWhitespace();

    // Check for nullable type
    bool isNullable = match('?');
    if (isNullable) skipWhitespace();

    // Parse initializer if present
    String? initializer;
    if (match('=')) {
      skipWhitespace();
      initializer = _parseInitializer();
    }

    // Expect semicolon
    if (!match(';')) {
      addError("Expected ';' after property declaration");
      return null;
    }

    return PropertyMetadata(
      name: name,
      type: _getTypeForName(typeStr),
      isReadable: true,
      isWritable: !isFinal && !isConst,
    );
  }

  /// Parses a getter or setter declaration.
  PropertyMetadata? _parseAccessor(bool isGetter) {
    final name = _parseIdentifier();
    if (name == null) {
      addError('Expected accessor name');
      return null;
    }

    skipWhitespace();

    // Parse getter/setter body
    if (!match('=>') && !match('{')) {
      addError("Expected '=>' or '{' after accessor name");
      return null;
    }

    // Skip body until we find the end
    if (peek() == '{') {
      var braceCount = 1;
      advance(); // Skip opening brace

      while (!isAtEnd() && braceCount > 0) {
        if (peek() == '{') braceCount++;
        if (peek() == '}') braceCount--;
        advance();
      }
    } else {
      // Skip arrow and expression until semicolon
      consumeUntil(';', includeDelimiter: true);
    }

    return PropertyMetadata(
      name: name,
      type: _getTypeForName(
          'dynamic'), // Type will be inferred from getter return type
      isReadable: isGetter,
      isWritable: !isGetter,
    );
  }

  /// Parses a type name, which could include generics.
  String? _parseType() {
    final identifier = _parseIdentifier();
    if (identifier == null) return null;

    skipWhitespace();

    // Parse type arguments if present
    if (match('<')) {
      final args = <String>[];

      while (!isAtEnd() && !lookAhead('>')) {
        skipWhitespace();

        final type = _parseType();
        if (type == null) {
          addError('Invalid type argument');
          return null;
        }

        args.add(type);

        skipWhitespace();
        if (!match(',')) break;
      }

      if (!match('>')) {
        addError("Expected '>' to close type arguments");
        return null;
      }

      return '$identifier<${args.join(', ')}>';
    }

    return identifier;
  }

  /// Parses an initializer expression.
  String? _parseInitializer() {
    final buffer = StringBuffer();
    var bracketCount = 0;
    var inString = false;
    var stringChar = '';

    while (!isAtEnd()) {
      final char = peek();
      if (char == null) break;

      if (!inString) {
        if (char == ';' && bracketCount == 0) break;
        if (char == '{' || char == '[' || char == '(') bracketCount++;
        if (char == '}' || char == ']' || char == ')') bracketCount--;
        if (char == '"' || char == "'") {
          inString = true;
          stringChar = char;
        }
      } else if (char == stringChar && peekAhead(-1) != '\\') {
        inString = false;
      }

      buffer.write(advance());
    }

    final result = buffer.toString().trim();
    return result.isEmpty ? null : result;
  }

  /// Parses an identifier (e.g., type name, property name).
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

  /// Gets or creates a Type instance for a type name.
  Type _getTypeForName(String name) {
    // Remove any generic type parameters and whitespace
    name = name.split('<')[0].trim();

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
}
