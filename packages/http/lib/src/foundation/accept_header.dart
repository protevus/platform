import 'package:protevus_http/foundation.dart';

/// Represents an Accept-* header.
///
/// An accept header is compound with a list of items,
/// sorted by descending quality.
class AcceptHeader {
  /// The list of AcceptHeaderItem objects.
  final Map<String, AcceptHeaderItem> _items = {};

  /// Indicates whether the items are sorted.
  bool _sorted = true;

  /// Constructs an AcceptHeader with the given items.
  AcceptHeader(List<AcceptHeaderItem> items) {
    for (var item in items) {
      add(item);
    }
  }

  /// Builds an AcceptHeader instance from a string.
  static AcceptHeader fromString(String? headerValue) {
    var parts = HeaderUtils.split(headerValue ?? '', ',;=');
    var index = 0;

    return AcceptHeader(parts.map((subParts) {
      var part = subParts.isNotEmpty ? subParts[0] : '';

      // Convert subParts.sublist(1) to List<List<String>>
      var restParts = subParts.sublist(1).map((item) => [item]).toList();
      var attributes = HeaderUtils.combine(restParts);

      var item = AcceptHeaderItem(
        part,
        Map<String, String>.from(
            attributes.map((key, value) => MapEntry(key, value.toString()))),
      );
      item.setIndex(index++);
      return item;
    }).toList());
  }

  /// Returns header value's string representation.
  @override
  String toString() {
    return _items.values.join(',');
  }

  /// Tests if header has given value.
  bool has(String value) {
    return _items.containsKey(value);
  }

  /// Returns given value's item, if exists.
  AcceptHeaderItem? get(String value) {
    return _items[value] ??
        _items['${value.split('/')[0]}/*'] ??
        _items['*/*'] ??
        _items['*'];
  }

  /// Adds an item.
  AcceptHeader add(AcceptHeaderItem item) {
    _items[item.getValue()] = item;
    _sorted = false;
    return this;
  }

  /// Returns all items.
  List<AcceptHeaderItem> all() {
    _sort();
    return _items.values.toList();
  }

  /// Filters items on their value using given regex.
  AcceptHeader filter(String pattern) {
    var regex = RegExp(pattern);
    return AcceptHeader(_items.values
        .where((item) => regex.hasMatch(item.getValue()))
        .toList());
  }

  /// Returns first item.
  AcceptHeaderItem? first() {
    _sort();
    return _items.isNotEmpty ? _items.values.first : null;
  }

  /// Sorts items by descending quality.
  void _sort() {
    if (!_sorted) {
      var sortedItems = _items.values.toList()
        ..sort((a, b) {
          var qA = a.getQuality();
          var qB = b.getQuality();

          if (qA == qB) {
            return a.getIndex().compareTo(b.getIndex());
          }

          return qB.compareTo(qA);
        });

      _items.clear();
      for (var item in sortedItems) {
        _items[item.getValue()] = item;
      }

      _sorted = true;
    }
  }
}
