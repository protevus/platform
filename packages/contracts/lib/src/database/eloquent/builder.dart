import '../query/builder.dart';

/// Interface for Eloquent query builder.
///
/// This contract serves as a marker interface for Eloquent query builders.
/// While it doesn't define any methods, it exists to improve IDE support
/// and type safety when working with Eloquent query builders.
abstract class EloquentBuilder extends QueryBuilder {}
