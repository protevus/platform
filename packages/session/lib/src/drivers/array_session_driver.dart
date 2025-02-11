import 'dart:async';
import 'dart:collection';

import '../contracts/session_driver.dart';

/// A session driver that stores sessions in memory.
class ArraySessionDriver implements SessionDriver {
  final Map<String, _SessionData> _sessions = HashMap();

  @override
  Future<Map<String, dynamic>?> read(String id) async {
    final session = _sessions[id];
    if (session == null || session.isExpired) {
      return null;
    }
    return Map.from(session.data);
  }

  @override
  Future<void> write(String id, Map<String, dynamic> data) async {
    _sessions[id] = _SessionData(data);
  }

  @override
  Future<void> destroy(String id) async {
    _sessions.remove(id);
  }

  @override
  Future<List<String>> all() async {
    return _sessions.keys.toList(growable: false);
  }

  @override
  Future<void> gc(Duration lifetime) async {
    _sessions.removeWhere((_, session) => session.isExpired);
  }
}

/// Internal class to track session data and expiration.
class _SessionData {
  final Map<String, dynamic> data;
  final DateTime createdAt;

  _SessionData(Map<String, dynamic> data)
      : data = Map.unmodifiable(data),
        createdAt = DateTime.now();

  bool get isExpired {
    final now = DateTime.now();
    return now.difference(createdAt) >= const Duration(hours: 2);
  }
}
