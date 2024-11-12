import 'command.dart';

abstract class Queue {
  Future<void> push(Command command);
  Future<void> later(Duration delay, Command command);
  Future<void> pushOn(String queue, Command command);
  Future<void> laterOn(String queue, Duration delay, Command command);
}
