/// Utility functions for type casting
class TypeUtils {
  /// Cast a List<dynamic> to List<Map<String, dynamic>>
  static List<Map<String, dynamic>> castToMapList(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((item) => item as Map<String, dynamic>).toList();
  }

  /// Cast a dynamic value to Map<String, dynamic>
  static Map<String, dynamic> castToMap(dynamic value) {
    if (value == null) return {};
    return value as Map<String, dynamic>;
  }

  /// Cast a List<dynamic> to List<String>
  static List<String> castToStringList(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((item) => item.toString()).toList();
  }
}
