/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 * (C) S. Brett Sutton <bsutton@onepub.dev>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';

import 'dcli_function.dart';

///
/// Returns the current working directory.
///
/// ```dart
/// print(pwd);
/// ```
///
/// See join
///
String get pwd => _PWD().pwd;

class _PWD extends DCliFunction {
  String get pwd => Directory.current.path;
}
