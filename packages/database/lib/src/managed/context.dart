/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_database/src/managed/data_model_manager.dart' as mm;
import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/persistent_store/persistent_store.dart';
import 'package:protevus_database/src/query/query.dart';

/// A service object that handles connecting to and sending queries to a database.
///
/// You create objects of this type to use the Conduit ORM. Create instances in [ApplicationChannel.prepare]
/// and inject them into controllers that execute database queries.
///
/// A context contains two types of objects:
///
/// - [PersistentStore] : Maintains a connection to a specific database. Transfers data between your application and the database.
/// - [ManagedDataModel] : Contains information about the [ManagedObject] subclasses in your application.
///
/// Example usage:
///
///         class Channel extends ApplicationChannel {
///            ManagedContext context;
///
///            @override
///            Future prepare() async {
///               var store = new PostgreSQLPersistentStore(...);
///               var dataModel = new ManagedDataModel.fromCurrentMirrorSystem();
///               context = new ManagedContext(dataModel, store);
///            }
///
///            @override
///            Controller get entryPoint {
///              final router = new Router();
///              router.route("/path").link(() => new DBController(context));
///              return router;
///            }
///         }
class ManagedContext implements APIComponentDocumenter {
  /// Creates a new instance of [ManagedContext] with the provided [dataModel] and [persistentStore].
  ///
  /// This is the default constructor.
  ///
  /// A [Query] is sent to the database described by [persistentStore]. A [Query] may only be executed
  /// on this context if its type is in [dataModel].
  ManagedContext(this.dataModel, this.persistentStore) {
    mm.add(dataModel!);
    _finalizer.attach(this, persistentStore, detach: this);
  }

  /// Creates a child [ManagedContext] from the provided [parentContext].
  ///
  /// The created child context will share the same [persistentStore] and [dataModel]
  /// as the [parentContext]. This allows you to perform database operations within
  /// a transaction by creating a child context and executing queries on it.
  ///
  /// Example usage:
  ///
  ///     await context.transaction((transaction) async {
  ///       final childContext = ManagedContext.childOf(transaction);
  ///       final query = Query<MyModel>(childContext)..values.name = 'John';
  ///       await query.insert();
  ///     });
  ManagedContext.childOf(ManagedContext parentContext)
      : persistentStore = parentContext.persistentStore,
        dataModel = parentContext.dataModel;

  /// A [Finalizer] that is used to automatically close the [PersistentStore] when the [ManagedContext] is destroyed.
  ///
  /// This [Finalizer] is attached to the [ManagedContext] instance in the constructor, and will call the `close()` method
  /// of the [PersistentStore] when the [ManagedContext] is garbage collected or explicitly closed. This ensures that the
  /// resources associated with the [PersistentStore] are properly cleaned up when the [ManagedContext] is no longer needed.
  static final Finalizer<PersistentStore> _finalizer =
      Finalizer((store) async => store.close());

  /// The persistent store that [Query]s on this context are executed through.
  ///
  /// The [PersistentStore] is responsible for maintaining the connection to the database and
  /// executing queries on behalf of the [ManagedContext]. This property holds the instance
  /// of the persistent store that this [ManagedContext] will use to interact with the database.
  PersistentStore persistentStore;

  /// The data model containing the [ManagedEntity]s that describe the [ManagedObject]s this instance works with.
  final ManagedDataModel? dataModel;

  /// Runs all [Query]s in [transactionBlock] within a database transaction.
  ///
  /// Queries executed within [transactionBlock] will be executed as a database transaction.
  /// A [transactionBlock] is passed a [ManagedContext] that must be the target of all queries
  /// within the block. The context passed to the [transactionBlock] is *not* the same as
  /// the context the transaction was created from.
  ///
  /// *You must not use the context this method was invoked on inside the transactionBlock.
  /// Doing so will deadlock your application.*
  ///
  /// If an exception is encountered in [transactionBlock], any query that has already been
  /// executed will be rolled back and this method will rethrow the exception.
  ///
  /// You may manually rollback a query by throwing a [Rollback] object. This will exit the
  /// [transactionBlock], roll back any changes made in the transaction, but this method will not
  /// throw.
  ///
  /// Rollback takes a string but the transaction
  /// returns `Future<void>`. It would seem to be a better idea to still throw the manual Rollback
  /// so the user has a consistent method of handling the rollback. We could add a property
  /// to the Rollback class 'manual' which would be used to indicate a manual rollback.
  /// For the moment I've changed the return type to Future<void> as
  /// The parameter passed to [Rollback]'s constructor will be returned from this method
  /// so that the caller can determine why the transaction was rolled back.
  ///
  /// Example usage:
  ///
  ///         await context.transaction((transaction) async {
  ///            final q = new Query<Model>(transaction)
  ///             ..values = someObject;
  ///            await q.insert();
  ///            ...
  ///         });
  Future<T> transaction<T>(
    Future<T> Function(ManagedContext transaction) transactionBlock,
  ) {
    return persistentStore.transaction(
      ManagedContext.childOf(this),
      transactionBlock,
    );
  }

  /// Closes this [ManagedContext] and releases its underlying resources.
  ///
  /// This method closes the connection to [persistentStore] and releases [dataModel].
  /// A context may not be reused once it has been closed.
  Future close() async {
    await persistentStore.close();
    _finalizer.detach(this);
    mm.remove(dataModel!);
  }

  /// Returns the [ManagedEntity] for the given [type] from the [dataModel].
  ///
  /// See [ManagedDataModel.entityForType].
  ManagedEntity entityForType(Type type) {
    return dataModel!.entityForType(type);
  }

  /// Inserts a single [object] into this context.
  ///
  /// This method is a shorthand for creating a [Query] with the provided [object] and
  /// calling [Query.insert] to insert the object into the database.
  ///
  /// This method is useful when you need to insert a single object into the database.
  /// If you need to insert multiple objects, consider using the [insertObjects] method
  /// instead.
  ///
  /// Example usage:
  ///
  ///     final user = User()..name = 'John Doe';
  ///     await context.insertObject(user);
  ///
  /// @param object The [ManagedObject] instance to be inserted.
  /// @return A [Future] that completes with the inserted [object] when the insert operation is complete.
  Future<T> insertObject<T extends ManagedObject>(T object) {
    final query = Query<T>(this)..values = object;
    return query.insert();
  }

  /// Inserts each object in [objects] into this context.
  ///
  /// This method takes a list of [ManagedObject] instances and inserts them into the
  /// database in a single operation. If any of the insertions fail, no objects will
  /// be inserted and an exception will be thrown.
  ///
  /// Example usage:
  ///
  ///     final users = [
  ///       User()..name = 'John Doe',
  ///       User()..name = 'Jane Doe',
  ///     ];
  ///     await context.insertObjects(users);
  ///
  /// @param objects A list of [ManagedObject] instances to be inserted.
  /// @return A [Future] that completes with a list of the inserted objects when the
  ///         insert operation is complete.
  Future<List<T>> insertObjects<T extends ManagedObject>(
    List<T> objects,
  ) async {
    return Query<T>(this).insertMany(objects);
  }

  /// Returns an object of type [T] from this context if it exists, otherwise returns null.
  ///
  /// This method retrieves a single [ManagedObject] of type [T] from the database based on the provided [identifier].
  /// If the object of type [T] is found in the database, it is returned. If the object is not found, `null` is returned.
  ///
  /// If the type [T] cannot be inferred, an `ArgumentError` is thrown. Similarly, if the provided [identifier] is not
  /// of the same type as the primary key of the [ManagedEntity] for type [T], `null` is returned.
  ///
  /// Example usage:
  ///
  ///     final user = await context.fetchObjectWithID<User>(1);
  ///     if (user != null) {
  ///       print('Found user: ${user.name}');
  ///     } else {
  ///       print('User not found');
  ///     }
  ///
  /// @param identifier The value of the primary key for the object of type [T] to fetch.
  /// @return A [Future] that completes with the fetched object of type [T] if it exists, or `null` if it does not.
  Future<T?> fetchObjectWithID<T extends ManagedObject>(
    dynamic identifier,
  ) async {
    final entity = dataModel!.tryEntityForType(T);
    if (entity == null) {
      throw ArgumentError("Unknown entity '$T' in fetchObjectWithID. "
          "Provide a type to this method and ensure it is in this context's data model.");
    }

    final primaryKey = entity.primaryKeyAttribute!;
    if (!primaryKey.type!.isAssignableWith(identifier)) {
      return null;
    }

    final query = Query<T>(this)
      ..where((o) => o[primaryKey.name]).equalTo(identifier);
    return query.fetchOne();
  }

  /// Documents the components of the [ManagedContext] by delegating to the
  /// [dataModel]'s [documentComponents] method.
  ///
  /// This method is part of the [APIComponentDocumenter] interface, which is
  /// implemented by [ManagedContext]. It is responsible for generating
  /// documentation for the components (such as [ManagedEntity] and
  /// [ManagedAttribute]) that are part of the data model managed by this
  /// [ManagedContext].
  ///
  /// The documentation is generated and added to the provided [APIDocumentContext].
  @override
  void documentComponents(APIDocumentContext context) =>
      dataModel!.documentComponents(context);
}

/// An exception that can be thrown to rollback a transaction in [ManagedContext.transaction].
///
/// When thrown in a transaction, it will cancel an in-progress transaction and rollback
/// any changes it has made.
class Rollback {
  /// Default constructor, takes a [reason] object that can be anything.
  ///
  /// The parameter [reason] will be returned by [ManagedContext.transaction].
  Rollback(this.reason);

  /// The reason this rollback occurred.
  ///
  /// This value is returned from [ManagedContext.transaction] when this instance is thrown.
  final String reason;
}
