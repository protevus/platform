import 'should_be_unique.dart';

/// Marker interface to indicate that a queued job should be unique until processing begins.
abstract class ShouldBeUniqueUntilProcessing extends ShouldBeUnique {}
