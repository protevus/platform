import 'package:meta/meta.dart';
import '../higher_order_tap_proxy.dart';

/// A mixin that provides tap functionality.
///
/// Similar to Laravel's Tappable trait, this allows classes to tap into
/// method chains for side effects.
mixin Tappable {
  /// Call the given callback with this instance then return the instance.
  ///
  /// If no callback is provided, returns a [HigherOrderTapProxy] that can be
  /// used to tap into method chains.
  ///
  /// Example with callback:
  /// ```dart
  /// class MyClass with Tappable {
  ///   String value = '';
  ///
  ///   MyClass setValue(String newValue) {
  ///     value = newValue;
  ///     return this;
  ///   }
  /// }
  ///
  /// final instance = MyClass()
  ///   .tap((obj) => print('Before: ${obj.value}'))
  ///   .setValue('test')
  ///   .tap((obj) => print('After: ${obj.value}'));
  /// ```
  ///
  /// Example without callback:
  /// ```dart
  /// final instance = MyClass()
  ///   .tap() // Returns HigherOrderTapProxy
  ///   .setValue('test') // Proxied to instance
  ///   .tap() // Returns new HigherOrderTapProxy
  ///   .setValue('another'); // Proxied to instance
  /// ```
  @useResult
  dynamic tap([void Function(dynamic instance)? callback]) {
    if (callback == null) {
      return HigherOrderTapProxy(this);
    }

    callback(this);
    return this;
  }
}
