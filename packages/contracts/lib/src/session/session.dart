/// Interface for session management.
abstract class Session {
  /// Get the name of the session.
  String getName();

  /// Set the name of the session.
  void setName(String name);

  /// Get the current session ID.
  String getId();

  /// Set the session ID.
  void setId(String id);

  /// Start the session, reading the data from a handler.
  bool start();

  /// Save the session data to storage.
  void save();

  /// Get all of the session data.
  Map<String, dynamic> all();

  /// Checks if a key exists.
  bool exists(dynamic key);

  /// Checks if a key is present and not null.
  bool has(dynamic key);

  /// Get an item from the session.
  dynamic get(String key, [dynamic default_]);

  /// Get the value of a given key and then forget it.
  dynamic pull(String key, [dynamic default_]);

  /// Put a key / value pair or array of key / value pairs in the session.
  void put(dynamic key, [dynamic value]);

  /// Get the CSRF token value.
  String token();

  /// Regenerate the CSRF token value.
  void regenerateToken();

  /// Remove an item from the session, returning its value.
  dynamic remove(String key);

  /// Remove one or many items from the session.
  void forget(dynamic keys);

  /// Remove all of the items from the session.
  void flush();

  /// Flush the session data and regenerate the ID.
  bool invalidate();

  /// Generate a new session identifier.
  bool regenerate([bool destroy = false]);

  /// Generate a new session ID for the session.
  bool migrate([bool destroy = false]);

  /// Determine if the session has been started.
  bool isStarted();

  /// Get the previous URL from the session.
  String? previousUrl();

  /// Set the "previous" URL in the session.
  void setPreviousUrl(String url);

  /// Get the session handler instance.
  dynamic getHandler();

  /// Determine if the session handler needs a request.
  bool handlerNeedsRequest();

  /// Set the request on the handler instance.
  void setRequestOnHandler(dynamic request);
}
