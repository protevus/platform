/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Base exception class for container-related errors.
abstract class ContainerException implements Exception {
  /// The error message
  final String message;

  /// Optional cause of the exception
  final Object? cause;

  /// Creates a new container exception
  ContainerException(this.message, [this.cause]);

  @override
  String toString() => cause == null ? message : '$message (Caused by: $cause)';
}

/// Exception thrown when reflection operations fail
class ReflectionException extends ContainerException {
  ReflectionException(String message, [Object? cause]) : super(message, cause);
}

/// Exception thrown when a binding resolution fails
class BindingResolutionException extends ContainerException {
  BindingResolutionException(String message, [Object? cause])
      : super(message, cause);
}

/// Exception thrown when a circular dependency is detected
class CircularDependencyException extends ContainerException {
  CircularDependencyException(String message, [Object? cause])
      : super(message, cause);
}

/// Exception thrown when an entry is not found in the container
class EntryNotFoundException extends ContainerException {
  /// The identifier that was not found
  final String id;

  EntryNotFoundException(this.id, [Object? cause])
      : super('No entry was found for identifier "$id"', cause);
}

/// Exception thrown when there are contextual binding issues
class ContextualBindingException extends ContainerException {
  ContextualBindingException(String message, [Object? cause])
      : super(message, cause);
}
