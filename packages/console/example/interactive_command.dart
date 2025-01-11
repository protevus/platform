import 'package:platform_console/platform_console.dart';

/// A command that demonstrates interactive features.
class SetupCommand extends Command {
  @override
  String get name => 'setup';

  @override
  String get description => 'Interactive setup wizard';

  @override
  String get signature => 'setup {--force : Skip confirmations}';

  @override
  Future<void> handle() async {
    output.info('Welcome to the setup wizard!');
    output.newLine();

    // Basic prompt
    final name = await prompt.ask('What is your name?', 'User');
    output.success('Hello, $name!');
    output.newLine();

    // Confirmation
    if (!option('force') == true) {
      final proceed = await prompt.confirm('Would you like to continue?', true);
      if (!proceed) {
        output.comment('Setup cancelled.');
        return;
      }
    }

    // Choice selection
    final environment = await prompt.choice(
      'Select your environment:',
      ['development', 'staging', 'production'],
      'development',
    );
    output.info('Selected environment: $environment');
    output.newLine();

    // Secret input
    final apiKey = await prompt.secret('Enter your API key:');
    output.success('API key saved securely.');
    output.newLine();

    // Auto-completion
    final framework = await prompt.askWithCompletion(
      'Which framework do you use?',
      ['Laravel', 'Symfony', 'Django', 'Rails', 'Express'],
      'Laravel',
    );
    output.info('Selected framework: $framework');
    output.newLine();

    // Progress bar
    await prompt.progressBar('Installing dependencies', 5, (progress) async {
      for (var i = 0; i < 5; i++) {
        await Future.delayed(Duration(milliseconds: 500));
        progress(i + 1);
      }
      return true;
    });

    // Progress spinner for indeterminate tasks
    await prompt.spinner('Configuring environment', () async {
      await Future.delayed(Duration(seconds: 2));
      return true;
    });

    output.newLine();
    output.success('Setup completed successfully!');
  }
}

void main(List<String> arguments) async {
  final app = Application(
    name: 'Interactive Demo',
    version: '1.0.0',
  );

  app.addCommands([
    ListCommand(),
    SetupCommand(),
  ]);

  await app.runWithArguments(arguments);
}

/* Example usage:

# Run the interactive setup
dart run example/interactive_command.dart setup

# Run setup without confirmations
dart run example/interactive_command.dart setup --force

*/
