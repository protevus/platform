# Process Package Examples

This directory contains examples demonstrating the usage of the Process package.

## Running the Examples

```bash
# Get dependencies
dart pub get

# Run the example
dart run example.dart
```

## Examples Included

1. **Basic Process Execution**
   - Simple command execution with `echo`
   - Output capturing and handling
   - Basic process configuration

2. **Process Configuration**
   - Working directory configuration with `path()`
   - Environment variables with `env()`
   - Output suppression with `quietly()`
   - Process timeouts and idle timeouts

3. **Process Pool**
   - Concurrent process execution
   - Pool result handling
   - Real-time output capturing
   - Process coordination

4. **Process Pipe**
   - Sequential process execution
   - Output piping between processes
   - Command chaining
   - Error handling in pipelines

5. **Error Handling**
   - Process failure handling
   - Exception catching and handling
   - Error output capturing
   - Custom error callbacks

6. **Testing**
   - Process faking with `fake()`
   - Output sequence simulation
   - Timing simulation
   - Process behavior mocking

## Additional Examples

For more specific examples, see:

- [Process Execution](../doc/execution.md) - Detailed process execution examples
- [Process Coordination](../doc/coordination.md) - Advanced pool and pipe examples
- [Testing Utilities](../doc/testing.md) - Comprehensive testing examples

## Notes

- Some examples require specific system commands (`ls`, `sort`, `uniq`). These commands are commonly available on Unix-like systems.
- Error handling examples intentionally demonstrate failure cases.
- The testing examples show how to use the package's testing utilities in your own tests.
- Process pools demonstrate concurrent execution - actual execution order may vary.
- Process pipes demonstrate sequential execution - output flows from one process to the next.

## System Requirements

- Dart SDK >= 3.0.0
- Unix-like system for some examples (Linux, macOS)
- Basic system commands (`echo`, `ls`, etc.)

## Best Practices Demonstrated

1. Always handle process errors appropriately
2. Use timeouts for long-running processes
3. Configure working directories explicitly
4. Set environment variables when needed
5. Use `quietly()` for noisy processes
6. Clean up resources properly
7. Test process-dependent code thoroughly

## Further Reading

- [Package Documentation](../README.md)
- [API Reference](https://pub.dev/documentation/platform_process)
- [Contributing Guide](../CONTRIBUTING.md)
