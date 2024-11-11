import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:converter/src/extractors/base_extractor.dart';
import 'package:converter/src/extractors/php_extractor.dart';

/// Factory for creating language-specific extractors
class ExtractorFactory {
  /// Create an appropriate extractor based on file extension
  static LanguageExtractor? createExtractor(String extension) {
    switch (extension.toLowerCase()) {
      case '.php':
        return PhpExtractor();
      // TODO: Add more extractors as they're implemented
      // case '.py':
      //   return PythonExtractor();
      // case '.ts':
      // case '.js':
      //   return TypeScriptExtractor();
      // case '.java':
      //   return JavaExtractor();
      default:
        return null;
    }
  }
}

/// Main contract extractor CLI
class ContractExtractorCLI {
  final String sourcePath;
  final String outputPath;
  final bool verbose;

  ContractExtractorCLI({
    required this.sourcePath,
    required this.outputPath,
    this.verbose = false,
  });

  /// Run the extraction process
  Future<void> run() async {
    try {
      if (await FileSystemEntity.isDirectory(sourcePath)) {
        await _processDirectory(sourcePath);
      } else if (await FileSystemEntity.isFile(sourcePath)) {
        await _processFile(sourcePath);
      } else {
        throw Exception('Source path does not exist: $sourcePath');
      }
    } catch (e) {
      print('Error: $e');
      exit(1);
    }
  }

  /// Process a directory recursively
  Future<void> _processDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        await _processFile(entity.path);
      }
    }
  }

  /// Process a single file
  Future<void> _processFile(String filePath) async {
    final extension = path.extension(filePath);
    final extractor = ExtractorFactory.createExtractor(extension);

    if (extractor == null) {
      if (verbose) {
        print('Skipping unsupported file type: $filePath');
      }
      return;
    }

    try {
      // Calculate relative path to maintain directory structure
      final relativePath = path.relative(filePath, from: sourcePath);
      final destDir = path.join(outputPath, path.dirname(relativePath));

      // Create destination directory
      await Directory(destDir).create(recursive: true);

      // Extract contract
      final contract = await extractor.parseFile(filePath);
      final yamlContent = extractor.convertToYaml(contract);

      // Write YAML contract
      final yamlFile = File(path.join(
        destDir,
        '${path.basenameWithoutExtension(filePath)}.yaml',
      ));
      await yamlFile.writeAsString(yamlContent);

      if (verbose) {
        print('Processed: $filePath');
      }
    } catch (e) {
      print('Error processing $filePath: $e');
    }
  }
}

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'source',
      abbr: 's',
      help: 'Source file or directory path',
      mandatory: true,
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output directory for YAML contracts',
      mandatory: true,
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose output',
      defaultsTo: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Usage: dart extract_contracts.dart [options]');
      print(parser.usage);
      exit(0);
    }

    final cli = ContractExtractorCLI(
      sourcePath: results['source'] as String,
      outputPath: results['output'] as String,
      verbose: results['verbose'] as bool,
    );

    await cli.run();
    print('Contract extraction completed successfully.');
  } catch (e) {
    print('Error: $e');
    print('\nUsage: dart extract_contracts.dart [options]');
    print(parser.usage);
    exit(1);
  }
}
