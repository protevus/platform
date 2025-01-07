# Contributing to DBO for Dart

First off, thank you for considering contributing to DBO for Dart! It's people like you that make this project better.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead and why
* Include any error messages or stack traces

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* A clear and descriptive title
* A detailed description of the proposed functionality
* Explain why this enhancement would be useful
* List any similar features in other libraries if applicable

### Pull Requests

* Fork the repository and create your branch from `main`
* If you've added code that should be tested, add tests
* Ensure the test suite passes
* Make sure your code follows the existing code style
* Write a good commit message

## Development Setup

1. Install the Dart SDK (stable version)
2. Clone the repository
3. Run `dart pub get` to install dependencies
4. Run tests with `dart test`

## Project Structure

```
lib/
  ├── pdo.dart              # Main library file
  └── src/
      ├── core/             # Core DBO components
      │   ├── pdo_column.dart
      │   ├── pdo_param.dart
      │   └── pdo_result.dart
      ├── pdo_base.dart     # Base DBO class
      ├── pdo_statement.dart # Statement interface
      └── pdo_exception.dart # DBO exceptions

test/
  ├── core/                 # Core component tests
  ├── helpers/             # Test utilities
  └── all_tests.dart       # Test runner
```

## Testing

We use the `test` package for testing. All tests should be placed in the `test` directory and follow the naming convention `*_test.dart`.

To run tests:

```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage
```

### Writing Tests

* Test files should mirror the structure of the lib directory
* Each public API should have corresponding tests
* Use descriptive test names that explain the behavior being tested
* Follow the Arrange-Act-Assert pattern
* Use test groups to organize related tests

## Documentation

* All public APIs must be documented
* Use dartdoc comments for documentation
* Include examples in documentation where appropriate
* Keep documentation up to date with code changes

## Code Style

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style). Some key points:

* Use `dart format` to format your code
* Follow the file organization conventions
* Write descriptive variable and function names
* Keep functions focused and concise
* Use type annotations for public APIs

## Database Driver Implementation

When implementing a new database driver:

1. Create a new class that extends `DBO`
2. Implement all required methods
3. Create a corresponding statement class
4. Add comprehensive tests
5. Document driver-specific features or limitations

Example structure for a new driver:

```dart
class PDOMySQL extends DBO {
  @override
  PDOStatement prepare(String statement, [List<dynamic>? driverOptions]) {
    // Implementation
  }

  // Other overridden methods...
}

class PDOMySQLStatement implements PDOStatement {
  // Implementation
}
```

## Release Process

1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Create a release PR
4. After approval and merge, tag the release
5. Publish to pub.dev

## Questions?

Feel free to open an issue with the "question" label if you need help or clarification.

Thank you for contributing! 🎉
