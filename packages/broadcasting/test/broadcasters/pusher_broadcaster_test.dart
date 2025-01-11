import 'package:pusher_client/pusher_client.dart' as pusher;
import 'package:test/test.dart';
import 'package:protevus_broadcasting/broadcasting.dart';

void main() {
  group('PusherBroadcaster', () {
    late PusherBroadcaster broadcaster;
    late pusher.PusherClient mockPusher;
    const testKey = 'test-key';
    const testSecret = 'test-secret';

    setUp(() async {
      // Create a mock Pusher client for testing
      final options = pusher.PusherOptions(
        cluster: 'test',
        encrypted: true,
      );
      mockPusher = pusher.PusherClient(testKey, options, enableLogging: false);
      broadcaster = PusherBroadcaster(mockPusher, testKey, testSecret);
    });

    test('authenticates private channels', () async {
      const channelName = 'private-test';
      const socketId = 'socket.123';

      // Register auth callback
      broadcaster.registerAuthCallback(
        'private-*',
        (channel, auth) async => true,
      );

      final result = await broadcaster.auth(channelName, socketId);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['auth'], isA<String>());
      expect(result['auth'].startsWith(testKey), isTrue);
    });

    test('authenticates presence channels', () async {
      const channelName = 'presence-test';
      const socketId = 'socket.123';

      // Register presence auth callback
      broadcaster.registerPresenceAuthCallback(
        'presence-*',
        (channel, auth) async => {
          'id': '123',
          'name': 'Test User',
        },
      );

      final result = await broadcaster.auth(channelName, socketId);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['auth'], isA<String>());
      expect(result['channel_data'], isA<String>());
      expect(result['auth'].startsWith(testKey), isTrue);
    });

    test('validates webhooks', () async {
      const payload = '{"event":"test"}';
      final hmac = await broadcaster.validateWebhook(
        {'x-pusher-signature': 'invalid'},
        payload,
      );
      expect(hmac, isFalse);
    });

    test('throws when no auth callback is registered', () async {
      const channelName = 'private-test';
      const socketId = 'socket.123';

      expect(
        () => broadcaster.auth(channelName, socketId),
        throwsA(isA<BroadcastException>()),
      );
    });

    test('matches channel patterns correctly', () async {
      var callbackCalled = false;
      broadcaster.registerAuthCallback(
        'private-users.{id}',
        (channel, auth) async {
          callbackCalled = true;
          return true;
        },
      );

      await broadcaster.auth('private-users.123', 'socket.123');
      expect(callbackCalled, isTrue);
    });
  });

  group('PusherFactory', () {
    test('creates broadcaster for production', () async {
      final broadcaster = await PusherFactory.create(
        key: 'test-key',
        secret: 'test-secret',
        cluster: 'test',
        autoConnect: false,
      );

      expect(broadcaster, isA<PusherBroadcaster>());
    });

    test('creates broadcaster for local development', () async {
      final broadcaster = await PusherFactory.createLocal(
        key: 'test-key',
        secret: 'test-secret',
      );

      expect(broadcaster, isA<PusherBroadcaster>());
    });
  });
}
