import 'package:test/test.dart';
import 'package:source_span/source_span.dart';
import 'package:belatuk_code_buffer/belatuk_code_buffer.dart';
import 'package:belatuk_symbol_table/belatuk_symbol_table.dart';
import 'package:illuminate_view/src/core/renderer.dart';
import '../helpers/test_helpers.dart';

void main() {
  late Renderer renderer;
  late CodeBuffer buffer;
  late SymbolTable scope;
  late SourceFile source;

  setUp(() {
    renderer = Renderer();
    buffer = CodeBuffer();
    scope = SymbolTable();
    source = SourceFile.fromString('form');
  });

  test('adds csrf token to POST forms', () {
    // Setup
    scope.create('_token', value: 'test-token');

    final form = createElement(
        'form', [createAttribute('method', 'post', source, 0)], [], source, 0);

    // Act
    renderer.renderElement(form, buffer, scope, true);
    final output = buffer.toString();

    // Assert
    expect(output, contains('<input type="hidden"'));
    expect(output, contains('name="_token"'));
    expect(output, contains('value="test-token"'));
  });

  test('does not add csrf token to GET forms', () {
    scope.create('_token', value: 'test-token');
    final form = createElement(
        'form', [createAttribute('method', 'GET', source, 0)], [], source, 0);

    renderer.renderElement(form, buffer, scope, true);
    expect(buffer.toString(), isNot(contains('name="_token"')));
  });

  test('handles missing method attribute', () {
    scope.create('_token', value: 'test-token');
    final form = createElement('form', [], [], source, 0);

    renderer.renderElement(form, buffer, scope, true);
    expect(buffer.toString(), isNot(contains('name="_token"')));
  });

  test('handles missing token in scope', () {
    final form = createElement(
        'form', [createAttribute('method', 'POST', source, 0)], [], source, 0);

    renderer.renderElement(form, buffer, scope, true);
    expect(buffer.toString(), isNot(contains('name="_token"')));
  });
}
