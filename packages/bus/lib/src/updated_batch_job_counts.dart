/// Helper class for tracking batch job counts.
///
/// This class provides a way to track the number of processed and failed jobs
/// within a batch, making it easier to update batch state.
class UpdatedBatchJobCounts {
  /// The number of processed jobs.
  final int processedJobs;

  /// The number of failed jobs.
  final int failedJobs;

  /// Creates a new batch job counts instance.
  ///
  /// [processedJobs] The number of processed jobs.
  /// [failedJobs] The number of failed jobs.
  const UpdatedBatchJobCounts({
    required this.processedJobs,
    required this.failedJobs,
  });

  /// Create a new instance with incremented processed jobs.
  ///
  /// Returns a new instance with the processed jobs count incremented by one.
  UpdatedBatchJobCounts incrementProcessed() {
    return UpdatedBatchJobCounts(
      processedJobs: processedJobs + 1,
      failedJobs: failedJobs,
    );
  }

  /// Create a new instance with incremented failed jobs.
  ///
  /// Returns a new instance with both the processed and failed jobs counts
  /// incremented by one.
  UpdatedBatchJobCounts incrementFailed() {
    return UpdatedBatchJobCounts(
      processedJobs: processedJobs + 1,
      failedJobs: failedJobs + 1,
    );
  }

  /// Create a new instance with the given counts.
  ///
  /// [processedJobs] The new number of processed jobs.
  /// [failedJobs] The new number of failed jobs.
  ///
  /// Returns a new instance with the given counts.
  UpdatedBatchJobCounts withCounts({
    int? processedJobs,
    int? failedJobs,
  }) {
    return UpdatedBatchJobCounts(
      processedJobs: processedJobs ?? this.processedJobs,
      failedJobs: failedJobs ?? this.failedJobs,
    );
  }

  /// Create a new instance from a JSON map.
  ///
  /// [data] The JSON map containing the counts.
  ///
  /// Returns a new instance with the counts from the JSON map.
  factory UpdatedBatchJobCounts.fromJson(Map<String, dynamic> data) {
    return UpdatedBatchJobCounts(
      processedJobs: data['processed_jobs'] as int,
      failedJobs: data['failed_jobs'] as int,
    );
  }

  /// Convert this instance to a JSON map.
  ///
  /// Returns a JSON map containing the counts.
  Map<String, dynamic> toJson() {
    return {
      'processed_jobs': processedJobs,
      'failed_jobs': failedJobs,
    };
  }
}
