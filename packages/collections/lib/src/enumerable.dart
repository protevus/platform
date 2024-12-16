import 'dart:math';
import 'collection.dart';

/// An interface that provides common collection operations.
abstract class Enumerable<T> {
  /// Get all items in the collection.
  Iterable<T> all();

  /// Get the average value of a given key.
  double? avg([num Function(T element)? callback]);

  /// Get the items in the collection that are not present in the given items.
  Collection<T> diff(Iterable<T> items);

  /// Run a filter over each of the items.
  Enumerable<T> filter(bool Function(T element) test);

  /// Try to get the first item from the collection.
  T? tryFirst([bool Function(T element)? predicate]);

  /// Try to get the last item from the collection.
  T? tryLast([bool Function(T element)? predicate]);

  /// Run a map over each of the items.
  Collection<R> mapItems<R>(R Function(T element) toElement);

  /// Get the max value of a given key.
  T? max([dynamic Function(T element)? callback]);

  /// Get the min value of a given key.
  T? min([dynamic Function(T element)? callback]);

  /// Get one or a specified number of items randomly.
  Collection<T> random([int? number]);

  /// Skip the first {$count} items.
  Collection<T> skip(int count);

  /// Take the first {$limit} items.
  Collection<T> take(int limit);

  /// Return only unique items from the collection.
  Collection<T> unique([Object? Function(T element)? callback]);

  /// Join items with a string.
  String join([String separator = '']);
}
