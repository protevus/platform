# Testing Guide

## Overview

This guide outlines our testing approach, which follows Laravel's testing patterns while leveraging Dart's testing capabilities. It covers unit testing, integration testing, performance testing, and Laravel-style testing approaches.

## Test Types

### 1. Unit Tests
```dart
void main() {
  group('Service Tests', () {
    late Container container;
    late UserService service;
    
    setUp(() {
      container = Container(reflector);
      container.bind<Database>((c) => MockDatabase());
      service = container.make<UserService>();
    });
    
    test('creates user', () async {
      var user = await service.create({
        'name': 'John Doe',
        'email': 'john@example.com'
      });
      
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
    });
    
    test('validates user data', () {
      expect(
        () => service.create({'name': 'John Doe'}),
        throwsA(isA<ValidationException>())
      );
    });
  });
}
```

### 2. Integration Tests
```dart
void main() {
  group('API Integration', () {
    late Application app;
    
    setUp(() async {
      app = await createApplication();
      await app.initialize();
    });
    
    tearDown(() async {
      await app.shutdown();
    });
    
    test('creates user through API', () async {
      var response = await app.post('/users', body: {
        'name': 'John Doe',
        'email': 'john@example.com'
      });
      
      expect(response.statusCode, equals(201));
      expect(response.json['name'], equals('John Doe'));
    });
    
    test('handles validation errors', () async {
      var response = await app.post('/users', body: {
        'name': 'John Doe'
      });
      
      expect(response.statusCode, equals(422));
      expect(response.json['errors'], contains('email'));
    });
  });
}
```

### 3. Performance Tests
```dart
void main() {
  group('Performance Tests', () {
    late Application app;
    
    setUp(() async {
      app = await createApplication();
      await app.initialize();
    });
    
    test('handles concurrent requests', () async {
      var stopwatch = Stopwatch()..start();
      
      // Create 100 concurrent requests
      var futures = List.generate(100, (i) => 
        app.get('/users')
      );
      
      var responses = await Future.wait(futures);
      stopwatch.stop();
      
      // Verify responses
      expect(responses, everyElement(
        predicate((r) => r.statusCode == 200)
      ));
      
      // Check performance
      expect(
        stopwatch.elapsedMilliseconds / responses.length,
        lessThan(100) // Less than 100ms per request
      );
    });
    
    test('handles database operations efficiently', () async {
      var stopwatch = Stopwatch()..start();
      
      // Create 1000 records
      for (var i = 0; i < 1000; i++) {
        await app.post('/users', body: {
          'name': 'User $i',
          'email': 'user$i@example.com'
        });
      }
      
      stopwatch.stop();
      
      // Check performance
      expect(
        stopwatch.elapsedMilliseconds / 1000,
        lessThan(50) // Less than 50ms per operation
      );
    });
  });
}
```

### 4. Laravel-Style Feature Tests
```dart
void main() {
  group('Feature Tests', () {
    late TestCase test;
    
    setUp(() {
      test = await TestCase.make();
    });
    
    test('user can register', () async {
      await test
        .post('/register', {
          'name': 'John Doe',
          'email': 'john@example.com',
          'password': 'password',
          'password_confirmation': 'password'
        })
        .assertStatus(302)
        .assertRedirect('/home');
        
      test.assertDatabaseHas('users', {
        'email': 'john@example.com'
      });
    });
    
    test('user can login', () async {
      // Create user
      await test.createUser({
        'email': 'john@example.com',
        'password': 'password'
      });
      
      await test
        .post('/login', {
          'email': 'john@example.com',
          'password': 'password'
        })
        .assertAuthenticated();
    });
  });
}
```

## Performance Testing Tools

### 1. WRK Benchmarking
```bash
# Basic load test
wrk -t12 -c400 -d30s http://localhost:8080/api/endpoint

# Test with custom script
wrk -t12 -c400 -d30s -s script.lua http://localhost:8080/api/endpoint
```

### 2. Custom Load Testing
```dart
void main() {
  test('load test', () async {
    var client = HttpClient();
    var stopwatch = Stopwatch()..start();
    
    // Configure test
    var duration = Duration(minutes: 1);
    var concurrency = 100;
    var results = <Duration>[];
    
    // Run test
    while (stopwatch.elapsed < duration) {
      var requests = List.generate(concurrency, (i) async {
        var requestWatch = Stopwatch()..start();
        await client.get('localhost', 8080, '/api/endpoint');
        requestWatch.stop();
        results.add(requestWatch.elapsed);
      });
      
      await Future.wait(requests);
    }
    
    // Analyze results
    var average = results.reduce((a, b) => a + b) ~/ results.length;
    var sorted = List.of(results)..sort();
    var p95 = sorted[(sorted.length * 0.95).floor()];
    var p99 = sorted[(sorted.length * 0.99).floor()];
    
    print('Results:');
    print('Average: ${average.inMilliseconds}ms');
    print('P95: ${p95.inMilliseconds}ms');
    print('P99: ${p99.inMilliseconds}ms');
  });
}
```

## Best Practices

### 1. Test Organization
```dart
// Group related tests
group('UserService', () {
  group('creation', () {
    test('creates valid user', () {});
    test('validates input', () {});
    test('handles duplicates', () {});
  });
  
  group('authentication', () {
    test('authenticates valid credentials', () {});
    test('rejects invalid credentials', () {});
  });
});
```

### 2. Test Data Management
```dart
class TestCase {
  // Create test data
  Future<User> createUser([Map<String, dynamic>? attributes]) async {
    return factory.create(User, attributes);
  }
  
  // Clean up after tests
  Future<void> cleanup() async {
    await database.truncate(['users', 'posts', 'comments']);
  }
}
```

### 3. Assertions
```dart
// Use descriptive assertions
expect(user.name, equals('John Doe'),
  reason: 'User name should match input');
  
expect(response.statusCode,
  isIn([200, 201]),
  reason: 'Response should indicate success'
);

expect(
  () => service.validateEmail('invalid'),
  throwsA(isA<ValidationException>()),
  reason: 'Should reject invalid email'
);
```

## Performance Benchmarks

### 1. Response Time Targets
```yaml
API Endpoints:
- Average: < 100ms
- P95: < 200ms
- P99: < 500ms

Database Operations:
- Simple queries: < 10ms
- Complex queries: < 50ms
- Writes: < 20ms

Cache Operations:
- Reads: < 5ms
- Writes: < 10ms
```

### 2. Throughput Targets
```yaml
API Layer:
- Minimum: 1000 requests/second
- Target: 5000 requests/second

Database Layer:
- Reads: 10000 operations/second
- Writes: 1000 operations/second

Cache Layer:
- Operations: 50000/second
```

### 3. Resource Usage Targets
```yaml
Memory:
- Base: < 100MB
- Under load: < 500MB
- Leak rate: < 1MB/hour

CPU:
- Idle: < 5%
- Average load: < 40%
- Peak load: < 80%

Connections:
- Database: < 100 concurrent
- Cache: < 1000 concurrent
- HTTP: < 10000 concurrent
```

## Next Steps

1. Implement test helpers
2. Add more Laravel-style assertions
3. Create performance test suite
4. Add continuous benchmarking
5. Improve test coverage

Would you like me to:
1. Create more test examples?
2. Add specific performance tests?
3. Create Laravel-compatible test helpers?
