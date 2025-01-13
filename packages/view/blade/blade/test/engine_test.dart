import 'package:blade/src/ast/ast.dart';
import 'package:blade/src/config.dart';
import 'package:blade/src/engine/engine.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

void main() {
  group('Engine', () {
    late Engine engine;
    late BladeConfig config;

    setUp(() {
      config = BladeConfig();
      engine = Engine(config);
    });

    test('renders basic template', () async {
      var compiled = '''
<div>
  <?= \$name ?>
  <?= \$greeting ?>
</div>
''';

      var data = <String, dynamic>{
        'name': 'John',
        'greeting': 'Hello!',
      };

      var output = await engine.render(compiled, data);
      expect(output, contains('John'));
      expect(output, contains('Hello!'));
    });

    test('renders nested data', () async {
      var compiled = '''
<div>
  <?= \$user->name ?>
  <?= \$user->profile->bio ?>
</div>
''';

      var data = <String, dynamic>{
        'user': <String, dynamic>{
          'name': 'John',
          'profile': <String, dynamic>{
            'bio': 'Developer',
          },
        },
      };

      var output = await engine.render(compiled, data);
      expect(output, contains('John'));
      expect(output, contains('Developer'));
    });

    test('renders with template inheritance', () async {
      var compiled = '''
<?php \$__env->startSection('content'); ?>
  <h1><?= \$title ?></h1>
  <div><?= \$content ?></div>
<?php \$__env->endSection(); ?>

<?php \$__env->startSection('sidebar'); ?>
  <nav><?= \$menu ?></nav>
<?php \$__env->endSection(); ?>

<?php echo \$__env->make('layouts.app'); ?>
''';

      var data = <String, dynamic>{
        'title': 'Welcome',
        'content': 'Hello World',
        'menu': 'Navigation',
      };

      var output = await engine.render(compiled, data);
      expect(output, contains('Welcome'));
      expect(output, contains('Hello World'));
      expect(output, contains('Navigation'));
    });

    test('renders components', () async {
      var compiled = '''
<?php echo \$__env->renderComponent('alert', [
  'type' => 'error',
  'message' => \$message,
]); ?>
''';

      var data = <String, dynamic>{
        'message': 'Error occurred',
      };

      // Register a test component
      config.components['alert'] = (attributes) {
        return TestComponent(
          'alert',
          attributes,
          const <String, List<AstNode>>{},
          SourceFile.fromString('').span(0),
        );
      };

      var output = await engine.render(compiled, data);
      expect(output, contains('Error occurred'));
      expect(output, contains('error')); // component type
    });

    test('renders with slots', () async {
      var compiled = '''
<?php \$__env->slot('title'); ?>
  <?= \$title ?>
<?php \$__env->endSlot(); ?>

<?php \$__env->slot('footer'); ?>
  <?= \$footer ?>
<?php \$__env->endSlot(); ?>

<?php echo \$__env->renderComponent('card'); ?>
''';

      var data = <String, dynamic>{
        'title': 'Card Title',
        'footer': 'Card Footer',
      };

      // Register a test component
      config.components['card'] = (attributes) {
        return TestComponent(
          'card',
          attributes,
          const <String, List<AstNode>>{},
          SourceFile.fromString('').span(0),
        );
      };

      var output = await engine.render(compiled, data);
      expect(output, contains('Card Title'));
      expect(output, contains('Card Footer'));
    });

    test('handles missing data gracefully', () async {
      var compiled = '''
<div>
  <?= \$name ?? 'Guest' ?>
  <?= \$greeting ?? 'Welcome' ?>
</div>
''';

      var data = <String, dynamic>{
        'name': 'John',
        // greeting is missing
      };

      var output = await engine.render(compiled, data);
      expect(output, contains('John'));
      expect(output, contains('Welcome')); // default value
    });

    test('handles nested includes', () async {
      var compiled = '''
<?php echo \$__env->make('header', ['title' => \$title]); ?>
<main>
  <?php echo \$__env->make('sidebar', ['menu' => \$menu]); ?>
  <div><?= \$content ?></div>
</main>
<?php echo \$__env->make('footer'); ?>
''';

      var data = <String, dynamic>{
        'title': 'Page Title',
        'menu': <String>['Home', 'About'],
        'content': 'Main Content',
      };

      var output = await engine.render(compiled, data);
      expect(output, contains('Page Title'));
      expect(output, contains('Main Content'));
      expect(output, contains('Home'));
      expect(output, contains('About'));
    });

    test('handles runtime errors gracefully', () async {
      var compiled = '''
<?php echo \$undefined->property; ?>
''';

      var data = <String, dynamic>{};

      expect(() => engine.render(compiled, data), throwsA(isA<BladeError>()));
    });
  });
}

/// A test component for verifying component rendering
class TestComponent extends Component {
  TestComponent(
    String name,
    Map<String, dynamic> attributes,
    Map<String, List<AstNode>> slots,
    FileSpan span,
  ) : super(name, attributes, slots, span);

  @override
  Future<String> render(Map<String, dynamic> data) async {
    var type = attributes['type'] ?? 'default';
    var message = attributes['message'] ?? '';
    return '<div class="$type">$message</div>';
  }
}
