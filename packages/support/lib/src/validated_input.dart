import 'package:platform_contracts/contracts.dart';
import 'facades/date.dart';

/// A class that provides validated input data with array-like access.
///
/// This class implements the ValidatedData contract and provides additional
/// functionality for handling input data, including date parsing.
class ValidatedInput implements ValidatedData {
  /// The underlying data store.
  final Map<String, dynamic> _data;

  /// Creates a new ValidatedInput instance.
  ValidatedInput([Map<String, dynamic>? data]) : _data = Map.from(data ?? {});

  @override
  Map<String, dynamic> toArray() => Map.from(_data);

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  dynamic operator [](String key) => _data[key];

  @override
  void operator []=(String key, dynamic value) {
    _data[key] = value;
  }

  @override
  void remove(String key) {
    _data.remove(key);
  }

  @override
  Iterator<MapEntry<String, dynamic>> get iterator => _data.entries.iterator;

  /// Get all of the input data.
  Map<String, dynamic> all() => toArray();

  /// Get a subset of the input data.
  Map<String, dynamic> only(List<String> keys) {
    return Map.fromEntries(
      keys
          .where((key) => containsKey(key))
          .map((key) => MapEntry(key, this[key])),
    );
  }

  /// Get all input data except for a specified array of items.
  Map<String, dynamic> except(List<String> keys) {
    return Map.fromEntries(
      _data.entries.where((entry) => !keys.contains(entry.key)),
    );
  }

  /// Merge new input into the current input data.
  void merge(Map<String, dynamic> input) {
    _data.addAll(input);
  }

  /// Replace the input data with a new set.
  void replace(Map<String, dynamic> input) {
    _data.clear();
    _data.addAll(input);
  }

  /// Get a value from the input data as a DateTime.
  DateTime? date(String key, {String? format}) {
    final value = this[key];
    if (value == null) return null;

    if (value is DateTime) return value;
    if (value is String) {
      try {
        return Date.parse(value).dateTime;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Get a value from the input data as a bool.
  bool? boolean(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is bool) return value;
    if (value is String) {
      return ['1', 'true', 'yes', 'on'].contains(value.toLowerCase());
    }
    if (value is num) return value != 0;
    return null;
  }

  /// Get a value from the input data as an int.
  int? integer(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Get a value from the input data as a double.
  double? decimal(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Get a value from the input data as a String.
  String? string(String key) {
    final value = this[key];
    if (value == null) return null;

    return value.toString();
  }

  /// Get a value from the input data as a List.
  List<T>? list<T>(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is List) {
      try {
        if (T == String) {
          return value.map((e) => e.toString()).toList() as List<T>;
        }
        if (T == int) {
          return value
              .map((e) => (e is num) ? e.toInt() : int.parse(e.toString()))
              .toList() as List<T>;
        }
        if (T == double) {
          return value
              .map(
                  (e) => (e is num) ? e.toDouble() : double.parse(e.toString()))
              .toList() as List<T>;
        }
        if (T == bool) {
          return value
              .map((e) => (e is bool)
                  ? e
                  : ['1', 'true', 'yes', 'on']
                      .contains(e.toString().toLowerCase()))
              .toList() as List<T>;
        }
        return value.cast<T>();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Get a value from the input data as a Map.
  Map<String, T>? map<T>(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is Map) {
      try {
        final result = <String, T>{};
        for (final entry in value.entries) {
          final k = entry.key.toString();
          final v = entry.value;
          if (T == String) {
            result[k] = v.toString() as T;
          } else if (T == int && v is num) {
            result[k] = v.toInt() as T;
          } else if (T == double && v is num) {
            result[k] = v.toDouble() as T;
          } else if (T == bool) {
            result[k] = (v is bool
                ? v
                : ['1', 'true', 'yes', 'on']
                    .contains(v.toString().toLowerCase())) as T;
          } else if (v is T) {
            result[k] = v;
          } else {
            return null;
          }
        }
        return result;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Determine if the input data has a given key.
  bool has(String key) => containsKey(key);

  /// Determine if the input data is missing a given key.
  bool missing(String key) => !has(key);

  /// Determine if the input data has a non-empty value for a given key.
  bool filled(String key) {
    final value = this[key];
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  /// Get the keys present in the input data.
  Set<String> keys() => _data.keys.toSet();

  /// Get the values present in the input data.
  List<dynamic> values() => _data.values.toList();
}
