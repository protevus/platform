import 'package:illuminate_console/console.dart';

/// A command that demonstrates table formatting features.
class TableDemoCommand extends Command {
  @override
  String get name => 'table';

  @override
  String get description => 'Demonstrate table formatting features';

  @override
  String get signature =>
      'table {--style=box : Table border style (none, ascii, box)}';

  @override
  Future<void> handle() async {
    output.info('Table Formatting Demo');
    output.newLine();

    // Basic table
    output.info('Basic Table:');
    output.table(
      ['ID', 'Name', 'Email'],
      [
        ['1', 'John Doe', 'john@example.com'],
        ['2', 'Jane Smith', 'jane@example.com'],
        ['3', 'Bob Wilson', 'bob@example.com'],
      ],
    );
    output.newLine();

    // Table with different alignments
    output.info('Table with Alignments:');
    output.table(
      ['ID', 'Product', 'Price', 'Stock'],
      [
        ['1', 'Widget', '\$19.99', '150'],
        ['2', 'Gadget', '\$29.99', '75'],
        ['3', 'Doohickey', '\$15.99', '200'],
      ],
      columnAlignments: [
        ColumnAlignment.right, // ID
        ColumnAlignment.left, // Product
        ColumnAlignment.right, // Price
        ColumnAlignment.center, // Stock
      ],
    );
    output.newLine();

    // Table with different border style
    final style = option('style')?.toLowerCase() ?? 'box';
    final borderStyle = switch (style) {
      'none' => BorderStyle.none,
      'ascii' => BorderStyle.ascii,
      _ => BorderStyle.box,
    };

    output.info('Table with $style borders:');
    output.table(
      ['Name', 'Role', 'Department'],
      [
        ['Alice Johnson', 'Manager', 'Sales'],
        ['Bob Smith', 'Developer', 'Engineering'],
        ['Carol Williams', 'Designer', 'UX'],
      ],
      borderStyle: borderStyle,
      cellPadding: 2,
    );
    output.newLine();

    // Wide content table
    output.info('Table with Wide Content:');
    output.table(
      ['Title', 'Description'],
      [
        [
          'Project Alpha',
          'A long description that demonstrates how tables handle wide content '
              'and potentially wraps across multiple lines in the terminal.'
        ],
        [
          'Project Beta',
          'Another lengthy description to show content formatting '
              'in constrained spaces.'
        ],
      ],
    );
  }
}

void main(List<String> arguments) async {
  final app = Application(
    name: 'Table Demo',
    version: '1.0.0',
  );

  app.addCommands([
    HelpCommand(),
    TableDemoCommand(),
  ]);

  await app.runWithArguments(arguments);
}

/* Example usage:

# Show default table formatting
dart run example/table_command.dart table

# Show table with ASCII borders
dart run example/table_command.dart table --style=ascii

# Show table without borders
dart run example/table_command.dart table --style=none

*/
