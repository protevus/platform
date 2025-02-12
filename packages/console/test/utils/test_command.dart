import 'package:args/args.dart';
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

  @override
  void configure(ArgParser parser) {
    // Add test options if no signature is provided
    if (_signature == null) {
      parser.addFlag(
        'flag',
        help: 'Test flag',
        negatable: true,
      );
      parser.addOption(
        'option',
        help: 'Test option',
      );
    }
  }
}
