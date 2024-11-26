# Testing Package Specification

## Overview

The Testing package provides a robust testing framework that matches Laravel's testing functionality. It supports test case base classes, assertions, database testing, HTTP testing, and mocking while integrating with our Container and Event packages.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Container Package Specification](container_package_specification.md) for dependency injection
> - See [Events Package Specification](events_package_specification.md) for event testing

## Core Features

### 1. Test Case

```dart
/// Base test case class
abstract class TestCase {
  /// Container instance
  late Container container;
  
  /// Application instance
  late Application app;
  
  /// Event dispatcher
  late EventDispatcherContract events;
  
  /// Sets up test case
  @override
  void setUp() {
    container = Container();
    app = Application(container);
    events = container.make<EventDispatcherContract>();
    
    setUpApplication();
    registerServices();
  }
  
  /// Sets up application
  void setUpApplication() {
    app.singleton<Application>((c) => app);
    app.singleton<Container>((c) => container);
    app.singleton<EventDispatcherContract>((c) => events);
  }
  
  /// Registers test services
  void registerServices() {}
  
  /// Creates test instance
  T make<T>([dynamic parameters]) {
    return container.make<T>(parameters);
  }
  
  /// Runs test in transaction
  Future<T> transaction<T>(Future<T> Function() callback) async {
    var db = container.make<DatabaseManager>();
    return await db.transaction(callback);
  }
  
  /// Refreshes database
  Future<void> refreshDatabase() async {
    await artisan.call('migrate:fresh');
  }
  
  /// Seeds database
  Future<void> seed([String? class]) async {
    await artisan.call('db:seed', [
      if (class != null) '--class=$class'
    ]);
  }
}
```

### 2. HTTP Testing

```dart
/// HTTP test case
abstract class HttpTestCase extends TestCase {
  /// HTTP client
  late TestClient client;
  
  @override
  void setUp() {
    super.setUp();
    client = TestClient(app);
  }
  
  /// Makes GET request
  Future<TestResponse> get(String uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? query
  }) {
    return client.get(uri, headers: headers, query: query);
  }
  
  /// Makes POST request
  Future<TestResponse> post(String uri, {
    Map<String, String>? headers,
    dynamic body
  }) {
    return client.post(uri, headers: headers, body: body);
  }
  
  /// Makes PUT request
  Future<TestResponse> put(String uri, {
    Map<String, String>? headers,
    dynamic body
  }) {
    return client.put(uri, headers: headers, body: body);
  }
  
  /// Makes DELETE request
  Future<TestResponse> delete(String uri, {
    Map<String, String>? headers
  }) {
    return client.delete(uri, headers: headers);
  }
  
  /// Acts as user
  Future<void> actingAs(User user) async {
    await auth.login(user);
  }
}

/// Test HTTP client
class TestClient {
  /// Application instance
  final Application app;
  
  TestClient(this.app);
  
  /// Makes HTTP request
  Future<TestResponse> request(
    String method,
    String uri, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? query
  }) async {
    var request = Request(method, uri)
      ..headers.addAll(headers ?? {})
      ..body = body
      ..uri = uri.replace(queryParameters: query);
      
    var response = await app.handle(request);
    return TestResponse(response);
  }
}

/// Test HTTP response
class TestResponse {
  /// Response instance
  final Response response;
  
  TestResponse(this.response);
  
  /// Asserts response status
  void assertStatus(int status) {
    expect(response.statusCode, equals(status));
  }
  
  /// Asserts response is OK
  void assertOk() {
    assertStatus(200);
  }
  
  /// Asserts response is redirect
  void assertRedirect([String? location]) {
    expect(response.statusCode, inInclusiveRange(300, 399));
    if (location != null) {
      expect(response.headers['location'], equals(location));
    }
  }
  
  /// Asserts response contains JSON
  void assertJson(Map<String, dynamic> json) {
    expect(response.json(), equals(json));
  }
  
  /// Asserts response contains text
  void assertSee(String text) {
    expect(response.body, contains(text));
  }
}
```

### 3. Database Testing

```dart
/// Database test case
abstract class DatabaseTestCase extends TestCase {
  /// Database manager
  late DatabaseManager db;
  
  @override
  void setUp() {
    super.setUp();
    db = container.make<DatabaseManager>();
  }
  
  /// Seeds database
  Future<void> seed(String seeder) async {
    await artisan.call('db:seed', ['--class=$seeder']);
  }
  
  /// Asserts database has record
  Future<void> assertDatabaseHas(
    String table,
    Map<String, dynamic> data
  ) async {
    var count = await db.table(table)
      .where(data)
      .count();
      
    expect(count, greaterThan(0));
  }
  
  /// Asserts database missing record
  Future<void> assertDatabaseMissing(
    String table,
    Map<String, dynamic> data
  ) async {
    var count = await db.table(table)
      .where(data)
      .count();
      
    expect(count, equals(0));
  }
  
  /// Asserts database count
  Future<void> assertDatabaseCount(
    String table,
    int count
  ) async {
    var actual = await db.table(table).count();
    expect(actual, equals(count));
  }
}
```

### 4. Event Testing

```dart
/// Event test case
abstract class EventTestCase extends TestCase {
  /// Fake event dispatcher
  late FakeEventDispatcher events;
  
  @override
  void setUp() {
    super.setUp();
    events = FakeEventDispatcher();
    container.instance<EventDispatcherContract>(events);
  }
  
  /// Asserts event dispatched
  void assertDispatched(Type event, [Function? callback]) {
    expect(events.dispatched(event), isTrue);
    
    if (callback != null) {
      var dispatched = events.dispatched(event, callback);
      expect(dispatched, isTrue);
    }
  }
  
  /// Asserts event not dispatched
  void assertNotDispatched(Type event) {
    expect(events.dispatched(event), isFalse);
  }
  
  /// Asserts nothing dispatched
  void assertNothingDispatched() {
    expect(events.hasDispatched(), isFalse);
  }
}

/// Fake event dispatcher
class FakeEventDispatcher implements EventDispatcherContract {
  /// Dispatched events
  final List<dynamic> _events = [];
  
  @override
  Future<void> dispatch<T>(T event) async {
    _events.add(event);
  }
  
  /// Checks if event dispatched
  bool dispatched(Type event, [Function? callback]) {
    var dispatched = _events.whereType<Type>();
    if (dispatched.isEmpty) return false;
    
    if (callback == null) return true;
    
    return dispatched.any((e) => callback(e));
  }
  
  /// Checks if any events dispatched
  bool hasDispatched() => _events.isNotEmpty;
}
```

## Integration Examples

### 1. HTTP Testing
```dart
class UserTest extends HttpTestCase {
  test('creates user', () async {
    var response = await post('/users', body: {
      'name': 'John Doe',
      'email': 'john@example.com'
    });
    
    response.assertStatus(201);
    await assertDatabaseHas('users', {
      'email': 'john@example.com'
    });
  });
  
  test('requires authentication', () async {
    var user = await User.factory().create();
    await actingAs(user);
    
    var response = await get('/dashboard');
    response.assertOk();
  });
}
```

### 2. Database Testing
```dart
class OrderTest extends DatabaseTestCase {
  test('creates order', () async {
    await seed(ProductSeeder);
    
    var order = await Order.create({
      'product_id': 1,
      'quantity': 5
    });
    
    await assertDatabaseHas('orders', {
      'id': order.id,
      'quantity': 5
    });
  });
}
```

### 3. Event Testing
```dart
class PaymentTest extends EventTestCase {
  test('dispatches payment events', () async {
    var payment = await processPayment(order);
    
    assertDispatched(PaymentProcessed, (event) {
      return event.payment.id == payment.id;
    });
  });
}
```

## Testing

```dart
void main() {
  group('HTTP Testing', () {
    test('makes requests', () async {
      var client = TestClient(app);
      
      var response = await client.get('/users');
      
      expect(response.statusCode, equals(200));
      expect(response.json(), isA<List>());
    });
    
    test('handles authentication', () async {
      var case = UserTest();
      await case.setUp();
      
      await case.actingAs(user);
      var response = await case.get('/profile');
      
      response.assertOk();
    });
  });
  
  group('Database Testing', () {
    test('seeds database', () async {
      var case = OrderTest();
      await case.setUp();
      
      await case.seed(ProductSeeder);
      
      await case.assertDatabaseCount('products', 10);
    });
  });
}
```

## Next Steps

1. Implement core testing features
2. Add HTTP testing
3. Add database testing
4. Add event testing
5. Write tests
6. Add examples

## Development Guidelines

### 1. Getting Started
Before implementing testing features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Review [Container Package Specification](container_package_specification.md)
6. Review [Events Package Specification](events_package_specification.md)

### 2. Implementation Process
For each testing feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Support dependency injection (see [Container Package Specification](container_package_specification.md))
5. Support event testing (see [Events Package Specification](events_package_specification.md))

### 4. Integration Considerations
When implementing testing features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)

### 5. Performance Guidelines
Testing system must:
1. Execute tests efficiently
2. Support parallel testing
3. Handle large test suites
4. Manage test isolation
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Testing package tests must:
1. Cover all testing features
2. Test HTTP assertions
3. Verify database testing
4. Check event assertions
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Testing documentation must:
1. Explain testing patterns
2. Show assertion examples
3. Cover test organization
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
