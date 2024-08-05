/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

class TypeCoercionException implements Exception {
  TypeCoercionException(this.expectedType, this.actualType);

  final Type expectedType;
  final Type actualType;

  @override
  String toString() {
    return "input is not expected type '$expectedType' (input is '$actualType')";
  }
}
