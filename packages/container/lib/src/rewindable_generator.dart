/// A generator that can be rewound and counted.
///
/// This class wraps a generator function and provides the ability to rewind
/// and count the generated items, which is particularly useful for container
/// tagged bindings.
class RewindableGenerator<T> extends Iterable<T> {
  /// The generator callback.
  final Iterable<T> Function() _generator;

  /// The number of items callback or value.
  dynamic _count;

  /// Create a new generator instance.
  ///
  /// @param generator The generator callback
  /// @param count The count callback or value
  RewindableGenerator(this._generator, this._count);

  @override
  Iterator<T> get iterator => _generator().iterator;

  @override
  int get length {
    if (_count is Function) {
      _count = _count();
    }
    return _count as int;
  }

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  T get first => _generator().first;

  @override
  T get last => _generator().last;

  @override
  T get single => _generator().single;

  @override
  T elementAt(int index) => _generator().elementAt(index);

  @override
  List<T> toList({bool growable = true}) =>
      _generator().toList(growable: growable);

  @override
  Set<T> toSet() => _generator().toSet();
}
