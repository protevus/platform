/*
 * This file is part of the Protevus Platform.
 * This file is a port of the PHP CountableInterface.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// An abstract class representing objects that can be counted.
///
/// Classes that implement this interface must provide a [count] getter
/// that returns the current count of the object.
abstract class Countable {
  int get count;
}
