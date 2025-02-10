import 'dart:math';
import 'collection.dart';

/// A set of helper functions for working with arrays.
class Arr {
  /// Create a new instance of the Arr class.
  const Arr._();

  /// Determine whether the given value is array accessible.
  static bool accessible(dynamic value) {
    return value is List || value is Map;
  }

  /// Add an element to an array using "dot" notation if it doesn't exist.
  static void add(Map<String, dynamic> array, String key, dynamic value) {
    if (!has(array, key)) {
      set(array, key, value);
    }
  }

  /// Collapse an array of arrays into a single array.
  static List<T> collapse<T>(Iterable<Iterable<T>> array) {
    return array.expand((element) => element).toList();
  }

  /// Cross join the given arrays, returning all possible permutations.
  static List<List<T>> crossJoin<T>(List<List<T>> arrays) {
    if (arrays.isEmpty) return [];
    if (arrays.length == 1) return arrays[0].map((e) => [e]).toList();

    final result = <List<T>>[];
    final firstArray = arrays[0];
    final remainingArrays = arrays.sublist(1);
    final subPermutations = crossJoin(remainingArrays);

    for (var item in firstArray) {
      for (var subPerm in subPermutations) {
        result.add([item, ...subPerm]);
      }
    }

    return result;
  }

  /// Divide an array into two arrays. One with keys and the other with values.
  static Map<String, List<dynamic>> divide(Map<String, dynamic> array) {
    return {
      'keys': array.keys.toList(),
      'values': array.values.toList(),
    };
  }

  /// Flatten a multi-dimensional array into a single level.
  static List<T> flatten<T>(Iterable array, [int depth = -1]) {
    final result = <T>[];

    for (var item in array) {
      if (item is Iterable && depth != 0) {
        result.addAll(flatten<T>(item, depth - 1));
      } else {
        result.add(item as T);
      }
    }

    return result;
  }

  /// Remove one or many array items from a given array using "dot" notation.
  static void forget(Map<String, dynamic> array, dynamic keys) {
    final keysList = keys is String ? <String>[keys] : keys as List<String>;

    for (var key in keysList) {
      if (key.contains('.')) {
        final segments = key.split('.');
        _forgetNested(array, segments);
      } else {
        array.remove(key);
      }
    }
  }

  static void _forgetNested(Map<String, dynamic> array, List<String> segments) {
    var current = array;
    final lastSegment = segments.last;
    segments = segments.sublist(0, segments.length - 1);

    for (var segment in segments) {
      if (!current.containsKey(segment) || current[segment] is! Map) {
        return;
      }
      current = current[segment] as Map<String, dynamic>;
    }

    current.remove(lastSegment);
  }

  /// Get an item from an array using "dot" notation.
  static T? get<T>(dynamic array, String? key, [T? defaultValue]) {
    if (array == null || key == null) {
      return defaultValue;
    }

    if (!key.contains('.')) {
      if (array is Map) {
        return array.containsKey(key) ? array[key] as T : defaultValue;
      }
      if (array is List && int.tryParse(key) != null) {
        final index = int.parse(key);
        return index >= 0 && index < array.length
            ? array[index] as T
            : defaultValue;
      }
      return defaultValue;
    }

    final segments = key.split('.');
    var current = array;

    for (var segment in segments) {
      if (current is! Map && current is! List) {
        return defaultValue;
      }

      if (current is List) {
        final index = int.tryParse(segment);
        if (index == null || index < 0 || index >= current.length) {
          return defaultValue;
        }
        current = current[index];
      } else {
        final map = current as Map;
        if (!map.containsKey(segment)) {
          return defaultValue;
        }
        current = map[segment];
      }
    }

    return current as T? ?? defaultValue;
  }

  /// Check if an item or items exist in an array using "dot" notation.
  static bool has(dynamic array, dynamic keys) {
    if (array == null) {
      return false;
    }

    final keysList = keys is String ? <String>[keys] : keys as List<String>;

    for (var key in keysList) {
      if (key.contains('.')) {
        final segments = key.split('.');
        var current = array;

        for (var segment in segments) {
          if (current is! Map && current is! List) {
            return false;
          }

          if (current is List) {
            final index = int.tryParse(segment);
            if (index == null || index < 0 || index >= current.length) {
              return false;
            }
            current = current[index];
          } else {
            final map = current as Map;
            if (!map.containsKey(segment)) {
              return false;
            }
            current = map[segment];
          }
        }
      } else {
        if (array is Map && !array.containsKey(key)) {
          return false;
        }
        if (array is List) {
          final index = int.tryParse(key);
          if (index == null || index < 0 || index >= array.length) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// Determines if an array is associative.
  static bool isAssoc(dynamic array) {
    if (array is! Map) {
      return false;
    }

    return array.keys.any((key) => key is! int);
  }

  /// Get a subset of the items from the given array.
  static Map<String, dynamic> only(
    Map<String, dynamic> array,
    List<String> keys,
  ) {
    return Map.fromEntries(
      array.entries.where((entry) => keys.contains(entry.key)),
    );
  }

  /// Pluck an array of values from an array.
  static List<T> pluck<T>(
    Iterable<Map<String, dynamic>> array,
    String key, [
    String? value,
  ]) {
    if (value == null) {
      return array.map((item) => item[key] as T).toList();
    }

    return array
        .map((item) => MapEntry(item[key] as String, item[value] as T))
        .fold<Map<String, T>>({}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        })
        .values
        .toList();
  }

  /// Push an item onto the beginning of an array.
  static void prepend<T>(List<dynamic> array, T value, [String? key]) {
    if (key != null) {
      array.insert(0, {key: value});
    } else {
      array.insert(0, value);
    }
  }

  /// Get a value from the array, and remove it.
  static T? pull<T>(Map<String, dynamic> array, String key, [T? defaultValue]) {
    final value = get<T>(array, key, defaultValue);
    forget(array, key);
    return value;
  }

  /// Get one or a specified number of random values from an array.
  static List<T> random<T>(List<T> array, [int? number]) {
    if (array.isEmpty) {
      return [];
    }

    if (number == null) {
      return [array[Random().nextInt(array.length)]];
    }

    if (number <= 0) {
      throw ArgumentError('Number must be greater than 0');
    }

    if (number > array.length) {
      throw ArgumentError('Number cannot be greater than array length');
    }

    final shuffled = List<T>.from(array)..shuffle();
    return shuffled.take(number).toList();
  }

  /// Set an array item to a given value using "dot" notation.
  static void set(Map<String, dynamic> array, String key, dynamic value) {
    if (!key.contains('.')) {
      array[key] = value;
      return;
    }

    final segments = key.split('.');
    var current = array;

    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      if (!current.containsKey(segment) || current[segment] is! Map) {
        current[segment] = <String, dynamic>{};
      }
      current = current[segment] as Map<String, dynamic>;
    }

    current[segments.last] = value;
  }

  /// Shuffle the given array and return the result.
  static List<T> shuffle<T>(List<T> array) {
    final shuffled = List<T>.from(array);
    shuffled.shuffle();
    return shuffled;
  }

  /// Convert a flattened "dot" notation array to an expanded array.
  static Map<String, dynamic> undot(Map<String, dynamic> array) {
    final results = <String, dynamic>{};

    for (var entry in array.entries) {
      if (entry.key.contains('.')) {
        set(results, entry.key, entry.value);
      } else {
        results[entry.key] = entry.value;
      }
    }

    return results;
  }

  /// Filter the array using the given callback.
  static List<T> where<T>(List<T> array, bool Function(T) callback) {
    return array.where(callback).toList();
  }

  /// If the given value is not an array and not null, wrap it in one.
  static List<T> wrap<T>(dynamic value) {
    if (value == null) {
      return <T>[];
    }

    if (value is List<T>) {
      return value;
    }

    if (value is List) {
      return value.cast<T>();
    }

    if (value is T) {
      return <T>[value];
    }

    throw ArgumentError(
        'Cannot wrap value of type ${value.runtimeType} as List<$T>');
  }
}
