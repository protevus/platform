# Model Package Gap Analysis

## Overview

This document analyzes the gaps between our Model package's actual implementation and Laravel's Eloquent functionality, identifying areas that need implementation or documentation updates.

> **Related Documentation**
> - See [Model Package Specification](model_package_specification.md) for current implementation
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for overall status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup

## Implementation Gaps

### 1. Missing Laravel Features
```dart
// Documented but not implemented:

// 1. Model Scopes
class ModelScope {
  // Need to implement:
  Query<T> apply<T extends Model>(Query<T> query);
  bool shouldApply<T extends Model>(Query<T> query);
}

// 2. Model Observers
class ModelObserver<T extends Model> {
  // Need to implement:
  void creating(T model);
  void created(T model);
  void updating(T model);
  void updated(T model);
  void deleting(T model);
  void deleted(T model);
  void restored(T model);
  void forceDeleted(T model);
}

// 3. Model Factories
class ModelFactory<T extends Model> {
  // Need to implement:
  T definition();
  T make([Map<String, dynamic>? attributes]);
  Future<T> create([Map<String, dynamic>? attributes]);
  List<T> makeMany(int count, [Map<String, dynamic>? attributes]);
  Future<List<T>> createMany(int count, [Map<String, dynamic>? attributes]);
}
```

### 2. Missing Relationship Types
```dart
// Need to implement:

// 1. Many to Many
class BelongsToMany<T extends Model> extends Relationship<T> {
  // Need to implement:
  String get table;
  String get foreignPivotKey;
  String get relatedPivotKey;
  List<String> get pivotColumns;
  
  Future<List<T>> get();
  Future<void> attach(List<dynamic> ids, [Map<String, dynamic>? attributes]);
  Future<void> detach(List<dynamic>? ids);
  Future<void> sync(List<dynamic> ids);
  Future<void> toggle(List<dynamic> ids);
  Future<void> updateExistingPivot(dynamic id, Map<String, dynamic> attributes);
}

// 2. Has Many Through
class HasManyThrough<T extends Model> extends Relationship<T> {
  // Need to implement:
  String get through;
  String get firstKey;
  String get secondKey;
  String get localKey;
  String get secondLocalKey;
  
  Future<List<T>> get();
}

// 3. Polymorphic Relations
class MorphTo extends Relationship<Model> {
  // Need to implement:
  String get morphType;
  String get morphId;
  
  Future<Model?> get();
}
```

### 3. Missing Query Features
```dart
// Need to implement:

// 1. Advanced Where Clauses
class Query<T extends Model> {
  // Need to implement:
  Query<T> whereIn(String column, List<dynamic> values);
  Query<T> whereNotIn(String column, List<dynamic> values);
  Query<T> whereBetween(String column, List<dynamic> values);
  Query<T> whereNotBetween(String column, List<dynamic> values);
  Query<T> whereNull(String column);
  Query<T> whereNotNull(String column);
  Query<T> whereDate(String column, DateTime date);
  Query<T> whereMonth(String column, int month);
  Query<T> whereYear(String column, int year);
  Query<T> whereTime(String column, String operator, DateTime time);
}

// 2. Joins
class Query<T extends Model> {
  // Need to implement:
  Query<T> join(String table, String first, [String? operator, String? second]);
  Query<T> leftJoin(String table, String first, [String? operator, String? second]);
  Query<T> rightJoin(String table, String first, [String? operator, String? second]);
  Query<T> crossJoin(String table);
}

// 3. Aggregates
class Query<T extends Model> {
  // Need to implement:
  Future<int> count([String column = '*']);
  Future<dynamic> max(String column);
  Future<dynamic> min(String column);
  Future<num> avg(String column);
  Future<num> sum(String column);
}
```

## Documentation Gaps

### 1. Missing API Documentation
```dart
// Need to document:

/// Applies a scope to the query.
/// 
/// Example:
/// ```dart
/// class PublishedScope implements Scope {
///   Query<T> apply<T extends Model>(Query<T> query) {
///     return query.where('published', true);
///   }
/// }
/// ```
void addGlobalScope(Scope scope);

/// Defines a local scope.
///
/// Example:
/// ```dart
/// Query<Post> published() {
///   return where('published', true);
/// }
/// ```
void scopePublished(Query query);
```

### 2. Missing Integration Examples
```dart
// Need examples for:

// 1. Model Observers
class UserObserver extends ModelObserver<User> {
  @override
  void created(User user) {
    // Send welcome email
  }
  
  @override
  void deleted(User user) {
    // Cleanup user data
  }
}

// 2. Model Factories
class UserFactory extends ModelFactory<User> {
  @override
  User definition() {
    return User()
      ..name = faker.person.name()
      ..email = faker.internet.email();
  }
}

// 3. Many to Many Relationships
class User extends Model {
  Future<List<Role>> roles() {
    return belongsToMany<Role>('role_user')
      .withPivot(['expires_at'])
      .wherePivot('active', true)
      .get();
  }
}
```

### 3. Missing Test Coverage
```dart
// Need tests for:

void main() {
  group('Model Scopes', () {
    test('applies global scopes', () async {
      var posts = await Post.all();
      expect(posts.every((p) => p.published), isTrue);
    });
    
    test('applies local scopes', () async {
      var posts = await Post().recent().popular().get();
      expect(posts, hasLength(greaterThan(0)));
    });
  });
  
  group('Model Factories', () {
    test('creates model instances', () async {
      var users = await UserFactory().createMany(3);
      expect(users, hasLength(3));
      expect(users.first.name, isNotEmpty);
    });
  });
}
```

## Implementation Priority

1. **High Priority**
   - Model scopes (Laravel compatibility)
   - Model observers (Laravel compatibility)
   - Many to Many relationships

2. **Medium Priority**
   - Model factories
   - Advanced where clauses
   - Query joins

3. **Low Priority**
   - Additional relationship types
   - Additional query features
   - Performance optimizations

## Next Steps

1. **Implementation Tasks**
   - Add model scopes
   - Add model observers
   - Add many to many relationships
   - Add model factories

2. **Documentation Tasks**
   - Document model scopes
   - Document model observers
   - Document relationships
   - Add integration examples

3. **Testing Tasks**
   - Add scope tests
   - Add observer tests
   - Add relationship tests
   - Add factory tests

## Development Guidelines

### 1. Getting Started
Before implementing model features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Model Package Specification](model_package_specification.md)

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
4. Match specifications in [Model Package Specification](model_package_specification.md)

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
