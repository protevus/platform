import 'dart:io';

/// A constant instance of [ProtevusEnv].
const ProtevusEnvironment protevusEnv = ProtevusEnvironment();

/// Queries the environment's `ANGEL_ENV` value.
class ProtevusEnvironment {
  final String? _customValue;

  /// You can optionally provide a custom value, in order to override the system's
  /// value.
  const ProtevusEnvironment([this._customValue]);

  /// Returns the value of the `ANGEL_ENV` variable; defaults to `'development'`.
  String get value =>
      (_customValue ?? Platform.environment['PROTEVUS_ENV'] ?? 'development')
          .toLowerCase();

  /// Returns whether the [value] is `'development'`.
  bool get isDevelopment => value == 'development';

  /// Returns whether the [value] is `'production'`.
  bool get isProduction => value == 'production';

  /// Returns whether the [value] is `'staging'`.
  bool get isStaging => value == 'staging';
}
