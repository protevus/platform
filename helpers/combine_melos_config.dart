import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:args/args.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('input',
        abbr: 'i', defaultsTo: '.melos', help: 'Input directory for YAML files')
    ..addOption('output',
        abbr: 'o', defaultsTo: 'melos.yaml', help: 'Output file path');

  final results = parser.parse(arguments);
  final inputDir = results['input'];
  final outputFile = results['output'];

  try {
    final baseContent = File('$inputDir/base.yaml').readAsStringSync();

    final scriptFiles = Directory(inputDir)
        .listSync()
        .where((file) =>
            file.path.endsWith('.yaml') && !file.path.endsWith('base.yaml'))
        .map((file) => file.path.split('/').last)
        .toList();

    final combinedScripts = {};

    for (final file in scriptFiles) {
      print('Processing $file');
      final content = File('$inputDir/$file').readAsStringSync();
      final yaml = loadYaml(content);
      if (yaml == null ||
          yaml['scripts'] == null ||
          yaml['scripts']['_'] == null) {
        print(
            'Warning: $file does not contain expected script structure. Skipping.');
        continue;
      }
      combinedScripts.addAll(yaml['scripts']['_']);
    }

    final outputYamlEditor = YamlEditor(baseContent);
    outputYamlEditor.update(['scripts'], combinedScripts);

    File(outputFile).writeAsStringSync(outputYamlEditor.toString());
    print('Combined Melos configuration written to $outputFile');
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
