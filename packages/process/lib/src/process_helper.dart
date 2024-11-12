import 'process.dart';

Angel3Process angel3Process(
  String command,
  List<String> arguments, {
  String? workingDirectory,
  Map<String, String>? environment,
  Duration? timeout,
  bool tty = false,
  bool enableReadError = true,
}) {
  return Angel3Process(
    command,
    arguments,
    workingDirectory: workingDirectory,
    environment: environment,
    timeout: timeout,
    tty: tty,
    enableReadError: enableReadError,
  );
}
