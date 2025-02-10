import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_macroable/macroable.dart';
import 'package:illuminate_support/support.dart';

class CookieJar
    with Macroable, InteractsWithTime
    implements QueueingFactory, CookieFactory {
  final Map<String, Map<String, dynamic>> _queued = {};
  final String _path;
  final String _domain;
  final bool _secure;
  final bool _httpOnly;
  final String? _sameSite;

  CookieJar({
    String path = '/',
    String? domain,
    bool secure = false,
    bool httpOnly = true,
    String? sameSite,
  })  : _path = path,
        _domain = domain ?? '',
        _secure = secure,
        _httpOnly = httpOnly,
        _sameSite = sameSite;

  @override
  Map<String, String> make(
    String name,
    String value, {
    String? domain,
    bool? httpOnly,
    int? minutes,
    String? path,
    bool? raw,
    String? sameSite,
    bool? secure,
  }) {
    final cookie = <String, String>{
      'name': name,
      'value': _encodeValue(value, raw ?? false),
      'domain': domain ?? _domain,
      'path': path ?? _path,
      'expires': _getExpirationTime(minutes),
      'secure': (secure ?? _secure).toString(),
      'httponly': (httpOnly ?? _httpOnly).toString(),
      'samesite': sameSite ?? _sameSite ?? '',
    };

    return Map.fromEntries(
        cookie.entries.where((entry) => entry.value.isNotEmpty));
  }

  @override
  void queue(String name, String value, [Map<String, dynamic>? options]) {
    _queued[name] = {'value': value, ...?options};
  }

  bool hasQueued(String key) {
    return _queued.containsKey(key);
  }

  @override
  Map<String, dynamic> getQueuedCookies() {
    return Map.fromEntries(_queued.entries.map((entry) => MapEntry(
        entry.key,
        make(
          entry.key,
          entry.value['value'] as String,
          domain: entry.value['domain'] as String?,
          httpOnly: entry.value['httpOnly'] as bool?,
          minutes: entry.value['minutes'] as int?,
          path: entry.value['path'] as String?,
          raw: entry.value['raw'] as bool?,
          sameSite: entry.value['sameSite'] as String?,
          secure: entry.value['secure'] as bool?,
        ))));
  }

  @override
  void unqueue(String name) {
    _queued.remove(name);
  }

  String _encodeValue(String value, bool raw) {
    return raw ? value : Uri.encodeComponent(value);
  }

  String _getExpirationTime(int? minutes) {
    if (minutes != null) {
      return currentTime()
          .add(Duration(minutes: minutes))
          .toUtc()
          .toIso8601String();
    }
    return '';
  }

  // Additional methods can be added here as needed
}
