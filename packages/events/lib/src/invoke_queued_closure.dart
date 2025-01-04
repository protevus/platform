/// A class for invoking queued closures.
class InvokeQueuedClosure {
  /// Handle the queued closure.
  dynamic handle(Function closure, List<dynamic> arguments) {
    return Function.apply(closure, arguments);
  }

  /// Handle a failed closure by invoking catch callbacks.
  void failed(
    Function closure,
    List<dynamic> arguments,
    List<Function> catchCallbacks,
    dynamic error,
  ) {
    for (var callback in catchCallbacks) {
      Function.apply(callback, [arguments, error]);
    }
  }

  /// Get the display name for this job.
  String displayName() => 'Closure';

  /// Get the job ID.
  String? jobId() => null;
}
