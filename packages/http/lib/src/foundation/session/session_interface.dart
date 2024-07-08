import 'package:protevus_http/foundation_session.dart';
import 'package:protevus_http/foundation_storage.dart';

/// Interface for the session.
abstract class SessionInterface {
  /// Starts the session storage.
  ///
  /// Throws [StateError] if session fails to start.
  bool start();

  /// Returns the session ID.
  String getId();

  /// Sets the session ID.
  void setId(String id);

  /// Returns the session name.
  String getName();

  /// Sets the session name.
  void setName(String name);

  /// Invalidates the current session.
  ///
  /// Clears all session attributes and flashes and regenerates the
  /// session and deletes the old session from persistence.
  ///
  /// [lifetime] Sets the cookie lifetime for the session cookie. A null value
  /// will leave the system settings unchanged, 0 sets the cookie
  /// to expire with browser session. Time is in seconds, and is
  /// not a Unix timestamp.
  bool invalidate({int? lifetime});

  /// Migrates the current session to a new session id while maintaining all
  /// session attributes.
  ///
  /// [destroy] Whether to delete the old session or leave it to garbage collection.
  /// [lifetime] Sets the cookie lifetime for the session cookie. A null value
  /// will leave the system settings unchanged, 0 sets the cookie
  /// to expire with browser session. Time is in seconds, and is
  /// not a Unix timestamp.
  bool migrate({bool destroy = false, int? lifetime});

  /// Force the session to be saved and closed.
  ///
  /// This method is generally not required for real sessions as
  /// the session will be automatically saved at the end of
  /// code execution.
  void save();

  /// Checks if an attribute is defined.
  bool has(String name);

  /// Returns an attribute.
  T? get<T>(String name, [T? defaultValue]);

  /// Sets an attribute.
  void set(String name, dynamic value);

  /// Returns attributes.
  Map<String, dynamic> all();

  /// Sets attributes.
  void replace(Map<String, dynamic> attributes);

  /// Removes an attribute.
  ///
  /// Returns the removed value or null when it does not exist.
  T? remove<T>(String name);

  /// Clears all attributes.
  void clear();

  /// Checks if the session was started.
  bool isStarted();

  /// Registers a SessionBagInterface with the session.
  void registerBag(SessionBagInterface bag);

  /// Gets a bag instance by name.
  SessionBagInterface getBag(String name);

  /// Gets session meta.
  MetadataBag getMetadataBag();
}
