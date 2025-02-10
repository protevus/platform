import 'package:illuminate_console/console.dart';

/// A test implementation of [Command] for testing purposes.
class TestCommand extends Command {
  /// The command signature if provided.
  final String? _signature;

  /// Create a new test command instance.
  TestCommand({String? signature}) : _signature = signature;

  @override
  String get name => _signature?.split(' ').first ?? 'test';

  @override
  String get description => 'Test command for testing';

  @override
  String? get signature => _signature;

  @override
  Future<void> handle() async {
    // No-op for testing
  }
}
