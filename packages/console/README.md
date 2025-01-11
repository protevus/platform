# Platform Console

A Dart implementation of Laravel's console package, providing an elegant way to create command-line applications.

## Features

- Laravel-style command signatures
- Rich console output with ANSI colors
- Argument and option parsing
- Help system with detailed output
- Command discovery and registration
- Interactive features:
  * User prompts with default values
  * Yes/no confirmations
  * Multiple choice selection
  * Password input with hidden text
  * Auto-completion suggestions
  * Progress spinners

## Usage

### Creating a Command

```dart
import 'package:platform_console/platform_console.dart';

class GreetCommand extends Command {
  @override
  String get name => 'greet';

  @override
  String get description => 'Greet a user with a custom message';

  @override
  String get signature => 'greet {name : The name to greet} {--uppercase : Convert to uppercase}';

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
```

### Setting Up the Application

```dart
void main(List<String> arguments) async {
  final app = Application(
    name: 'My Console App',
    version: '1.0.0',
  );

  // Register commands
  app.addCommands([
    ListCommand(), // Built-in command to list available commands
    GreetCommand(),
  ]);

  // Run the application
  await app.runWithArguments(arguments);
}
```

### Command Signatures

Commands can be defined using Laravel-style signatures:

- Required arguments: `{name}`
- Optional arguments: `{name?}`
- Arguments with defaults: `{name=World}`
- Array arguments: `{names*}`
- Options: `{--option}`
- Options with values: `{--option=}`
- Options with defaults: `{--option=default}`
- Option shortcuts: `{-o|--option}`

### Console Output and Interaction

The package provides various output and interaction methods:

```dart
// Output methods
output.info('Information message');
output.error('Error message');
output.warning('Warning message');
output.success('Success message');
output.comment('Comment message');

// Interactive prompts
final name = await prompt.ask('What is your name?', 'User');
final confirm = await prompt.confirm('Continue?', true);
final password = await prompt.secret('Enter password:');
final choice = await prompt.choice('Select environment:', ['dev', 'prod']);
final framework = await prompt.askWithCompletion(
  'Select framework:',
  ['Laravel', 'Symfony', 'Django'],
);

// Progress indicators
// For tasks with known steps
await prompt.progressBar('Installing dependencies', totalSteps, (progress) async {
  for (var i = 0; i < totalSteps; i++) {
    await installDependency(i);
    progress(i + 1); // Update progress
  }
});

// For indeterminate tasks
await prompt.spinner('Processing', () async {
  await someAsyncTask();
});

// Table output
// Basic table
output.table(
  ['ID', 'Name', 'Email'],
  [
    ['1', 'John Doe', 'john@example.com'],
    ['2', 'Jane Smith', 'jane@example.com'],
  ],
);

// Table with alignments and styling
output.table(
  ['ID', 'Product', 'Price', 'Stock'],
  [
    ['1', 'Widget', '$19.99', '150'],
    ['2', 'Gadget', '$29.99', '75'],
  ],
  columnAlignments: [
    ColumnAlignment.right,  // ID
    ColumnAlignment.left,   // Product
    ColumnAlignment.right,  // Price
    ColumnAlignment.center, // Stock
  ],
  borderStyle: BorderStyle.box,    // or .ascii, .none
  cellPadding: 1,
);
```

### Table Formatting

Tables support various formatting options:

- Border Styles:
  * `BorderStyle.box` - Unicode box drawing characters (default)
  * `BorderStyle.ascii` - Simple ASCII characters (+, -, |)
  * `BorderStyle.none` - No borders, space-separated

- Column Alignments:
  * `ColumnAlignment.left` - Left-aligned text (default)
  * `ColumnAlignment.right` - Right-aligned text
  * `ColumnAlignment.center` - Centered text

- Cell Padding:
  * Configurable padding between cell content and borders
  * Default: 1 space on each side

### Running Commands

```bash
# List available commands
dart run app.dart list

# Show command help
dart run app.dart greet --help

# Run command with arguments
dart run app.dart greet "John Doe"

# Run command with options
dart run app.dart greet "John Doe" --uppercase
```

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  platform_console: ^0.0.1
```

## License

This package is open-sourced software licensed under the MIT license.
