import 'dart:async';

import 'package:test/test.dart';
import 'package:illuminate_broadcasting/broadcasting.dart';

class TestBroadcaster implements Broadcaster {
  final events = <String>[];
  final channels =
      <String, FutureOr<bool> Function(String, Map<String, dynamic>?)>{};
  final presenceChannels = <String,
      FutureOr<Map<String, dynamic>?> Function(
          String, Map<String, dynamic>?)>{};

  @override
  Future<Map<String, dynamic>> auth(String channelName, String socketId,
      {Map<String, dynamic>? auth}) async {
    return {'auth': 'test'};
  }

  @override
  Future<void> broadcast(
      List<Channel> channels, String event, Map<String, dynamic> data,
      {String? socketId}) async {
    events.add('$event:${channels.map((c) => c.toString()).join(',')}');
  }

  @override
  Future<void> broadcastTo(
      Channel channel, String event, Map<String, dynamic> data,
      {String? socketId}) async {
    events.add('$event:${channel.toString()}');
  }

  @override
  String? getSocketId() => 'test-socket';

  @override
  void registerAuthCallback(String pattern,
      FutureOr<bool> Function(String, Map<String, dynamic>?) callback) {
    channels[pattern] = callback;
  }

  @override
  void registerPresenceAuthCallback(
      String pattern,
      FutureOr<Map<String, dynamic>?> Function(String, Map<String, dynamic>?)
          callback) {
    presenceChannels[pattern] = callback;
  }

  @override
  Future<bool> validateWebhook(
      Map<String, String> headers, String payload) async {
    return true;
  }
}

void main() {
  group('BroadcastManager', () {
    late BroadcastManager manager;
    late TestBroadcaster testBroadcaster;

    setUp(() {
      manager = BroadcastManager();
      testBroadcaster = TestBroadcaster();
    });

    test('registers and retrieves drivers', () async {
      await manager.registerDriver(
        'test',
        (_) => testBroadcaster,
      );
      manager.defaultDriver = 'test';

      final driver = await manager.driver();
      expect(driver, equals(testBroadcaster));
    });

    test('broadcasts to channels', () async {
      await manager.registerDriver(
        'test',
        (_) => testBroadcaster,
      );
      manager.defaultDriver = 'test';

      final channel = Channel('test-channel');
      await manager.broadcastTo(
        channel,
        'test-event',
        {'message': 'hello'},
      );

      expect(testBroadcaster.events, contains('test-event:test-channel'));
    });

    test('broadcasts to multiple channels', () async {
      await manager.registerDriver(
        'test',
        (_) => testBroadcaster,
      );
      manager.defaultDriver = 'test';

      final channels = [
        Channel('channel-1'),
        Channel('channel-2'),
      ];
      await manager.broadcast(
        channels,
        'test-event',
        {'message': 'hello'},
      );

      expect(
          testBroadcaster.events, contains('test-event:channel-1,channel-2'));
    });

    test('creates channel instances', () {
      final private = manager.private('test');
      final presence = manager.presence('test');
      final encrypted = manager.encrypted('test');

      expect(private, isA<PrivateChannel>());
      expect(private.toString(), equals('private-test'));

      expect(presence, isA<PresenceChannel>());
      expect(presence.toString(), equals('presence-test'));

      expect(encrypted, isA<EncryptedPrivateChannel>());
      expect(encrypted.toString(), equals('private-encrypted-test'));
    });

    test('throws when accessing unregistered driver', () {
      expect(
        () => manager.driver('unknown'),
        throwsA(isA<BroadcastException>()),
      );
    });

    test('throws when setting invalid default driver', () {
      expect(
        () => manager.defaultDriver = 'unknown',
        throwsA(isA<BroadcastException>()),
      );
    });

    test('removes drivers', () async {
      await manager.registerDriver(
        'test',
        (_) => testBroadcaster,
      );
      manager.defaultDriver = 'test';

      manager.removeDriver('test');

      expect(
        () => manager.driver('test'),
        throwsA(isA<BroadcastException>()),
      );
    });

    test('clears all drivers', () async {
      await manager.registerDriver(
        'test1',
        (_) => testBroadcaster,
      );
      await manager.registerDriver(
        'test2',
        (_) => TestBroadcaster(),
      );

      manager.clearDrivers();

      expect(
        () => manager.driver('test1'),
        throwsA(isA<BroadcastException>()),
      );
      expect(
        () => manager.driver('test2'),
        throwsA(isA<BroadcastException>()),
      );
    });
  });
}
