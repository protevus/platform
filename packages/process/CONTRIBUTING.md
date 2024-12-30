# Contributing to Process

First off, thanks for taking the time to contribute! 🎉

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a new branch for your feature/fix
4. Make your changes
5. Run the tests
6. Submit a pull request

## Development Setup

1. Install Dart SDK (version >= 3.0.0)
2. Clone the repository
3. Run `dart pub get` to install dependencies
4. Run `dart test` to ensure everything is working

## Running Tests

```bash
# Run all tests
./tool/test.sh

# Run only unit tests
./tool/test.sh --unit

# Run tests with coverage
./tool/test.sh --coverage

# Run tests in watch mode
./tool/test.sh --watch
```

## Code Style

This project follows the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style). Please ensure your code:

- Uses the standard Dart formatting (`dart format`)
- Passes static analysis (`dart analyze`)
- Includes documentation comments for public APIs
- Has appropriate test coverage

## Pull Request Process

1. Update the README.md with details of changes if needed
2. Update the CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
3. Update the version number following [Semantic Versioning](https://semver.org/)
4. Include tests for any new functionality
5. Ensure all tests pass
6. Update documentation as needed

## Writing Tests

- Write unit tests for all new functionality
- Include both success and failure cases
- Test edge cases and error conditions
- Use the provided testing utilities for process faking
- Aim for high test coverage

Example test:

```dart
void main() {
  group('Process Execution', () {
    late Factory factory;

    setUp(() {
      factory = Factory();
    });

    test('executes command successfully', () async {
      factory.fake({
        'test-command': FakeProcessDescription()
          ..withExitCode(0)
          ..replaceOutput('Test output'),
      });

      final result = await factory
          .command('test-command')
          .run();

      expect(result.successful(), isTrue);
      expect(result.output(), equals('Test output'));
    });
  });
}
```

## Documentation

- Document all public APIs
- Include examples in documentation comments
- Keep the README.md up to date
- Add inline comments for complex logic

## Reporting Issues

When reporting issues:

1. Use the issue template if provided
2. Include steps to reproduce
3. Include expected vs actual behavior
4. Include system information:
   - Dart version
   - Operating system
   - Package version
5. Include any relevant error messages or logs

## Feature Requests

Feature requests are welcome! Please:

1. Check existing issues/PRs to avoid duplicates
2. Explain the use case
3. Provide examples of how the feature would work
4. Consider edge cases and potential issues

## Questions?

Feel free to:

- Open an issue for questions
- Ask in discussions
- Reach out to maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
