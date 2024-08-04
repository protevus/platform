/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_typeforge/codable.dart';
import 'package:meta/meta.dart';

class APIObject extends Coding {
  Map<String, dynamic> extensions = {};

  @mustCallSuper
  @override
  void decode(KeyedArchive object) {
    super.decode(object);

    final extensionKeys = object.keys.where((k) => k.startsWith("x-"));
    for (final key in extensionKeys) {
      extensions[key] = object.decode(key);
    }
  }

  @override
  @mustCallSuper
  void encode(KeyedArchive object) {
    final invalidKeys = extensions.keys
        .where((key) => !key.startsWith("x-"))
        .map((key) => "'$key'")
        .toList();
    if (invalidKeys.isNotEmpty) {
      throw ArgumentError(
        "extension keys must start with 'x-'. The following keys are invalid: ${invalidKeys.join(", ")}",
      );
    }

    extensions.forEach((key, value) {
      object.encode(key, value);
    });
  }
}
