import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pusher_client/pusher_client.dart' as pusher;

import '../channels/channel.dart';
import '../exceptions/broadcast_exception.dart';
import 'broadcaster.dart';

/// Implementation of the Broadcaster interface using Pusher as the underlying service.
class PusherBroadcaster implements Broadcaster {
  /// The Pusher client instance.
  final pusher.PusherClient _pusher;

  /// The application key.
  final String _key;

  /// The application secret.
  final String _secret;

  /// Map of channel patterns to their authentication callbacks.
  final Map<String, FutureOr<bool> Function(String, Map<String, dynamic>?)>
      _authCallbacks = {};

  /// Map of presence channel patterns to their authentication callbacks.
  final Map<
      String,
      FutureOr<Map<String, dynamic>?> Function(
          String, Map<String, dynamic>?)> _presenceAuthCallbacks = {};

  /// Creates a new Pusher broadcaster instance.
  ///
  /// Parameters:
  /// - [pusher]: The configured Pusher client instance
  /// - [key]: The Pusher application key
  /// - [secret]: The Pusher application secret
  PusherBroadcaster(this._pusher, this._key, this._secret);

  @override
  Future<Map<String, dynamic>> auth(
    String channelName,
    String socketId, {
    Map<String, dynamic>? auth,
  }) async {
    if (channelName.startsWith('presence-')) {
      return _authenticatePresenceChannel(channelName, socketId, auth);
    }
    return _authenticatePrivateChannel(channelName, socketId, auth);
  }

  /// Authenticates a private channel subscription.
  Future<Map<String, dynamic>> _authenticatePrivateChannel(
    String channelName,
    String socketId,
    Map<String, dynamic>? auth,
  ) async {
    final callback = _findAuthCallback(channelName);
    if (callback == null) {
      throw BroadcastException(
          'No authentication callback registered for channel: $channelName');
    }

    final canAuthenticate = await callback(channelName, auth);
    if (!canAuthenticate) {
      throw BroadcastException(
          'Authentication rejected for channel: $channelName');
    }

    final signature = _generateSignature(socketId, channelName);
    return {
      'auth': '$_key:$signature',
    };
  }

  /// Authenticates a presence channel subscription.
  Future<Map<String, dynamic>> _authenticatePresenceChannel(
    String channelName,
    String socketId,
    Map<String, dynamic>? auth,
  ) async {
    final callback = _findPresenceAuthCallback(channelName);
    if (callback == null) {
      throw BroadcastException(
          'No presence authentication callback registered for channel: $channelName');
    }

    final userData = await callback(channelName, auth);
    if (userData == null) {
      throw BroadcastException(
          'Authentication rejected for presence channel: $channelName');
    }

    final channelData = jsonEncode({
      'user_id': userData['id']?.toString() ?? '',
      'user_info': userData,
    });

    final signature = _generateSignature(socketId, channelName, channelData);
    return {
      'auth': '$_key:$signature',
      'channel_data': channelData,
    };
  }

  /// Generates an authentication signature for channel subscription.
  String _generateSignature(String socketId, String channelName,
      [String? channelData]) {
    final stringToSign = channelData == null
        ? '$socketId:$channelName'
        : '$socketId:$channelName:$channelData';
    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode(stringToSign));
    return digest.toString();
  }

  @override
  Future<void> broadcast(
    List<Channel> channels,
    String event,
    Map<String, dynamic> data, {
    String? socketId,
  }) async {
    final formattedChannels = channels.map((c) => c.toString()).toList();

    try {
      for (final channelName in formattedChannels) {
        final channel = _pusher.subscribe(channelName);
        await channel.trigger(event, data);
      }
    } catch (e, stackTrace) {
      throw BroadcastException(
        'Failed to broadcast event: $event',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> broadcastTo(
    Channel channel,
    String event,
    Map<String, dynamic> data, {
    String? socketId,
  }) async {
    try {
      final pusherChannel = _pusher.subscribe(channel.toString());
      await pusherChannel.trigger(event, data);
    } catch (e, stackTrace) {
      throw BroadcastException(
        'Failed to broadcast event: $event to channel: ${channel.toString()}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> validateWebhook(
      Map<String, String> headers, String payload) async {
    final signature = headers['x-pusher-signature'];
    if (signature == null) {
      return false;
    }

    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode(payload));
    return signature == digest.toString();
  }

  @override
  String? getSocketId() => _pusher.getSocketId();

  @override
  void registerAuthCallback(
    String pattern,
    FutureOr<bool> Function(String channelName, Map<String, dynamic>? auth)
        callback,
  ) {
    _authCallbacks[pattern] = callback;
  }

  @override
  void registerPresenceAuthCallback(
    String pattern,
    FutureOr<Map<String, dynamic>?> Function(
            String channelName, Map<String, dynamic>? auth)
        callback,
  ) {
    _presenceAuthCallbacks[pattern] = callback;
  }

  /// Finds the appropriate authentication callback for a channel.
  FutureOr<bool> Function(String, Map<String, dynamic>?)? _findAuthCallback(
      String channelName) {
    return _authCallbacks.entries
        .where((entry) => _channelMatchesPattern(channelName, entry.key))
        .map((entry) => entry.value)
        .firstOrNull;
  }

  /// Finds the appropriate presence authentication callback for a channel.
  FutureOr<Map<String, dynamic>?> Function(String, Map<String, dynamic>?)?
      _findPresenceAuthCallback(String channelName) {
    return _presenceAuthCallbacks.entries
        .where((entry) => _channelMatchesPattern(channelName, entry.key))
        .map((entry) => entry.value)
        .firstOrNull;
  }

  /// Checks if a channel name matches a pattern.
  bool _channelMatchesPattern(String channelName, String pattern) {
    final regexPattern = pattern
        .replaceAll('.', r'\.')
        .replaceAll('*', r'[^.]+')
        .replaceAll('{id}', r'[^.]+');
    return RegExp('^$regexPattern\$').hasMatch(channelName);
  }
}
