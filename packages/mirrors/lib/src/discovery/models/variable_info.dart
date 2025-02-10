/// Information about a top-level variable.
///
/// Contains metadata about a variable including:
/// - The variable's name
/// - Type
/// - Whether it's final, const, or private
class VariableInfo {
  /// The name of the variable
  final String name;

  /// The type of the variable
  final Type type;

  /// Whether this variable is final
  final bool isFinal;

  /// Whether this variable is const
  final bool isConst;

  /// Whether this variable is private
  final bool isPrivate;

  /// Creates a new [VariableInfo] instance.
  ///
  /// All parameters are required:
  /// - [name]: The variable's name
  /// - [type]: The variable's type
  /// - [isFinal]: Whether the variable is final
  /// - [isConst]: Whether the variable is const
  /// - [isPrivate]: Whether the variable is private
  const VariableInfo({
    required this.name,
    required this.type,
    required this.isFinal,
    required this.isConst,
    required this.isPrivate,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    if (isConst) buffer.write('const ');
    if (isFinal) buffer.write('final ');
    buffer.write('$type $name');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VariableInfo &&
        other.name == name &&
        other.type == type &&
        other.isFinal == isFinal &&
        other.isConst == isConst &&
        other.isPrivate == isPrivate;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      type,
      isFinal,
      isConst,
      isPrivate,
    );
  }
}
