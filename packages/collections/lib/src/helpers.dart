import 'collection.dart';
import 'arr.dart';

/// Create a collection from the given value.
Collection<T> collect<T>(Iterable<T>? value) {
  return Collection<T>(value);
}

/// Fill in data where it's missing using dot notation.
void dataFill(Map<String, dynamic> target, String key, dynamic value) {
  if (!Arr.has(target, key)) {
    dataSet(target, key, value);
  }
}

/// Get an item using dot notation.
dynamic dataGet(dynamic target, String key, [dynamic defaultValue]) {
  if (key.isEmpty) {
    return target;
  }

  if (key.contains('*')) {
    final segments = key.split('.');
    dynamic current = target;
    List<dynamic> results = [];
    bool foundWildcard = false;

    void processSegment(dynamic obj, List<String> remainingSegments,
        [int depth = 0]) {
      if (remainingSegments.isEmpty) {
        results.add(obj);
        return;
      }

      final segment = remainingSegments.first;
      final rest = remainingSegments.sublist(1);

      if (segment == '*') {
        foundWildcard = true;
        if (obj is Iterable) {
          for (var item in obj) {
            processSegment(item, rest, depth + 1);
          }
        }
      } else if (obj is Map) {
        if (obj.containsKey(segment)) {
          processSegment(obj[segment], rest, depth + 1);
        }
      } else if (obj is List && int.tryParse(segment) != null) {
        final index = int.parse(segment);
        if (index < obj.length) {
          processSegment(obj[index], rest, depth + 1);
        }
      }
    }

    processSegment(target, segments);
    return foundWildcard ? results : defaultValue;
  } else if (key.contains('{first}') || key.contains('{last}')) {
    final segments = key.split('.');
    dynamic current = target;

    for (var segment in segments) {
      if (segment == '{first}') {
        current = current is Map ? current[current.keys.first] : current[0];
      } else if (segment == '{last}') {
        current = current is Map
            ? current[current.keys.last]
            : current[current.length - 1];
      } else {
        current = Arr.get(current, segment, defaultValue);
        if (current == defaultValue) return defaultValue;
      }
    }

    return current;
  } else {
    return Arr.get(target, key, defaultValue);
  }
}

/// Set an item using dot notation.
void dataSet(Map<String, dynamic> target, String key, dynamic value,
    {bool overwrite = true}) {
  if (key.contains('*')) {
    final segments = key.split('.');
    dynamic current = target;

    void processSegment(
        dynamic obj, List<String> remainingSegments, dynamic val) {
      if (remainingSegments.isEmpty) return;

      final segment = remainingSegments.first;
      final rest = remainingSegments.sublist(1);

      if (segment == '*') {
        if (obj is Iterable) {
          for (var item in obj) {
            if (item is Map<String, dynamic>) {
              if (rest.isEmpty) {
                if (overwrite) {
                  item[key.split('.').last] = val;
                }
              } else {
                final lastKey = rest.last;
                if (rest.length == 1) {
                  item[lastKey] = val;
                } else {
                  processSegment(item, rest, val);
                }
              }
            }
          }
        }
      } else {
        if (obj is Map<String, dynamic>) {
          if (!obj.containsKey(segment)) {
            obj[segment] = rest.isNotEmpty ? <String, dynamic>{} : val;
          }
          if (rest.isNotEmpty) {
            processSegment(obj[segment], rest, val);
          }
        }
      }
    }

    processSegment(target, segments, value);
  } else if (key.contains('{first}') || key.contains('{last}')) {
    final segments = key.split('.');
    dynamic current = target;

    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      if (segment == '{first}') {
        current = current is Map ? current[current.keys.first] : current[0];
      } else if (segment == '{last}') {
        current = current is Map
            ? current[current.keys.last]
            : current[current.length - 1];
      } else {
        if (current is Map<String, dynamic>) {
          current = current.putIfAbsent(segment, () => <String, dynamic>{});
        }
      }
    }

    final lastSegment = segments.last;
    if (lastSegment == '{first}') {
      if (current is Map) {
        current[current.keys.first] = value;
      } else if (current is List) {
        current[0] = value;
      }
    } else if (lastSegment == '{last}') {
      if (current is Map) {
        current[current.keys.last] = value;
      } else if (current is List) {
        current[current.length - 1] = value;
      }
    } else {
      if (current is Map<String, dynamic>) {
        if (overwrite || !current.containsKey(lastSegment)) {
          current[lastSegment] = value;
        }
      }
    }
  } else {
    final segments = key.split('.');
    dynamic current = target;

    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      if (current is Map<String, dynamic>) {
        if (int.tryParse(segments[i + 1]) != null) {
          current = current.putIfAbsent(segment, () => <dynamic>[]);
        } else {
          current = current.putIfAbsent(segment, () => <String, dynamic>{});
        }
      } else if (current is List && int.tryParse(segment) != null) {
        final index = int.parse(segment);
        while (current.length <= index) {
          current.add(null);
        }
        if (current[index] == null) {
          current[index] = <String, dynamic>{};
        }
        current = current[index];
      }
    }

    final lastSegment = segments.last;
    if (current is Map<String, dynamic>) {
      if (overwrite || !current.containsKey(lastSegment)) {
        current[lastSegment] = value;
      }
    } else if (current is List && int.tryParse(lastSegment) != null) {
      final index = int.parse(lastSegment);
      while (current.length <= index) {
        current.add(null);
      }
      if (overwrite || current[index] == null) {
        current[index] = value;
      }
    }
  }
}

/// Remove an item using dot notation.
void dataForget(dynamic target, String key) {
  if (key.contains('*')) {
    final segments = key.split('.');
    dynamic current = target;

    void processSegment(dynamic obj, List<String> remainingSegments) {
      if (remainingSegments.isEmpty) return;

      final segment = remainingSegments.first;
      final rest = remainingSegments.sublist(1);

      if (segment == '*') {
        if (obj is Iterable) {
          for (var item in obj) {
            if (item is Map<String, dynamic>) {
              if (rest.isEmpty) {
                item.clear();
              } else {
                processSegment(item, rest);
              }
            }
          }
        }
      } else {
        if (obj is Map<String, dynamic> && obj.containsKey(segment)) {
          if (rest.isEmpty) {
            obj.remove(segment);
          } else {
            processSegment(obj[segment], rest);
          }
        } else if (obj is List && int.tryParse(segment) != null) {
          final index = int.parse(segment);
          if (index < obj.length) {
            if (rest.isEmpty) {
              obj.removeAt(index);
            } else {
              processSegment(obj[index], rest);
            }
          }
        }
      }
    }

    processSegment(target, segments);
  } else if (key.contains('{first}') || key.contains('{last}')) {
    final segments = key.split('.');
    dynamic current = target;

    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      if (segment == '{first}') {
        current = current is Map ? current[current.keys.first] : current[0];
      } else if (segment == '{last}') {
        current = current is Map
            ? current[current.keys.last]
            : current[current.length - 1];
      } else if (current is Map<String, dynamic> &&
          current.containsKey(segment)) {
        current = current[segment];
      } else {
        return;
      }
    }

    final lastSegment = segments.last;
    if (lastSegment == '{first}') {
      if (current is Map) {
        current.remove(current.keys.first);
      } else if (current is List && current.isNotEmpty) {
        current.removeAt(0);
      }
    } else if (lastSegment == '{last}') {
      if (current is Map) {
        current.remove(current.keys.last);
      } else if (current is List && current.isNotEmpty) {
        current.removeLast();
      }
    } else {
      if (current is Map) {
        current.remove(lastSegment);
      }
    }
  } else {
    final segments = key.split('.');
    dynamic current = target;

    for (var i = 0; i < segments.length - 1; i++) {
      final segment = segments[i];
      if (current is Map<String, dynamic> && current.containsKey(segment)) {
        current = current[segment];
      } else if (current is List && int.tryParse(segment) != null) {
        final index = int.parse(segment);
        if (index < current.length) {
          current = current[index];
        } else {
          return;
        }
      } else {
        return;
      }
    }

    final lastSegment = segments.last;
    if (current is Map) {
      current.remove(lastSegment);
    } else if (current is List && int.tryParse(lastSegment) != null) {
      final index = int.parse(lastSegment);
      if (index < current.length) {
        current.removeAt(index);
      }
    }
  }
}

/// Get the first element of an array.
T? head<T>(Iterable<T> items) {
  return items.isEmpty ? null : items.first;
}

/// Get the last element of an array.
T? last<T>(Iterable<T> items) {
  return items.isEmpty ? null : items.last;
}

/// Return the default value of the given value.
T value<T>(T Function() valueFactory) {
  return valueFactory();
}
