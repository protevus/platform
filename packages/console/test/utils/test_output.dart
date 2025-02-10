import 'package:illuminate_console/console.dart';
import 'package:illuminate_console/src/output/table.dart';

/// A test implementation of [Output] that captures output for verification.
class TestOutput implements Output {
  /// The captured output lines.
  final List<String> lines = [];

  /// The captured error lines.
  final List<String> errorLines = [];

  /// The current verbosity level.
  @override
  final Verbosity verbosity;

  /// Create a new test output instance.
  TestOutput({this.verbosity = Verbosity.normal});

  @override
  void write(String message) {
    lines.add(message);
  }

  @override
  void writeln(String message) {
    lines.add('$message\n');
  }

  @override
  void newLine([int count = 1]) {
    for (var i = 0; i < count; i++) {
      lines.add('\n');
    }
  }

  @override
  void info(String message) {
    writeln(message);
  }

  @override
  void error(String message) {
    errorLines.add('$message\n');
  }

  @override
  void warning(String message) {
    writeln(message);
  }

  @override
  void success(String message) {
    writeln(message);
  }

  @override
  void comment(String message) {
    writeln(message);
  }

  @override
  void question(String message) {
    writeln(message);
  }

  @override
  void table(
    List<String> headers,
    List<List<String>> rows, {
    List<ColumnAlignment>? columnAlignments,
    BorderStyle borderStyle = BorderStyle.box,
    int cellPadding = 1,
  }) {
    final table = Table(
      headers: headers,
      rows: rows,
      columnAlignments: columnAlignments,
      borderStyle: borderStyle,
      cellPadding: cellPadding,
    );
    writeln(table.toString());
  }

  /// Get all output as a single string.
  String get output => lines.join();

  /// Get all error output as a single string.
  String get errorOutput => errorLines.join();

  /// Clear all captured output.
  void clear() {
    lines.clear();
    errorLines.clear();
  }
}
