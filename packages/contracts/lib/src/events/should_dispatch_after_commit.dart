/// Interface for events that should be dispatched after database commit.
///
/// This contract serves as a marker interface for events that should
/// only be dispatched after their database transaction has been committed.
abstract class ShouldDispatchAfterCommit {}
