# Model Package Specification

## Overview

The Model package provides a robust data modeling system that matches Laravel's Eloquent functionality. It supports active record pattern, relationships, attribute casting, serialization, and model events while leveraging Dart's type system.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Events Package Specification](events_package_specification.md) for model events

## Core Features

### 1. Base Model

```dart
/// Core model implementation
abstract class Model {
  /// Model attributes
  final Map<String, dynamic> _attributes = {};
  
  /// Original attributes
  final Map<String, dynamic> _original = {};
  
  /// Changed attributes
  final Set<String> _changes = {};
  
  /// Model constructor
  Model([Map<String, dynamic>? attributes]) {
    fill(attributes ?? {});
  }
  
  /// Gets table name
  String get table;
  
  /// Gets primary key
  String get primaryKey => 'id';
  
  /// Gets fillable attributes
  List<String> get fillable => [];
  
  /// Gets guarded attributes
  List<String> get guarded => ['id'];
  
  /// Gets attribute value
  dynamic operator [](String key) => getAttribute(key);
  
  /// Sets attribute value
  operator []=(String key, dynamic value) => setAttribute(key, value);
  
  /// Gets an attribute
  dynamic getAttribute(String key) {
    return _attributes[key];
  }
  
  /// Sets an attribute
  void setAttribute(String key, dynamic value) {
    if (!_original.containsKey(key)) {
      _original[key] = _attributes[key];
    }
    
    _attributes[key] = value;
    _changes.add(key);
  }
  
  /// Fills attributes
  void fill(Map<String, dynamic> attributes) {
    for (var key in attributes.keys) {
      if (_isFillable(key)) {
        this[key] = attributes[key];
      }
    }
  }
  
  /// Checks if attribute is fillable
  bool _isFillable(String key) {
    if (guarded.contains(key)) return false;
    if (fillable.isEmpty) return true;
    return fillable.contains(key);
  }
  
  /// Gets changed attributes
  Map<String, dynamic> getDirty() {
    var dirty = <String, dynamic>{};
    for (var key in _changes) {
      dirty[key] = _attributes[key];
    }
    return dirty;
  }
  
  /// Checks if model is dirty
  bool get isDirty => _changes.isNotEmpty;
  
  /// Gets original attributes
  Map<String, dynamic> getOriginal() => Map.from(_original);
  
  /// Resets changes
  void syncOriginal() {
    _original.clear();
    _original.addAll(_attributes);
    _changes.clear();
  }
  
  /// Converts to map
  Map<String, dynamic> toMap() => Map.from(_attributes);
  
  /// Converts to JSON
  String toJson() => jsonEncode(toMap());
}
```

### 2. Model Relationships

```dart
/// Has one relationship
class HasOne<T extends Model> extends Relationship<T> {
  /// Foreign key
  final String foreignKey;
  
  /// Local key
  final String localKey;
  
  HasOne(Query<T> query, Model parent, this.foreignKey, this.localKey)
      : super(query, parent);
  
  @override
  Future<T?> get() async {
    return await query
      .where(foreignKey, parent[localKey])
      .first();
  }
}

/// Has many relationship
class HasMany<T extends Model> extends Relationship<T> {
  /// Foreign key
  final String foreignKey;
  
  /// Local key
  final String localKey;
  
  HasMany(Query<T> query, Model parent, this.foreignKey, this.localKey)
      : super(query, parent);
  
  @override
  Future<List<T>> get() async {
    return await query
      .where(foreignKey, parent[localKey])
      .get();
  }
}

/// Belongs to relationship
class BelongsTo<T extends Model> extends Relationship<T> {
  /// Foreign key
  final String foreignKey;
  
  /// Owner key
  final String ownerKey;
  
  BelongsTo(Query<T> query, Model child, this.foreignKey, this.ownerKey)
      : super(query, child);
  
  @override
  Future<T?> get() async {
    return await query
      .where(ownerKey, parent[foreignKey])
      .first();
  }
}
```

### 3. Model Events

```dart
/// Model events mixin
mixin ModelEvents {
  /// Event dispatcher
  static EventDispatcherContract? _dispatcher;
  
  /// Sets event dispatcher
  static void setEventDispatcher(EventDispatcherContract dispatcher) {
    _dispatcher = dispatcher;
  }
  
  /// Fires a model event
  Future<bool> fireModelEvent(String event) async {
    if (_dispatcher == null) return true;
    
    var result = await _dispatcher!.dispatch('model.$event', this);
    return result != false;
  }
  
  /// Fires creating event
  Future<bool> fireCreatingEvent() => fireModelEvent('creating');
  
  /// Fires created event
  Future<bool> fireCreatedEvent() => fireModelEvent('created');
  
  /// Fires updating event
  Future<bool> fireUpdatingEvent() => fireModelEvent('updating');
  
  /// Fires updated event
  Future<bool> fireUpdatedEvent() => fireModelEvent('updated');
  
  /// Fires deleting event
  Future<bool> fireDeletingEvent() => fireModelEvent('deleting');
  
  /// Fires deleted event
  Future<bool> fireDeletedEvent() => fireModelEvent('deleted');
}
```

### 4. Model Query Builder

```dart
/// Model query builder
class Query<T extends Model> {
  /// Database connection
  final DatabaseConnection _connection;
  
  /// Model instance
  final T _model;
  
  /// Query constraints
  final List<String> _wheres = [];
  final List<dynamic> _bindings = [];
  final List<String> _orders = [];
  int? _limit;
  int? _offset;
  
  Query(this._connection, this._model);
  
  /// Adds where clause
  Query<T> where(String column, [dynamic value]) {
    _wheres.add('$column = ?');
    _bindings.add(value);
    return this;
  }
  
  /// Adds order by clause
  Query<T> orderBy(String column, [String direction = 'asc']) {
    _orders.add('$column $direction');
    return this;
  }
  
  /// Sets limit
  Query<T> limit(int limit) {
    _limit = limit;
    return this;
  }
  
  /// Sets offset
  Query<T> offset(int offset) {
    _offset = offset;
    return this;
  }
  
  /// Gets first result
  Future<T?> first() async {
    var results = await get();
    return results.isEmpty ? null : results.first;
  }
  
  /// Gets results
  Future<List<T>> get() async {
    var sql = _toSql();
    var rows = await _connection.select(sql, _bindings);
    return rows.map((row) => _hydrate(row)).toList();
  }
  
  /// Builds SQL query
  String _toSql() {
    var sql = 'select * from ${_model.table}';
    
    if (_wheres.isNotEmpty) {
      sql += ' where ${_wheres.join(' and ')}';
    }
    
    if (_orders.isNotEmpty) {
      sql += ' order by ${_orders.join(', ')}';
    }
    
    if (_limit != null) {
      sql += ' limit $_limit';
    }
    
    if (_offset != null) {
      sql += ' offset $_offset';
    }
    
    return sql;
  }
  
  /// Hydrates model from row
  T _hydrate(Map<String, dynamic> row) {
    var instance = _model.newInstance() as T;
    instance.fill(row);
    instance.syncOriginal();
    return instance;
  }
}
```

## Integration Examples

### 1. Basic Model Usage
```dart
// Define model
class User extends Model {
  @override
  String get table => 'users';
  
  @override
  List<String> get fillable => ['name', 'email'];
  
  String get name => this['name'];
  set name(String value) => this['name'] = value;
  
  String get email => this['email'];
  set email(String value) => this['email'] = value;
}

// Create user
var user = User()
  ..name = 'John Doe'
  ..email = 'john@example.com';

await user.save();

// Find user
var found = await User.find(1);
print(found.name); // John Doe
```

### 2. Relationships
```dart
class User extends Model {
  // Has many posts
  Future<List<Post>> posts() {
    return hasMany<Post>('user_id').get();
  }
  
  // Has one profile
  Future<Profile?> profile() {
    return hasOne<Profile>('user_id').get();
  }
}

class Post extends Model {
  // Belongs to user
  Future<User?> user() {
    return belongsTo<User>('user_id').get();
  }
}

// Use relationships
var user = await User.find(1);
var posts = await user.posts();
var profile = await user.profile();
```

### 3. Events
```dart
// Register event listener
Model.getEventDispatcher().listen<ModelCreated<User>>((event) {
  var user = event.model;
  print('User ${user.name} was created');
});

// Create user (triggers event)
var user = User()
  ..name = 'Jane Doe'
  ..email = 'jane@example.com';

await user.save();
```

## Testing

```dart
void main() {
  group('Model', () {
    test('handles attributes', () {
      var user = User()
        ..name = 'John'
        ..email = 'john@example.com';
      
      expect(user.name, equals('John'));
      expect(user.isDirty, isTrue);
      expect(user.getDirty(), containsPair('name', 'John'));
    });
    
    test('tracks changes', () {
      var user = User()
        ..fill({
          'name': 'John',
          'email': 'john@example.com'
        });
      
      user.syncOriginal();
      user.name = 'Jane';
      
      expect(user.isDirty, isTrue);
      expect(user.getOriginal()['name'], equals('John'));
      expect(user.name, equals('Jane'));
    });
  });
  
  group('Relationships', () {
    test('loads relationships', () async {
      var user = await User.find(1);
      var posts = await user.posts();
      
      expect(posts, hasLength(greaterThan(0)));
      expect(posts.first, isA<Post>());
    });
  });
}
```

## Next Steps

1. Implement core model features
2. Add relationship types
3. Add model events
4. Add query builder
5. Write tests
6. Add benchmarks

## Development Guidelines

### 1. Getting Started
Before implementing model features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Events Package Specification](events_package_specification.md)

### 2. Implementation Process
For each model feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Support model events (see [Events Package Specification](events_package_specification.md))

### 4. Integration Considerations
When implementing model features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)

### 5. Performance Guidelines
Model system must:
1. Handle large datasets efficiently
2. Optimize relationship loading
3. Support eager loading
4. Cache query results
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Model tests must:
1. Cover all model operations
2. Test relationships
3. Verify events
4. Check query building
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Model documentation must:
1. Explain model patterns
2. Show relationship examples
3. Cover event handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
