import 'package:protevus_http/src/serializable.dart';

/// An exception thrown when an ORM property validator is violated.
///
/// Behaves the same as [SerializableException].
class ValidationException extends SerializableException {
  ValidationException(super.errors);
}
