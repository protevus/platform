/// Process management package for Dart.
///
/// This package provides a fluent interface for working with processes in Dart,
/// similar to Laravel's Process package. It offers:
///
/// - Process execution with timeouts and idle timeouts
/// - Process pools for concurrent execution
/// - Process piping for sequential execution
/// - Process output capturing and streaming
/// - Process environment and working directory configuration
/// - TTY mode support
/// - Testing utilities with process faking and recording
library process;

// Core functionality
export 'src/contracts/process_result.dart';
export 'src/exceptions/process_failed_exception.dart';
export 'src/factory.dart';
export 'src/pending_process.dart';
export 'src/process_result.dart';

// Process execution
export 'src/invoked_process.dart';
export 'src/invoked_process_pool.dart';

// Process coordination
export 'src/pipe.dart';
export 'src/pool.dart' hide ProcessPoolResults;

// Process results
export 'src/process_pool_results.dart';

// Testing utilities
export 'src/fake_invoked_process.dart';
export 'src/fake_process_description.dart';
export 'src/fake_process_result.dart';
export 'src/fake_process_sequence.dart';

// Re-export common types
export 'dart:io' show ProcessSignal;
