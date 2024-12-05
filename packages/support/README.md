# Platform Support

Core support utilities and helper functions for the framework.

## Features

This package provides fundamental utilities and abstractions used throughout the framework:

### Multiple Instance Management

The `MultipleInstanceManager` class provides a way to manage multiple instances of a class with different configurations:

```dart
// Define a class that needs multiple instances
class Database {
  final String host;
  final int port;
  
  Database({required this.host, required this.port});
}

// Create a manager with a factory function
final manager = MultipleInstanceManager<Database>((config) {
  return Database(
    host: config['host'] as String,
    port: config['port'] as int,
  );
});

// Configure different instances
manager.configure({
  'host': 'localhost',
  'port': 5432,
}, 'primary');

manager.configure({
  'host': 'readonly.db',
  'port': 5432,
}, 'readonly');

// Get instances (they're created lazily)
final primary = manager.instance('primary');
final readonly = manager.instance('readonly');

// Extend existing configuration
manager.extend({
  'timeout': Duration(seconds: 30),
}, 'primary');

// Check instance/config existence
if (manager.hasConfiguration('primary')) {
  final config = manager.getConfiguration('primary');
  // Use configuration
}

if (manager.has('primary')) {
  // Instance has been created
}

// Reset instances
manager.reset('primary'); // Keeps configuration
manager.reset('readonly', preserveConfig: false); // Removes configuration

// Get all instances/configs
final instances = manager.instances();
final names = manager.names();
final configs = manager.configurations();

// Count instances
print(manager.count); // Number of configurations
print(manager.instanceCount); // Number of created instances
```

### Carbon Date/Time

The `Carbon` class provides an expressive interface for working with dates and times:

```dart
final now = Carbon.now();
final tomorrow = now.addDay();
final nextWeek = now.addWeek();

// Fluent date manipulation
final date = Carbon.parse('2023-01-01')
  ..addDays(5)
  ..subMonth()
  ..startOfDay();

// Date comparison and formatting
if (date.isFuture) {
  print(date.toDateString()); // 2022-12-06
}
```

### Message Handling

The `MessageBag` class provides a flexible container for storing and retrieving messages:

```dart
final messages = MessageBag()
  ..add('email', 'Invalid email format')
  ..add('password', 'Password too short')
  ..add('password', 'Must contain special characters');

// Get first message
print(messages.first()); // Invalid email format

// Get all messages for a key
print(messages.get('password')); // ['Password too short', 'Must contain special characters']

// Format messages
messages.setFormat('Error: :message');
print(messages.first()); // Error: Invalid email format
```

### JavaScript Expression Handler

The `Js` class provides safe conversion of values to JavaScript expressions:

```dart
final js = Js('Hello World');
print(js.toJs()); // 'Hello World'

final jsNull = Js(null);
print(jsNull.toJs()); // null

final jsNumber = Js(42);
print(jsNumber.toJs()); // 42

// Use in HTML
final jsHtml = Js('alert("Hello")');
print(jsHtml.toHtml()); // <script>alert("Hello")</script>
```

### HTML String Handling

The `HtmlString` class provides safe handling of HTML content:

```dart
final html = HtmlString('<p>Hello</p>');
print(html.toHtml()); // Outputs raw HTML
print(html.toString()); // Escaped HTML for safe display
```

### Lottery System

The `Lottery` class provides probability-based operations:

```dart
// 50% chance of winning
final lottery = Lottery.percentage(50);
if (lottery.choose()) {
  print('Winner!');
}

// 1 in 5 chance
final odds = Lottery.odds(1, 5);

// Run async operation with probability
await lottery.run(() async {
  // This runs 50% of the time
});

// Run sync operation with probability
lottery.sync(() {
  // This runs 50% of the time
});
```

### Environment Handling

The `Env` class provides environment variable management:

```dart
// Get environment variables with defaults
final debug = Env.get('APP_DEBUG', defaultValue: false);
final port = Env.getInt('PORT', defaultValue: 8080);

// Check environment
if (Env.isDevelopment) {
  // Development-specific code
}
```

### Reflection Capabilities

The `Reflector` class provides reflection utilities:

```dart
final reflector = Reflector();

// Get class information
final methods = reflector.getMethods(someObject);
final properties = reflector.getProperties(someObject);

// Invoke methods dynamically
await reflector.invoke(object, 'methodName', ['arg1', 'arg2']);
```

### Configuration URL Parser

The `ConfigurationUrlParser` helps parse configuration URLs:

```dart
final parser = ConfigurationUrlParser();
final config = parser.parseConfiguration('redis://user:pass@localhost:6379/0');

print(config.host); // localhost
print(config.port); // 6379
print(config.username); // user
```

### Fluent Interface

The `Fluent` class provides a fluent interface for working with attributes:

```dart
final user = Fluent({
  'name': 'John',
  'age': 30,
})
  ..set('email', 'john@example.com')
  ..set('active', true);

print(user.get('name')); // John
print(user.toJson());
```

### Optional Values

The `Optional` class provides safe handling of potentially null values:

```dart
final value = Optional.of(someNullableValue)
  .map((val) => val * 2)
  .get(defaultValue);

// Or with null checks
final optional = Optional.of(someValue);
if (optional.isPresent) {
  optional.ifPresent((value) {
    // Do something with value
  });
}
```

### String Manipulation

The package includes comprehensive string manipulation utilities through the `Stringable` class:

```dart
final str = Stringable('hello world')
  ..upper() // HELLO WORLD
  ..camel() // helloWorld
  ..snake() // hello_world
  ..title(); // Hello World

// Get portions of strings
print(str.after(' ')); // world
print(str.before(' ')); // hello
print(str.between('[', ']')); // Extract between delimiters

// Transform strings
print(str.limit(5, '...')); // hello...
print(str.ascii()); // Convert to ASCII
print(str.slug()); // URL friendly slugs
```

### Process Handling

The package provides utilities for process management:

```dart
final process = Process()
  ..setTimeout(Duration(seconds: 30))
  ..setWorkingDirectory('path/to/dir');

final result = await process.run('command', ['arg1', 'arg2']);
```

### Deferred Operations

Support for deferred operations and callbacks:

```dart
final deferred = DeferredCallback(() async {
  // Deferred operation
});

final collection = DeferredCallbackCollection()
  ..push(deferred)
  ..push(anotherDeferred);

await collection.execute();
```

### Traits

The package includes various traits for extending functionality:

#### Data Interaction
- `InteractsWithData` - Provides methods for data manipulation and transformation
- `InteractsWithTime` - Adds time manipulation methods
- `ReflectsClosures` - Adds closure reflection capabilities

```dart
class MyDataHandler with InteractsWithData {
  dynamic transformValue(dynamic value) {
    return transform(value, (val) {
      // Transform the value
      return val.toString().toUpperCase();
    });
  }
}
```

#### Debugging and Development
- `Dumpable` - Adds dump and dd capabilities for debugging
```dart
class MyClass with Dumpable {
  void debug() {
    dump(); // Print object state
    dd(); // Print and die
  }
}
```

#### Method Handling
- `ForwardsCalls` - Implements method forwarding for delegation
```dart
class Delegator with ForwardsCalls {
  final target = SomeClass();
  
  dynamic forward(String method, List<dynamic> parameters) {
    return forwardCallTo(target, method, parameters);
  }
}
```

#### Side Effects
- `Tappable` - Adds tap method for side effects without breaking chains
```dart
final result = someObject
  .tap((obj) {
    // Perform side effect
    print(obj.someValue);
  })
  .continueChain();
```

### Global Helper Functions

The package provides a comprehensive set of global helper functions for common operations:

```dart
// Environment helpers
final debug = env('APP_DEBUG', false);
final port = env('PORT', 8080);

// Collection helpers
final collection = collect([1, 2, 3]);
final value = data('user.name', {'user': {'name': 'John'}});

// String manipulation
final str = string('hello world');
final snake = snakeCase('fooBar'); // foo_bar
final camel = camelCase('foo_bar'); // fooBar
final studly = studlyCase('foo_bar'); // FooBar
final slug = slugify('Hello World'); // hello-world
final random = randomString(16);

// Value handling
final opt = optional(someValue);
final result = tap(value, (val) => print(val));
final className = class_basename(object);

// Execution control
final once = createOnce();
once.call(() => print('Executes once'));

final onceable = createOnceable();
onceable.once('key', () => print('Executes once'));

await sleepFor(Duration(seconds: 1));

// Value conversion
final str = stringify(someValue);

// State checking
if (blank(value)) print('Value is empty');
if (filled(value)) print('Value is not empty');

// Value transformation
final result = value_of(() => expensiveOperation());
final output = when(condition, () => 'Yes', orElse: () => 'No');
```

## Usage

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  platform_support: ^1.0.0
```

Then import and use:

```dart
import 'package:platform_support/platform_support.dart';

// Use any of the features described above
final date = Carbon.now();
final messages = MessageBag();
final env = Env.get('APP_ENV');
final lottery = Lottery.percentage(50);

// Use traits
class MyClass with Dumpable, InteractsWithData, Tappable {
  void someMethod() {
    // Use trait methods
    dump();
    transform(data, (val) => val.toString());
    tap((self) => print('Side effect'));
  }
}

// Manage multiple instances
final manager = MultipleInstanceManager<Database>((config) {
  return Database(config);
});
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/yourusername/platform/issues).
