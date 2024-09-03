/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

class IntermediateException implements Exception {
  IntermediateException(this.underlying, this.keyPath);

  final dynamic underlying;

  final List<dynamic> keyPath;
}
