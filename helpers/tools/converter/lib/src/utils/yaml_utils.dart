import 'package:yaml/yaml.dart';

/// Utility class for handling YAML conversions
class YamlUtils {
  /// Convert YamlMap to regular Map recursively
  static Map<String, dynamic> convertYamlToMap(YamlMap yamlMap) {
    return Map<String, dynamic>.fromEntries(
      yamlMap.entries.map((entry) {
        if (entry.value is YamlMap) {
          return MapEntry(
            entry.key.toString(),
            convertYamlToMap(entry.value as YamlMap),
          );
        } else if (entry.value is YamlList) {
          return MapEntry(
            entry.key.toString(),
            convertYamlList(entry.value as YamlList),
          );
        }
        return MapEntry(entry.key.toString(), entry.value);
      }),
    );
  }

  /// Convert YamlList to regular List recursively
  static List<dynamic> convertYamlList(YamlList yamlList) {
    return yamlList.map((item) {
      if (item is YamlMap) {
        return convertYamlToMap(item);
      } else if (item is YamlList) {
        return convertYamlList(item);
      }
      return item;
    }).toList();
  }
}
