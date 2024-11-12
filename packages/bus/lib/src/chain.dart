import 'command.dart';
import 'dispatcher.dart';

class PendingChain {
  final Dispatcher _dispatcher;
  final List<Command> _commands;

  PendingChain(this._dispatcher, this._commands);

  Future<void> dispatch() async {
    for (var command in _commands) {
      await _dispatcher.dispatch(command);
    }
  }
}
