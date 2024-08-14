/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 * (C) S. Brett Sutton <bsutton@onepub.dev>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_console/core.dart';

/// Prints the contents of the file located at [path] to stdout.
///
/// ```dart
/// cat("/var/log/syslog");
/// ```
///
/// If the file does not exists then a CatException is thrown.
///
void cat(String path, {LineAction stdout = print}) =>
    Cat().cat(path, stdout: stdout);

/// Class for the [cat] function.
class Cat extends DCliFunction {
  /// implementation for the [cat] function.
  void cat(String path, {LineAction stdout = print}) {
    verbose(() => 'cat:  ${truepath(path)}');

    if (!exists(path)) {
      throw CatException('The file at ${truepath(path)} does not exists');
    }

    LineFile(path).readAll((line) {
      stdout(line);
      return true;
    });
  }
}

/// Thrown if the [cat] function encouters an error.
class CatException extends DCliFunctionException {
  /// Thrown if the [cat] function encouters an error.
  CatException(super.reason, [super.stacktrace]);
}
