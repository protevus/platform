import 'dart:io' show stdout, stderr;
import 'package:ansicolor/ansicolor.dart';
import 'table.dart';

/// Represents the verbosity level of output.
enum Verbosity {
  quiet,
  normal,
  verbose,
  veryVerbose,
  debug,
}

/// Abstract base class for console output.
abstract class Output {
  /// The current verbosity level.
  Verbosity get verbosity;

  /// Write a message to the output.
  void write(String message);

  /// Write a message to the output with a newline.
  void writeln(String message);

  /// Write a blank line.
  void newLine([int count = 1]);

  /// Write an info message.
  void info(String message);

  /// Write an error message.
  void error(String message);

  /// Write a warning message.
  void warning(String message);

  /// Write a success message.
  void success(String message);

  /// Write a comment.
  void comment(String message);

  /// Write a question.
  void question(String message);

  /// Display a table with headers and rows.
  void table(
    List<String> headers,
    List<List<String>> rows, {
    List<ColumnAlignment>? columnAlignments,
    BorderStyle borderStyle = BorderStyle.box,
    int cellPadding = 1,
  });
}

/// Console output implementation using ANSI colors.
class ConsoleOutput implements Output {
  /// The current verbosity level.
  @override
  final Verbosity verbosity;

  /// ANSI pen for blue text (info).
  final _infoPen = AnsiPen()..blue();

  /// ANSI pen for red text (error).
  final _errorPen = AnsiPen()..red();

  /// ANSI pen for yellow text (warning).
  final _warningPen = AnsiPen()..yellow();

  /// ANSI pen for green text (success).
  final _successPen = AnsiPen()..green();

  /// ANSI pen for gray text (comment).
  final _commentPen = AnsiPen()..gray();

  /// ANSI pen for cyan text (question).
  final _questionPen = AnsiPen()..cyan();

  /// Create a new console output instance.
  ConsoleOutput({this.verbosity = Verbosity.normal});

  @override
  void write(String message) {
    stdout.write(message);
  }

  @override
  void writeln(String message) {
    stdout.writeln(message);
  }

  @override
  void newLine([int count = 1]) {
    for (var i = 0; i < count; i++) {
      stdout.writeln();
    }
  }

  @override
  void info(String message) {
    writeln(_infoPen(message));
  }

  @override
  void error(String message) {
    stderr.writeln(_errorPen(message));
  }

  @override
  void warning(String message) {
    writeln(_warningPen(message));
  }

  @override
  void success(String message) {
    writeln(_successPen(message));
  }

  @override
  void comment(String message) {
    writeln(_commentPen(message));
  }

  @override
  void question(String message) {
    writeln(_questionPen(message));
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
}

/// Output implementation that buffers all output.
class BufferedOutput implements Output {
  /// The current verbosity level.
  @override
  final Verbosity verbosity;

  /// The buffer of messages.
  final List<String> _buffer = [];

  /// Create a new buffered output instance.
  BufferedOutput({this.verbosity = Verbosity.normal});

  /// Get the buffered content.
  String get content => _buffer.join('\n');

  /// Clear the buffer.
  void clear() => _buffer.clear();

  @override
  void write(String message) {
    _buffer.add(message);
  }

  @override
  void writeln(String message) {
    _buffer.add('$message\n');
  }

  @override
  void newLine([int count = 1]) {
    for (var i = 0; i < count; i++) {
      _buffer.add('\n');
    }
  }

  @override
  void info(String message) => writeln(message);

  @override
  void error(String message) => writeln(message);

  @override
  void warning(String message) => writeln(message);

  @override
  void success(String message) => writeln(message);

  @override
  void comment(String message) => writeln(message);

  @override
  void question(String message) => writeln(message);

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
}
