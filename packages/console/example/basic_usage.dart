import 'package:illuminate_console/console.dart';

/// A simple command that greets the user.
class GreetCommand extends Command {
  @override
  String get name => 'greet';

  @override
  String get description => 'Greet a user with a custom message';

  @override
  String get signature =>
      'greet {name : The name to greet} {--uppercase : Convert to uppercase}';

  @override
  Future<void> handle() async {
    final name = argument<String>('name') ?? 'World';
    var message = 'Hello, $name!';

    if (option('uppercase') == true) {
      message = message.toUpperCase();
    }

    output.info(message);
  }
}

void main(List<String> arguments) async {
  // Create a new console application
  final app = Application(
    name: 'Example Console App',
    version: '1.0.0',
  );

  // Register commands
  app.addCommands([
    HelpCommand(),
    GreetCommand(),
  ]);

  // Run the application with arguments
  await app.runWithArguments(arguments);
}

/* Example usage:

# List available commands
dart run example/basic_usage.dart list

# Show help for greet command
dart run example/basic_usage.dart greet --help

# Greet a user
dart run example/basic_usage.dart greet "John Doe"

# Greet a user with uppercase
dart run example/basic_usage.dart greet "John Doe" --uppercase

*/
