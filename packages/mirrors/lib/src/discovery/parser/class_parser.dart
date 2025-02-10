import '../../metadata/constructor_metadata.dart';
import '../../metadata/method_metadata.dart';
import '../../metadata/property_metadata.dart';
import 'base_parser.dart';
import 'parser.dart';
import '../../metadata/class_metadata.dart';
import 'property_parser.dart';
import 'method_parser.dart';
import 'constructor_parser.dart';
import 'type_parser.dart';

/// Parser for Dart class declarations.
class ClassParser extends BaseParser {
  // Specialized parsers for class members
  late final PropertyParser _propertyParser;
  late final MethodParser _methodParser;
  late final ConstructorParser _constructorParser;
  late final TypeParser _typeParser;

  @override
  bool canParse(String source) {
    init(source);
    skipWhitespace();

    // Check for class modifiers
    if (lookAhead('abstract') || lookAhead('final')) {
      return true;
    }

    // Check for class keyword
    return lookAhead('class');
  }

  @override
  ParseResult<ClassMetadata> parse(String source) {
    init(source);

    try {
      // Parse class declaration
      final metadata = _parseClassDeclaration();
      if (metadata == null) {
        return ParseResult.failure(['Failed to parse class declaration']);
      }

      // Initialize member parsers with class name
      _propertyParser = PropertyParser();
      _methodParser = MethodParser();
      _constructorParser = ConstructorParser(metadata.name);
      _typeParser = TypeParser();

      // Parse class body
      final body = _parseClassBody();
      if (body == null) {
        return ParseResult.failure(['Failed to parse class body']);
      }

      // Update metadata with parsed body
      return ParseResult.success(ClassMetadata(
        name: metadata.name,
        typeParameters: metadata.typeParameters,
        superclass: metadata.superclass,
        interfaces: metadata.interfaces,
        isAbstract: metadata.isAbstract,
        isFinal: metadata.isFinal,
        properties: body['properties'] as Map<String, PropertyMetadata>,
        methods: body['methods'] as Map<String, MethodMetadata>,
        constructors: body['constructors'] as List<ConstructorMetadata>,
      ));
    } catch (e) {
      return ParseResult.failure(['Error parsing class: $e']);
    }
  }

  /// Parses the class declaration including modifiers, name, type parameters,
  /// superclass, and interfaces.
  ClassMetadata? _parseClassDeclaration() {
    skipWhitespace();

    // Parse modifiers
    bool isAbstract = false;
    bool isFinal = false;

    if (match('abstract')) {
      isAbstract = true;
      skipWhitespace();
    } else if (match('final')) {
      isFinal = true;
      skipWhitespace();
    }

    // Parse 'class' keyword
    if (!match('class')) {
      addError("Expected 'class' keyword");
      return null;
    }

    skipWhitespace();

    // Parse class name
    final name = _parseIdentifier();
    if (name == null) {
      addError('Expected class name');
      return null;
    }

    // Parse type parameters if present
    final typeParameters = _parseTypeParameters();

    skipWhitespace();

    // Parse superclass if present
    String? superclass;
    if (match('extends')) {
      skipWhitespace();
      final type = _typeParser
          .parse(consumeUntil('implements', includeDelimiter: false).trim());
      if (type.isSuccess) {
        superclass = type.result!.fullName;
      }
    }

    skipWhitespace();

    // Parse interfaces if present
    final interfaces = <String>[];
    if (match('implements')) {
      skipWhitespace();
      while (!isAtEnd() && !lookAhead('{')) {
        final type = _typeParser
            .parse(consumeUntil(',', includeDelimiter: false).trim());
        if (type.isSuccess) {
          interfaces.add(type.result!.fullName);
        }

        skipWhitespace();
        if (!match(',')) break;
        skipWhitespace();
      }
    }

    return ClassMetadata(
      name: name,
      typeParameters: typeParameters,
      superclass: superclass,
      interfaces: interfaces,
      isAbstract: isAbstract,
      isFinal: isFinal,
    );
  }

  /// Parses the class body including properties, methods, and constructors.
  Map<String, dynamic>? _parseClassBody() {
    skipWhitespace();

    if (!match('{')) {
      addError("Expected '{' to begin class body");
      return null;
    }

    final properties = <String, PropertyMetadata>{};
    final methods = <String, MethodMetadata>{};
    final constructors = <ConstructorMetadata>[];

    // Parse class members until we reach the closing brace
    while (!isAtEnd() && !lookAhead('}')) {
      skipWhitespace();

      // Try to parse as constructor first (since constructors start with the class name)
      if (_constructorParser.canParse(peekLine())) {
        final result = _constructorParser.parse(consumeMember());
        if (result.isSuccess) {
          constructors.add(result.result!);
          continue;
        }
      }

      // Try to parse as property
      if (_propertyParser.canParse(peekLine())) {
        final result = _propertyParser.parse(consumeMember());
        if (result.isSuccess) {
          properties[result.result!.name] = result.result!;
          continue;
        }
      }

      // Try to parse as method
      if (_methodParser.canParse(peekLine())) {
        final result = _methodParser.parse(consumeMember());
        if (result.isSuccess) {
          methods[result.result!.name] = result.result!;
          continue;
        }
      }

      // If we get here, we couldn't parse the member
      addError('Invalid class member');
      return null;
    }

    if (!match('}')) {
      addError("Expected '}' to end class body");
      return null;
    }

    return {
      'properties': properties,
      'methods': methods,
      'constructors': constructors,
    };
  }

  /// Peeks at the current line without consuming it.
  String peekLine() {
    final start = position;
    final line = consumeUntil(';', includeDelimiter: false);
    position = start;
    return line;
  }

  /// Consumes a complete class member (property, method, or constructor).
  String consumeMember() {
    final buffer = StringBuffer();
    var braceCount = 0;
    var inString = false;
    var stringChar = '';

    while (!isAtEnd()) {
      final char = peek();
      if (char == null) break;

      if (!inString) {
        if (char == '{') braceCount++;
        if (char == '}') braceCount--;
        if (char == '"' || char == "'") {
          inString = true;
          stringChar = char;
        }
        if (char == ';' && braceCount == 0) {
          buffer.write(advance());
          break;
        }
        if (braceCount < 0) break; // End of class body
      } else if (char == stringChar && peekAhead(-1) != '\\') {
        inString = false;
      }

      buffer.write(advance());
    }

    return buffer.toString();
  }

  /// Parses type parameters (e.g., <T> or <T extends Base>).
  List<String> _parseTypeParameters() {
    if (!match('<')) return [];

    final params = <String>[];

    while (!isAtEnd() && !lookAhead('>')) {
      skipWhitespace();

      final param = _parseTypeParameter();
      if (param == null) {
        addError('Invalid type parameter');
        return [];
      }

      params.add(param);

      skipWhitespace();
      if (!match(',')) break;
    }

    if (!match('>')) {
      addError("Expected '>' to close type parameters");
      return [];
    }

    return params;
  }

  /// Parses a single type parameter, including any bounds.
  String? _parseTypeParameter() {
    final name = _parseIdentifier();
    if (name == null) return null;

    skipWhitespace();

    // Parse type bounds if present
    if (match('extends')) {
      skipWhitespace();
      final type =
          _typeParser.parse(consumeUntil(',', includeDelimiter: false).trim());
      if (type.isSuccess) {
        return '$name extends ${type.result!.fullName}';
      }
      return null;
    }

    return name;
  }

  /// Parses an identifier (e.g., class name, method name).
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
}
