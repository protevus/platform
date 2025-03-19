import 'package:belatuk_code_buffer/belatuk_code_buffer.dart';
import 'package:belatuk_symbol_table/belatuk_symbol_table.dart';
import 'package:source_span/source_span.dart';
import 'package:illuminate_view/src/core/renderer.dart';
import 'package:illuminate_view/src/ast/ast.dart';
import 'test_element.dart';

String render(String template, {Map<String, dynamic>? values}) {
  var document = parseDocument(template);
  if (document == null) {
    throw Exception('Failed to parse template');
  }

  var buffer = CodeBuffer();
  var scope = SymbolTable(values: values ?? {});

  const Renderer().render(document, buffer, scope);
  return buffer.toString();
}

Element createElement(String name, List<Attribute> attributes,
    List<ElementChild> children, SourceFile source, int offset) {
  final span = source.span(offset);
  final lt = Token(TokenType.lt, span, RegExp('<').matchAsPrefix('<'));
  final tagName = Token(TokenType.id, span, RegExp(name).matchAsPrefix(name));
  final slash = Token(TokenType.slash, span, RegExp('/').matchAsPrefix('/'));
  final gt = Token(TokenType.gt, span, RegExp('>').matchAsPrefix('>'));

  // Create new tokens for closing tag
  final lt2 = Token(TokenType.lt, span, RegExp('<').matchAsPrefix('<'));
  final slash2 = Token(TokenType.slash, span, RegExp('/').matchAsPrefix('/'));
  final tagName2 = Token(TokenType.id, span, RegExp(name).matchAsPrefix(name));
  final gt2 = Token(TokenType.gt, span, RegExp('>').matchAsPrefix('>'));

  return RegularElement(lt, Identifier(tagName), attributes, gt, children, lt2,
      slash2, Identifier(tagName2), gt2);
}

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
