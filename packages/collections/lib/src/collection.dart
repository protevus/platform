import 'dart:collection';
import 'dart:math' as math;
import 'package:meta/meta.dart';
import 'package:platform_contracts/contracts.dart';
import 'enumerable.dart';
import 'lazy_collection.dart';
import 'exceptions/item_not_found_exception.dart';
import 'exceptions/multiple_items_found_exception.dart';

/// A wrapper around List that provides a fluent interface for working with arrays of data.
class Collection<T>
    with ListMixin<T>
    implements Enumerable<T>, CanBeEscapedWhenCastToString {
  /// The items contained in the collection.
  final List<T> _items;

  /// Whether the collection should be escaped when cast to string.
  bool _shouldEscape = false;

  /// Create a new collection.
  Collection([Iterable<T>? items]) : _items = List<T>.from(items ?? <T>[]);

  /// Create a collection with the given range.
  static Collection<int> range(int from, int to) {
    return Collection<int>(List.generate(to - from + 1, (i) => i + from));
  }

  /// Get all items in the collection.
  @override
  List<T> all() => List.unmodifiable(_items);

  /// Get a lazy collection for the items in this collection.
  LazyCollection<T> lazy() => LazyCollection<T>(_items);

  /// Get the average value of a given key.
  @override
  double? avg([num Function(T element)? callback]) {
    if (_items.isEmpty) return null;

    num sum = 0;
    for (var item in _items) {
      sum += callback?.call(item) ?? (item is num ? item : 0);
    }
    return sum / _items.length;
  }

  /// Get the median of a given key.
  num? median([num Function(T element)? callback]) {
    if (_items.isEmpty) return null;

    final values = callback != null
        ? _items.map(callback).where((n) => n != null).toList()
        : _items.whereType<num>().toList();

    if (values.isEmpty) return null;

    values.sort();
    final count = values.length;
    final middle = (count / 2).floor();

    if (count % 2 == 0) {
      return (values[middle - 1] + values[middle]) / 2;
    }

    return values[middle];
  }

  /// Get the mode of a given key.
  Collection<T> mode([num Function(T element)? callback]) {
    if (_items.isEmpty) return Collection<T>();

    final transformed = callback != null
        ? _items.map((e) => MapEntry(e, callback(e))).toList()
        : _items.map((e) => MapEntry(e, e is num ? e : null)).toList();

    final counts = <num, List<T>>{};
    for (var entry in transformed) {
      if (entry.value != null) {
        counts.putIfAbsent(entry.value as num, () => []).add(entry.key);
      }
    }

    if (counts.isEmpty) return Collection<T>();

    final maxCount = counts.values.map((list) => list.length).reduce(math.max);
    return Collection(counts.values
        .where((list) => list.length == maxCount)
        .expand((list) => list)
        .toList());
  }

  /// Get the max value of a given key.
  @override
  T? max([dynamic Function(T element)? callback]) {
    if (_items.isEmpty) return null;

    if (callback != null) {
      return _items.reduce((value, element) {
        final comp1 = callback(value);
        final comp2 = callback(element);
        if (comp1 is Comparable && comp2 is Comparable) {
          return comp1.compareTo(comp2) > 0 ? value : element;
        }
        return value;
      });
    }

    if (_items.first is Comparable) {
      return _items.reduce((value, element) {
        return (value as Comparable).compareTo(element) > 0 ? value : element;
      });
    }

    return _items.first;
  }

  /// Get the min value of a given key.
  @override
  T? min([dynamic Function(T element)? callback]) {
    if (_items.isEmpty) return null;

    if (callback != null) {
      return _items.reduce((value, element) {
        final comp1 = callback(value);
        final comp2 = callback(element);
        if (comp1 is Comparable && comp2 is Comparable) {
          return comp1.compareTo(comp2) < 0 ? value : element;
        }
        return value;
      });
    }

    if (_items.first is Comparable) {
      return _items.reduce((value, element) {
        return (value as Comparable).compareTo(element) < 0 ? value : element;
      });
    }

    return _items.first;
  }

  /// Sort through each item with a callback.
  Collection<T> sort([Comparator<T>? compare]) {
    final sorted = List<T>.from(_items);
    if (compare != null) {
      sorted.sort(compare);
    } else if (T is Comparable) {
      sorted.sort((a, b) => (a as Comparable).compareTo(b));
    }
    return Collection(sorted);
  }

  /// Sort the collection using the given callback.
  Collection<T> sortBy(dynamic Function(T element) callback,
      {bool desc = false}) {
    final sorted = List<T>.from(_items);
    sorted.sort((a, b) {
      final aVal = callback(a);
      final bVal = callback(b);
      if (aVal is Comparable && bVal is Comparable) {
        final comparison = aVal.compareTo(bVal);
        return desc ? -comparison : comparison;
      }
      return 0;
    });
    return Collection(sorted);
  }

  /// Sort the collection in descending order using the given callback.
  Collection<T> sortByDesc(dynamic Function(T element) callback) {
    return sortBy(callback, desc: true);
  }

  /// Sort the collection keys.
  Collection<T> sortKeys({bool desc = false}) {
    final sorted = Map.fromEntries(_items.asMap().entries.toList()
      ..sort((a, b) => desc ? b.key.compareTo(a.key) : a.key.compareTo(b.key)));
    return Collection(sorted.values);
  }

  /// Sort the collection keys in descending order.
  Collection<T> sortKeysDesc() {
    return sortKeys(desc: true);
  }

  /// Sort the collection keys using a callback.
  Collection<T> sortKeysUsing(Comparator<int> callback) {
    final sorted = Map.fromEntries(_items.asMap().entries.toList()
      ..sort((a, b) => callback(a.key, b.key)));
    return Collection(sorted.values);
  }

  /// Chunk the collection into chunks of the given size.
  Collection<Collection<T>> chunk(int size) {
    if (size <= 0) return Collection<Collection<T>>();

    final chunks = <Collection<T>>[];
    for (var i = 0; i < _items.length; i += size) {
      chunks.add(Collection(_items.sublist(
          i, i + size > _items.length ? _items.length : i + size)));
    }
    return Collection(chunks);
  }

  /// Chunk the collection into chunks with a callback.
  Collection<Collection<T>> chunkWhile(
      bool Function(T value, T previous) callback) {
    if (_items.isEmpty) return Collection<Collection<T>>();

    final chunks = <Collection<T>>[];
    var chunk = <T>[_items.first];

    for (var i = 1; i < _items.length; i++) {
      if (callback(_items[i], _items[i - 1])) {
        chunk.add(_items[i]);
      } else {
        chunks.add(Collection(chunk));
        chunk = <T>[_items[i]];
      }
    }

    if (chunk.isNotEmpty) {
      chunks.add(Collection(chunk));
    }

    return Collection(chunks);
  }

  /// Create chunks representing a "sliding window" view of the items in the collection.
  Collection<Collection<T>> sliding(int size, [int step = 1]) {
    if (size <= 0 || step <= 0) return Collection<Collection<T>>();

    final result = <Collection<T>>[];
    for (var i = 0; i <= _items.length - size; i += step) {
      result.add(Collection(_items.sublist(i, i + size)));
    }
    return Collection(result);
  }

  /// Cross join with the given lists, returning all possible permutations.
  Collection<List<dynamic>> crossJoin(List<List<dynamic>> lists) {
    final result = <List<dynamic>>[];
    final allLists = [_items, ...lists];

    void _crossJoin(List<dynamic> current, int depth) {
      if (depth == allLists.length) {
        result.add(List.from(current));
        return;
      }

      for (var item in allLists[depth]) {
        current.add(item);
        _crossJoin(current, depth + 1);
        current.removeLast();
      }
    }

    _crossJoin([], 0);
    return Collection(result);
  }

  /// Collapse a collection of arrays into a single flat collection.
  Collection<dynamic> collapse() {
    final result = <dynamic>[];
    for (var item in _items) {
      if (item is Iterable) {
        result.addAll(item);
      } else {
        result.add(item);
      }
    }
    return Collection(result);
  }

  /// Get the items in the collection that are not present in the given items.
  @override
  Collection<T> diff(Iterable<T> items) {
    return Collection(_items.where((item) => !items.contains(item)));
  }

  /// Get the items in the collection that are not present in the given items, using the callback.
  Collection<T> diffUsing(Iterable<T> items, int Function(T a, T b) callback) {
    return Collection(_items
        .where((item) => !items.any((other) => callback(item, other) == 0)));
  }

  /// Get the items in the collection whose keys and values are not present in the given items.
  Collection<T> diffAssoc(Iterable<T> items) {
    final otherMap =
        Map.fromIterables(List.generate(items.length, (i) => i), items);
    final thisMap =
        Map.fromIterables(List.generate(_items.length, (i) => i), _items);

    return Collection(thisMap.entries
        .where((entry) =>
            !otherMap.containsKey(entry.key) ||
            otherMap[entry.key] != entry.value)
        .map((entry) => entry.value));
  }

  /// Get the items in the collection whose keys and values are not present in the given items, using the callback.
  Collection<T> diffAssocUsing(
      Iterable<T> items, int Function(T a, T b) callback) {
    final otherMap =
        Map.fromIterables(List.generate(items.length, (i) => i), items);
    final thisMap =
        Map.fromIterables(List.generate(_items.length, (i) => i), _items);

    return Collection(thisMap.entries
        .where((entry) =>
            !otherMap.containsKey(entry.key) ||
            callback(entry.value, otherMap[entry.key] as T) != 0)
        .map((entry) => entry.value));
  }

  /// Get the items in the collection whose keys are not present in the given items.
  Collection<T> diffKeys(Iterable<T> items) {
    final otherKeys = Set.from(List.generate(items.length, (i) => i));
    return Collection(_items
        .asMap()
        .entries
        .where((entry) => !otherKeys.contains(entry.key))
        .map((entry) => entry.value));
  }

  /// Get the items in the collection whose keys are not present in the given items, using the callback.
  Collection<T> diffKeysUsing(
      Iterable<T> items, int Function(int a, int b) callback) {
    final otherKeys = List.generate(items.length, (i) => i);
    return Collection(_items
        .asMap()
        .entries
        .where(
            (entry) => !otherKeys.any((key) => callback(entry.key, key) == 0))
        .map((entry) => entry.value));
  }

  /// Retrieve duplicate items from the collection.
  Collection<T> duplicates([Object? Function(T element)? callback]) {
    final seen = <Object?>{};
    final duplicates = <T>{};

    for (var item in _items) {
      final key = callback?.call(item) ?? item;
      if (!seen.add(key)) {
        duplicates.add(item);
      }
    }

    return Collection(duplicates.toList());
  }

  /// Get all items except for those with the specified keys.
  Collection<T> except(Iterable<int> keys) {
    final keySet = Set.from(keys);
    return Collection(_items
        .asMap()
        .entries
        .where((entry) => !keySet.contains(entry.key))
        .map((entry) => entry.value));
  }

  /// Run a filter over each of the items.
  @override
  Collection<T> filter(bool Function(T element) test) {
    return Collection(_items.where(test));
  }

  /// Try to get the first item matching the predicate.
  @override
  T? tryFirst([bool Function(T element)? predicate]) {
    if (predicate == null) {
      return _items.isEmpty ? null : _items.first;
    }

    for (var item in _items) {
      if (predicate(item)) return item;
    }
    return null;
  }

  /// Get the first item in the collection but throw an exception if no matching items exist.
  T firstOrFail([bool Function(T element)? predicate]) {
    final item = tryFirst(predicate);
    if (item == null) {
      throw ItemNotFoundException(
        null,
        predicate != null
            ? 'No matching items found in collection.'
            : 'Collection is empty.',
      );
    }
    return item;
  }

  /// Get the first item in the collection, but only if exactly one item exists.
  T sole([bool Function(T element)? predicate]) {
    final filtered = predicate != null ? _items.where(predicate) : _items;
    final count = filtered.length;

    if (count == 0) {
      throw ItemNotFoundException(
        null,
        predicate != null
            ? 'No matching items found in collection.'
            : 'Collection is empty.',
      );
    }

    if (count > 1) {
      throw MultipleItemsFoundException(
        count,
        predicate != null
            ? 'Multiple matching items found in collection.'
            : 'Multiple items found in collection.',
      );
    }

    return filtered.first;
  }

  /// Try to get the last item matching the predicate.
  @override
  T? tryLast([bool Function(T element)? predicate]) {
    if (predicate == null) {
      return _items.isEmpty ? null : _items.last;
    }

    T? result;
    for (var item in _items) {
      if (predicate(item)) result = item;
    }
    return result;
  }

  /// Get the item before the first matching item.
  T? before(T value) {
    final index = _items.indexOf(value);
    if (index <= 0) return null;
    return _items[index - 1];
  }

  /// Get the item after the first matching item.
  T? after(T value) {
    final index = _items.indexOf(value);
    if (index == -1 || index >= _items.length - 1) return null;
    return _items[index + 1];
  }

  /// Flip the collection's items.
  Collection<dynamic> flip() {
    final result = <dynamic, dynamic>{};
    for (var i = 0; i < _items.length; i++) {
      result[_items[i]] = i;
    }
    return Collection(result.keys.toList());
  }

  /// Group an associative array by a field or using a callback.
  Map<K, Collection<T>> groupBy<K>(K Function(T element) keyFunction) {
    final result = <K, List<T>>{};
    for (var item in _items) {
      final key = keyFunction(item);
      result.putIfAbsent(key, () => []).add(item);
    }
    return result.map((key, value) => MapEntry(key, Collection(value)));
  }

  /// Key an associative array by a field or using a callback.
  Map<K, T> keyBy<K>(K Function(T element) keyFunction) {
    return Map.fromEntries(
      _items.map((item) => MapEntry(keyFunction(item), item)),
    );
  }

  /// Get the values of a given key.
  Collection<R> pluck<R>(R Function(T element) valueFunction) {
    return Collection(_items.map(valueFunction));
  }

  /// Run a dictionary map over the items.
  Map<K, List<V>> mapToDictionary<K, V>(
      MapEntry<K, V> Function(T element) callback) {
    final result = <K, List<V>>{};
    for (var item in _items) {
      final entry = callback(item);
      result.putIfAbsent(entry.key, () => []).add(entry.value);
    }
    return result;
  }

  /// Run an associative map over each of the items.
  Map<K, V> mapWithKeys<K, V>(MapEntry<K, V> Function(T element) callback) {
    return Map.fromEntries(_items.map(callback));
  }

  /// Determine if an item exists in the collection.
  bool contains(Object? item) => _items.contains(item);

  /// Determine if an item exists in the collection using strict comparison.
  bool containsStrict(T value) => _items.any((item) => identical(item, value));

  /// Determine if an item is not contained in the collection.
  bool doesntContain(Object? item) => !contains(item);

  /// Get an item from the collection by key or add it to collection if it does not exist.
  T getOrPut(int key, T Function() defaultValue) {
    if (key >= 0 && key < _items.length) {
      return _items[key];
    }
    final value = defaultValue();
    if (key == _items.length) {
      _items.add(value);
    } else {
      while (_items.length < key) {
        _items.add(null as T);
      }
      _items.add(value);
    }
    return value;
  }

  /// Determine if a given key exists in the collection.
  bool has(int index) => index >= 0 && index < _items.length;

  /// Determine if any of the given keys exist in the collection.
  bool hasAny(Iterable<int> keys) => keys.any(has);

  /// Get the intersection of the collection with the given items.
  Collection<T> intersect(Iterable<T> items) {
    final otherSet = Set.from(items);
    return Collection(_items.where((item) => otherSet.contains(item)));
  }

  /// Get the intersection of the collection with the given items, using the callback.
  Collection<T> intersectUsing(
      Iterable<T> items, int Function(T a, T b) callback) {
    return Collection(_items
        .where((item) => items.any((other) => callback(item, other) == 0)));
  }

  /// Get the intersection of the collection with the given items with additional index check.
  Collection<T> intersectAssoc(Iterable<T> items) {
    final otherMap =
        Map.fromIterables(List.generate(items.length, (i) => i), items);
    final thisMap =
        Map.fromIterables(List.generate(_items.length, (i) => i), _items);

    return Collection(thisMap.entries
        .where((entry) =>
            otherMap.containsKey(entry.key) &&
            otherMap[entry.key] == entry.value)
        .map((entry) => entry.value));
  }

  /// Get the intersection of the collection with the given items with additional index check, using the callback.
  Collection<T> intersectAssocUsing(
      Iterable<T> items, int Function(T a, T b) callback) {
    final otherMap =
        Map.fromIterables(List.generate(items.length, (i) => i), items);
    final thisMap =
        Map.fromIterables(List.generate(_items.length, (i) => i), _items);

    return Collection(thisMap.entries
        .where((entry) =>
            otherMap.containsKey(entry.key) &&
            callback(entry.value, otherMap[entry.key] as T) == 0)
        .map((entry) => entry.value));
  }

  /// Join items with a string.
  @override
  String join([String separator = '']) => _items.join(separator);

  /// Join items with a string and optional final separator.
  String joinWith(String separator, [String? lastSeparator]) {
    if (_items.isEmpty) return '';
    if (_items.length == 1) return _items.first.toString();

    if (lastSeparator == null) {
      return _items.join(separator);
    }

    final allButLast = _items.take(_items.length - 1).join(separator);
    return '$allButLast$lastSeparator${_items.last}';
  }

  /// Run a map over each of the items.
  @override
  Collection<R> mapItems<R>(R Function(T element) toElement) {
    return Collection(_items.map(toElement));
  }

  /// Create a new collection consisting of every n-th element.
  Collection<T> nth(int step, [int offset = 0]) {
    final result = <T>[];
    for (var i = offset; i < _items.length; i += step) {
      result.add(_items[i]);
    }
    return Collection(result);
  }

  /// Get the items with the specified keys.
  Collection<T> only(Iterable<int> keys) {
    return Collection(keys.where((key) => has(key)).map((key) => _items[key]));
  }

  /// Pad collection to the specified length with a value.
  Collection<T> pad(int size, T value) {
    final result = List<T>.from(_items);
    if (size > 0) {
      while (result.length < size) {
        result.add(value);
      }
    } else if (size < 0) {
      while (result.length < -size) {
        result.insert(0, value);
      }
    }
    return Collection(result);
  }

  /// Get one or a specified number of items randomly.
  @override
  Collection<T> random([int? number]) {
    if (_items.isEmpty) return Collection<T>();

    final random = math.Random();
    if (number == null) {
      return Collection([_items[random.nextInt(_items.length)]]);
    }

    final shuffled = List<T>.from(_items)..shuffle(random);
    return Collection(shuffled.take(number));
  }

  /// Multiply the items in the collection by the multiplier.
  Collection<T> multiply(int multiplier) {
    if (multiplier <= 0) return Collection<T>();
    return Collection(
        List.generate(multiplier, (_) => _items).expand((x) => x));
  }

  /// Create a collection by using this collection for keys and another for its values.
  Collection<MapEntry<T, V>> combine<V>(Iterable<V> values) {
    final valuesList = values.toList();
    if (_items.length != valuesList.length) {
      throw ArgumentError(
          'The number of elements in both collections must be equal');
    }
    return Collection(
      List.generate(
        _items.length,
        (i) => MapEntry(_items[i], valuesList[i]),
      ),
    );
  }

  /// Count the number of items in the collection by a field or using a callback.
  Map<K, int> countBy<K>(K Function(T element) callback) {
    final result = <K, int>{};
    for (var item in _items) {
      final key = callback(item);
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }

  /// Split a collection into a certain number of groups.
  Collection<Collection<T>> split(int numberOfGroups) {
    if (_items.isEmpty || numberOfGroups <= 0) {
      return Collection<Collection<T>>();
    }

    final result = <Collection<T>>[];
    final size = (_items.length / numberOfGroups).ceil();

    for (var i = 0; i < _items.length; i += size) {
      result.add(Collection(
        _items.sublist(i, math.min(i + size, _items.length)),
      ));
    }

    return Collection(result);
  }

  /// Split a collection into a certain number of groups, and fill the first groups completely.
  Collection<Collection<T>> splitIn(int numberOfGroups) {
    if (_items.isEmpty || numberOfGroups <= 0) {
      return Collection<Collection<T>>();
    }

    final size = (_items.length / numberOfGroups).ceil();
    return chunk(size);
  }

  /// Skip the first {$count} items.
  @override
  Collection<T> skip(int count) {
    return Collection(_items.skip(count));
  }

  /// Skip items in the collection until the given condition is met.
  Collection<T> skipUntil(bool Function(T element) callback) {
    var skip = true;
    return Collection(_items.where((element) {
      if (!skip) return true;
      if (callback(element)) {
        skip = false;
        return true;
      }
      return false;
    }));
  }

  /// Skip items in the collection while the given condition is met.
  Collection<T> skipWhile(bool Function(T element) callback) {
    var skip = true;
    return Collection(_items.where((element) {
      if (!skip) return true;
      if (!callback(element)) {
        skip = false;
        return true;
      }
      return false;
    }));
  }

  /// Splice a portion of the underlying collection array.
  Collection<T> splice(int offset, [int? length, List<T>? replacement]) {
    final removed = length != null
        ? _items.sublist(offset, math.min(offset + length, _items.length))
        : _items.sublist(offset);

    if (length != null) {
      _items.removeRange(offset, math.min(offset + length, _items.length));
    } else {
      _items.removeRange(offset, _items.length);
    }

    if (replacement != null) {
      _items.insertAll(offset, replacement);
    }

    return Collection(removed);
  }

  /// Take the first {$limit} items.
  @override
  Collection<T> take(int limit) {
    return Collection(_items.take(limit));
  }

  /// Take items in the collection until the given condition is met.
  Collection<T> takeUntil(bool Function(T element) callback) {
    final result = <T>[];
    for (var item in _items) {
      result.add(item);
      if (callback(item)) break;
    }
    return Collection(result);
  }

  /// Take items in the collection while the given condition is met.
  Collection<T> takeWhile(bool Function(T element) callback) {
    final result = <T>[];
    for (var item in _items) {
      if (!callback(item)) break;
      result.add(item);
    }
    return Collection(result);
  }

  /// Convert the collection to a Map.
  Map<K, V> toMap<K, V>(
    K Function(T element) keyFunction,
    V Function(T element) valueFunction,
  ) {
    return Map.fromEntries(
      _items.map((item) => MapEntry(keyFunction(item), valueFunction(item))),
    );
  }

  /// Return only unique items from the collection.
  @override
  Collection<T> unique([Object? Function(T element)? callback]) {
    final seen = Set();
    return Collection(_items.where((item) {
      final key = callback?.call(item) ?? item;
      return seen.add(key);
    }));
  }

  /// Union the collection with the given items.
  Collection<T> union(Iterable<T> items) {
    return Collection({..._items, ...items});
  }

  // ListMixin implementation
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

  @override
  void add(T element) => _items.add(element);

  @override
  void addAll(Iterable<T> iterable) => _items.addAll(iterable);

  @override
  void clear() => _items.clear();

  @override
  void removeRange(int start, int end) => _items.removeRange(start, end);

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _items.setRange(start, end, iterable, skipCount);
  }

  @override
  void setAll(int index, Iterable<T> iterable) =>
      _items.setAll(index, iterable);

  @override
  void insertAll(int index, Iterable<T> iterable) =>
      _items.insertAll(index, iterable);

  @override
  void insert(int index, T element) => _items.insert(index, element);

  @override
  bool remove(Object? element) => _items.remove(element);

  @override
  T removeAt(int index) => _items.removeAt(index);

  // CanBeEscapedWhenCastToString implementation
  @override
  Collection<T> escapeWhenCastingToString([bool escape = true]) {
    _shouldEscape = escape;
    return this;
  }

  @override
  String toString() {
    if (_shouldEscape) {
      return _items.map((item) => _escape(item.toString())).toString();
    }
    return _items.toString();
  }

  /// Escape special characters in a string.
  String _escape(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
