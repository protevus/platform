import 'dart:convert';
import 'package:belatuk_code_buffer/belatuk_code_buffer.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:source_span/source_span.dart';
import 'package:belatuk_symbol_table/belatuk_symbol_table.dart';
import '../ast/ast.dart';
import '../text/parser.dart';
import '../text/scanner.dart';

/// Parses a Jael document.
Document? parseDocument(String text,
    {sourceUrl, bool asDSX = false, void Function(JaelError error)? onError}) {
  var scanner = scan(text, sourceUrl: sourceUrl, asDSX: asDSX);

  //scanner.tokens.forEach(print);

  if (scanner.errors.isNotEmpty && onError != null) {
    scanner.errors.forEach(onError);
  } else if (scanner.errors.isNotEmpty) {
    throw scanner.errors.first;
  }

  var parser = Parser(scanner, asDSX: asDSX);
  var doc = parser.parseDocument();

  if (parser.errors.isNotEmpty && onError != null) {
    parser.errors.forEach(onError);
  } else if (parser.errors.isNotEmpty) {
    throw parser.errors.first;
  }

  return doc;
}

class Renderer {
  const Renderer();

  /// Render an error page.
  static void errorDocument(Iterable<JaelError> errors, CodeBuffer buf) {
    buf
      ..writeln('<!DOCTYPE html>')
      ..writeln('<html lang="en">')
      ..indent()
      ..writeln('<head>')
      ..indent()
      ..writeln(
        '<meta name="viewport" content="width=device-width, initial-scale=1">',
      )
      ..writeln('<title>${errors.length} Error(s)</title>')
      ..outdent()
      ..writeln('</head>')
      ..writeln('<body>')
      ..writeln('<h1>${errors.length} Error(s)</h1>')
      ..writeln('<ul>')
      ..indent();

    for (var error in errors) {
      var type =
          error.severity == JaelErrorSeverity.warning ? 'warning' : 'error';
      buf
        ..writeln('<li>')
        ..indent()
        ..writeln(
            '<b>$type:</b> ${error.span.start.toolString}: ${error.message}')
        ..writeln('<br>')
        ..writeln(
          '<span style="color: red;">${htmlEscape.convert(error.span.highlight(color: false)).replaceAll('\n', '<br>')}</span>',
        )
        ..outdent()
        ..writeln('</li>');
    }

    buf
      ..outdent()
      ..writeln('</ul>')
      ..writeln('</body>')
      ..writeln('</html>');
  }

  /// Renders a [document] into the [buffer] as HTML.
  ///
  /// If [strictResolution] is `false` (default: `true`), then undefined identifiers will return `null`
  /// instead of throwing.
  void render(Document document, CodeBuffer buffer, SymbolTable scope,
      {bool strictResolution = true}) {
    // Only create strict mode symbol if it doesn't exist
    try {
      scope.create('!strict!', value: strictResolution != false);
    } on StateError {
      // Symbol already exists, ignore
    }

    if (document.doctype != null) buffer.writeln(document.doctype!.span.text);
    renderElement(
        document.root, buffer, scope, document.doctype?.public == null);
  }

  void renderElement(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var childScope = scope.createChild();

    if (element.tagName.name == 'form') {
      renderForm(element, buffer, childScope, html5);
      return;
    }

    if (element.attributes.any((a) => a.name == 'for-each')) {
      renderForeach(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'if')) {
      renderIf(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'unless')) {
      renderUnless(element, buffer, childScope, html5);
      return;
    } else if (element.tagName.name == 'declare') {
      renderDeclare(element, buffer, childScope, html5);
      return;
    } else if (element.tagName.name == 'switch') {
      renderSwitch(element, buffer, childScope, html5);
      return;
    } else if (element.tagName.name == 'element') {
      registerCustomElement(element, buffer, childScope, html5);
      return;
    } else {
      var customElementValue =
          scope.resolve(customElementName(element.tagName.name))?.value;

      if (customElementValue is Element) {
        renderCustomElement(element, buffer, childScope, html5);
        return;
      }
    }

    buffer
      ..write('<')
      ..write(element.tagName.name);

    // Single attribute handling section for all elements
    for (var attribute in element.attributes) {
      var value = attribute.value?.compute(childScope);
      if (value == false || value == null && !attribute.isRaw) continue;

      buffer.write(' ${attribute.name}');
      if (value == true) continue;

      buffer.write('="');
      if (attribute.isRaw && attribute.string != null) {
        buffer.write(attribute.string!.value);
      } else if (value is Iterable) {
        buffer.write(htmlEscape.convert(value.join(' ')));
      } else if (value is Map) {
        buffer.write(htmlEscape
            .convert(value.keys.fold<StringBuffer>(StringBuffer(), (buf, k) {
          var v = value[k];
          if (v == null) return buf;
          return buf..write('$k: $v;');
        }).toString()));
      } else {
        buffer.write(attribute.isRaw
            ? value.toString()
            : htmlEscape.convert(value.toString()));
      }
      buffer.write('"');
    }

    if (element is SelfClosingElement) {
      buffer.writeln(html5 ? '>' : '/>');
    } else {
      buffer.writeln('>');
      buffer.indent();

      for (var i = 0; i < element.children.length; i++) {
        var child = element.children.elementAt(i);
        renderElementChild(element, child, buffer, childScope, html5, i,
            element.children.length);
      }

      buffer.writeln();
      buffer.outdent();
      buffer.writeln('</${element.tagName.name}>');
    }
  }

  void renderForeach(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var attribute = element.attributes.singleWhere((a) => a.name == 'for-each');
    if (attribute.value == null) return;

    var asAttribute =
        element.attributes.firstWhereOrNull((a) => a.name == 'as');
    var indexAsAttribute =
        element.attributes.firstWhereOrNull((a) => a.name == 'index-as');
    var alias = asAttribute?.value?.compute(scope)?.toString() ?? 'item';
    var indexAs = indexAsAttribute?.value?.compute(scope)?.toString() ?? 'i';
    var otherAttributes = element.attributes.where(
        (a) => a.name != 'for-each' && a.name != 'as' && a.name != 'index-as');
    late Element strippedElement;

    if (element is SelfClosingElement) {
      strippedElement = SelfClosingElement(element.lt, element.tagName,
          otherAttributes, element.slash, element.gt);
    } else if (element is RegularElement) {
      strippedElement = RegularElement(
          element.lt,
          element.tagName,
          otherAttributes,
          element.gt,
          element.children,
          element.lt2,
          element.slash,
          element.tagName2,
          element.gt2);
    }

    var items = attribute.value!.compute(scope);
    if (items is String) {
      // Get value from scope
      items = scope.resolve(items)?.value;
    }

    if (items == null || items is! Iterable) return;

    var i = 0;
    for (var item in items) {
      var childScope = scope.createChild(values: {alias: item, indexAs: i++});
      renderElement(strippedElement, buffer, childScope, html5);
    }
  }

  void renderIf(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var attribute = element.attributes.singleWhere((a) => a.name == 'if');

    var value = attribute.value!.compute(scope);
    var condition = false;

    if (value is String) {
      // Try to get value from scope
      var scopeValue = scope.resolve(value)?.value;
      if (scopeValue != null) {
        value = scopeValue;
      }
    }

    if (value is bool) {
      condition = value;
    } else if (value is String) {
      condition = value.toLowerCase() == 'true';
    } else {
      condition = value != null;
    }

    if (scope.resolve('!strict!')?.value == false) {
      condition = condition == true;
    }

    if (!condition) return;

    var otherAttributes = element.attributes.where((a) => a.name != 'if');
    late Element strippedElement;

    if (element is SelfClosingElement) {
      strippedElement = SelfClosingElement(element.lt, element.tagName,
          otherAttributes, element.slash, element.gt);
    } else if (element is RegularElement) {
      strippedElement = RegularElement(
          element.lt,
          element.tagName,
          otherAttributes,
          element.gt,
          element.children,
          element.lt2,
          element.slash,
          element.tagName2,
          element.gt2);
    }

    renderElement(strippedElement, buffer, scope, html5);
  }

  void renderDeclare(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    for (var attribute in element.attributes) {
      scope.create(attribute.name,
          value: attribute.value?.compute(scope), constant: true);
    }

    for (var i = 0; i < element.children.length; i++) {
      var child = element.children.elementAt(i);
      renderElementChild(
          element, child, buffer, scope, html5, i, element.children.length);
    }
  }

  void renderSwitch(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var value = element.attributes
        .firstWhereOrNull((a) => a.name == 'value')
        ?.value
        ?.compute(scope);

    var cases = element.children
        .whereType<Element>()
        .where((c) => c.tagName.name == 'case');

    for (var child in cases) {
      var comparison = child.attributes
          .firstWhereOrNull((a) => a.name == 'value')
          ?.value
          ?.compute(scope);
      if (comparison == value) {
        for (var i = 0; i < child.children.length; i++) {
          var c = child.children.elementAt(i);
          renderElementChild(
              element, c, buffer, scope, html5, i, child.children.length);
        }

        return;
      }
    }

    var defaultCase = element.children.firstWhereOrNull(
        (c) => c is Element && c.tagName.name == 'default') as Element?;
    if (defaultCase != null) {
      for (var i = 0; i < defaultCase.children.length; i++) {
        var child = defaultCase.children.elementAt(i);
        renderElementChild(element, child, buffer, scope, html5, i,
            defaultCase.children.length);
      }
    }
  }

  void renderElementChild(Element parent, ElementChild child, CodeBuffer buffer,
      SymbolTable scope, bool html5, int index, int total) {
    if (child is Text && parent.tagName.name != 'textarea') {
      var text = child.span.text;
      if (index == 0) {
        text = text.trimLeft();
      }
      if (index == total - 1) {
        text = text.trimRight();
      }
      // Remove extra newlines and normalize whitespace
      text = text.replaceAll(RegExp(r'\n\s*\n'), '\n');
      buffer.write(text);
    } else if (child is Interpolation) {
      var value = child.expression.compute(scope);

      if (value != null) {
        if (child.isRaw) {
          buffer.write(value);
        } else {
          buffer.write(htmlEscape.convert(value.toString()));
        }
      }
    } else if (child is Element) {
      if (buffer.lastLine?.text.isNotEmpty == true) buffer.writeln();
      renderElement(child, buffer, scope, html5);
    }
  }

  static String customElementName(String name) => 'elements@$name';

  void registerCustomElement(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    if (element is! RegularElement) {
      throw JaelError(JaelErrorSeverity.error,
          'Custom elements cannot be self-closing.', element.span);
    }

    var name = element.getAttribute('name')?.value?.compute(scope)?.toString();

    if (name == null) {
      throw JaelError(
          JaelErrorSeverity.error,
          "Attribute 'name' is required when registering a custom element.",
          element.tagName.span);
    }

    try {
      var p = scope.isRoot ? scope : scope.parent!;
      p.create(customElementName(name), value: element, constant: true);
    } on StateError {
      throw JaelError(
          JaelErrorSeverity.error,
          "Cannot re-define element '$name' in this scope.",
          element.getAttribute('name')!.span);
    }
  }

  void renderForm(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    // Get method first to determine if we need CSRF token
    print('All attributes:');
    for (var attr in element.attributes) {
      print(
          'Attribute name: ${attr.name}, string: ${attr.string?.value}, value: ${attr.value?.compute(scope)}');
      print('Attribute name type: ${attr.name.runtimeType}');
      print('Attribute name == "method": ${attr.name == 'method'}');
      print('Attribute name chars: ${attr.name.codeUnits}');
      print('method chars: ${'method'.codeUnits}');
    }
    var methodAttr =
        element.attributes.firstWhereOrNull((a) => a.name == 'method');
    print('Method attr: $methodAttr');
    print('Method attr string: ${methodAttr?.string?.value}');
    print('Method attr value: ${methodAttr?.value?.compute(scope)}');
    var method = methodAttr?.string?.value ??
        methodAttr?.value?.compute(scope)?.toString();
    print('Final method: $method');

    // Start form tag
    buffer.write('<form');

    // Write attributes
    for (var attribute in element.attributes) {
      var value = attribute.string?.value ?? attribute.value?.compute(scope);
      if (value == false || value == null) continue;

      buffer.write(' ');
      buffer.write(attribute.name);
      if (value == true) continue;

      buffer.write('="');
      if (attribute.name == 'method') {
        buffer.write(htmlEscape.convert(method ?? value.toString()));
      } else {
        buffer.write(htmlEscape.convert(value.toString()));
      }
      buffer.write('"');
    }

    buffer.writeln('>');
    buffer.indent();

    // Add CSRF token for POST forms
    if (method?.toUpperCase() == 'POST') {
      var token = scope.resolve('_token')?.value;
      if (token != null) {
        var input = createHiddenInput('_token', token);
        renderElement(input, buffer, scope, html5);
      }
    }

    // Render children
    for (var i = 0; i < element.children.length; i++) {
      var child = element.children.elementAt(i);
      renderElementChild(
          element, child, buffer, scope, html5, i, element.children.length);
    }

    buffer.writeln();
    buffer.outdent();
    buffer.writeln('</form>');
  }

  Element createHiddenInput(String name, String value) {
    // Create a source file for the input element
    final source = SourceFile.fromString(
        '<input type="hidden" name="_token" value="test-token">');
    final span = source.span(0);

    // Create tokens
    final lt = Token(TokenType.lt, span, RegExp('<').matchAsPrefix('<'));
    final input =
        Token(TokenType.id, span, RegExp('input').matchAsPrefix('input'));
    final equals =
        Token(TokenType.equals, span, RegExp('=').matchAsPrefix('='));
    final slash = Token(TokenType.slash, span, RegExp('/').matchAsPrefix('/'));
    final gt = Token(TokenType.gt, span, RegExp('>').matchAsPrefix('>'));

    // Create attribute tokens
    final typeToken =
        Token(TokenType.id, span, RegExp('type').matchAsPrefix('type'));
    final nameToken =
        Token(TokenType.id, span, RegExp('name').matchAsPrefix('name'));
    final valueToken =
        Token(TokenType.id, span, RegExp('value').matchAsPrefix('value'));

    // Create string tokens
    final hiddenToken =
        Token(TokenType.string, span, RegExp('hidden').matchAsPrefix('hidden'));
    final nameValueToken =
        Token(TokenType.string, span, RegExp(name).matchAsPrefix(name));
    final valueValueToken =
        Token(TokenType.string, span, RegExp(value).matchAsPrefix(value));

    // Create attributes
    final attributes = [
      Attribute(Identifier(typeToken), null, equals, null,
          StringLiteral(hiddenToken, 'hidden')),
      Attribute(Identifier(nameToken), null, equals, null,
          StringLiteral(nameValueToken, name)),
      Attribute(Identifier(valueToken), null, equals, null,
          StringLiteral(valueValueToken, value))
    ];

    return SelfClosingElement(lt, Identifier(input), attributes, slash, gt);
  }

  void renderUnless(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var attribute =
        element.attributes.firstWhereOrNull((a) => a.name == 'unless') ??
            element.attributes.firstWhere((a) => a.name == 'unless!');

    var value = attribute.value!.compute(scope);
    var condition = false;

    if (value is String) {
      // Try to get value from scope
      var scopeValue = scope.resolve(value)?.value;
      if (scopeValue != null) {
        value = scopeValue;
      }
    }

    print('Unless condition value: $value (${value.runtimeType})');

    // Handle different value types
    if (value is bool) {
      condition = value;
    } else if (value is num) {
      condition = value != 0;
    } else if (value is String) {
      condition = value.toLowerCase() == 'true';
    } else if (value is Iterable) {
      condition = value.isNotEmpty;
    } else {
      condition = value != null;
    }

    if (scope.resolve('!strict!')?.value == false) {
      condition = condition == true;
    }

    // Unless is inverse of if - only render if condition is false
    if (condition) return;

    var otherAttributes = element.attributes.where((a) => a.name != 'unless');
    late Element strippedElement;

    if (element is SelfClosingElement) {
      strippedElement = SelfClosingElement(element.lt, element.tagName,
          otherAttributes, element.slash, element.gt);
    } else if (element is RegularElement) {
      strippedElement = RegularElement(
          element.lt,
          element.tagName,
          otherAttributes,
          element.gt,
          element.children,
          element.lt2,
          element.slash,
          element.tagName2,
          element.gt2);
    }

    renderElement(strippedElement, buffer, scope, html5);
  }

  void renderCustomElement(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var template = scope.resolve(customElementName(element.tagName.name))!.value
        as RegularElement?;
    var renderAs = element.getAttribute('as')?.value?.compute(scope);
    var attrs = element.attributes.where((a) => a.name != 'as');

    for (var attribute in attrs) {
      if (attribute.name.startsWith('@')) {
        scope.create(attribute.name.substring(1),
            value: attribute.value?.compute(scope), constant: true);
      }
    }

    if (renderAs == false) {
      for (var i = 0; i < template!.children.length; i++) {
        var child = template.children.elementAt(i);
        renderElementChild(
            element, child, buffer, scope, html5, i, element.children.length);
      }
    } else {
      var tagName = renderAs?.toString() ?? 'div';

      var syntheticElement = RegularElement(
          template!.lt,
          SyntheticIdentifier(tagName),
          element.attributes
              .where((a) => a.name != 'as' && !a.name.startsWith('@')),
          template.gt,
          template.children,
          template.lt2,
          template.slash,
          SyntheticIdentifier(tagName),
          template.gt2);

      renderElement(syntheticElement, buffer, scope, html5);
    }
  }
}
