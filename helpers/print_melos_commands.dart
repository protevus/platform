import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  final file = File('melos.yaml');
  final yamlString = file.readAsStringSync();
  final yamlMap = loadYaml(yamlString);

  final scripts = yamlMap['scripts'] as YamlMap;

  print('Available Melos commands:');
  print('========================\n');

  scripts.forEach((key, value) {
    final description =
        value['description'] as String? ?? 'No description provided';
    print('${key.padRight(20)} $description');
  });

  print('\nUsage: melos run <command>');
  print(
      'For more details on a specific command, use: melos run <command> --help');
}
