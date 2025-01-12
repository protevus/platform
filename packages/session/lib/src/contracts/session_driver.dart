import 'dart:async';

/// Contract for session drivers that handle session data storage.
abstract class SessionDriver {
  /// Retrieves all data for the given session ID.
  Future<Map<String, dynamic>?> read(String id);

  /// Writes the session data to storage.
  Future<void> write(String id, Map<String, dynamic> data);

  /// Removes the session data from storage.
  Future<void> destroy(String id);

  /// Returns all session IDs from storage.
  Future<List<String>> all();

  /// Removes expired sessions from storage.
  Future<void> gc(Duration lifetime);
}
