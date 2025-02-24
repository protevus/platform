import 'dart:io';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';
import 'package:illuminate_filesystem/filesystem.dart';
import 'mocks/view_mocks.mocks.dart';

void main() {
  group('View Composer Tests', () {
    late ViewFactory factory;
    late EngineResolver engines;
    late FileViewFinder finder;
    late MockViewEngine engine;

    Future<void> createView(String name, [String content = '']) async {
      // Create base views directory
      final baseDir = Directory('views');
      if (!baseDir.existsSync()) {
        baseDir.createSync();
      }

      final segments = name.split('/');
      var currentPath = baseDir.path;

      // Create all parent directories if needed
      for (var i = 0; i < segments.length - 1; i++) {
        currentPath = '$currentPath/${segments[i]}';
        final dir = Directory(currentPath);
        if (!dir.existsSync()) {
          dir.createSync();
        }
      }

      // Create the view file
      final file = File('views/$name.blade.html');
      await file.writeAsString(content);
    }

    setUp(() async {
      engines = EngineResolver();
      finder = FileViewFinder();
      engine = MockViewEngine();
      factory = ViewFactory(engines, finder);

      // Register test engine
      engines.register('blade', () => engine);
      finder.addExtension('blade.html');
      finder.addLocation('views');

      when(engine.get(any, any)).thenAnswer((_) async => 'rendered');

      // Create test views
      await createView('profile');
      await createView('dashboard');
      await createView('user/profile');
    });

    tearDown(() {
      // Clean up test views
      final dir = Directory('views');
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('composer is called when view is rendered', () async {
      var composerCalled = false;
      factory.composer('profile', (String event, List<dynamic> args) {
        composerCalled = true;
        (args[0] as View).withManyData({'composer_var': 'composer_value'});
      });

      final view = await factory.make('profile');
      expect(composerCalled, isTrue);
      expect(view.toArray()['composer_var'], equals('composer_value'));
    });

    test('composer can be registered for multiple views', () async {
      var composerCallCount = 0;
      factory.composer(['profile', 'dashboard'],
          (String event, List<dynamic> args) {
        composerCallCount++;
        (args[0] as View).withManyData({'count': composerCallCount});
      });

      await factory.make('profile');
      await factory.make('dashboard');
      expect(composerCallCount, equals(2));
    });

    test('composer can be registered using wildcards', () async {
      var composerCalled = false;
      factory.composer('user.*', (String event, List<dynamic> args) {
        composerCalled = true;
        (args[0] as View).withManyData({'composer_var': 'composer_value'});
      });

      await factory.make('user.profile');
      expect(composerCalled, isTrue);
    });

    test('composer class can be registered', () async {
      factory.composer('profile', (String event, List<dynamic> args) {
        ProfileComposer().compose(args[0] as View);
      });

      final view = await factory.make('profile');
      expect(view.toArray()['user_name'], equals('John Doe'));
    });

    test('composer can be registered once', () async {
      var callCount = 0;
      factory.composer('profile', (String event, List<dynamic> args) {
        callCount++;
      });

      await factory.make('profile');
      await factory.make('profile');
      expect(callCount, equals(1));
    });

    test('composer can modify view data', () async {
      factory.composer('profile', (String event, List<dynamic> args) {
        final view = args[0] as View;
        final original = view.toArray()['original'] as String;
        view.withManyData({
          'modified': original + ' modified',
        });
      });

      final view = await factory.make('profile', {'original': 'value'});
      expect(view.toArray()['modified'], equals('value modified'));
    });
  });
}

class ProfileComposer {
  void compose(View view) {
    view.withManyData({'user_name': 'John Doe'});
  }
}
