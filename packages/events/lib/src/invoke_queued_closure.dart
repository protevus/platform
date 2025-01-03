import 'package:platform_collections/collections.dart';
import 'package:platform_container/container.dart';

import 'reflection/reflection.dart';

/// Class for invoking queued closures.
class InvokeQueuedClosure {
  /// Handle the event.
  void handle(Function closure, List<dynamic> arguments) {
    Function.apply(closure, arguments);
  }

  /// Handle a job failure.
  void failed(
    Function closure,
    List<dynamic> arguments,
    List<Function> catchCallbacks,
    Object exception,
  ) {
    arguments.add(exception);

    Collection(catchCallbacks).forEach((callback) {
      Function.apply(callback, arguments);
    });
  }

  /// Get the display name for the queued job.
  String displayName() => 'Closure';

  /// Get the job's unique identifier.
  String? jobId() => null;
}
