import 'package:blade/src/ast/ast.dart';
import 'package:blade/src/compiler/blade_parser.dart';
import 'package:blade/src/scanner/scanner.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

void main() {
  group('BladeParser', () {
    late SourceFile source;
    late Scanner scanner;
    late BladeParser parser;

    setUp(() {
      source = SourceFile.fromString('');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);
    });

    test('parses basic template structure', () {
      source = SourceFile.fromString('''
<div class="container">
  {{ \$title }}
  <p>{{ \$content }}</p>
</div>
''');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);

      var ast = parser.parse();
      expect(parser.errors, isEmpty);

      expect(ast.children, hasLength(1));
      var div = ast.children[0] as ElementNode;
      expect(div.tagName, equals('div'));
      expect(div.attributes['class'], equals('container'));
      expect(div.children, hasLength(3)); // text, expression, element
    });

    test('parses if directive', () {
      source = SourceFile.fromString('''
@if (\$isAdmin)
  <h1>Admin Panel</h1>
@else
  <p>Access Denied</p>
@endif
''');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);

      var ast = parser.parse();
      expect(parser.errors, isEmpty);

      expect(ast.children, hasLength(1));
      var ifNode = ast.children[0] as IfDirective;
      expect(ifNode.condition, isA<VariableNode>());
      expect((ifNode.condition as VariableNode).name, equals('isAdmin'));
      expect(ifNode.children, hasLength(1)); // h1 element
      expect(ifNode.elseBranch, hasLength(1)); // p element
    });

    test('parses foreach directive', () {
      source = SourceFile.fromString('''
@foreach (\$users as \$user)
  <div>{{ \$user->name }}</div>
@endforeach
''');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);

      var ast = parser.parse();
      expect(parser.errors, isEmpty);

      expect(ast.children, hasLength(1));
      var foreachNode = ast.children[0] as ForeachDirective;
      expect(foreachNode.items, isA<VariableNode>());
      expect((foreachNode.items as VariableNode).name, equals('users'));
      expect(foreachNode.itemName, equals('user'));
      expect(foreachNode.children, hasLength(1)); // div element
    });

    test('parses section and yield directives', () {
      source = SourceFile.fromString('''
@section('content')
  <h1>{{ \$title }}</h1>
  <div>{{ \$body }}</div>
@endsection

@yield('sidebar')
''');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);

      var ast = parser.parse();
      expect(parser.errors, isEmpty);

      expect(ast.sections, hasLength(1));
      var section = ast.sections['content']!;
      expect(section.sectionName, equals('content'));
      expect(section.children, hasLength(2)); // h1 and div elements

      expect(ast.yields, hasLength(1));
      var yield_ = ast.yields['sidebar']!;
      expect(yield_.sectionName, equals('sidebar'));
    });

    test('parses template inheritance', () {
      source = SourceFile.fromString('''
@extends('layouts.app')

@section('content')
  <h1>Page Title</h1>
@endsection

@section('sidebar')
  <nav>Menu</nav>
@endsection
''');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);

      var ast = parser.parse();
      expect(parser.errors, isEmpty);

      expect(ast.hasParent, isTrue);
      expect(ast.extends_?.layout, equals('layouts.app'));
      expect(ast.sections, hasLength(2));
      expect(ast.sections.keys, containsAll(['content', 'sidebar']));
    });

    test('parses include directive', () {
      source = SourceFile.fromString('''
<div>
  @include('partials.header', ['title' => \$title])
  <main>{{ \$content }}</main>
  @include('partials.footer')
</div>
''');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);

      var ast = parser.parse();
      expect(parser.errors, isEmpty);

      var div = ast.children[0] as ElementNode;
      var include1 = div.children[1] as IncludeDirective;
      var include2 = div.children[5] as IncludeDirective;

      expect(include1.view, equals('partials.header'));
      expect(include1.data, hasLength(1));
      expect(include1.data!['title'], isA<VariableNode>());

      expect(include2.view, equals('partials.footer'));
      expect(include2.data, isNull);
    });

    test('handles syntax errors gracefully', () {
      source = SourceFile.fromString('''
@if
  <div>Unclosed tag
@endif
''');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);

      var ast = parser.parse();
      expect(parser.errors, isNotEmpty);
      expect(parser.errors.first.message, contains('Expected identifier'));
    });

    test('handles nested directives', () {
      source = SourceFile.fromString('''
@foreach (\$users as \$user)
  @if (\$user->isAdmin)
    @foreach (\$user->permissions as \$permission)
      <li>{{ \$permission }}</li>
    @endforeach
  @endif
@endforeach
''');
      scanner = Scanner(source);
      parser = BladeParser(scanner.scan(), source);

      var ast = parser.parse();
      expect(parser.errors, isEmpty);

      var foreach1 = ast.children[0] as ForeachDirective;
      var if_ = foreach1.children[1] as IfDirective;
      var foreach2 = if_.children[1] as ForeachDirective;

      expect(foreach1.itemName, equals('user'));
      expect(foreach2.itemName, equals('permission'));
    });
  });
}
