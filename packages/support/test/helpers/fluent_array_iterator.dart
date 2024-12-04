import 'dart:collection';

/// Test helper class that implements Iterable for testing Fluent constructor
class FluentArrayIterator extends IterableBase<MapEntry<String, dynamic>> {
  final Map<String, dynamic> _items;

  FluentArrayIterator(this._items);

  @override
  Iterator<MapEntry<String, dynamic>> get iterator => _items.entries.iterator;

  /// Convert to Map for use with Fluent constructor
  Map<String, dynamic> toMap() => Map.from(_items);
}
