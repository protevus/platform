import 'command.dart';

abstract class Handler {
  Future<dynamic> handle(Command command);
}
