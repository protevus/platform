import 'dart:isolate';
import 'package:illuminate_mirrors/mirrors.dart';
import 'package:test/test.dart';

// Function to run in isolate
void isolateFunction(SendPort sendPort) {
  sendPort.send('Hello from isolate!');
}

void main() {
  group('Isolate Reflection', () {
    late RuntimeReflector reflector;

    setUp(() {
      reflector = RuntimeReflector.instance;
    });

    test('currentIsolate returns mirror for current isolate', () {
      final isolateMirror = reflector.currentIsolate;

      expect(isolateMirror, isNotNull);
      expect(isolateMirror.isCurrent, isTrue);
      expect(isolateMirror.debugName, equals('main'));
      expect(isolateMirror.rootLibrary, isNotNull);
    });

    test('reflectIsolate returns mirror for other isolate', () async {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        isolateFunction,
        receivePort.sendPort,
      );

      final isolateMirror = reflector.reflectIsolate(isolate, 'test-isolate');

      expect(isolateMirror, isNotNull);
      expect(isolateMirror.isCurrent, isFalse);
      expect(isolateMirror.debugName, equals('test-isolate'));
      expect(isolateMirror.rootLibrary, isNotNull);

      // Clean up
      receivePort.close();
      isolate.kill();
    });

    test('isolate mirror provides control over isolate', () async {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        isolateFunction,
        receivePort.sendPort,
      );

      final isolateMirror =
          reflector.reflectIsolate(isolate, 'test-isolate') as IsolateMirror;

      // Test pause/resume
      await isolateMirror.pause();
      await isolateMirror.resume();

      // Test error listener
      var errorReceived = false;
      isolateMirror.addErrorListener((error, stackTrace) {
        errorReceived = true;
      });

      // Test exit listener
      var exitReceived = false;
      isolateMirror.addExitListener((_) {
        exitReceived = false;
      });

      // Test kill
      await isolateMirror.kill();

      // Clean up
      receivePort.close();
    });

    test('isolate mirrors compare correctly', () async {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        isolateFunction,
        receivePort.sendPort,
      );

      final mirror1 = reflector.reflectIsolate(isolate, 'test-isolate');
      final mirror2 = reflector.reflectIsolate(isolate, 'test-isolate');
      final mirror3 = reflector.reflectIsolate(isolate, 'other-name');

      expect(mirror1, equals(mirror2));
      expect(mirror1, isNot(equals(mirror3)));
      expect(mirror1.hashCode, equals(mirror2.hashCode));
      expect(mirror1.hashCode, isNot(equals(mirror3.hashCode)));

      // Clean up
      receivePort.close();
      isolate.kill();
    });

    test('isolate mirror toString provides meaningful description', () {
      final currentMirror = reflector.currentIsolate;
      expect(
          currentMirror.toString(), equals('IsolateMirror "main" (current)'));

      final receivePort = ReceivePort();
      Isolate.spawn(
        isolateFunction,
        receivePort.sendPort,
      ).then((isolate) {
        final otherMirror = reflector.reflectIsolate(isolate, 'test-isolate');
        expect(otherMirror.toString(), equals('IsolateMirror "test-isolate"'));

        // Clean up
        receivePort.close();
        isolate.kill();
      });
    });
  });
}
