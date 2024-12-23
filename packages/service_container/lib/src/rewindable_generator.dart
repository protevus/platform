import 'dart:collection';

/// A generator that can be rewound to its initial state.
class RewindableGenerator extends IterableBase<dynamic> {
  final Iterable<dynamic> Function() _generator;
  final int _count;
  late Iterable<dynamic> _values;

  /// Creates a new rewindable generator with the given generator function and count.
  RewindableGenerator(this._generator, this._count) {
    _values = _generator();
  }

  /// Returns the count of items in the generator.
  int get count => _count;

  /// Checks if the generator is empty.
  @override
  bool get isEmpty => _count == 0;

  /// Returns an iterator for the current values.
  @override
  Iterator<dynamic> get iterator => _values.iterator;

  /// Rewinds the generator to its initial state.
  void rewind() {
    _values = _generator();
  }

  /// Converts the generator to a list.
  @override
  List<dynamic> toList({bool growable = false}) {
    return _values.toList(growable: growable);
  }

  /// Converts the generator to a set.
  @override
  Set<dynamic> toSet() {
    return _values.toSet();
  }

  /// Returns a string representation of the generator.
  @override
  String toString() {
    return _values.toString();
  }
}
