import 'dart:io';
import 'package:path/path.dart' as path;
import 'test_helper.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('translation_test_');
    resetTranslator();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    resetTranslator();
  });

  group('Global API', () {
    test('maintains singleton instance', () {
      final t1 = translator();
      final t2 = translator();
      expect(identical(t1, t2), isTrue);
    });

    test('configures translator with options', () {
      final t = translator(
        paths: ['/path/1', '/path/2'],
        locale: 'es',
        fallback: 'en',
      );

      expect(t.locale, 'es');
      expect(t.fallback, 'en');
    });

    test('trans function works with replacements', () async {
      final file = File(path.join(tempDir.path, 'en.json'));
      await file.writeAsString('{"welcome": "Hello, :name!"}');

      translator(paths: [tempDir.path]);

      expect(
        trans('welcome', replace: {'name': 'John'}),
        'Hello, John!',
      );
    });

    test('choice function handles pluralization', () async {
      final file = File(path.join(tempDir.path, 'en.json'));
      await file.writeAsString('''
        {
          "items": "You have :count item|You have :count items"
        }
      ''');

      translator(paths: [tempDir.path]);

      expect(
        choice('items', 1, replace: {'count': 1}),
        'You have 1 item',
      );
      expect(
        choice('items', 5, replace: {'count': 5}),
        'You have 5 items',
      );
    });

    test('setLocale changes default locale', () async {
      final enFile = File(path.join(tempDir.path, 'en.json'));
      await enFile.writeAsString('{"msg": "English"}');

      final esFile = File(path.join(tempDir.path, 'es.json'));
      await esFile.writeAsString('{"msg": "Spanish"}');

      translator(paths: [tempDir.path]);

      expect(trans('msg'), 'English');

      setLocale('es');
      expect(trans('msg'), 'Spanish');
    });

    test('setFallbackLocale sets fallback', () async {
      final enFile = File(path.join(tempDir.path, 'en.json'));
      await enFile.writeAsString('{"msg": "English"}');

      translator(paths: [tempDir.path]);
      setFallbackLocale('en');

      expect(trans('msg', locale: 'fr', fallback: true), 'English');
    });

    test('addNamespace registers namespace', () async {
      final vendorDir = Directory(path.join(tempDir.path, 'vendor', 'package'));
      await vendorDir.create(recursive: true);

      final file = File(path.join(vendorDir.path, 'en', 'messages.yaml'));
      await file.create(recursive: true);
      await file.writeAsString('title: Package Title');

      translator(paths: [tempDir.path]);
      addNamespace('package', vendorDir.path);

      expect(trans('package::messages.title'), 'Package Title');
    });

    test('addJsonPath registers JSON path', () async {
      final extraDir =
          await Directory.systemTemp.createTemp('translation_extra_');
      final extraFile = File(path.join(extraDir.path, 'en.json'));
      await extraFile.writeAsString('{"extra": "Extra Message"}');

      translator(paths: [tempDir.path]);
      addJsonPath(extraDir.path);

      expect(trans('extra'), 'Extra Message');

      await extraDir.delete(recursive: true);
    });

    test('addLines adds translations directly', () {
      translator();
      addLines({
        'hello': 'Hello',
        'bye': 'Goodbye',
      }, 'en');

      expect(trans('hello'), 'Hello');
      expect(trans('bye'), 'Goodbye');
    });

    test('resetTranslator clears singleton', () {
      final t1 = translator();
      resetTranslator();
      final t2 = translator();

      expect(identical(t1, t2), isFalse);
    });
  });
}
