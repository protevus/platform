import 'dart:io';
import '../output/output.dart';

/// Handles interactive prompts in console commands.
class Prompt {
  /// The output instance.
  final Output _output;

  /// Create a new prompt instance.
  Prompt(this._output);

  /// Ask a question and get the user's input.
  ///
  /// If [default_] is provided, it will be used if the user enters nothing.
  Future<String> ask(String question, [String? default_]) async {
    _output.question(
        '$question${default_ != null ? ' (default: $default_)' : ''}');
    _output.write('> ');

    final input = stdin.readLineSync()?.trim() ?? '';
    return input.isEmpty ? (default_ ?? '') : input;
  }

  /// Ask for confirmation with yes/no question.
  ///
  /// Returns true if the user confirms, false otherwise.
  Future<bool> confirm(String question, [bool default_ = false]) async {
    final defaultText = default_ ? 'Y/n' : 'y/N';
    _output.question('$question [$defaultText]');
    _output.write('> ');

    final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';
    if (input.isEmpty) {
      return default_;
    }

    return input == 'y' || input == 'yes';
  }

  /// Ask for a secret (password) with hidden input.
  ///
  /// The input will not be displayed as the user types.
  Future<String> secret(String question) async {
    _output.question(question);
    _output.write('> ');

    // Disable echo
    stdin.echoMode = false;
    final input = stdin.readLineSync()?.trim() ?? '';
    stdin.echoMode = true;
    _output.newLine();

    return input;
  }

  /// Ask a question with choices and return the selected value.
  ///
  /// Example:
  /// ```dart
  /// final color = await choice('Select a color:', ['red', 'green', 'blue']);
  /// ```
  Future<T> choice<T>(String question, List<T> choices, [T? default_]) async {
    _output.question(question);
    _output.newLine();

    for (var i = 0; i < choices.length; i++) {
      final choice = choices[i];
      final marker = choice == default_ ? '*' : ' ';
      _output.writeln('  [$marker] ${i + 1}) $choice');
    }
    _output.newLine();

    while (true) {
      _output.write('Enter your choice (1-${choices.length}): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (input.isEmpty && default_ != null) {
        return default_;
      }

      final index = int.tryParse(input);
      if (index != null && index >= 1 && index <= choices.length) {
        return choices[index - 1];
      }

      _output.error('Invalid choice. Please try again.');
    }
  }

  /// Ask a question with auto-completion support.
  ///
  /// As the user types, matching choices will be suggested.
  Future<String> askWithCompletion(
    String question,
    List<String> choices, [
    String? default_,
  ]) async {
    _output.question(
        '$question${default_ != null ? ' (default: $default_)' : ''}');
    _output.writeln('(Type to search, use arrow keys to navigate)');
    _output.write('> ');

    // TODO: Implement real-time completion with arrow key navigation
    final input = stdin.readLineSync()?.trim() ?? '';
    if (input.isEmpty && default_ != null) {
      return default_;
    }

    // For now, just return the input if it matches any choice
    if (choices.contains(input)) {
      return input;
    }

    // Find closest match
    final match = choices.firstWhere(
      (choice) => choice.toLowerCase().startsWith(input.toLowerCase()),
      orElse: () => input,
    );

    return match;
  }

  /// Display a progress bar for a task with known total steps.
  ///
  /// Example:
  /// ```dart
  /// await progressBar('Processing files', 100, (progress) async {
  ///   for (var i = 0; i < 100; i++) {
  ///     await processFile(i);
  ///     progress(i + 1);
  ///   }
  /// });
  /// ```
  Future<T> progressBar<T>(
    String message,
    int total,
    Future<T> Function(void Function(int current) progress) callback,
  ) async {
    const width = 50; // Progress bar width in characters
    var current = 0;
    var lastPercent = 0;

    void updateProgress(int value) {
      current = value;
      final percent = (current * 100 ~/ total).clamp(0, 100);

      if (percent != lastPercent) {
        final filled = (width * current) ~/ total;
        final empty = width - filled;
        final bar = '█' * filled + '░' * empty;

        stdout.write('\r$message [$bar] $percent%');
        lastPercent = percent;
      }
    }

    try {
      final result = await callback(updateProgress);
      stdout.write('\r$message [${('█' * width)}] 100%\n');
      return result;
    } catch (e) {
      stdout.write('\n');
      rethrow;
    }
  }

  /// Display a progress spinner while executing a task.
  ///
  /// Example:
  /// ```dart
  /// await spinner('Processing', () async {
  ///   await someAsyncTask();
  /// });
  /// ```
  Future<T> spinner<T>(
    String message,
    Future<T> Function() callback,
  ) async {
    const frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    var frameIndex = 0;
    var running = true;

    // Start spinner animation
    Future.doWhile(() async {
      stdout.write('\r${frames[frameIndex]} $message');
      frameIndex = (frameIndex + 1) % frames.length;
      await Future.delayed(Duration(milliseconds: 80));
      return running;
    });

    try {
      final result = await callback();
      running = false;
      stdout.write('\r✓ $message\n');
      return result;
    } catch (e) {
      running = false;
      stdout.write('\r✗ $message\n');
      rethrow;
    }
  }
}
