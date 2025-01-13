# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-01-01

### Added
- Initial release of the Blade template engine for Dart
- Full Laravel Blade syntax support
- Template inheritance with `@extends` and `@section`
- Component system with slots and attributes
- Conditional directives (`@if`, `@unless`, `@switch`)
- Loop directives (`@foreach`, `@forelse`, `@while`)
- Template includes and partials
- Custom directives support
- Template caching
- Error handling with source maps
- Flutter compatibility
- Comprehensive test suite
- Example application
- Documentation

### Features
- AST-based parsing for robust template processing
- Source map support for detailed error reporting
- Extensible component system
- Template inheritance and composition
- Configurable caching system
- Custom directive registration
- HTML escaping and raw output support
- Nested data binding
- Asynchronous rendering
- Flutter widget integration

### Implementation Details
- Scanner for tokenizing Blade templates
- Parser for building AST from tokens
- Transformer for handling template inheritance
- Code generator for PHP-compatible output
- Component system with slots and attributes
- Error handling with source maps
- Caching system for compiled templates
- Test suite with over 50 test cases
- Example application demonstrating key features
- Comprehensive documentation with usage examples

### Dependencies
- source_span: ^1.10.0 - For source mapping and error reporting
- collection: ^1.18.0 - For utility collections
- meta: ^1.9.0 - For annotations and metadata
- path: ^1.8.0 - For file path handling

### Development Dependencies
- lints: ^2.1.0 - For code quality
- test: ^1.24.0 - For testing
- mockito: ^5.4.0 - For mocking in tests

### Known Issues
- Template inheritance requires manual loading of parent templates
- Limited PHP compatibility in some edge cases
- Component slots do not support dynamic names yet

### Future Plans
- Improve PHP compatibility
- Add more Laravel Blade features
- Enhance Flutter integration
- Optimize performance
- Add more examples and documentation
- Support for custom template loaders
- Enhanced error messages
- More test coverage
