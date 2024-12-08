import 'package:dsr_container/container.dart';

/// Exception thrown when a circular dependency is detected in the container.
///
/// This exception is thrown when the container detects a circular dependency
/// while trying to resolve a type. A circular dependency occurs when type A
/// depends on type B which depends on type A, either directly or through
/// a chain of other dependencies.
///
/// Example:
/// ```dart
/// class A {
///   A(B b);
/// }
///
/// class B {
///   B(A a); // Circular dependency: A -> B -> A
/// }
///
/// try {
///   container.make('A');
/// } on CircularDependencyException catch (e) {
///   print(e.message); // "Circular dependency detected while resolving [A -> B -> A]"
///   print(e.path); // ["A", "B", "A"]
/// }
/// ```
class CircularDependencyException implements ContainerExceptionInterface {
  /// The error message describing the circular dependency.
  @override
  final String message;

  /// The path of dependencies that form the circle.
  final List<String> path;

  /// Creates a new [CircularDependencyException].
  ///
  /// The [path] parameter should contain the list of types in the order they
  /// were encountered while resolving dependencies, with the last type being
  /// the one that completes the circle.
  CircularDependencyException(this.path)
      : message =
            'Circular dependency detected while resolving [${path.join(" -> ")}]';

  @override
  String toString() => message;
}
