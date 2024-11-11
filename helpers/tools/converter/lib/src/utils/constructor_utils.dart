/// Utility functions for constructor generation
class ConstructorUtils {
  /// Generate constructor parameter declarations
  static String generateParameters(List<Map<String, dynamic>> properties) {
    final buffer = StringBuffer();
    for (final prop in properties) {
      final propName = prop['name'] as String;
      final propType = prop['type'] as String;
      final hasDefault = prop['has_default'] == true;

      if (hasDefault) {
        buffer.writeln('    $propType? $propName,');
      } else {
        buffer.writeln('    required $propType $propName,');
      }
    }
    return buffer.toString();
  }

  /// Generate constructor initialization statements
  static String generateInitializers(List<Map<String, dynamic>> properties) {
    final buffer = StringBuffer();
    for (final prop in properties) {
      final propName = prop['name'] as String;
      final hasDefault = prop['has_default'] == true;
      if (hasDefault) {
        buffer.writeln(
            '    _$propName = $propName ?? false;'); // TODO: Better default values
      } else {
        buffer.writeln('    _$propName = $propName;');
      }
    }
    return buffer.toString();
  }

  /// Check if a method is a constructor (__init__)
  static bool isConstructor(Map<String, dynamic> method) {
    return method['name'] == '__init__';
  }
}
