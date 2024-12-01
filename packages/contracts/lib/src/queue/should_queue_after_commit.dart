import 'should_queue.dart';

/// Marker interface to indicate that a job should be queued after database transactions are committed.
abstract class ShouldQueueAfterCommit extends ShouldQueue {}
