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

    // Check for conditional attributes
    if (element.attributes.any((a) => a.name == 'if')) {
      var ifAttribute = element.attributes.singleWhere((a) => a.name == 'if');
      var condition =
          _evaluateCondition(ifAttribute.value!.compute(scope), scope);
      if (!condition) return;
      element = _stripAttribute(element, 'if');
    } else if (element.attributes.any((a) => a.name == 'else-if')) {
      var elseIfAttribute =
          element.attributes.singleWhere((a) => a.name == 'else-if');
      var condition =
          _evaluateCondition(elseIfAttribute.value!.compute(scope), scope);
      if (!condition) return;
      element = _stripAttribute(element, 'else-if');
    }

    if (element.attributes.any((a) => a.name == 'for-each')) {
      renderForeach(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'unless')) {
      renderUnless(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'isset')) {
      renderIsset(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'empty')) {
      renderEmpty(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'auth')) {
      renderAuth(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'guest')) {
      renderGuest(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'production')) {
      renderProduction(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'env')) {
      renderEnv(element, buffer, childScope, html5);
      return;
    } else if (element.attributes.any((a) => a.name == 'method')) {
      renderMethod(element, buffer, childScope, html5);
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

    // Check if this element has conditional children
    var hasConditionalChildren = element.children.any((child) {
      if (child is! Element) return false;
      return child.attributes.any(
          (a) => a.name == 'if' || a.name == 'else-if' || a.name == 'else');
    });

    if (hasConditionalChildren) {
      renderIf(element, buffer, scope, html5);
      return;
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

  bool _evaluateCondition(dynamic value, SymbolTable scope) {
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

    return condition;
  }

  Element _stripAttribute(Element element, String attributeName) {
    var otherAttributes =
        element.attributes.where((a) => a.name != attributeName);

    if (element is SelfClosingElement) {
      return SelfClosingElement(element.lt, element.tagName, otherAttributes,
          element.slash, element.gt);
    } else if (element is RegularElement) {
      return RegularElement(
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

    return element;
  }

  void renderIf(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    if (element is! RegularElement) return;

    // Write opening tag and attributes
    buffer.write('<${element.tagName.name}');
    for (var attribute in element.attributes) {
      var value = attribute.value?.compute(scope);
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
    buffer.writeln('>');
    buffer.indent();

    // Process children
    var children = element.children.toList();
    var i = 0;
    var foundIf = false;
    var foundMatch = false;
    var inConditionalChain = false;

    try {
      while (i < children.length) {
        var child = children[i];
        if (child is! Element) {
          if (!inConditionalChain) {
            renderElementChild(
                element, child, buffer, scope, html5, i, children.length);
          }
          i++;
          continue;
        }

        // Check for start of conditional chain
        if (child.attributes.any((a) => a.name == 'if')) {
          foundIf = true;
          inConditionalChain = true;
          var condition = _evaluateCondition(
              child.attributes
                  .singleWhere((a) => a.name == 'if')
                  .value!
                  .compute(scope),
              scope);

          if (condition) {
            renderElement(_stripAttribute(child, 'if'), buffer, scope, html5);
            foundMatch = true;
            return;
          }
        } else if (foundIf && !foundMatch) {
          // Handle else-if conditions
          if (child.attributes.any((a) => a.name == 'else-if')) {
            var condition = _evaluateCondition(
                child.attributes
                    .singleWhere((a) => a.name == 'else-if')
                    .value!
                    .compute(scope),
                scope);
            if (condition) {
              renderElement(
                  _stripAttribute(child, 'else-if'), buffer, scope, html5);
              foundMatch = true;
              return;
            }
          }
          // Handle else condition
          else if (child.attributes.any((a) => a.name == 'else')) {
            if (!foundMatch) {
              renderElement(
                  _stripAttribute(child, 'else'), buffer, scope, html5);
              foundMatch = true;
            }
            return;
          }
          // Exit if we find a non-conditional element after starting a chain
          else if (!child.attributes.any((a) => a.name == 'else-if')) {
            return;
          }
        } else if (!inConditionalChain) {
          renderElement(child, buffer, scope, html5);
        }
        i++;
      }
    } finally {
      buffer.outdent();
      buffer.writeln('</${element.tagName.name}>');
    }
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
    if (element is! RegularElement) return;

    var methodAttr =
        element.attributes.firstWhereOrNull((a) => a.name == 'method');
    var methodValue = methodAttr?.value?.compute(scope);
    var method = methodValue?.toString().toUpperCase() ?? 'GET';

    // Write opening tag
    buffer.write('<form');

    // Write method attribute
    buffer.write(' method="${htmlEscape.convert(method)}"');

    // Write other attributes
    for (var attribute in element.attributes) {
      if (attribute.name == 'method') continue;
      var value = attribute.value?.compute(scope);
      if (value == false || value == null && !attribute.isRaw) continue;

      buffer.write(' ${attribute.name}="');
      if (attribute.isRaw && attribute.string != null) {
        buffer.write(attribute.string!.value);
      } else {
        buffer.write(htmlEscape.convert(value.toString()));
      }
      buffer.write('"');
    }

    buffer.write('>');

    // Add CSRF token for POST forms
    if (method == 'POST') {
      var token = scope.resolve('_token')?.value;
      if (token != null) {
        buffer.write(
            '<input type="hidden" name="_token" value="${htmlEscape.convert(token.toString())}">');
      }
    }

    // Render children
    if (element.children.isNotEmpty) {
      buffer.indent();
      for (var i = 0; i < element.children.length; i++) {
        var child = element.children.elementAt(i);
        if (child is Element &&
            child.attributes.any((a) => a.name == 'method')) {
          renderMethod(child, buffer, scope, html5, insideForm: true);
        } else {
          renderElementChild(
              element, child, buffer, scope, html5, i, element.children.length);
        }
      }
      buffer.outdent();
    }

    buffer.write('</form>');
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

  void renderIsset(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var attribute = element.attributes.singleWhere((a) => a.name == 'isset');
    var value = attribute.value!.compute(scope);
    var isSet = false;

    if (value is String) {
      // Handle multiple variables with && operator
      if (value.contains('&&')) {
        var variables = value.split('&&').map((v) => v.trim());
        isSet = variables.every((variable) {
          var val = scope.resolve(variable)?.value;
          return val != null;
        });
      } else {
        // Handle nested properties with dot notation
        var parts = value.split('.');
        dynamic val = scope.resolve(parts[0])?.value;
        for (var i = 1; i < parts.length && val != null; i++) {
          if (val is Map) {
            val = val[parts[i]];
          } else {
            val = null;
            break;
          }
        }
        isSet = val != null;
      }
    }

    if (!isSet) return;

    var strippedElement = _stripAttribute(element, 'isset');
    renderElement(strippedElement, buffer, scope, html5);
  }

  void renderEmpty(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var attribute = element.attributes.singleWhere((a) => a.name == 'empty');
    var value = attribute.value!.compute(scope);
    var isEmpty = true;

    if (value is String) {
      // Handle nested properties with dot notation
      var parts = value.split('.');
      dynamic val = scope.resolve(parts[0])?.value;
      for (var i = 1; i < parts.length && val != null; i++) {
        if (val is Map) {
          val = val[parts[i]];
        } else {
          val = null;
          break;
        }
      }
      value = val;
    } else {
      // Try to get value from scope if it's a simple variable
      var scopeValue = scope.resolve(value)?.value;
      if (scopeValue != null) {
        value = scopeValue;
      }
    }

    // Check if value is not empty
    if (value != null) {
      if (value is String && value.isNotEmpty) {
        isEmpty = false;
      } else if (value is Iterable && value.isNotEmpty) {
        isEmpty = false;
      } else if (value is num && value != 0) {
        isEmpty = false;
      } else if (value is bool && value == true) {
        isEmpty = false;
      }
    }

    if (!isEmpty) return;

    var strippedElement = _stripAttribute(element, 'empty');
    renderElement(strippedElement, buffer, scope, html5);
  }

  void renderAuth(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var attribute =
        element.attributes.firstWhereOrNull((a) => a.name == 'auth');
    var guard = attribute?.value?.compute(scope)?.toString() ?? 'default';
    var isAuthenticated = false;

    // Get auth value from scope
    var auth = scope.resolve('auth')?.value;
    if (auth != null) {
      if (auth is bool) {
        // Simple boolean auth check
        isAuthenticated = auth;
      } else if (auth is Map) {
        // Check specific guard
        var guardValue = auth[guard];
        if (guardValue is bool) {
          isAuthenticated = guardValue;
        }
      }
    }

    if (!isAuthenticated) return;

    var strippedElement = _stripAttribute(element, 'auth');
    renderElement(strippedElement, buffer, scope, html5);
  }

  void renderGuest(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var attribute =
        element.attributes.firstWhereOrNull((a) => a.name == 'guest');
    var guard = attribute?.value?.compute(scope)?.toString() ?? 'default';
    var isGuest = true;

    // Get auth value from scope
    var auth = scope.resolve('auth')?.value;
    if (auth != null) {
      if (auth is bool) {
        // Simple boolean auth check
        isGuest = !auth;
      } else if (auth is Map) {
        // Check specific guard
        var guardValue = auth[guard];
        if (guardValue is bool) {
          isGuest = !guardValue;
        }
      }
    }

    if (!isGuest) return;

    var strippedElement = _stripAttribute(element, 'guest');
    renderElement(strippedElement, buffer, scope, html5);
  }

  void renderProduction(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var isProduction = false;

    // Get app environment from scope
    var app = scope.resolve('app')?.value;
    if (app is Map) {
      var env = app['env'];
      if (env is String) {
        isProduction = env.toLowerCase() == 'production';
      }
    }

    if (!isProduction) return;

    var strippedElement = _stripAttribute(element, 'production');
    renderElement(strippedElement, buffer, scope, html5);
  }

  void renderEnv(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5) {
    var attribute = element.attributes.singleWhere((a) => a.name == 'env');
    var envList =
        attribute.value!.compute(scope).toString().toLowerCase().split(',');
    var isMatchingEnv = false;

    // Get app environment from scope
    var app = scope.resolve('app')?.value;
    if (app is Map) {
      var env = app['env'];
      if (env is String) {
        // Check if current environment matches any in the comma-separated list
        isMatchingEnv = envList.any((e) => e.trim() == env.toLowerCase());
      }
    }

    if (!isMatchingEnv) return;

    var strippedElement = _stripAttribute(element, 'env');
    renderElement(strippedElement, buffer, scope, html5);
  }

  void renderMethod(
      Element element, CodeBuffer buffer, SymbolTable scope, bool html5,
      {bool insideForm = false}) {
    var attribute = element.attributes.singleWhere((a) => a.name == 'method');
    var method = attribute.value!.compute(scope).toString().toUpperCase();

    // Only add _method field for PUT, PATCH, DELETE methods inside a form
    if (insideForm && method != 'GET' && method != 'POST') {
      buffer.write(
          '<input type="hidden" name="_method" value="${htmlEscape.convert(method)}">');
    }

    var strippedElement = _stripAttribute(element, 'method');
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
