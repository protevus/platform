import 'pending_process.dart';

/// A factory for creating process instances.
class Factory {
  /// Create a new factory instance.
  Factory();

  /// Create a new pending process instance with the given command.
  PendingProcess command(dynamic command) {
    if (command == null) {
      throw ArgumentError('Command cannot be null');
    }

    if (command is String && command.trim().isEmpty) {
      throw ArgumentError('Command string cannot be empty');
    }

    if (command is List) {
      if (command.isEmpty) {
        throw ArgumentError('Command list cannot be empty');
      }

      if (command.any((element) => element is! String)) {
        throw ArgumentError('Command list must contain only strings');
      }
    }

    if (command is! String && command is! List) {
      throw ArgumentError('Command must be a string or list of strings');
    }

    return PendingProcess(this)..withCommand(command);
  }
}
