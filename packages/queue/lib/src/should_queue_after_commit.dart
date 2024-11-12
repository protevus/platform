/// Marks a job as requiring to be queued after database transactions have committed.
///
/// Jobs implementing this interface will not be queued until all open database
/// transactions have been committed. This ensures data consistency by preventing
/// jobs from being processed before their related database changes are permanent.
///
/// Example:
/// ```dart
/// class CreateUserJob implements ShouldQueueAfterCommit {
///   final User user;
///
///   CreateUserJob(this.user);
///
///   void handle() {
///     // Send welcome email
///     // This will only happen after the user is actually saved to the database
///   }
/// }
/// ```
///
/// Note: If a transaction fails and rolls back, the job will not be queued.
abstract class ShouldQueueAfterCommit {}
