import 'dart:collection';
import 'dart:math';

/// A collection class inspired by Laravel's Collection, implemented in Dart.
class Collection<T> with ListMixin<T> {
  final List<T> _items;

  /// Creates a new [Collection] instance.
  Collection([Iterable<T>? items]) : _items = List<T>.from(items ?? <T>[]);

  /// Creates a new [Collection] instance from a [Map].
  factory Collection.fromMap(Map<dynamic, T> map) {
    return Collection(map.values);
  }

  @override
  int get length => _items.length;

  @override
  set length(int newLength) {
    _items.length = newLength;
  }

  @override
  T operator [](int index) => _items[index];

  @override
  void operator []=(int index, T value) {
    _items[index] = value;
  }

  /// Returns all items in the collection.
  List<T> all() => _items.toList();

  /// Returns the average value of the collection.
  double? avg([num Function(T element)? callback]) {
    if (isEmpty) return null;
    num sum = 0;
    for (final item in _items) {
      sum += callback != null ? callback(item) : (item as num);
    }
    return sum / length;
  }

  /// Chunks the collection into smaller collections of a given size.
  Collection<Collection<T>> chunk(int size) {
    return Collection(
      List.generate(
        (length / size).ceil(),
        (index) => Collection(_items.skip(index * size).take(size)),
      ),
    );
  }

  /// Collapses a collection of arrays into a single, flat collection.
  Collection<dynamic> collapse() {
    return Collection(_items.expand((e) => e is Iterable ? e : [e]));
  }

  /// Determines whether the collection contains a given item.
  @override
  bool contains(Object? item) => _items.contains(item);

  /// Returns the total number of items in the collection.
  int count() => length;

  /// Executes a callback over each item.
  void each(void Function(T item) callback) {
    for (final item in _items) {
      callback(item);
    }
  }

  /// Creates a new collection consisting of every n-th element.
  Collection<T> everyNth(int step) {
    return Collection(_items.where((item) => _items.indexOf(item) % step == 0));
  }

  /// Returns all items except for those with the specified keys.
  Collection<T> except(List<int> keys) {
    return Collection(
        _items.where((item) => !keys.contains(_items.indexOf(item))));
  }

  /// Filters the collection using the given callback.
  Collection<T> whereCustom(bool Function(T element) test) {
    return Collection(_items.where(test));
  }

  /// Returns the first element in the collection that passes the given truth test.
  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _items.firstWhere(test, orElse: orElse);
  }

  /// Flattens a multi-dimensional collection into a single dimension.
  Collection<dynamic> flatten({int depth = 1}) {
    List<dynamic> flattenHelper(dynamic item, int currentDepth) {
      if (currentDepth == 0 || item is! Iterable) return [item];
      return item.expand((e) => flattenHelper(e, currentDepth - 1)).toList();
    }

    return Collection(
        flattenHelper(_items, depth).expand((e) => e is Iterable ? e : [e]));
  }

  /// Flips the items in the collection.
  Collection<T> flip() {
    return Collection(_items.reversed);
  }

  /// Removes an item from the collection by its key.
  T? pull(int index) {
    if (index < 0 || index >= length) return null;
    return removeAt(index);
  }

  /// Concatenates the given array or collection with the original collection.
  Collection<T> concat(Iterable<T> items) {
    return Collection([..._items, ...items]);
  }

  /// Reduces the collection to a single value.
  @override
  U fold<U>(U initialValue, U Function(U previousValue, T element) combine) {
    return _items.fold(initialValue, combine);
  }

  /// Groups the collection's items by a given key.
  Map<K, List<T>> groupBy<K>(K Function(T element) keyFunction) {
    return _items.fold<Map<K, List<T>>>({}, (map, element) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => []).add(element);
      return map;
    });
  }

  /// Joins the items in a collection with a string.
  @override
  String join([String separator = '']) => _items.join(separator);

  /// Returns a new collection with the keys of the collection items.
  Collection<int> keys() => Collection(List.generate(length, (index) => index));

  /// Returns the last element in the collection.
  T? lastOrNull() => isNotEmpty ? _items.last : null;

  /// Runs a map over each of the items.
  Collection<R> mapCustom<R>(R Function(T e) toElement) {
    return Collection(_items.map(toElement));
  }

  /// Run a map over each nested chunk of items.
  Collection<R> mapSpread<R>(R Function(dynamic e) toElement) {
    return Collection(_items
        .expand((e) => e is Iterable ? e.map(toElement) : [toElement(e)]));
  }

  /// Returns the maximum value of a given key.
  T? max([Comparable<dynamic> Function(T element)? callback]) {
    if (isEmpty) return null;
    return _items.reduce((a, b) {
      final compareA =
          callback != null ? callback(a) : a as Comparable<dynamic>;
      final compareB =
          callback != null ? callback(b) : b as Comparable<dynamic>;
      return compareA.compareTo(compareB) > 0 ? a : b;
    });
  }

  /// Returns the minimum value of a given key.
  T? min([Comparable<dynamic> Function(T element)? callback]) {
    if (isEmpty) return null;
    return _items.reduce((a, b) {
      final compareA =
          callback != null ? callback(a) : a as Comparable<dynamic>;
      final compareB =
          callback != null ? callback(b) : b as Comparable<dynamic>;
      return compareA.compareTo(compareB) < 0 ? a : b;
    });
  }

  /// Returns only the items from the collection with the specified keys.
  Collection<T> only(List<int> keys) {
    return Collection(
        _items.where((item) => keys.contains(_items.indexOf(item))));
  }

  /// Retrieves all of the collection values for a given key.
  Collection<R> pluck<R>(R Function(T element) callback) {
    return Collection(_items.map(callback));
  }

  /// Removes and returns the last item from the collection.
  T? pop() => isNotEmpty ? removeLast() : null;

  /// Adds an item to the beginning of the collection.
  void prepend(T value) => insert(0, value);

  /// Adds an item to the end of the collection.
  void push(T value) => add(value);

  /// Returns a random item from the collection.
  T? random() => isEmpty ? null : this[_getRandomIndex()];

  /// Reverses the order of the collection's items.
  Collection<T> reverse() => Collection(_items.reversed);

  /// Searches the collection for a given value and returns the corresponding key if successful.
  int? search(T item, {bool Function(T, T)? compare}) {
    compare ??= (a, b) => a == b;
    final index = _items.indexWhere((element) => compare!(element, item));
    return index != -1 ? index : null;
  }

  /// Shuffles the items in the collection.
  @override
  void shuffle([Random? random]) {
    _items.shuffle(random);
  }

  /// Returns a slice of the collection starting at the given index.
  Collection<T> slice(int offset, [int? length]) {
    return Collection(
        _items.skip(offset).take(length ?? _items.length - offset));
  }

  /// Sorts the collection.
  Collection<T> sortCustom([int Function(T a, T b)? compare]) {
    final sorted = [..._items];
    sorted.sort(compare);
    return Collection(sorted);
  }

  /// Takes the first or last {n} items.
  @override
  Collection<T> take(int count) {
    if (count < 0) {
      return Collection(_items.skip(_items.length + count));
    }
    return Collection(_items.take(count));
  }

  /// Returns a JSON representation of the collection.
  String toJson() =>
      '[${_items.map((e) => e is Map ? _mapToJson(e as Map<dynamic, dynamic>) : e.toString()).join(',')}]';

  /// Merges the given array or collection with the original collection.
  Collection<T> merge(Iterable<T> items) {
    return Collection([..._items, ...items]);
  }

  // Helper methods
  int _getRandomIndex() =>
      (DateTime.now().millisecondsSinceEpoch % length).abs();

  String _mapToJson(Map<dynamic, dynamic> map) {
    final pairs = map.entries.map((e) =>
        '"${e.key}":${e.value is Map ? _mapToJson(e.value as Map<dynamic, dynamic>) : '"${e.value}"'}');
    return '{${pairs.join(',')}}';
  }
}
