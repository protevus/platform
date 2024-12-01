import 'broadcaster.dart';

/// Interface for creating broadcaster instances.
///
/// This contract defines how broadcaster instances should be created and managed.
/// It provides methods for getting broadcaster instances by name.
abstract class BroadcastFactory {
  /// Get a broadcaster implementation by name.
  ///
  /// Example:
  /// ```dart
  /// // Get the default broadcaster
  /// var broadcaster = factory.connection();
  ///
  /// // Get a specific broadcaster
  /// var pusherBroadcaster = factory.connection('pusher');
  /// ```
  Future<Broadcaster> connection([String? name]);
}
