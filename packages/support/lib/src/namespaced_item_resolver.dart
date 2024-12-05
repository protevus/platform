/// A class for resolving dot-notated strings into items.
///
/// While Dart doesn't support namespaces directly, this class provides
/// functionality for resolving dot-notated strings into items from a
/// data structure, similar to Laravel's NamespacedItemResolver.
class NamespacedItemResolver {
  /// The separator used in the segments.
  final String separator;

  /// Create a new namespaced item resolver instance.
  const NamespacedItemResolver([this.separator = '.']);

  /// Parse a key into its segments.
  List<String> parseKey(String key) {
    if (key.isEmpty) return [];
    return key.split(separator);
  }

  /// Get an item from an array using "dot" notation.
  T? get<T>(dynamic target, String key, [T? defaultValue]) {
    if (key.isEmpty) return target as T?;

    final segments = parseKey(key);
    if (segments.isEmpty) return target as T?;

    dynamic value = target;
    for (final segment in segments) {
      if (value == null) {
        return defaultValue;
      }

      if (value is Map) {
        value = value[segment];
      } else if (value is List && _isValidIndex(segment, value.length)) {
        value = value[int.parse(segment)];
      } else {
        return defaultValue;
      }
    }

    return (value ?? defaultValue) as T?;
  }

  /// Set an item on an array or object using dot notation.
  void set(dynamic target, String key, dynamic value) {
    if (key.isEmpty) return;

    final segments = parseKey(key);
    if (segments.isEmpty) return;

    dynamic current = target;
    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      final nextSegment = segments[i + 1];

      if (current is! Map) return;

      // Initialize the current segment if needed
      if (!current.containsKey(segment)) {
        if (_isNumeric(nextSegment)) {
          current[segment] = [];
        } else {
          current[segment] = {};
        }
      } else if (_isNumeric(nextSegment) && current[segment] is! List) {
        current[segment] = [];
      }

      current = current[segment];

      // Handle array indices
      if (_isNumeric(nextSegment)) {
        final index = int.parse(nextSegment);
        if (current is List) {
          // Ensure list has enough capacity
          while (current.length <= index) {
            current.add(null);
          }

          // If there are more segments after this, ensure we have a map at this index
          if (i + 2 < segments.length && !_isNumeric(segments[i + 2])) {
            if (current[index] == null || current[index] is! Map) {
              current[index] = {};
            }
            // Navigate to the map at this index
            current = current[index];
            i++; // Skip the numeric segment since we've handled it
          }
        }
      }
    }

    // Handle the final segment
    final lastSegment = segments.last;
    if (current is Map) {
      current[lastSegment] = value;
    } else if (current is List) {
      if (_isNumeric(lastSegment)) {
        final index = int.parse(lastSegment);
        while (current.length <= index) {
          current.add(null);
        }
        current[index] = value;
      } else {
        // We're trying to set a property on a map within the array
        final parentSegment = segments[segments.length - 2];
        if (_isNumeric(parentSegment)) {
          final index = int.parse(parentSegment);
          if (index < current.length) {
            if (current[index] == null || current[index] is! Map) {
              current[index] = <String, dynamic>{};
            }
            (current[index] as Map)[lastSegment] = value;
          }
        }
      }
    }
  }

  /// Remove an item from an array using "dot" notation.
  void remove(dynamic target, String key) {
    if (key.isEmpty) return;

    final segments = parseKey(key);
    if (segments.isEmpty) return;

    dynamic current = target;
    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];

      if (current is! Map || !current.containsKey(segment)) {
        return;
      }

      current = current[segment];
    }

    if (current is Map) {
      current.remove(segments.last);
    } else if (current is List &&
        _isValidIndex(segments.last, current.length)) {
      current.removeAt(int.parse(segments.last));
    }
  }

  /// Check if an item or items exist in using "dot" notation.
  bool has(dynamic target, dynamic key) {
    if (key is List) {
      return key.every((k) => has(target, k));
    }

    if (key is! String) return false;

    if (key.isEmpty) return false;

    final segments = parseKey(key);
    if (segments.isEmpty) return false;

    dynamic current = target;
    for (final segment in segments) {
      if (current == null) return false;

      if (current is Map) {
        if (!current.containsKey(segment)) return false;
        current = current[segment];
      } else if (current is List) {
        if (!_isValidIndex(segment, current.length)) return false;
        current = current[int.parse(segment)];
      } else {
        return false;
      }
    }

    return true;
  }

  /// Check if a string represents a valid numeric index.
  bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return int.tryParse(str) != null;
  }

  /// Check if a string represents a valid index for a list.
  bool _isValidIndex(String str, int length) {
    if (!_isNumeric(str)) return false;
    final index = int.parse(str);
    return index >= 0 && index < length;
  }
}
