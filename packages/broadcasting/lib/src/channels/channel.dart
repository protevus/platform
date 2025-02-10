import 'package:meta/meta.dart';

/// Base class for all broadcast channels.
///
/// Channels represent different types of communication paths in the broadcasting system.
/// They can be public, private, or presence channels, each with their own authentication
/// and subscription rules.
@immutable
class Channel {
  /// The name of the channel.
  final String name;

  /// Creates a new channel instance.
  ///
  /// The [name] parameter specifies the unique identifier for this channel.
  const Channel(this.name);

  /// Returns the string representation of the channel.
  ///
  /// This is typically used when communicating with the broadcasting server.
  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Channel &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Represents a private channel that requires authentication.
///
/// Private channels are used when the communication needs to be restricted to
/// authenticated users who have the necessary permissions.
class PrivateChannel extends Channel {
  /// Creates a new private channel instance.
  ///
  /// The [name] parameter will be prefixed with 'private-' to identify it as a
  /// private channel.
  PrivateChannel(String name) : super('private-$name');
}

/// Represents a presence channel that provides member presence information.
///
/// Presence channels extend private channels by maintaining a list of users
/// currently subscribed to the channel, allowing for real-time user tracking
/// and presence-based features.
class PresenceChannel extends Channel {
  /// Creates a new presence channel instance.
  ///
  /// The [name] parameter will be prefixed with 'presence-' to identify it as a
  /// presence channel.
  PresenceChannel(String name) : super('presence-$name');
}

/// Represents an encrypted private channel.
///
/// Encrypted private channels provide an additional layer of security by
/// encrypting the messages before broadcasting them.
class EncryptedPrivateChannel extends Channel {
  /// Creates a new encrypted private channel instance.
  ///
  /// The [name] parameter will be prefixed with 'private-encrypted-' to identify
  /// it as an encrypted private channel.
  EncryptedPrivateChannel(String name) : super('private-encrypted-$name');
}
