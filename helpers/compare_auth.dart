import 'dart:io';
import 'dart:convert';

class PackageComparison {
  final String name;
  final String laravelPath;
  final String dartPath;

  PackageComparison(this.name, this.laravelPath, this.dartPath);
}

class Config {
  final String laravelPath;
  final String dartPath;

  Config(this.laravelPath, this.dartPath);

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      json['laravel_path'] as String,
      json['dart_path'] as String,
    );
  }

  factory Config.fromFile(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        throw 'Config file not found: $path';
      }
      final jsonContent = file.readAsStringSync();
      final json = jsonDecode(jsonContent) as Map<String, dynamic>;
      return Config.fromJson(json);
    } catch (e) {
      throw 'Error reading config file: $e';
    }
  }
}

Future<List<PackageComparison>> findMatchingPackages(
    String laravelRoot, String dartRoot) async {
  final List<PackageComparison> matches = [];
  final dartDir = Directory(dartRoot);

  if (!await dartDir.exists()) {
    print('Error: Dart packages directory not found: $dartRoot');
    exit(1);
  }

  // Get list of package names from dart project directory
  await for (final dartPackage in dartDir.list()) {
    if (dartPackage is Directory) {
      final packageName = dartPackage.path.split('/').last;
      final laravelPackagePath =
          '$laravelRoot/src/Illuminate/${packageName.capitalize()}';

      // Check if corresponding Laravel package exists
      if (await Directory(laravelPackagePath).exists()) {
        matches.add(PackageComparison(
          packageName,
          laravelPackagePath,
          '${dartPackage.path}/lib',
        ));
      }
    }
  }

  return matches;
}

void printUsage() {
  print('Usage: dart compare_auth.dart [options] [package_name]');
  print('Options:');
  print('  --laravel-path <path>    Laravel framework path (overrides config)');
  print('  --dart-path <path>       Dart packages path (overrides config)');
  print(
      '  --config <path>          Config file path (default: scripts/config/compare.json)');
  print('  --help                   Show this help message');
  print('\nExample:');
  print('  dart compare_auth.dart auth');
  print(
      '  dart compare_auth.dart --laravel-path /path/to/laravel --dart-path /path/to/dart auth');
}

Future<void> main(List<String> args) async {
  // Default config file path
  String configPath = 'scripts/config/compare.json';
  String? laravelPath;
  String? dartPath;
  String? targetPackage;

  // Parse command line arguments
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--help':
        printUsage();
        exit(0);
      case '--config':
        if (i + 1 < args.length) {
          configPath = args[++i];
        }
        break;
      case '--laravel-path':
        if (i + 1 < args.length) {
          laravelPath = args[++i];
        }
        break;
      case '--dart-path':
        if (i + 1 < args.length) {
          dartPath = args[++i];
        }
        break;
      default:
        if (!args[i].startsWith('--')) {
          targetPackage = args[i].toLowerCase();
        }
    }
  }

  try {
    // Load config file
    final config = Config.fromFile(configPath);

    // CLI arguments override config values
    final finalLaravelPath = laravelPath ?? config.laravelPath;
    final finalDartPath = dartPath ?? config.dartPath;

    // Find all matching packages between Laravel and Dart implementations
    final packages =
        await findMatchingPackages(finalLaravelPath, finalDartPath);

    if (packages.isEmpty) {
      print(
          'No matching packages found between Laravel and Dart implementations.');
      exit(1);
    }

    if (targetPackage != null) {
      // Process specific package
      final package = packages.firstWhere(
        (p) => p.name.toLowerCase() == targetPackage,
        orElse: () =>
            throw 'Package "$targetPackage" not found.\nAvailable packages: ${packages.map((p) => p.name).join(", ")}',
      );
      await processPackage(package);
    } else {
      // Process all matching packages
      for (final package in packages) {
        print('\n========== Processing package: ${package.name} ==========\n');
        await processPackage(package);
      }
    }
  } catch (e) {
    print('Error: $e');
    print('\nFor help, run: dart compare_auth.dart --help');
    exit(1);
  }
}

Future<void> processPackage(PackageComparison package) async {
  print('\n=== Laravel ${package.name} Implementation ===\n');
  await dumpDirectory(package.laravelPath);

  print('\n=== Dart ${package.name} Implementation ===\n');
  await dumpDirectory(package.dartPath);
}

Future<void> dumpDirectory(String path) async {
  final dir = Directory(path);
  if (!await dir.exists()) {
    print('Directory not found: $path');
    return;
  }

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File) {
      final ext = entity.path.split('.').last.toLowerCase();
      if (['php', 'dart'].contains(ext)) {
        print('\n--- ${entity.path} ---\n');
        final contents = await entity.readAsString();
        print(contents);
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
