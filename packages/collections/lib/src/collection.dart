import 'dart:math' as math;

/// A collection class that provides Laravel-like collection functionality.
class Collection<T> implements Iterable<T> {
  /// The underlying list of items.
  final List<T> _items;

  /// Creates a new collection instance.
  Collection([Iterable<T>? items])
      : _items = items != null ? List<T>.from(items) : [];

  /// Creates a new collection instance from any iterable.
  factory Collection.from(Iterable<T> items) => Collection(items);

  /// Creates an empty collection.
  factory Collection.empty() => Collection();

  /// Wraps any value in a collection.
  static Collection<T> wrap<T>(dynamic value) {
    if (value == null) return Collection<T>();
    if (value is Collection<T>) return value;
    if (value is Iterable<T>) return Collection<T>.from(value);
    if (value is T) return Collection<T>([value]);
    throw ArgumentError('Cannot wrap value of type ${value.runtimeType}');
  }

  /// Gets all items in the collection.
  List<T> all() => toList();

  @override
  List<T> toList({bool growable = true}) =>
      growable ? List<T>.from(_items) : List<T>.unmodifiable(_items);

  @override
  int get length => _items.length;

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  T get first => _items.first;

  @override
  T get last => _items.last;

  @override
  Iterator<T> get iterator => _items.iterator;

  T operator [](int index) => _items[index];
  void operator []=(int index, T value) => _items[index] = value;

  /// Adds an item to the collection.
  void add(T item) => _items.add(item);

  /// Adds all items from an iterable to the collection.
  void addAll(Iterable<T> items) => _items.addAll(items);

  /// Removes an item from the collection.
  bool remove(T item) => _items.remove(item);

  /// Removes the item at the given index.
  T removeAt(int index) => _items.removeAt(index);

  /// Removes a range of items from the collection.
  void removeRange(int start, int end) => _items.removeRange(start, end);

  /// Removes all items from the collection.
  void clear() => _items.clear();

  @override
  Collection<R> map<R>(R Function(T) f) => Collection(_items.map(f));

  /// Maps each item in the collection to a new value.
  Collection<R> mapItems<R>(R Function(T) f) => map(f);

  @override
  Collection<T> where(bool Function(T) test) => Collection(_items.where(test));

  @override
  Collection<R> whereType<R>() => Collection(_items.whereType<R>());

  @override
  R fold<R>(R initial, R Function(R previous, T element) combine) =>
      _items.fold(initial, combine);

  @override
  bool any(bool Function(T) test) => _items.any(test);

  @override
  bool every(bool Function(T) test) => _items.every(test);

  @override
  void forEach(void Function(T element) action) => _items.forEach(action);

  @override
  Collection<T> followedBy(Iterable<T> other) =>
      Collection([..._items, ...other]);

  /// Returns a new collection with the items in reversed order.
  Collection<T> reverse() => Collection(_items.reversed);

  /// Sorts the items in the collection.
  void sort([int Function(T a, T b)? compare]) => _items.sort(compare);

  /// Returns a new collection with the items sorted.
  Collection<T> sorted([int Function(T a, T b)? compare]) {
    final sorted = List<T>.from(_items);
    sorted.sort(compare);
    return Collection(sorted);
  }

  @override
  Collection<T> take(int count) => Collection(_items.take(count));

  @override
  Collection<T> skip(int count) => Collection(_items.skip(count));

  /// Returns a new collection with elements that satisfy the predicate.
  Collection<T> filter(bool Function(T) test) => where(test);

  /// Returns a new collection containing only the elements at the given indices.
  Collection<T> only(List<int> indices) =>
      Collection(indices.map((i) => _items[i]));

  /// Returns a new collection excluding the elements at the given indices.
  Collection<T> except(List<int> indices) {
    final indexSet = indices.toSet();
    return Collection(
        _items.where((item) => !indexSet.contains(_items.indexOf(item))));
  }

  /// Returns a random element from the collection.
  T random() {
    if (isEmpty) {
      throw StateError('Cannot get a random element from empty collection');
    }
    return _items[math.Random().nextInt(length)];
  }

  /// Returns a new collection with duplicate elements removed.
  Collection<T> unique() => Collection(_items.toSet());

  /// Returns a new collection with elements chunked into groups of [size].
  Collection<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Size must be positive');
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(_items.skip(i).take(size).toList());
    }
    return Collection(result);
  }

  /// Returns a new collection with elements split into [numberOfGroups] groups.
  Collection<List<T>> splitIn(int numberOfGroups) {
    if (numberOfGroups <= 0) {
      throw ArgumentError('Number of groups must be positive');
    }
    final size = (length / numberOfGroups).ceil();
    return chunk(size);
  }

  /// Returns a new collection with elements split by the given value.
  Collection<List<T>> split(T separator) {
    final result = <List<T>>[];
    var current = <T>[];
    for (final item in _items) {
      if (item == separator) {
        if (current.isNotEmpty) {
          result.add(List<T>.from(current));
          current = <T>[];
        }
      } else {
        current.add(item);
      }
    }
    if (current.isNotEmpty) {
      result.add(List<T>.from(current));
    }
    return Collection(result);
  }

  /// Returns the average value of numeric elements.
  double avg(num Function(T) selector) {
    if (isEmpty) return 0;
    final sum = _items.fold<num>(0, (sum, item) => sum + selector(item));
    return sum / length;
  }

  /// Returns the maximum value in the collection.
  T max() {
    if (isEmpty) throw StateError('Cannot get max of empty collection');
    return _items.reduce((a, b) {
      if (a is Comparable && b is Comparable) {
        return (a as Comparable).compareTo(b) > 0 ? a : b;
      }
      throw TypeError();
    });
  }

  /// Returns the minimum value in the collection.
  T min() {
    if (isEmpty) throw StateError('Cannot get min of empty collection');
    return _items.reduce((a, b) {
      if (a is Comparable && b is Comparable) {
        return (a as Comparable).compareTo(b) < 0 ? a : b;
      }
      throw TypeError();
    });
  }

  /// Returns a new collection with elements before the given value.
  Collection<T> before(T value) {
    final index = _items.indexOf(value);
    if (index == -1) return Collection.empty();
    return Collection(_items.take(index));
  }

  /// Returns a new collection with elements after the given value.
  Collection<T> after(T value) {
    final index = _items.indexOf(value);
    if (index == -1) return Collection.empty();
    return Collection(_items.skip(index + 1));
  }

  /// Returns a map counting occurrences of elements.
  Map<K, int> countBy<K>([K Function(T)? keySelector]) {
    final selector = keySelector ?? ((T item) => item as K);
    final result = <K, int>{};
    for (final item in _items) {
      final key = selector(item);
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }

  /// Returns a new collection with elements grouped by the given key.
  Map<K, Collection<T>> groupBy<K>(K Function(T) keySelector) {
    final result = <K, List<T>>{};
    for (final item in _items) {
      final key = keySelector(item);
      (result[key] ??= []).add(item);
    }
    return result.map((k, v) => MapEntry(k, Collection(v)));
  }

  /// Returns a new collection keyed by the given key.
  Map<K, T> keyBy<K>(K Function(T) keySelector) =>
      Map.fromEntries(_items.map((item) => MapEntry(keySelector(item), item)));

  /// Returns a new collection with values extracted by key.
  Collection<V> pluck<V>(String key) {
    if (T is! Map<String, dynamic>) throw TypeError();
    return Collection(
        _items.map((item) => (item as Map<String, dynamic>)[key] as V));
  }

  /// Returns a new collection with elements in the given range.
  Collection<T> range(int start, [int? end]) {
    end ??= length;
    if (start < 0) start = length + start;
    if (end < 0) end = length + end;
    return Collection(_items.skip(start).take(end - start));
  }

  /// Returns a new collection with elements that are not in the other collection.
  Collection<T> diff(Iterable<T> other) {
    final otherSet = other.toSet();
    return Collection(_items.where((item) => !otherSet.contains(item)));
  }

  /// Returns a new collection with elements that are in both collections.
  Collection<T> intersect(Iterable<T> other) {
    final otherSet = other.toSet();
    return Collection(_items.where((item) => otherSet.contains(item)));
  }

  /// Returns a new collection with elements from both collections combined.
  Collection<T> union(Iterable<T> other) => Collection({..._items, ...other});

  /// Returns a new collection with elements transformed using the pipe.
  Collection<R> pipe<R>(Collection<R> Function(Collection<T>) callback) =>
      callback(this);

  /// Returns a new collection with elements tapped by the callback.
  Collection<T> tap(void Function(Collection<T>) callback) {
    callback(this);
    return this;
  }

  /// Returns a new collection with elements that pass the truth test.
  Collection<T> whenNotEmpty(Collection<T> Function(Collection<T>) callback) =>
      isEmpty ? this : callback(this);

  /// Returns a new collection with elements unless the condition is true.
  Collection<T> unless(bool Function(Collection<T>) condition,
          Collection<T> Function(Collection<T>) callback) =>
      condition(this) ? this : callback(this);

  /// Returns a new collection with elements repeated [times] times.
  Collection<T> multiply(int times) {
    if (times <= 0) return Collection.empty();
    return Collection(List.generate(times, (_) => _items).expand((x) => x));
  }

  /// Returns a new collection with elements combined with another collection.
  Collection<T> combine(Iterable<T> other) => Collection([..._items, ...other]);

  /// Returns a new collection with nested collections flattened.
  Collection<dynamic> collapse() {
    final result = <dynamic>[];
    void flatten(dynamic item) {
      if (item is Iterable) {
        for (final subItem in item) {
          if (subItem is Iterable) {
            flatten(subItem);
          } else {
            result.add(subItem);
          }
        }
      } else {
        result.add(item);
      }
    }

    for (final item in _items) {
      flatten(item);
    }
    return Collection(result);
  }

  /// Returns a new collection with all possible combinations of elements.
  Collection<List<T>> crossJoin(Iterable<T> other) {
    final result = <List<T>>[];
    for (final item1 in _items) {
      for (final item2 in other) {
        result.add([item1, item2]);
      }
    }
    return Collection(result);
  }

  /// Returns true if the collection contains the element using strict equality.
  bool containsStrict(Object? element) =>
      _items.any((item) => identical(item, element));

  /// Returns true if the collection does not contain the element.
  bool doesntContain(Object? element) => !contains(element);

  /// Returns the first element or throws if the collection is empty.
  T firstOrFail() {
    if (isEmpty) throw StateError('Collection is empty');
    return first;
  }

  /// Returns the sole element that matches the predicate.
  T sole([bool Function(T)? predicate]) {
    if (predicate != null) {
      return where(predicate).single;
    }
    return single;
  }

  /// Returns a new collection with elements chunked based on the predicate.
  Collection<List<T>> chunkWhile(bool Function(T, T) predicate) {
    if (isEmpty) return Collection.empty();
    final result = <List<T>>[];
    var current = <T>[_items.first];
    for (var i = 1; i < length; i++) {
      if (predicate(_items[i - 1], _items[i])) {
        current.add(_items[i]);
      } else {
        result.add(List<T>.from(current));
        current = <T>[_items[i]];
      }
    }
    if (current.isNotEmpty) {
      result.add(List<T>.from(current));
    }
    return Collection(result);
  }

  /// Returns a map representation of the collection.
  Map<K, V> toMap<K, V>() {
    if (T is! MapEntry<K, V>) {
      throw TypeError();
    }
    final entries = _items.cast<MapEntry<K, V>>();
    return Map.fromEntries(entries);
  }

  /// Gets or sets a value in the collection.
  T getOrPut(T key, T Function() defaultValue) {
    final index = _items.indexOf(key);
    if (index != -1) return _items[index];
    final value = defaultValue();
    add(value);
    return value;
  }

  /// Returns a new collection with elements mapped to a dictionary.
  Map<K, V> mapToDictionary<K, V>(MapEntry<K, V> Function(T) transform) =>
      Map.fromEntries(_items.map(transform));

  /// Returns a new collection with elements mapped with keys.
  Map<K, T> mapWithKeys<K>(K Function(T) keySelector) =>
      Map.fromEntries(_items.map((item) => MapEntry(keySelector(item), item)));

  @override
  bool contains(Object? element) => _items.contains(element);

  @override
  T elementAt(int index) => _items[index];

  @override
  Collection<R> expand<R>(Iterable<R> Function(T) f) =>
      Collection(_items.expand(f));

  @override
  T firstWhere(bool Function(T) test, {T Function()? orElse}) =>
      _items.firstWhere(test, orElse: orElse);

  @override
  Collection<R> cast<R>() => Collection(_items.cast<R>());

  @override
  String join([String separator = ""]) => _items.join(separator);

  @override
  T lastWhere(bool Function(T) test, {T Function()? orElse}) =>
      _items.lastWhere(test, orElse: orElse);

  @override
  T reduce(T Function(T value, T element) combine) => _items.reduce(combine);

  @override
  T get single => _items.single;

  @override
  T singleWhere(bool Function(T) test, {T Function()? orElse}) =>
      _items.singleWhere(test, orElse: orElse);

  @override
  Collection<T> skipWhile(bool Function(T) test) =>
      Collection(_items.skipWhile(test));

  @override
  Collection<T> takeWhile(bool Function(T) test) =>
      Collection(_items.takeWhile(test));

  @override
  Set<T> toSet() => _items.toSet();

  @override
  String toString() => _items.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Collection &&
          runtimeType == other.runtimeType &&
          _listEquals(_items, other._items);

  @override
  int get hashCode => Object.hashAll(_items);

  bool _listEquals<E>(List<E> list1, List<E> list2) {
    if (identical(list1, list2)) return true;
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
