/// Represents metadata about a column in a PDO result set.
class PDOColumn {
  /// Creates a new PDO column metadata object.
  ///
  /// [name] and [position] are required.
  /// Optional [length], [precision], [type], and [flags] provide additional metadata.
  const PDOColumn({
    required this.name,
    required this.position,
    this.length,
    this.precision,
    this.type,
    this.flags,
  });

  /// The name of the column
  final String name;

  /// The position of the column in the result set (0-based)
  final int position;

  /// The maximum length of the column, if applicable
  final int? length;

  /// The numeric precision of the column, if applicable
  final int? precision;

  /// The native database type of the column
  final String? type;

  /// Additional flags describing the column
  final List<String>? flags;

  /// Creates a copy of this column with optionally modified values.
  PDOColumn copyWith({
    String? name,
    int? position,
    int? length,
    int? precision,
    String? type,
    List<String>? flags,
  }) =>
      PDOColumn(
        name: name ?? this.name,
        position: position ?? this.position,
        length: length ?? this.length,
        precision: precision ?? this.precision,
        type: type ?? this.type,
        flags: flags ?? this.flags,
      );

  @override
  String toString() =>
      'PDOColumn{name: $name, position: $position, type: $type, length: $length, precision: $precision, flags: $flags}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PDOColumn &&
        other.name == name &&
        other.position == position &&
        other.length == length &&
        other.precision == precision &&
        other.type == type &&
        _listEquals(other.flags, flags);
  }

  @override
  int get hashCode => Object.hash(
        name,
        position,
        length,
        precision,
        type,
        flags == null ? null : Object.hashAll(flags!),
      );

  /// Helper method to compare two lists for equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return a == b;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
