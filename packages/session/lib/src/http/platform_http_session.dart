import 'dart:async';
import 'dart:io';
import 'dart:collection';

import '../session_store.dart';

/// A [HttpSession] implementation that wraps a [SessionStore].
class PlatformHttpSession implements HttpSession, Map<dynamic, dynamic> {
  final SessionStore _store;
  final String _id;
  final _map = <String, dynamic>{};
  Duration? _timeout;
  void Function()? _onTimeout;

  PlatformHttpSession(this._store) : _id = _store.id {
    // Sync initial data from store
    _map.addAll(_store.all());
  }

  @override
  String get id => _id;

  @override
  void clear() {
    _map.clear();
    _store.clear();
  }

  @override
  bool destroy() {
    _map.clear();
    _store.destroy();
    return true;
  }

  @override
  dynamic operator [](Object? key) {
    return key is String ? _map[key] : null;
  }

  @override
  void operator []=(dynamic key, dynamic value) {
    if (key is String) {
      _map[key] = value;
      _store.set(key, value);
    }
  }

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  bool get isNew => !_store.isStarted;

  @override
  Iterable<String> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  void remove(Object? key) {
    if (key is String) {
      _map.remove(key);
      _store.remove(key);
    }
  }

  @override
  void addAll(Map<dynamic, dynamic> other) {
    other.forEach((key, value) {
      if (key is String) {
        this[key] = value;
      }
    });
  }

  @override
  void addEntries(Iterable<MapEntry<dynamic, dynamic>> entries) {
    for (final entry in entries) {
      if (entry.key is String) {
        this[entry.key] = entry.value;
      }
    }
  }

  @override
  Map<RK, RV> cast<RK, RV>() => _map.cast<RK, RV>();

  @override
  bool containsKey(Object? key) => _map.containsKey(key);

  @override
  bool containsValue(Object? value) => _map.containsValue(value);

  @override
  Iterable<MapEntry<dynamic, dynamic>> get entries =>
      _map.entries.map((e) => MapEntry<dynamic, dynamic>(e.key, e.value));

  @override
  void forEach(void Function(dynamic key, dynamic value) action) {
    _map.forEach(action);
  }

  @override
  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(dynamic key, dynamic value) convert) {
    return _map.map(convert);
  }

  @override
  dynamic putIfAbsent(dynamic key, dynamic Function() ifAbsent) {
    if (key is! String) return null;
    final value = _map.putIfAbsent(key, ifAbsent);
    _store.set(key, value);
    return value;
  }

  @override
  void removeWhere(bool Function(dynamic key, dynamic value) test) {
    _map.removeWhere((key, value) => test(key, value));
    // Sync removals to store
    _store.clear();
    _map.forEach((key, value) => _store.set(key, value));
  }

  @override
  dynamic update(
    dynamic key,
    dynamic Function(dynamic value) update, {
    dynamic Function()? ifAbsent,
  }) {
    if (key is! String) {
      throw ArgumentError.value(key, 'key', 'Must be a String');
    }
    final value = _map.update(key, update, ifAbsent: ifAbsent);
    _store.set(key, value);
    return value;
  }

  @override
  void updateAll(dynamic Function(dynamic key, dynamic value) update) {
    _map.updateAll(update);
    // Sync updates to store
    _map.forEach((key, value) => _store.set(key, value));
  }

  @override
  Iterable<dynamic> get values => _map.values;

  @override
  Duration? get timeout => _timeout;

  @override
  set timeout(Duration? timeout) {
    _timeout = timeout;
  }

  @override
  void Function()? get onTimeout => _onTimeout;

  @override
  set onTimeout(void Function()? callback) {
    _onTimeout = callback;
  }
}
