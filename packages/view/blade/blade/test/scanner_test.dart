import 'package:blade/src/scanner/scanner.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

void main() {
  group('Scanner', () {
    late SourceFile source;
    late Scanner scanner;

    setUp(() {
      source = SourceFile.fromString('''
<div>
  {{ \$name }}
  @if (\$isAdmin)
    <h1>Admin Panel</h1>
  @endif
  {!! \$rawHtml !!}
  {{-- Comment --}}
</div>
''');
      scanner = Scanner(source);
    });

    test('scans basic tokens correctly', () {
      var tokens = scanner.scan();
      expect(scanner.errors, isEmpty);

      var types = tokens.map((t) => t.type).toList();
      expect(
          types,
          containsAllInOrder([
            TokenType.openTag,
            TokenType.identifier,
            TokenType.closeTag,
            TokenType.whitespace,
            TokenType.expression,
            TokenType.whitespace,
            TokenType.directive,
            TokenType.openTag,
            TokenType.identifier,
            TokenType.closeTag,
            TokenType.text,
            TokenType.openTag,
            TokenType.slash,
            TokenType.identifier,
            TokenType.closeTag,
            TokenType.whitespace,
            TokenType.directive,
            TokenType.whitespace,
            TokenType.rawExpression,
            TokenType.whitespace,
            TokenType.comment,
            TokenType.whitespace,
            TokenType.openTag,
            TokenType.slash,
            TokenType.identifier,
            TokenType.closeTag,
            TokenType.eof,
          ]));
    });

    test('handles nested structures', () {
      source = SourceFile.fromString('''
@if (\$user)
  @foreach (\$items as \$item)
    <p>{{ \$item }}</p>
  @endforeach
@endif
''');
      scanner = Scanner(source);
      var tokens = scanner.scan();
      expect(scanner.errors, isEmpty);

      var directives = tokens
          .where((t) => t.type == TokenType.directive)
          .map((t) => t.lexeme)
          .toList();
      expect(directives, ['@if', '@foreach', '@endforeach', '@endif']);
    });

    test('handles blade comments', () {
      source = SourceFile.fromString('''
{{-- This is a comment --}}
<div>
  {{-- Nested
      multiline
      comment --}}
</div>
''');
      scanner = Scanner(source);
      var tokens = scanner.scan();
      expect(scanner.errors, isEmpty);

      var comments = tokens
          .where((t) => t.type == TokenType.comment)
          .map((t) => t.lexeme)
          .toList();
      expect(comments.length, 2);
      expect(comments[0], contains('This is a comment'));
      expect(comments[1], contains('Nested\n      multiline\n      comment'));
    });

    test('handles unterminated expressions', () {
      source = SourceFile.fromString('{{ \$name');
      scanner = Scanner(source);
      var tokens = scanner.scan();
      expect(scanner.errors, hasLength(1));
      expect(scanner.errors.first.message, contains('Unterminated expression'));
    });

    test('handles unterminated raw expressions', () {
      source = SourceFile.fromString('{!! \$html');
      scanner = Scanner(source);
      var tokens = scanner.scan();
      expect(scanner.errors, hasLength(1));
      expect(scanner.errors.first.message,
          contains('Unterminated raw expression'));
    });

    test('handles unterminated comments', () {
      source = SourceFile.fromString('{{-- Comment');
      scanner = Scanner(source);
      var tokens = scanner.scan();
      expect(scanner.errors, hasLength(1));
      expect(scanner.errors.first.message, contains('Unterminated comment'));
    });

    test('handles unterminated tags', () {
      source = SourceFile.fromString('<div');
      scanner = Scanner(source);
      var tokens = scanner.scan();
      expect(scanner.errors, hasLength(1));
      expect(scanner.errors.first.message, contains('Unterminated tag'));
    });
  });
}
