import 'package:protevus_http/foundation_exception.dart';

/// This exception is typically thrown when there's an issue with JSON parsing,
/// serialization, or deserialization. It extends [UnexpectedValueException]
/// and implements [RequestExceptionInterface].
///
/// Example usage:
/// ```dart
/// try {
///   // Some JSON operation
/// } catch (e) {
///   throw JsonException('Failed to parse JSON: $e');
/// }
/// ```
/// @author Magnus Nordlander <magnus@fervo.se>
class JsonException extends UnexpectedValueException
    implements RequestExceptionInterface {
  /// Creates a new instance of [JsonException].
  JsonException([super.message]);
}
