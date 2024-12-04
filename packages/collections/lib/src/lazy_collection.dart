import 'dart:math';
import 'package:platform_contracts/contracts.dart';
import 'collection.dart';
import 'enumerable.dart';

/// A memory efficient collection that only loads items as needed.
class LazyCollection<T>
    implements Enumerable<T>, Iterable<T>, CanBeEscapedWhenCastToString {
  /// The source iterable that will be lazily evaluated.
  final Iterable<T> Function() _source;

  /// Whether the collection should be escaped when cast to string.
  bool _shouldEscape = false;

  /// Create a new lazy collection.
  LazyCollection(Iterable<T> items) : _source = (() => items);

  /// Create a lazy collection from a callback.
  LazyCollection.from(Iterable<T> Function() callback) : _source = callback;

  @override
  Iterable<T> all() => _source();

  @override
  double? avg([num Function(T element)? callback]) {
    var count = 0;
    num sum = 0;

    for (var item in _source()) {
      sum += callback?.call(item) ?? (item is num ? item : 0);
      count++;
    }

    return count > 0 ? sum / count : null;
  }

  @override
  Collection<T> diff(Iterable<T> items) {
    return Collection(_source().where((item) => !items.contains(item)));
  }

  @override
  LazyCollection<T> filter(bool Function(T element) test) {
    return LazyCollection.from(() => _source().where(test));
  }

  @override
  T? tryFirst([bool Function(T element)? predicate]) {
    if (predicate == null) {
      final iterator = _source().iterator;
      return iterator.moveNext() ? iterator.current : null;
    }

    for (var item in _source()) {
      if (predicate(item)) return item;
    }
    return null;
  }

  @override
  T? tryLast([bool Function(T element)? predicate]) {
    if (predicate == null) {
      var result = null;
      for (var item in _source()) {
        result = item;
      }
      return result;
    }

    T? result;
    for (var item in _source()) {
      if (predicate(item)) result = item;
    }
    return result;
  }

  @override
  Collection<R> mapItems<R>(R Function(T element) toElement) {
    return Collection(_source().map(toElement));
  }

  @override
  T? max([dynamic Function(T element)? callback]) {
    final iterator = _source().iterator;
    if (!iterator.moveNext()) return null;

    var result = iterator.current;
    while (iterator.moveNext()) {
      final current = iterator.current;
      final comp1 = callback?.call(result);
      final comp2 = callback?.call(current);

      if (comp1 != null &&
          comp2 != null &&
          comp1 is Comparable &&
          comp2 is Comparable) {
        if (comp2.compareTo(comp1) > 0) result = current;
      } else if (result is Comparable && current is Comparable) {
        if (current.compareTo(result) > 0) result = current;
      }
    }
    return result;
  }

  @override
  T? min([dynamic Function(T element)? callback]) {
    final iterator = _source().iterator;
    if (!iterator.moveNext()) return null;

    var result = iterator.current;
    while (iterator.moveNext()) {
      final current = iterator.current;
      final comp1 = callback?.call(result);
      final comp2 = callback?.call(current);

      if (comp1 != null &&
          comp2 != null &&
          comp1 is Comparable &&
          comp2 is Comparable) {
        if (comp2.compareTo(comp1) < 0) result = current;
      } else if (result is Comparable && current is Comparable) {
        if (current.compareTo(result) < 0) result = current;
      }
    }
    return result;
  }

  @override
  Collection<T> random([int? number]) {
    final items = _source().toList();
    if (items.isEmpty) return Collection<T>();

    final random = Random();
    if (number == null) {
      return Collection([items[random.nextInt(items.length)]]);
    }

    items.shuffle(random);
    return Collection(items.take(number));
  }

  @override
  Collection<T> skip(int count) {
    return Collection(_source().skip(count));
  }

  @override
  Collection<T> take(int limit) {
    return Collection(_source().take(limit));
  }

  @override
  Collection<T> unique([Object? Function(T element)? callback]) {
    final seen = Set();
    return Collection(_source().where((item) {
      final key = callback?.call(item) ?? item;
      return seen.add(key);
    }));
  }

  /// Create a lazy collection by chunking the source into smaller collections.
  LazyCollection<List<T>> chunk(int size) {
    if (size <= 0) return LazyCollection(<List<T>>[]);

    return LazyCollection.from(() sync* {
      var chunk = <T>[];
      for (var item in _source()) {
        chunk.add(item);
        if (chunk.length == size) {
          yield List.unmodifiable(chunk);
          chunk = <T>[];
        }
      }
      if (chunk.isNotEmpty) {
        yield List.unmodifiable(chunk);
      }
    });
  }

  /// Create a lazy collection that will only evaluate items matching the predicate.
  LazyCollection<T> takeUntil(bool Function(T element) predicate) {
    return LazyCollection.from(() sync* {
      for (var item in _source()) {
        if (predicate(item)) break;
        yield item;
      }
    });
  }

  /// Create a lazy collection that will only evaluate items while the predicate is true.
  LazyCollection<T> takeWhileCondition(bool Function(T element) predicate) {
    return LazyCollection.from(() sync* {
      for (var item in _source()) {
        if (!predicate(item)) break;
        yield item;
      }
    });
  }

  /// Create a lazy collection that will skip items until the predicate is true.
  LazyCollection<T> skipUntil(bool Function(T element) predicate) {
    return LazyCollection.from(() sync* {
      var yielding = false;
      for (var item in _source()) {
        if (!yielding && predicate(item)) {
          yielding = true;
        }
        if (yielding) {
          yield item;
        }
      }
    });
  }

  /// Create a lazy collection that will skip items while the predicate is true.
  LazyCollection<T> skipWhileCondition(bool Function(T element) predicate) {
    return LazyCollection.from(() sync* {
      var yielding = false;
      for (var item in _source()) {
        if (!yielding && !predicate(item)) {
          yielding = true;
        }
        if (yielding) {
          yield item;
        }
      }
    });
  }

  /// Create a lazy collection that will map and flatten the results.
  LazyCollection<R> flatMap<R>(Iterable<R> Function(T element) callback) {
    return LazyCollection.from(() sync* {
      for (var item in _source()) {
        yield* callback(item);
      }
    });
  }

  // Iterable implementation
  @override
  Iterator<T> get iterator => _source().iterator;

  @override
  T get first {
    final iterator = _source().iterator;
    if (!iterator.moveNext()) {
      throw StateError('No elements');
    }
    return iterator.current;
  }

  @override
  T get last {
    final iterator = _source().iterator;
    if (!iterator.moveNext()) {
      throw StateError('No elements');
    }
    T result = iterator.current;
    while (iterator.moveNext()) {
      result = iterator.current;
    }
    return result;
  }

  @override
  bool any(bool Function(T) test) => _source().any(test);

  @override
  Iterable<R> cast<R>() => _source().cast<R>();

  @override
  bool contains(Object? element) => _source().contains(element);

  @override
  T elementAt(int index) => _source().elementAt(index);

  @override
  bool every(bool Function(T) test) => _source().every(test);

  @override
  Iterable<R> expand<R>(Iterable<R> Function(T) f) => _source().expand(f);

  @override
  T firstWhere(bool Function(T) test, {T Function()? orElse}) =>
      _source().firstWhere(test, orElse: orElse);

  @override
  R fold<R>(R initialValue, R Function(R, T) combine) =>
      _source().fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => _source().followedBy(other);

  @override
  void forEach(void Function(T) action) => _source().forEach(action);

  @override
  String join([String separator = ""]) => _source().join(separator);

  @override
  T lastWhere(bool Function(T) test, {T Function()? orElse}) =>
      _source().lastWhere(test, orElse: orElse);

  @override
  Iterable<R> map<R>(R Function(T) f) => _source().map(f);

  @override
  T reduce(T Function(T, T) combine) => _source().reduce(combine);

  @override
  T get single => _source().single;

  @override
  T singleWhere(bool Function(T) test, {T Function()? orElse}) =>
      _source().singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skipWhile(bool Function(T) test) => _source().skipWhile(test);

  @override
  Iterable<T> takeWhile(bool Function(T) test) => _source().takeWhile(test);

  @override
  List<T> toList({bool growable = true}) =>
      _source().toList(growable: growable);

  @override
  Set<T> toSet() => _source().toSet();

  @override
  Iterable<T> where(bool Function(T) test) => _source().where(test);

  @override
  Iterable<R> whereType<R>() => _source().whereType<R>();

  @override
  bool get isEmpty => !iterator.moveNext();

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  int get length {
    var count = 0;
    for (var _ in this) {
      count++;
    }
    return count;
  }

  // CanBeEscapedWhenCastToString implementation
  @override
  LazyCollection<T> escapeWhenCastingToString([bool escape = true]) {
    _shouldEscape = escape;
    return this;
  }

  @override
  String toString() {
    if (_shouldEscape) {
      return _source().map((item) => _escape(item.toString())).toString();
    }
    return _source().toString();
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
