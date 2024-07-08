import 'dart:io';
import 'package:protevus_http/foundation_session.dart';

/// Metadata container.
///
/// Adds metadata to the session.
class MetadataBag implements SessionBagInterface {
  static const String CREATED = 'c';
  static const String UPDATED = 'u';
  static const String LIFETIME = 'l';

  Map<String, int> _meta = {CREATED: 0, UPDATED: 0, LIFETIME: 0};

  String _name = '__metadata';
  String _storageKey;
  late int _lastUsed;
  int _updateThreshold;

  /// Constructor for MetadataBag.
  ///
  /// @param storageKey The key used to store bag in the session
  /// @param updateThreshold The time to wait between two UPDATED updates
  MetadataBag({String storageKey = '_sf2_meta', int updateThreshold = 0})
      : _storageKey = storageKey,
        _updateThreshold = updateThreshold;

  @override
  void initialize(List<dynamic> array) {
    // In Dart, we can't use a reference to array directly,
    // so we'll copy the data and update it as needed
    _meta = Map<String, int>.from(array.first as Map<String, dynamic>);

    if (_meta.containsKey(CREATED)) {
      _lastUsed = _meta[UPDATED]!;

      int timeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (timeStamp - _meta[UPDATED]! >= _updateThreshold) {
        _meta[UPDATED] = timeStamp;
      }
    } else {
      _stampCreated();
    }
  }

  /// Gets the lifetime that the session cookie was set with.
  int getLifetime() {
    return _meta[LIFETIME]!;
  }

  /// Stamps a new session's metadata.
  ///
  /// @param lifetime Sets the cookie lifetime for the session cookie. A null value
  ///                 will leave the system settings unchanged, 0 sets the cookie
  ///                 to expire with browser session. Time is in seconds, and is
  ///                 not a Unix timestamp.
  void stampNew([int? lifetime]) {
    _stampCreated(lifetime);
  }

  @override
  String getStorageKey() {
    return _storageKey;
  }

  /// Gets the created timestamp metadata.
  ///
  /// @return Unix timestamp
  int getCreated() {
    return _meta[CREATED]!;
  }

  /// Gets the last used metadata.
  ///
  /// @return Unix timestamp
  int getLastUsed() {
    return _lastUsed;
  }

  @override
  dynamic clear() {
    // nothing to do
    return null;
  }

  @override
  String getName() {
    return _name;
  }

  /// Sets name.
  void setName(String name) {
    _name = name;
  }

  void _stampCreated([int? lifetime]) {
    int timeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _meta[CREATED] = _meta[UPDATED] = _lastUsed = timeStamp;
    _meta[LIFETIME] = lifetime ??
        int.parse(Platform.environment['SESSION_COOKIE_LIFETIME'] ?? '0');
  }
}
