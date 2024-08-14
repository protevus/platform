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

import 'package:scope/scope.dart';

/// [DCliPlatform] exists so we can scope
/// Platform in unit tests to return non-standard results
/// e.g. isWindows == true on a linux platform
class DCliPlatform {
  /// Returns a singleton providing
  /// access to DCli settings.
  factory DCliPlatform() {
    if (Scope.hasScopeKey(scopeKey)) {
      return Scope.use(scopeKey);
    } else {
      return _self ??= DCliPlatform._internal();
    }
  }

  /// To use this method create a [Scope] and inject this
  /// as a value into the scope.
  factory DCliPlatform.forScope({DCliPlatformOS? overriddenPlatform}) =>
      DCliPlatform._internal(overriddenPlatform: overriddenPlatform);

  DCliPlatform._internal({this.overriddenPlatform});

  static ScopeKey<DCliPlatform> scopeKey = ScopeKey<DCliPlatform>();

  static DCliPlatform? _self;

  DCliPlatformOS? overriddenPlatform;

  /// True if you are running on a Mac.
  bool get isMacOS => overriddenPlatform == null
      ? Platform.isMacOS
      : overriddenPlatform == DCliPlatformOS.macos;

  /// True if you are running on a Linux system.
  bool get isLinux => overriddenPlatform == null
      ? Platform.isLinux
      : overriddenPlatform == DCliPlatformOS.linux;

  /// True if you are running on a Window system.
  bool get isWindows => overriddenPlatform == null
      ? Platform.isWindows
      : overriddenPlatform == DCliPlatformOS.windows;
}

enum DCliPlatformOS { windows, linux, macos }
