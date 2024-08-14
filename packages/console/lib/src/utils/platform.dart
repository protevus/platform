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

import 'package:protevus_console/core.dart';

/// Extensions for the Platform class
extension PlatformEx on Platform {
  /// Returns the OS specific End Of Line (eol) character.
  /// On Windows this is '\r\n' on all other platforms
  /// it is '\n'.
  /// Usage: Platform().eol
  ///
  /// Note: you must import both:
  /// ```dart
  /// import 'dart:io';
  /// import 'package:dcli/dcli.dart';
  /// ```
  String get eol => DCliPlatform().isWindows ? '\r\n' : '\n';
}

String get eol => DCliPlatform().isWindows ? '\r\n' : '\n';
