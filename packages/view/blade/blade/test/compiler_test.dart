import 'package:blade/src/ast/ast.dart' show BladeError;
import 'package:blade/src/compiler/compiler.dart';
import 'package:blade/src/config.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

void main() {
  group('Compiler', () {
    late Compiler compiler;

    setUp(() {
      compiler = Compiler(BladeConfig());
    });

    test('compiles basic expressions', () async {
      var source = SourceFile.fromString('''
<div>
  Hello, {{ \$name }}!
  {!! \$rawHtml !!}
</div>
''');

      var output = await compiler.compile(source);
      expect(output, contains('Hello, <?= \$name ?>!'));
      expect(output, contains('<?= \$rawHtml ?>'));
    });

    test('compiles if directives', () async {
      var source = SourceFile.fromString('''
@if (\$isAdmin)
  <h1>Admin Panel</h1>
@else
  <p>Access Denied</p>
@endif
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php if (\$isAdmin): ?>'));
      expect(output, contains('<h1>Admin Panel</h1>'));
      expect(output, contains('<?php else: ?>'));
      expect(output, contains('<p>Access Denied</p>'));
      expect(output, contains('<?php endif; ?>'));
    });

    test('compiles foreach loops', () async {
      var source = SourceFile.fromString('''
<ul>
  @foreach (\$items as \$item)
    <li>{{ \$item }}</li>
  @endforeach
</ul>
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php foreach (\$items as \$item): ?>'));
      expect(output, contains('<li><?= \$item ?></li>'));
      expect(output, contains('<?php endforeach; ?>'));
    });

    test('compiles template inheritance', () async {
      var source = SourceFile.fromString('''
@extends('layouts.app')

@section('content')
  <h1>{{ \$title }}</h1>
  <div>{{ \$content }}</div>
@endsection

@section('sidebar')
  <nav>Menu</nav>
@endsection
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php \$__env->startSection(\'content\'); ?>'));
      expect(output, contains('<h1><?= \$title ?></h1>'));
      expect(output, contains('<?php \$__env->endSection(); ?>'));
      expect(output, contains('<?php echo \$__env->make(\'layouts.app\'); ?>'));
    });

    test('compiles components', () async {
      var source = SourceFile.fromString('''
<x-alert type="error" :message="\$message">
  <x-slot name="title">
    {{ \$title }}
  </x-slot>
  
  <p>Default content</p>
</x-alert>
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php echo \$__env->renderComponent(\'alert\''));
      expect(output, contains('\'type\' => \'error\''));
      expect(output, contains('\'message\' => \$message'));
      expect(output, contains('<?php \$__env->slot(\'title\'); ?>'));
      expect(output, contains('<?= \$title ?>'));
      expect(output, contains('<?php \$__env->endSlot(); ?>'));
    });

    test('compiles includes', () async {
      var source = SourceFile.fromString('''
@include('header', ['title' => \$title])
<main>
  {{ \$content }}
</main>
@include('footer')
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php echo \$__env->make(\'header\''));
      expect(output, contains('\'title\' => \$title'));
      expect(output, contains('<main>'));
      expect(output, contains('<?= \$content ?>'));
      expect(output, contains('<?php echo \$__env->make(\'footer\''));
    });

    test('handles compilation errors', () async {
      var source = SourceFile.fromString('''
@if
  <div>Unclosed tag
@endif
''');

      expect(() => compiler.compile(source), throwsA(isA<BladeError>()));
    });

    test('compiles nested structures', () async {
      var source = SourceFile.fromString('''
@foreach (\$users as \$user)
  @if (\$user->isAdmin)
    @foreach (\$user->permissions as \$permission)
      <li>{{ \$permission }}</li>
    @endforeach
  @endif
@endforeach
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php foreach (\$users as \$user): ?>'));
      expect(output, contains('<?php if (\$user->isAdmin): ?>'));
      expect(output,
          contains('<?php foreach (\$user->permissions as \$permission): ?>'));
      expect(output, contains('<li><?= \$permission ?></li>'));
      expect(output, contains('<?php endforeach; ?>'));
      expect(output, contains('<?php endif; ?>'));
      expect(output, contains('<?php endforeach; ?>'));
    });

    test('compiles switch statements', () async {
      var source = SourceFile.fromString('''
@switch(\$type)
  @case('user')
    <p>Regular User</p>
    @break
  @case('admin')
    <p>Administrator</p>
    @break
  @default
    <p>Guest</p>
@endswitch
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php switch(\$type): ?>'));
      expect(output, contains('<?php case \'user\': ?>'));
      expect(output, contains('<p>Regular User</p>'));
      expect(output, contains('<?php break; ?>'));
      expect(output, contains('<?php case \'admin\': ?>'));
      expect(output, contains('<p>Administrator</p>'));
      expect(output, contains('<?php default: ?>'));
      expect(output, contains('<p>Guest</p>'));
      expect(output, contains('<?php endswitch; ?>'));
    });

    test('compiles unless directives', () async {
      var source = SourceFile.fromString('''
@unless (\$isGuest)
  <p>Welcome back!</p>
@endunless
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php if (! (\$isGuest)): ?>'));
      expect(output, contains('<p>Welcome back!</p>'));
      expect(output, contains('<?php endif; ?>'));
    });

    test('compiles auth directives', () async {
      var source = SourceFile.fromString('''
@auth
  <p>Welcome, {{ \$user->name }}!</p>
@else
  <p>Please log in.</p>
@endauth
''');

      var output = await compiler.compile(source);
      expect(output, contains('<?php if(auth()->check()): ?>'));
      expect(output, contains('<p>Welcome, <?= \$user->name ?>!</p>'));
      expect(output, contains('<?php else: ?>'));
      expect(output, contains('<p>Please log in.</p>'));
      expect(output, contains('<?php endif; ?>'));
    });
  });
}
