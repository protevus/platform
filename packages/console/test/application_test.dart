import 'package:platform_console/platform_console.dart';
import 'package:test/test.dart';

import 'utils/test_command.dart';
import 'utils/test_output.dart';

void main() {
  group('Application', () {
    late Application app;
    late TestOutput output;

    setUp(() {
      output = TestOutput();
      app = Application(
        name: 'Test App',
        version: '1.0.0',
        output: output,
      );
    });

    test('registers commands', () {
      final command = TestCommand();
      app.add(command);

      expect(app.commands, contains(command));
      expect(app.getCommand('test'), equals(command));
    });

    test('registers multiple commands', () {
      final commands = [
        TestCommand(signature: 'test1'),
        TestCommand(signature: 'test2'),
      ];

      app.addCommands(commands);

      expect(app.commands, containsAll(commands));
      expect(app.getCommand('test1'), equals(commands[0]));
      expect(app.getCommand('test2'), equals(commands[1]));
    });

    test('filters hidden commands', () {
      app.addCommands([
        TestCommand(signature: 'visible'),
        _HiddenCommand(),
      ]);

      expect(app.visibleCommands.length, equals(1));
      expect(app.visibleCommands.first.name, equals('visible'));
    });

    test('runs commands by name', () async {
      var ran = false;
      app.add(_RunTrackingCommand(onRun: () => ran = true));

      await app.run('track');

      expect(ran, isTrue);
    });

    test('throws on unknown command', () {
      expect(
        () => app.run('unknown'),
        throwsA(isA<CommandNotFoundException>()),
      );
    });

    test('shows help for command', () async {
      final command = TestCommand(
        signature: 'test {name} {--flag}',
      );
      app.add(command);

      await app.run('test', ['--help']);

      expect(output.output, contains('test'));
      expect(output.output, contains('Test command for testing'));
      expect(output.output, contains('name'));
      expect(output.output, contains('--flag'));
    });

    test('handles empty arguments', () async {
      app.add(TestCommand());
      await app.runWithArguments([]);

      // Should show list of commands
      expect(output.output, contains('Available commands:'));
      expect(output.output, contains('test'));
    });

    test('passes arguments to command', () async {
      var receivedArgs = <String>[];
      app.add(_RunTrackingCommand(
        onRun: () {},
        onArgs: (args) => receivedArgs = args,
      ));

      await app.runWithArguments(['track', 'arg1', '--flag']);

      expect(receivedArgs, equals(['arg1', '--flag']));
    });
  });
}

/// A command that tracks when it is run.
class _RunTrackingCommand extends Command {
  final void Function() onRun;
  final void Function(List<String>)? onArgs;

  _RunTrackingCommand({
    required this.onRun,
    this.onArgs,
  });

  @override
  String get name => 'track';

  @override
  String get description => 'Tracking command';

  @override
  Future<void> handle() async {
    onRun();
  }

  @override
  Future<void> run(List<String> args) async {
    onArgs?.call(args);
    await super.run(args);
  }
}

/// A command that is hidden from listings.
class _HiddenCommand extends Command {
  @override
  String get name => 'hidden';

  @override
  String get description => 'Hidden command';

  @override
  bool get hidden => true;

  @override
  Future<void> handle() async {}
}
