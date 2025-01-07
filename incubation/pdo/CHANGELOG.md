# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - Unreleased

Initial development release.

### Added
- Core PDO functionality ported from PHP to Dart
- Base PDO class with standard database operations
- PDOStatement interface for prepared statements
- Support for multiple fetch modes:
  - FETCH_ASSOC
  - FETCH_NUM
  - FETCH_BOTH
  - FETCH_OBJ
  - FETCH_COLUMN
  - FETCH_KEY_PAIR
  - FETCH_NAMED
- Parameter binding support:
  - Named parameters
  - Positional parameters
  - Type conversion (PARAM_STR, PARAM_INT, PARAM_BOOL, PARAM_LOB)
- Column metadata handling
- Transaction support
- Error handling with SQLSTATE codes
- Example MySQL driver implementation
- Comprehensive test suite
- GitHub Actions CI/CD pipeline
- Documentation and contribution guidelines

### Changed
- Adapted PHP's synchronous API to Dart's async/await pattern
- Enhanced error handling with Dart-specific exceptions
- Improved type safety using Dart's type system

### Known Issues
- Some PHP PDO features not yet implemented:
  - FETCH_CLASS mode
  - FETCH_INTO mode
  - FETCH_LAZY mode
  - Some driver-specific attributes

## Notes

### PHP PDO Compatibility
This implementation aims to provide a familiar interface for PHP developers while taking advantage of Dart's features. Some differences from PHP's PDO include:

- Async/await usage instead of synchronous calls
- Strong typing where appropriate
- Dart-idiomatic naming conventions where they make more sense
- Enhanced error handling with more specific exceptions
- More extensive test coverage requirements

### Driver Implementation
The initial release includes an example MySQL driver implementation. Additional drivers can be implemented by:

1. Extending the PDO class
2. Implementing the required methods
3. Creating a corresponding statement class
4. Adding comprehensive tests
5. Documenting driver-specific features

### Future Plans
- Implement remaining fetch modes
- Add more database drivers
- Enhance documentation with more examples
- Add performance benchmarks
- Improve error messages and debugging
- Add connection pooling support
