/// Provides conditional execution methods for the pipeline.
mixin Conditionable<T> {
  T when(bool Function() callback, void Function(T) callback2) {
    if (callback()) {
      callback2(this as T);
    }
    return this as T;
  }

  T unless(bool Function() callback, void Function(T) callback2) {
    if (!callback()) {
      callback2(this as T);
    }
    return this as T;
  }
}
