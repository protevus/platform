/// Marks a job as requiring encryption before being stored in the queue.
///
/// Jobs implementing this interface will be automatically encrypted using the
/// configured encrypter before being serialized and stored in the queue.
///
/// Example:
/// ```dart
/// class SensitiveJob implements ShouldBeEncrypted {
///   final String sensitiveData;
///
///   SensitiveJob(this.sensitiveData);
///
///   void handle() {
///     // Process sensitive data
///   }
/// }
/// ```
abstract class ShouldBeEncrypted {}
