import 'package:platform_contracts/contracts.dart';

/// Mixin to add batch functionality to jobs.
///
/// This mixin provides methods for configuring how a job should be processed
/// within a batch.
mixin Batchable {
  /// The batch ID this job belongs to.
  String? _batchId;

  /// The index of this job within its batch.
  int? _batchIndex;

  /// Get the batch ID this job belongs to.
  String? get batchId => _batchId;

  /// Get the index of this job within its batch.
  int? get batchIndex => _batchIndex;

  /// Set the batch information for this job.
  ///
  /// [batchId] The batch ID this job belongs to.
  /// [batchIndex] The index of this job within its batch.
  void withBatch(String batchId, int batchIndex) {
    _batchId = batchId;
    _batchIndex = batchIndex;
  }

  /// Remove this job from its batch.
  void removeBatch() {
    _batchId = null;
    _batchIndex = null;
  }

  /// Whether this job belongs to a batch.
  bool get inBatch => _batchId != null;
}
