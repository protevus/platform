/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:scope/scope.dart';

/// A utility class for managing unit test behavior in DCli.
///
/// This class provides static members to control and detect when code is running
/// within a unit test environment. It uses the `scope` package to manage a boolean
/// flag indicating whether the current execution context is a unit test.
class UnitTestController {
  /// A ScopeKey used to indicate whether the current execution is within a unit test.
  ///
  /// This key is injected when running a unit test, allowing DCli code to be
  /// 'unit test' aware and modify its behavior to be unit test friendly.
  /// The default value is false, indicating that by default, the code is not
  /// running in a unit test environment.
  ///
  /// Usage:
  /// - When set to true, it signals that the code is running within a unit test.
  /// - DCli functions can check this key to adjust their behavior accordingly.
  static final unitTestingKey =
      ScopeKey<bool>.withDefault(false, 'Running in a unit test');

  /// Executes the provided action within a unit test context.
  ///
  /// This method creates a new [Scope] where the [unitTestingKey] is set to true,
  /// indicating that the code is running within a unit test environment. It then
  /// executes the provided [action] within this scope.
  ///
  /// Certain DCli functions modify their behavior when run within a unit test.
  /// They rely on this scope to determine if they are in a unit test environment.
  ///
  /// Usage:
  /// ```dart
  /// await UnitTestController.withUnitTest(() {
  ///   // Your unit test code here
  /// });
  /// ```
  ///
  /// Parameters:
  ///   - action: A void function that contains the code to be executed within the unit test context.
  ///
  /// Returns:
  ///   A [Future] that completes when the action has finished executing.
  static Future<void> withUnitTest(void Function() action) async {
    final scope = Scope()..value(unitTestingKey, true);
    await scope.run(() async => action());
  }
}
