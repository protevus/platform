import 'package:source_span/source_span.dart';
import 'package:illuminate_view/src/ast/ast.dart' hide RegularElement;
import 'test_element.dart';

/// Helper to create tokens for testing
Token createToken(TokenType type, String text, SourceFile source, int offset) {
  final span = source.span(offset, offset + text.length);
  final match = RegExp(RegExp.escape(text)).matchAsPrefix(text);
  return Token(type, span, match);
}

/// Create a test element with given attributes and content
TestElement createElement(String tag, List<Attribute> attributes,
    List<ElementChild> children, SourceFile source, int offset) {
  // Create element
  final element = TestElement(
    createToken(TokenType.lt, '<', source, offset),
    Identifier(createToken(TokenType.id, tag, source, offset + 1)),
    attributes,
    createToken(TokenType.gt, '>', source, offset + tag.length + 1),
    [], // Empty initial children
    createToken(TokenType.lt, '<', source, offset + tag.length + 2),
    createToken(TokenType.slash, '/', source, offset + tag.length + 3),
    Identifier(createToken(TokenType.id, tag, source, offset + tag.length + 4)),
    createToken(TokenType.gt, '>', source, offset + tag.length + 5),
  );

  // Add children with parent reference
  final mutableChildren = element.children as List<ElementChild>;
  for (final child in children) {
    if (child is Element) {
      (child as dynamic).parent = element; // Set parent reference
    }
    mutableChildren.add(child);
  }

  return element;
}

/// Create an attribute with given name and value
Attribute createAttribute(
    String name, String? value, SourceFile source, int offset) {
  // Create a new source file just for this attribute
  final attrSource = SourceFile.fromString('$name=${value ?? ""}');

  // Create tokens
  final nameToken = Token(TokenType.id, attrSource.span(0, name.length),
      RegExp(name).matchAsPrefix(name));
  final equalsToken = Token(
      TokenType.equals,
      attrSource.span(name.length, name.length + 1),
      RegExp('=').matchAsPrefix('='));

  // Create value token and string literal if value is present
  final stringLiteral = value == null
      ? null
      : StringLiteral(
          Token(TokenType.string, attrSource.span(name.length + 1),
              RegExp(value).matchAsPrefix(value)),
          value);

  return Attribute(
      Identifier(nameToken),
      null, // Don't set string for name
      equalsToken,
      null,
      stringLiteral);
}

/// Create a text node with given content
TextNode createTextNode(String text, SourceFile source, int offset) {
  return TextNode(createToken(TokenType.text, text, source, offset));
}
