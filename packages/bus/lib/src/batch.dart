import 'command.dart';
import 'dispatcher.dart';

class Batch {
  // Implement Batch
}

class PendingBatch {
  final Dispatcher _dispatcher;
  final List<Command> _commands;

  PendingBatch(this._dispatcher, this._commands);

  Future<void> dispatch() async {
    for (var command in _commands) {
      await _dispatcher.dispatch(command);
    }
  }
}
