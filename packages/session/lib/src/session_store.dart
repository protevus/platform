import 'dart:async';
import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:illuminate_contracts/contracts.dart';

import 'contracts/session_driver.dart';

/// Manages session data and provides an interface for interacting with sessions.
class SessionStore {
  final String _id;
  final SessionDriver _driver;
  final bool _encrypt;
  final EncrypterContract? _encrypter;
  final Map<String, dynamic> _attributes;
  bool _started = false;

  /// Creates a new session store.
  SessionStore(
    this._id,
    this._driver, {
    bool encrypt = false,
    EncrypterContract? encrypter,
    Map<String, dynamic>? attributes,
  })  : _encrypt = encrypt,
        _encrypter = encrypter,
        _attributes = HashMap.from(attributes ?? {});

  /// The session ID.
  String get id => _id;

  /// Whether the session has been started.
  bool get isStarted => _started;

  /// Gets all session data.
  Map<String, dynamic> all() => Map.unmodifiable(_attributes);

  /// Gets the value for the given key.
  T? get<T>(String key, [T? defaultValue]) =>
      _attributes[key] as T? ?? defaultValue;

  /// Sets a value in the session.
  void set<T>(String key, T value) {
    _attributes[key] = value;
  }

  /// Checks if the session has the given key.
  bool has(String key) => _attributes.containsKey(key);

  /// Removes a value from the session.
  void remove(String key) {
    _attributes.remove(key);
  }

  /// Removes all values from the session.
  void clear() {
    _attributes.clear();
  }

  /// Gets multiple values from the session.
  Map<String, dynamic> only(List<String> keys) {
    return Map.fromEntries(
      keys.where((key) => has(key)).map((key) => MapEntry(key, get(key))),
    );
  }

  /// Starts the session.
  Future<void> start() async {
    if (!_started) {
      final data = await _driver.read(_id);
      if (data != null) {
        _attributes.addAll(_decryptData(data));
      }
      _started = true;
    }
  }

  /// Saves the session data.
  Future<void> save() {
    return _driver.write(_id, _encryptData(_attributes));
  }

  /// Destroys the session.
  Future<void> destroy() {
    _attributes.clear();
    _started = false;
    return _driver.destroy(_id);
  }

  /// Flashes data to the session.
  void flash(String key, dynamic value) {
    final List<String> flash =
        (get<List>('_flash.new') ?? <String>[]).cast<String>();
    set('_flash.new', [...flash, key]);
    set(key, value);
  }

  /// Reflashes all flash data.
  void reflash() {
    final List<String> old =
        (get<List>('_flash.old') ?? <String>[]).cast<String>();
    final List<String> current =
        (get<List>('_flash.new') ?? <String>[]).cast<String>();
    set('_flash.new', [...current, ...old]);
  }

  /// Keeps the specified flash data for another request.
  void keep([List<String>? keys]) {
    final List<String> old =
        (get<List>('_flash.old') ?? <String>[]).cast<String>();
    final List<String> current =
        (get<List>('_flash.new') ?? <String>[]).cast<String>();
    final toKeep = keys ?? old;
    set('_flash.new', [...current, ...toKeep]);
  }

  /// Ages the flash data.
  void ageFlashData() {
    // Remove old flash data
    final List<String> old =
        (get<List>('_flash.old') ?? <String>[]).cast<String>();
    for (final key in old) {
      remove(key);
    }

    // Move current flash to old
    final List<String> current =
        (get<List>('_flash.new') ?? <String>[]).cast<String>();
    set('_flash.old', current);
    set('_flash.new', <String>[]);
  }

  Map<String, dynamic> _decryptData(Map<String, dynamic> data) {
    if (!_encrypt || _encrypter == null) return data;
    return Map.fromEntries(
      data.entries.map((e) => MapEntry(
            e.key,
            _encrypter!.decrypt(e.value.toString()),
          )),
    );
  }

  Map<String, dynamic> _encryptData(Map<String, dynamic> data) {
    if (!_encrypt || _encrypter == null) return data;
    return Map.fromEntries(
      data.entries.map((e) => MapEntry(
            e.key,
            _encrypter!.encrypt(e.value.toString()),
          )),
    );
  }

  @override
  String toString() => 'SessionStore(id: $_id, attributes: $_attributes)';
}
