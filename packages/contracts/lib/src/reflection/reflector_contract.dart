/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'base.dart';
import 'metadata.dart';

export 'base.dart';
export 'metadata.dart';

/// Core reflector contract for type introspection.
abstract class ReflectorContract {
  /// Get a class mirror
  ClassMirror? reflectClass(Type type);

  /// Get a type mirror
  TypeMirror reflectType(Type type);

  /// Get an instance mirror
  InstanceMirror reflect(Object object);

  /// Get a library mirror
  LibraryMirror reflectLibrary(Uri uri);

  /// Create a new instance
  dynamic createInstance(
    Type type, {
    List<dynamic>? positionalArgs,
    Map<String, dynamic>? namedArgs,
    String? constructorName,
  });
}
