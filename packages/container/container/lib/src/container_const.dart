/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// A utility class that contains constant values related to container functionality.
///
/// This class is not meant to be instantiated and only provides static constants.
/// It includes a default error message for reflection-related issues.
class ContainerConst {
  /// The default error message for reflection-related issues.
  ///
  /// This message is used when an attempt is made to perform a reflective action,
  /// but the `ThrowingReflector` class is being used, which disables reflection.
  /// Consider using the `MirrorsReflector` class if reflection is necessary.
  static const String defaultErrorMessage =
      'You attempted to perform a reflective action, but you are using `ThrowingReflector`, '
      'a class which disables reflection. Consider using the `MirrorsReflector` '
      'class if you need reflection.';

  /// Private constructor to prevent instantiation of this utility class.
  ///
  /// This constructor is marked as private (with the underscore prefix) to ensure
  /// that the `ContainerConst` class cannot be instantiated. This is consistent
  /// with the class's purpose of only providing static constants.
  ContainerConst._();
}
