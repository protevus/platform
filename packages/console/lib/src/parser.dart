import 'package:args/args.dart';

/// Parses command signatures into arguments and options.
class Parser {
  /// Parse the given console command signature into its components.
  ///
  /// Returns a tuple containing:
  /// - The command name
  /// - List of InputArgument objects
  /// - List of InputOption objects
  static (String, List<InputArgument>, List<InputOption>) parse(
      String signature) {
    if (!_isValidSignature(signature)) {
      throw ArgumentError('Invalid command signature format');
    }

    final name = _extractName(signature);
    final parameters = _extractParameters(signature);

    final arguments = <InputArgument>[];
    final options = <InputOption>[];

    for (final param in parameters) {
      if (param.startsWith('--')) {
        options.add(_parseOption(param.substring(2)));
      } else if (param.startsWith('-')) {
        // Handle shortcut-only options
        options.add(_parseOption(param.substring(1)));
      } else {
        arguments.add(_parseArgument(param));
      }
    }

    return (name, arguments, options);
  }

  /// Validate the signature format.
  static bool _isValidSignature(String signature) {
    if (signature.trim().isEmpty) return false;

    // Check for balanced braces
    var openBraces = 0;
    for (var i = 0; i < signature.length; i++) {
      if (signature[i] == '{') openBraces++;
      if (signature[i] == '}') openBraces--;
      if (openBraces < 0) return false;
    }
    if (openBraces != 0) return false;

    // Check for valid command name
    final parts = signature.trim().split(' ');
    if (parts.isEmpty || !RegExp(r'^[a-zA-Z][\w:-]*$').hasMatch(parts.first)) {
      return false;
    }

    return true;
  }

  /// Extract the command name from the signature.
  static String _extractName(String signature) {
    final parts = signature.trim().split(' ');
    return parts.first;
  }

  /// Extract the parameters from the signature.
  static List<String> _extractParameters(String signature) {
    final parameters = <String>[];
    final regex = RegExp(r'\{([^}]+)\}');

    final matches = regex.allMatches(signature);
    for (final match in matches) {
      parameters.add(match.group(1)!);
    }

    return parameters;
  }

  /// Parse an argument definition.
  static InputArgument _parseArgument(String definition) {
    var name = definition;
    var description = '';
    var defaultValue = '';
    var mode = InputArgumentMode.required;

    // Check for description
    if (definition.contains(':')) {
      final parts = definition.split(':');
      name = parts[0].trim();
      description = parts[1].trim();
    }

    // Check for array argument (must check before optional)
    if (name.endsWith('*')) {
      name = name.substring(0, name.length - 1);
      mode = InputArgumentMode.isArray;
    }
    // Check for optional argument
    else if (name.endsWith('?')) {
      name = name.substring(0, name.length - 1);
      mode = InputArgumentMode.optional;
    }

    // Check for default value
    if (name.contains('=')) {
      final parts = name.split('=');
      name = parts[0].trim();
      defaultValue = parts[1].trim();
      mode = InputArgumentMode.optional;
    }

    return InputArgument(
      name: name,
      mode: mode,
      description: description,
      defaultValue: defaultValue,
    );
  }

  /// Parse an option definition.
  static InputOption _parseOption(String definition) {
    var name = definition;
    var description = '';
    var defaultValue = '';
    var mode = InputOptionMode.none;
    String? shortcut;

    // Check for description
    if (definition.contains(':')) {
      final parts = definition.split(':');
      name = parts[0].trim();
      description = parts[1].trim();
    }

    // Check for shortcut (must check first to avoid conflicts)
    if (name.contains('|')) {
      final parts = name.split('|');
      shortcut = parts[0].trim();
      name = parts[1].trim();
      if (name.startsWith('--')) {
        name = name.substring(2);
      }
    }

    // Check for array option (must check before value option)
    if (name.endsWith('=*')) {
      name = name.substring(0, name.length - 2);
      mode = InputOptionMode.isArray;
    }
    // Check for value option
    else if (name.endsWith('=')) {
      name = name.substring(0, name.length - 1);
      mode = InputOptionMode.optional;
    }

    // Check for default value
    if (name.contains('=')) {
      final parts = name.split('=');
      name = parts[0].trim();
      defaultValue = parts[1].trim();
      mode = InputOptionMode.optional;
    }

    return InputOption(
      name: name,
      shortcut: shortcut,
      mode: mode,
      description: description,
      defaultValue: defaultValue,
    );
  }
}

/// Represents the mode of an input argument.
enum InputArgumentMode {
  required,
  optional,
  isArray,
}

/// Represents an input argument definition.
class InputArgument {
  final String name;
  final InputArgumentMode mode;
  final String description;
  final String defaultValue;

  InputArgument({
    required this.name,
    this.mode = InputArgumentMode.required,
    this.description = '',
    this.defaultValue = '',
  });
}

/// Represents the mode of an input option.
enum InputOptionMode {
  none,
  optional,
  isArray,
}

/// Represents an input option definition.
class InputOption {
  final String name;
  final String? shortcut;
  final InputOptionMode mode;
  final String description;
  final String defaultValue;

  InputOption({
    required this.name,
    this.shortcut,
    this.mode = InputOptionMode.none,
    this.description = '',
    this.defaultValue = '',
  });
}
