/// Utility functions for name conversions
class NameUtils {
  /// Convert Python method/property name to Dart style
  static String toDartName(String pythonName) {
    // Handle special Python method names
    if (pythonName.startsWith('__') && pythonName.endsWith('__')) {
      final name = pythonName.substring(2, pythonName.length - 2);
      if (name == 'init') return 'new';
      return name;
    }

    // Convert snake_case to camelCase
    final parts = pythonName.split('_');
    if (parts.isEmpty) return pythonName;

    return parts.first +
        parts
            .skip(1)
            .where((p) => p.isNotEmpty)
            .map((p) => p[0].toUpperCase() + p.substring(1))
            .join('');
  }
}
