/// Interface for events that should be handled after database commit.
///
/// This contract serves as a marker interface for events that should
/// only be handled after their database transaction has been committed.
abstract class ShouldHandleEventsAfterCommit {}
