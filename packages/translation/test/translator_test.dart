import 'dart:io';
import 'package:path/path.dart' as path;
import 'test_helper.dart';

void main() {
  late Directory tempDir;
  late FileLoader loader;
  late Translator translator;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('translation_test_');
    loader = FileLoader([tempDir.path]);
    translator = Translator(loader, 'en');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Translator', () {
    test('retrieves basic translations', () async {
      final file = File(path.join(tempDir.path, 'en.json'));
      await file.writeAsString('{"hello": "Hello!"}');

      expect(translator.translate('hello'), 'Hello!');
    });

    test('handles missing translations', () {
      expect(translator.translate('missing'), 'missing');
    });

    test('handles replacements', () async {
      final file = File(path.join(tempDir.path, 'en.json'));
      await file.writeAsString('''
        {
          "welcome": "Welcome, :name!",
          "status": ":Name has :count messages"
        }
      ''');

      expect(
        translator.translate('welcome', replace: {'name': 'John'}),
        'Welcome, John!',
      );

      expect(
        translator.translate(
          'status',
          replace: {'name': 'john', 'count': 5},
        ),
        'John has 5 messages',
      );
    });

    test('handles fallback locales', () async {
      final enFile = File(path.join(tempDir.path, 'en.json'));
      await enFile.writeAsString('{"msg": "English"}');

      final esFile = File(path.join(tempDir.path, 'es.json'));
      await esFile.writeAsString('{"msg": "Spanish"}');

      translator.fallback = 'en';

      expect(translator.translate('msg', locale: 'es'), 'Spanish');
      expect(translator.translate('missing', locale: 'es'), 'missing');

      // Should fall back to English
      expect(
        translator.translate('msg', locale: 'fr', fallback: true),
        'English',
      );
    });

    test('handles file-based translations', () async {
      final dir = Directory(path.join(tempDir.path, 'en'));
      await dir.create();
      final file = File(path.join(dir.path, 'messages.yaml'));
      await file.writeAsString('''
        greeting: Hello!
        farewell: Goodbye!
      ''');

      expect(translator.translate('messages.greeting'), 'Hello!');
      expect(translator.translate('messages.farewell'), 'Goodbye!');
    });

    test('handles namespaced translations', () async {
      final vendorDir = Directory(path.join(tempDir.path, 'vendor', 'package'));
      await vendorDir.create(recursive: true);

      final file = File(path.join(vendorDir.path, 'en', 'messages.yaml'));
      await file.create(recursive: true);
      await file.writeAsString('''
        title: Package Title
        desc: Package Description
      ''');

      translator.addNamespace('package', vendorDir.path);

      expect(
        translator.translate('package::messages.title'),
        'Package Title',
      );
      expect(
        translator.translate('package::messages.desc'),
        'Package Description',
      );
    });

    test('handles pluralization', () async {
      final file = File(path.join(tempDir.path, 'en.json'));
      await file.writeAsString('''
        {
          "apples": "apple|apples",
          "messages": "You have :count message|You have :count messages"
        }
      ''');

      expect(translator.choice('apples', 1), 'apple');
      expect(translator.choice('apples', 2), 'apples');

      expect(
        translator.choice('messages', 1, replace: {'count': 1}),
        'You have 1 message',
      );
      expect(
        translator.choice('messages', 5, replace: {'count': 5}),
        'You have 5 messages',
      );
    });

    test('handles locale switching', () async {
      final enFile = File(path.join(tempDir.path, 'en.json'));
      await enFile.writeAsString('{"msg": "English"}');

      final esFile = File(path.join(tempDir.path, 'es.json'));
      await esFile.writeAsString('{"msg": "Spanish"}');

      expect(translator.translate('msg'), 'English');

      translator.locale = 'es';
      expect(translator.translate('msg'), 'Spanish');

      translator.locale = 'en';
      expect(translator.translate('msg'), 'English');
    });

    test('validates locale format', () {
      expect(
        () => translator.locale = 'en/US',
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => translator.locale = 'en\\US',
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles adding lines directly', () {
      translator.addLines({
        'greet': 'Hello',
        'bye': 'Goodbye',
      }, 'en');

      expect(translator.translate('greet'), 'Hello');
      expect(translator.translate('bye'), 'Goodbye');
    });

    test('handles JSON paths', () async {
      final extraDir =
          await Directory.systemTemp.createTemp('translation_extra_');
      final extraFile = File(path.join(extraDir.path, 'en.json'));
      await extraFile.writeAsString('{"extra": "Extra Message"}');

      translator.addJsonPath(extraDir.path);

      expect(translator.translate('extra'), 'Extra Message');

      await extraDir.delete(recursive: true);
    });
  });
}
