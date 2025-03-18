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

  if (children.isEmpty) {
    return SelfClosingElement(lt, Identifier(tagName), attributes, slash, gt);
  }

  return RegularElement(lt, Identifier(tagName), attributes, gt, children, lt,
      slash, Identifier(tagName), gt);
}

Attribute createAttribute(
    String name, String value, SourceFile source, int offset) {
  final span = source.span(offset);
  final nameToken = Token(TokenType.id, span, RegExp(name).matchAsPrefix(name));
  final equals = Token(TokenType.equals, span, RegExp('=').matchAsPrefix('='));
  final valueToken =
      Token(TokenType.string, span, RegExp(value).matchAsPrefix(value));

  return Attribute(Identifier(nameToken), null, equals, null,
      StringLiteral(valueToken, value));
}
