import 'dart:collection';

class RewindableGenerator extends IterableBase {
  /// The generator callback.
  final Function _generator;

  /// The number of tagged services.
  dynamic _count;

  /// Create a new generator instance.
  RewindableGenerator(this._generator, this._count);

  @override
  Iterator get iterator => _generator() as Iterator;

  /// Get the total number of tagged services.
  @override
  int get length {
    if (_count is Function) {
      _count = _count();
    }
    return _count as int;
  }
}
