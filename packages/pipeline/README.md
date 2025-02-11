<p align="center"><a href="https://protevus.com" target="_blank"><img src="https://git.protevus.com/protevus/branding/raw/branch/main/protevus-logo-bg.png"></a></p>

# Platform Pipeline

A Laravel-compatible pipeline implementation in Dart, providing a robust way to pass objects through a series of operations.

[![Pub Version](https://img.shields.io/pub/v/platform_pipeline)]()
[![Build Status](https://img.shields.io/github/workflow/status/platform/pipeline/tests)]()

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Class-Based Pipes](#class-based-pipes)
  - [Invokable Classes](#invokable-classes)
  - [Using Different Method Names](#using-different-method-names)
  - [Passing Parameters to Pipes](#passing-parameters-to-pipes)
  - [Early Pipeline Termination](#early-pipeline-termination)
  - [Conditional Pipeline Execution](#conditional-pipeline-execution)
- [Advanced Usage](#advanced-usage)
  - [Working with Objects](#working-with-objects)
  - [Async Operations](#async-operations)
- [Laravel API Compatibility](#laravel-api-compatibility)
- [Comparison with Laravel](#comparison-with-laravel)
- [Troubleshooting](#troubleshooting)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Overview

Platform Pipeline is a 100% API-compatible port of Laravel's Pipeline to Dart. It allows you to pass an object through a series of operations (pipes) in a fluent, maintainable way. Each pipe can examine, modify, or replace the object before passing it to the next pipe in the sequence.

## Features

- 💯 100% Laravel Pipeline API compatibility
- 🔄 Support for class-based and callable pipes
- 🎯 Dependency injection through container integration
- ⚡ Async operation support
- 🔀 Conditional pipeline execution
- 🎭 Method name customization via `via()`
- 🎁 Parameter passing to pipes
- 🛑 Early pipeline termination
- 🧪 Comprehensive test coverage

## Requirements

- Dart SDK: >=2.17.0 <4.0.0
- platform_container: ^1.0.0

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  platform_pipeline: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:illuminate_pipeline/pipeline.dart';
import 'package:illuminate_container/container.dart';

void main() async {
  // Create a container instance
  var container = Container();
  
  // Create a pipeline
  var result = await Pipeline(container)
    .send('Hello')
    .through([
      (String value, next) => next(value + ' World'),
      (String value, next) => next(value + '!'),
    ])
    .then((value) => value);

  print(result); // Outputs: Hello World!
}
```

### Class-Based Pipes

```dart
class UppercasePipe {
  Future<String> handle(String value, Function next) async {
    return next(value.toUpperCase());
  }
}

class AddExclamationPipe {
  Future<String> handle(String value, Function next) async {
    return next(value + '!');
  }
}

void main() async {
  var container = Container();
  
  var result = await Pipeline(container)
    .send('hello')
    .through([
      UppercasePipe(),
      AddExclamationPipe(),
    ])
    .then((value) => value);

  print(result); // Outputs: HELLO!
}
```

### Invokable Classes

```dart
class TransformPipe {
  Future<String> call(String value, Function next) async {
    return next(value.toUpperCase());
  }
}

void main() async {
  var container = Container();
  
  var result = await Pipeline(container)
    .send('hello')
    .through([TransformPipe()])
    .then((value) => value);

  print(result); // Outputs: HELLO
}
```

### Using Different Method Names

```dart
class CustomPipe {
  Future<String> transform(String value, Function next) async {
    return next(value.toUpperCase());
  }
}

void main() async {
  var container = Container();
  
  var result = await Pipeline(container)
    .send('hello')
    .through([CustomPipe()])
    .via('transform')
    .then((value) => value);

  print(result); // Outputs: HELLO
}
```

### Passing Parameters to Pipes

```dart
class PrefixPipe {
  Future<String> handle(
    String value,
    Function next, [
    String prefix = '',
  ]) async {
    return next('$prefix$value');
  }
}

void main() async {
  var container = Container();
  container.registerFactory<PrefixPipe>((c) => PrefixPipe());
  
  var pipeline = Pipeline(container);
  pipeline.registerPipeType('PrefixPipe', PrefixPipe);
  
  var result = await pipeline
    .send('World')
    .through('PrefixPipe:Hello ')
    .then((value) => value);

  print(result); // Outputs: Hello World
}
```

### Early Pipeline Termination

```dart
void main() async {
  var container = Container();
  
  var result = await Pipeline(container)
    .send('hello')
    .through([
      (value, next) => 'TERMINATED', // Pipeline stops here
      (value, next) => next('NEVER REACHED'),
    ])
    .then((value) => value);

  print(result); // Outputs: TERMINATED
}
```

### Conditional Pipeline Execution

```dart
void main() async {
  var container = Container();
  var shouldTransform = true;
  
  var result = await Pipeline(container)
    .send('hello')
    .when(() => shouldTransform, (Pipeline pipeline) {
      pipeline.pipe([
        (value, next) => next(value.toUpperCase()),
      ]);
    })
    .then((value) => value);

  print(result); // Outputs: HELLO
}
```

## Advanced Usage

### Working with Objects

```dart
class User {
  String name;
  int age;
  
  User(this.name, this.age);
}

class AgeValidationPipe {
  Future<User> handle(User user, Function next) async {
    if (user.age < 18) {
      throw Exception('User must be 18 or older');
    }
    return next(user);
  }
}

class NameFormattingPipe {
  Future<User> handle(User user, Function next) async {
    user.name = user.name.trim().toLowerCase();
    return next(user);
  }
}

void main() async {
  var container = Container();
  
  var user = User('John Doe ', 20);
  
  try {
    user = await Pipeline(container)
      .send(user)
      .through([
        AgeValidationPipe(),
        NameFormattingPipe(),
      ])
      .then((value) => value);
      
    print('${user.name} is ${user.age} years old');
    // Outputs: john doe is 20 years old
  } catch (e) {
    print('Validation failed: $e');
  }
}
```

### Async Operations

```dart
class AsyncTransformPipe {
  Future<String> handle(String value, Function next) async {
    // Simulate async operation
    await Future.delayed(Duration(seconds: 1));
    return next(value.toUpperCase());
  }
}

void main() async {
  var container = Container();
  
  var result = await Pipeline(container)
    .send('hello')
    .through([AsyncTransformPipe()])
    .then((value) => value);

  print(result); // Outputs after 1 second: HELLO
}
```

## Laravel API Compatibility

This package maintains 100% API compatibility with Laravel's Pipeline implementation. All Laravel Pipeline features are supported:

- `send()` - Set the object being passed through the pipeline
- `through()` - Set the array of pipes
- `pipe()` - Push additional pipes onto the pipeline
- `via()` - Set the method to call on the pipes
- `then()` - Run the pipeline with a final destination callback
- `thenReturn()` - Run the pipeline and return the result

## Comparison with Laravel

| Feature | Laravel | Platform Pipeline |
|---------|---------|------------------|
| API Methods | ✓ | ✓ |
| Container Integration | ✓ | ✓ |
| Pipe Types | Class, Callable | Class, Callable |
| Async Support | ✗ | ✓ |
| Type Safety | ✗ | ✓ |
| Parameter Passing | ✓ | ✓ |
| Early Termination | ✓ | ✓ |
| Method Customization | ✓ | ✓ |
| Conditional Execution | ✓ | ✓ |

## Troubleshooting

### Common Issues

1. Container Not Provided
```dart
// ❌ Wrong
var pipeline = Pipeline(null);

// ✓ Correct
var container = Container();
var pipeline = Pipeline(container);
```

2. Missing Type Registration
```dart
// ❌ Wrong
pipeline.through('CustomPipe:param');

// ✓ Correct
pipeline.registerPipeType('CustomPipe', CustomPipe);
pipeline.through('CustomPipe:param');
```

3. Incorrect Method Name
```dart
// ❌ Wrong
class CustomPipe {
  void process(value, next) {} // Wrong method name
}

// ✓ Correct
class CustomPipe {
  void handle(value, next) {} // Default method name
}
// Or specify the method name:
pipeline.via('process').through([CustomPipe()]);
```

## Testing

Run the tests with:

```bash
dart test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is open-sourced software licensed under the MIT license.
