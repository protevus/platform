import '../../metadata/constructor_metadata.dart';
import '../../metadata/parameter_metadata.dart';
import 'parser.dart';
import 'base_parser.dart';

/// Parser for class constructors.
class ConstructorParser extends BaseParser {
  final String className;

  ConstructorParser(this.className);

  @override
  bool canParse(String source) {
    init(source);
    skipWhitespace();

    // Check for constructor modifiers
    if (lookAhead('const') || lookAhead('factory')) {
      return true;
    }

    // Check for constructor name
    return lookAhead(className);
  }

  @override
  ParseResult<ConstructorMetadata> parse(String source) {
    init(source);

    try {
      // Parse constructor declaration
      final metadata = _parseConstructorDeclaration();
      if (metadata == null) {
        return ParseResult.failure(['Failed to parse constructor declaration']);
      }

      return ParseResult.success(metadata);
    } catch (e) {
      return ParseResult.failure(['Error parsing constructor: $e']);
    }
  }

  /// Parses a constructor declaration.
  ConstructorMetadata? _parseConstructorDeclaration() {
    skipWhitespace();

    // Parse modifiers
    bool isConst = false;
    bool isFactory = false;

    while (true) {
      if (match('const')) {
        if (isConst) {
          addError("Duplicate 'const' modifier");
          return null;
        }
        isConst = true;
      } else if (match('factory')) {
        if (isFactory) {
          addError("Duplicate 'factory' modifier");
          return null;
        }
        isFactory = true;
      } else {
        break;
      }
      skipWhitespace();
    }

    // Parse constructor name
    if (!match(className)) {
      addError('Expected constructor name');
      return null;
    }

    // Parse named constructor if present
    String constructorName = '';
    if (match('.')) {
      final name = _parseIdentifier();
      if (name == null) {
        addError('Expected named constructor identifier');
        return null;
      }
      constructorName = name;
    }

    skipWhitespace();

    // Parse parameters
    if (!match('(')) {
      addError("Expected '(' after constructor name");
      return null;
    }

    final parameters = <ParameterMetadata>[];
    final parameterTypes = <Type>[];

    // Parse parameter list
    if (!match(')')) {
      while (true) {
        skipWhitespace();

        final param = _parseParameter();
        if (param == null) {
          addError('Invalid parameter');
          return null;
        }

        parameters.add(param);
        parameterTypes.add(param.type);

        skipWhitespace();
        if (match(')')) break;

        if (!match(',')) {
          addError("Expected ',' or ')' after parameter");
          return null;
        }
      }
    }

    skipWhitespace();

    // Parse initializer list if present
    if (match(':')) {
      skipWhitespace();
      while (!isAtEnd() && !lookAhead('{') && !lookAhead('=>')) {
        // Skip initializer
        consumeUntil(',', includeDelimiter: true);
        skipWhitespace();
      }
    }

    // Parse constructor body unless redirecting
    if (!match('=>')) {
      if (!match('{')) {
        addError("Expected '{' to begin constructor body");
        return null;
      }

      // Skip constructor body
      var braceCount = 1;
      while (!isAtEnd() && braceCount > 0) {
        if (peek() == '{') braceCount++;
        if (peek() == '}') braceCount--;
        advance();
      }
    } else {
      // Skip redirecting constructor call
      consumeUntil(';', includeDelimiter: true);
    }

    return ConstructorMetadata(
      name: constructorName,
      parameterTypes: parameterTypes,
      parameters: parameters,
    );
  }

  /// Parses a parameter declaration.
  ParameterMetadata? _parseParameter() {
    bool isRequired = false;
    bool isNamed = false;

    // Check if we're in a named parameter group
    if (lookAhead('{')) {
      isNamed = true;
      match('{');
      skipWhitespace();
    }

    // Check for required modifier
    if (match('required')) {
      isRequired = true;
      skipWhitespace();
    }

    // Parse type
    final typeStr = _parseType();
    if (typeStr == null) {
      addError('Expected parameter type');
      return null;
    }

    skipWhitespace();

    // Check for 'this.' prefix
    bool isFieldFormal = match('this.');

    // Parse name
    final name = _parseIdentifier();
    if (name == null) {
      addError('Expected parameter name');
      return null;
    }

    skipWhitespace();

    // Check for nullable type
    bool isNullable = match('?');
    if (isNullable) skipWhitespace();

    // Parse default value if present
    String? defaultValue;
    if (match('=')) {
      skipWhitespace();
      defaultValue = _parseDefaultValue();
    }

    // Check for end of named parameter group
    if (isNamed && match('}')) {
      skipWhitespace();
    }

    return ParameterMetadata(
      name: name,
      type: _getTypeForName(typeStr),
      isRequired: isRequired || !isNamed,
      isNamed: isNamed,
      isNullable: isNullable,
      defaultValue:
          defaultValue != null ? _parseDefaultValueLiteral(defaultValue) : null,
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

  /// Parses a default value expression.
  String? _parseDefaultValue() {
    final buffer = StringBuffer();
    var bracketCount = 0;
    var inString = false;
    var stringChar = '';

    while (!isAtEnd()) {
      final char = peek();
      if (char == null) break;

      if (!inString) {
        if ((char == ',' || char == '}' || char == ')') && bracketCount == 0)
          break;
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

  /// Parses a default value literal into its actual value.
  dynamic _parseDefaultValueLiteral(String value) {
    if (value == 'null') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (value.startsWith("'") && value.endsWith("'")) {
      return value.substring(1, value.length - 1);
    }
    if (int.tryParse(value) != null) return int.parse(value);
    if (double.tryParse(value) != null) return double.parse(value);
    return value;
  }

  /// Parses an identifier (e.g., type name, parameter name).
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
