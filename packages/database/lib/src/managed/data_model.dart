/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:collection/collection.dart' show IterableExtension;
import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/query/query.dart';
import 'package:protevus_runtime/runtime.dart';

/// Instances of this class contain descriptions and metadata for mapping [ManagedObject]s to database rows.
///
/// An instance of this type must be used to initialize a [ManagedContext], and so are required to use [Query]s.
///
/// The [ManagedDataModel.fromCurrentMirrorSystem] constructor will reflect on an application's code and find
/// all subclasses of [ManagedObject], building a [ManagedEntity] for each.
///
/// Most applications do not need to access instances of this type.
class ManagedDataModel extends Object implements APIComponentDocumenter {
  /// Creates an instance of [ManagedDataModel] from a list of types that extend [ManagedObject]. It is preferable
  /// to use [ManagedDataModel.fromCurrentMirrorSystem] over this method.
  ///
  /// To register a class as a managed object within this data model, you must include its type in the list. Example:
  ///
  ///       new DataModel([User, Token, Post]);
  ManagedDataModel(List<Type> instanceTypes) {
    final runtimes = RuntimeContext.current.runtimes.iterable
        .whereType<ManagedEntityRuntime>()
        .toList();
    final expectedRuntimes = instanceTypes
        .map(
          (t) => runtimes.firstWhereOrNull((e) => e.entity.instanceType == t),
        )
        .toList();

    if (expectedRuntimes.any((e) => e == null)) {
      throw ManagedDataModelError(
        "Data model types were not found!",
      );
    }

    for (final runtime in expectedRuntimes) {
      _entities[runtime!.entity.instanceType] = runtime.entity;
      _tableDefinitionToEntityMap[runtime.entity.tableDefinition] =
          runtime.entity;
    }
    for (final runtime in expectedRuntimes) {
      runtime!.finalize(this);
    }
  }

  /// Creates an instance of a [ManagedDataModel] from all subclasses of [ManagedObject] in all libraries visible to the calling library.
  ///
  /// This constructor will search every available package and file library that is visible to the library
  /// that runs this constructor for subclasses of [ManagedObject]. A [ManagedEntity] will be created
  /// and stored in this instance for every such class found.
  ///
  /// Standard Dart libraries (prefixed with 'dart:') and URL-encoded libraries (prefixed with 'data:') are not searched.
  ///
  /// This is the preferred method of instantiating this type.
  ManagedDataModel.fromCurrentMirrorSystem() {
    final runtimes = RuntimeContext.current.runtimes.iterable
        .whereType<ManagedEntityRuntime>();

    for (final runtime in runtimes) {
      _entities[runtime.entity.instanceType] = runtime.entity;
      _tableDefinitionToEntityMap[runtime.entity.tableDefinition] =
          runtime.entity;
    }
    for (final runtime in runtimes) {
      runtime.finalize(this);
    }
  }

  /// Returns an [Iterable] of all [ManagedEntity] instances registered in this [ManagedDataModel].
  ///
  /// This property provides access to the collection of all [ManagedEntity] instances that
  /// were discovered and registered during the construction of this [ManagedDataModel].
  Iterable<ManagedEntity> get entities => _entities.values;

  /// Returns a [ManagedEntity] for a [Type].
  ///
  /// [type] may be either a sub
  /// [type] may be either a subclass of [ManagedObject] or a [ManagedObject]'s table definition. For example, the following
  /// definition
  final Map<Type, ManagedEntity> _entities = {};

  /// A map that associates table definitions to their corresponding [ManagedEntity] instances.
  ///
  /// This map is used to retrieve a [ManagedEntity] instance given a table definition type,
  /// which can be useful when the type of the managed object is not known.
  final Map<String, ManagedEntity> _tableDefinitionToEntityMap = {};

  /// Returns a [ManagedEntity] for a [Type].
  ///
  /// [type] may be either a subclass of [ManagedObject] or a [ManagedObject]'s table definition. For example, the following
  /// definition, you could retrieve its entity by passing MyModel or _MyModel as an argument to this method:
  ///
  ///         class MyModel extends ManagedObject<_MyModel> implements _MyModel {}
  ///         class _MyModel {
  ///           @primaryKey
  ///           int id;
  ///         }
  /// If the [type] has no known [ManagedEntity] then a [StateError] is thrown.
  /// Use [tryEntityForType] to test if an entity exists.
  ManagedEntity entityForType(Type type) {
    final entity = tryEntityForType(type);

    if (entity == null) {
      throw StateError(
        "No entity found for '$type. Did you forget to create a 'ManagedContext'?",
      );
    }

    return entity;
  }

  /// Attempts to retrieve a [ManagedEntity] for the given [Type].
  ///
  /// This method first checks the [_entities] map for a direct match on the [Type]. If no match is found,
  /// it then checks the [_tableDefinitionToEntityMap] for a match on the string representation of the [Type].
  ///
  /// If a [ManagedEntity] is found, it is returned. Otherwise, `null` is returned.
  ManagedEntity? tryEntityForType(Type type) =>
      _entities[type] ?? _tableDefinitionToEntityMap[type.toString()];

  /// Documents the components of the managed data model.
  ///
  /// This method iterates over all the [ManagedEntity] instances registered in this
  /// [ManagedDataModel] and calls the `documentComponents` method on each one, passing
  /// the provided [APIDocumentContext] instance.
  ///
  /// This allows each [ManagedEntity] to describe its own components, such as the
  /// database table definition and the properties of the corresponding [ManagedObject]
  /// subclass, in the context of the API documentation.
  @override
  void documentComponents(APIDocumentContext context) {
    for (final e in entities) {
      e.documentComponents(context);
    }
  }
}

/// An error that is thrown when a [ManagedDataModel] encounters an issue.
///
/// This error is used to indicate that there was a problem during the
/// construction or usage of a [ManagedDataModel] instance. The error
/// message provides information about the specific issue that occurred.
class ManagedDataModelError extends Error {
  ManagedDataModelError(this.message);

  final String message;

  @override
  String toString() {
    return "Data Model Error: $message";
  }
}
