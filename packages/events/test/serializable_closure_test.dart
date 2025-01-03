import 'dart:convert';
import 'package:platform_events/events.dart';
import 'package:test/test.dart';

void main() {
  group('SerializableClosure', () {
    test('creates with auto-generated identifier', () {
      final closure = (String name) => 'Hello $name';
      final serializable = SerializableClosure(closure);
      expect(serializable.identifier, isNotEmpty);
    });

    test('creates with provided identifier', () {
      final closure = (String name) => 'Hello $name';
      final serializable = SerializableClosure(closure, identifier: 'test-id');
      expect(serializable.identifier, equals('test-id'));
    });

    test('getClosure returns original closure', () {
      final closure = (String name) => 'Hello $name';
      final serializable = SerializableClosure(closure);
      expect(serializable.getClosure(), equals(closure));
    });

    test('toJson includes identifier', () {
      final closure = (String name) => 'Hello $name';
      final serializable = SerializableClosure(closure, identifier: 'test-id');
      final json = serializable.toJson();
      expect(json['identifier'], equals('test-id'));
    });

    test('fromJson reconstructs closure from registered factory', () {
      final closure = (String name) => 'Hello $name';
      SerializableClosure.register('test-id', () => closure);

      final json = {'identifier': 'test-id'};
      final reconstructed = SerializableClosure.fromJson(json);
      expect(reconstructed('world'), equals('Hello world'));
    });

    test('fromJson throws when factory not registered', () {
      final json = {'identifier': 'unknown-id'};
      expect(
        () => SerializableClosure.fromJson(json),
        throwsStateError,
      );
    });

    test('create registers and creates serializable closure', () {
      final closure = (String name) => 'Hello $name';
      final serializable = SerializableClosure.create(
        closure,
        'test-id',
        () => closure,
      );

      // Should be able to reconstruct
      final json = serializable.toJson();
      final reconstructed = SerializableClosure.fromJson(json);
      expect(reconstructed('world'), equals('Hello world'));
    });

    test('can be encoded/decoded through json', () {
      final closure = (String name) => 'Hello $name';
      final serializable = SerializableClosure.create(
        closure,
        'test-id',
        () => closure,
      );

      // Encode/decode cycle
      final encoded = jsonEncode(serializable.toJson());
      final decoded = SerializableClosure.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );

      expect(decoded('world'), equals('Hello world'));
    });
  });
}
