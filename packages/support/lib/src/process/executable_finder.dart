import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:glob/glob.dart';

/// A class to find executables in the system PATH.
class ExecutableFinder {
  /// The environment variables.
  final Map<String, String> _env;

  /// Creates a new executable finder.
  ExecutableFinder([Map<String, String>? env])
      : _env = env ?? Platform.environment;

  /// Find the executable path.
  String? find(String name) {
    // If it's already a full path, verify it exists
    if (path.isAbsolute(name)) {
      return _verifyExecutable(name);
    }

    // Check for executable in current directory
    final currentDir =
        _verifyExecutable(path.join(Directory.current.path, name));
    if (currentDir != null) {
      return currentDir;
    }

    // Search in PATH
    final pathDirs = _getPathDirs();
    for (final dir in pathDirs) {
      if (Platform.isWindows) {
        // Try each extension
        final exts = _env['PATHEXT']?.split(';') ?? ['.exe', '.bat', '.cmd'];
        for (final ext in exts) {
          if (name.toLowerCase().endsWith(ext.toLowerCase())) {
            final executable = _verifyExecutable(path.join(dir, name));
            if (executable != null) return executable;
            break;
          }
          final executable = _verifyExecutable(path.join(dir, name + ext));
          if (executable != null) return executable;
        }
      } else {
        final executable = _verifyExecutable(path.join(dir, name));
        if (executable != null) return executable;
      }
    }

    return null;
  }

  /// Find all matching executables in PATH.
  List<String> findAll(String pattern) {
    final results = <String>{}; // Use Set to avoid duplicates
    final glob = Glob(pattern, caseSensitive: false);

    // If it's already a full path, verify it exists
    if (path.isAbsolute(pattern)) {
      final executable = _verifyExecutable(pattern);
      if (executable != null) {
        results.add(executable);
      }
      return results.toList();
    }

    // Check for executable in current directory
    _findInDirectory(Directory.current.path, pattern, glob, results);

    // Search in PATH
    final pathDirs = _getPathDirs();
    for (final dir in pathDirs) {
      _findInDirectory(dir, pattern, glob, results);
    }

    return results.toList();
  }

  /// Find executables in a directory that match the pattern.
  void _findInDirectory(
      String dir, String pattern, Glob glob, Set<String> results) {
    try {
      final directory = Directory(dir);
      if (!directory.existsSync()) return;

      for (final entity in directory.listSync()) {
        if (entity is! File) continue;

        final basename = path.basename(entity.path);
        if (!glob.matches(basename)) continue;

        final executable = _verifyExecutable(entity.path);
        if (executable != null) {
          results.add(executable);
        }
      }
    } catch (_) {
      // Ignore directory access errors
    }
  }

  /// Get the directories in PATH.
  List<String> _getPathDirs() {
    final pathSeparator = Platform.isWindows ? ';' : ':';
    final path = _env['PATH'] ?? '';
    return path.split(pathSeparator).where((dir) => dir.isNotEmpty).toList();
  }

  /// Build the full path to an executable.
  String _buildExecutablePath(String dir, String name) {
    if (Platform.isWindows) {
      // Windows needs to check for multiple extensions
      final exts = _env['PATHEXT']?.split(';') ?? ['.exe', '.bat', '.cmd'];
      if (exts.any((ext) => name.toLowerCase().endsWith(ext.toLowerCase()))) {
        return path.join(dir, name);
      }
      // Try each extension
      return path.join(dir, '$name${exts.first}');
    }
    return path.join(dir, name);
  }

  /// Verify that a file exists and is executable.
  String? _verifyExecutable(String filePath) {
    if (!File(filePath).existsSync()) {
      return null;
    }

    if (Platform.isWindows) {
      // On Windows, check if the file has an executable extension
      final ext = path.extension(filePath).toLowerCase();
      final exts =
          _env['PATHEXT']?.toLowerCase().split(';') ?? ['.exe', '.bat', '.cmd'];
      return exts.contains(ext) ? filePath : null;
    }

    // On Unix-like systems, check if the file is executable
    try {
      final stat = File(filePath).statSync();
      final isExecutable = stat.mode & 0x49 != 0; // Check for executable bit
      return isExecutable ? filePath : null;
    } catch (_) {
      return null;
    }
  }

  /// Get the default search path.
  List<String> getDefaultPath() {
    if (Platform.isWindows) {
      return [
        r'C:\Windows\system32',
        r'C:\Windows',
        r'C:\Windows\System32\Wbem',
        r'C:\Windows\System32\WindowsPowerShell\v1.0',
      ];
    }

    return [
      '/usr/local/bin',
      '/usr/bin',
      '/bin',
      '/usr/sbin',
      '/sbin',
    ];
  }

  /// Find an executable with a specific version requirement.
  String? findWithVersion(String name, String version) {
    final executables = findAll(name);
    if (executables.isEmpty) {
      return null;
    }

    for (final executable in executables) {
      try {
        final result = Process.runSync(executable, ['--version']);
        if (result.exitCode == 0 &&
            result.stdout.toString().contains(version)) {
          return executable;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  /// Check if an executable exists.
  bool exists(String name) => find(name) != null;
}
