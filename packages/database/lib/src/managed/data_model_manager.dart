/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/managed/data_model.dart';
import 'package:protevus_database/src/managed/entity.dart';

/// A map that keeps track of the number of [ManagedDataModel] instances in the system.
Map<ManagedDataModel, int> _dataModels = {};

/// Finds a [ManagedEntity] for the specified [Type].
///
/// Searches through the [_dataModels] map to find the first [ManagedEntity] that
/// matches the given [Type]. If no matching [ManagedEntity] is found and [orElse]
/// is provided, the [orElse] function is called to provide a fallback
/// [ManagedEntity]. If no [ManagedEntity] is found and [orElse] is not provided,
/// a [StateError] is thrown.
///
/// Parameters:
/// - `type`: The [Type] of the [ManagedEntity] to find.
/// - `orElse`: An optional function that returns a fallback [ManagedEntity] if
///   no match is found.
///
/// Returns:
/// The found [ManagedEntity], or the result of calling [orElse] if provided and
/// no match is found.
///
/// Throws:
/// A [StateError] if no [ManagedEntity] is found and [orElse] is not provided.
ManagedEntity findEntity(
  Type type, {
  ManagedEntity Function()? orElse,
}) {
  for (final d in _dataModels.keys) {
    final entity = d.tryEntityForType(type);
    if (entity != null) {
      return entity;
    }
  }

  if (orElse == null) {
    throw StateError(
      "No entity found for '$type. Did you forget to create a 'ManagedContext'?",
    );
  }

  return orElse();
}

/// Adds a [ManagedDataModel] to the [_dataModels] map, incrementing the count if it already exists
/// or setting the count to 1 if it's a new entry.
///
/// Parameters:
/// - `dataModel`: The [ManagedDataModel] to be added to the map.
void add(ManagedDataModel dataModel) {
  _dataModels.update(dataModel, (count) => count + 1, ifAbsent: () => 1);
}

/// Removes a [ManagedDataModel] from the [_dataModels] map, decrementing the count if it already exists.
///
/// If the count becomes less than 1, the [ManagedDataModel] is removed from the map completely.
///
/// Parameters:
/// - `dataModel`: The [ManagedDataModel] to be removed from the map.
void remove(ManagedDataModel dataModel) {
  if (_dataModels[dataModel] != null) {
    _dataModels.update(dataModel, (count) => count - 1);
    if (_dataModels[dataModel]! < 1) {
      _dataModels.remove(dataModel);
    }
  }
}
