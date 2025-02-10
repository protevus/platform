import 'dbo_param_type.dart';

/// A class representing a parameter in a DBO statement.
class DBOParam {
  /// The name of the parameter (for named parameters)
  final String? name;

  /// The position of the parameter (for positional parameters)
  final int position;

  /// The value of the parameter
  dynamic value;

  /// The type of the parameter (PDOParamType.*)
  final int type;

  /// The maximum length of the parameter value
  final int? length;

  /// Driver-specific options for this parameter
  final dynamic driverOptions;

  /// Creates a new PDOParam instance.
  DBOParam({
    this.name,
    required this.position,
    this.value,
    required this.type,
    this.length,
    this.driverOptions,
  });

  /// Gets the value of the parameter converted to the appropriate type.
  dynamic getTypedValue() {
    if (value == null) {
      return null;
    }

    switch (type) {
      case DBOParamType.BOOL:
        if (value is bool) {
          return value;
        }
        if (value is num) {
          return value != 0;
        }
        if (value is String) {
          final lower = value.toLowerCase();
          final trimmed = lower.trim();
          return trimmed == 'true' || trimmed == 'yes' || trimmed == '1';
        }
        // Already checked for null at the start of the method
        try {
          String strValue;
          try {
            strValue = value.toString();
          } catch (_) {
            return false;
          }
          final lower = strValue.toLowerCase();
          final trimmed = lower.trim();
          return trimmed == 'true' || trimmed == 'yes' || trimmed == '1';
        } catch (_) {
          return false;
        }

      case DBOParamType.INT:
        if (value is int) {
          return value;
        }
        if (value is num) {
          return value.toInt();
        }
        if (value is String) {
          return int.tryParse(value) ?? 0;
        }
        if (value is bool) {
          return value ? 1 : 0;
        }

      case DBOParamType.STR:
        if (value is String) {
          return value;
        }
        try {
          String strValue;
          try {
            strValue = value.toString();
          } catch (_) {
            return '';
          }
          return strValue;
        } catch (_) {
          return '';
        }

      case DBOParamType.LOB:
        // Pass through LOB data without conversion
        return value;

      case DBOParamType.NULL:
        return null;

      default:
        // For unknown types, try to convert to string or return null
        try {
          String strValue;
          try {
            strValue = value.toString();
          } catch (_) {
            return null;
          }
          return strValue;
        } catch (_) {
          return null;
        }
    }
  }

  /// Creates a copy of this parameter with optionally modified values.
  DBOParam copyWith({
    String? name,
    int? position,
    dynamic value,
    int? type,
    int? length,
    dynamic driverOptions,
  }) {
    return DBOParam(
      name: name ?? this.name,
      position: position ?? this.position,
      value: value ?? this.value,
      type: type ?? this.type,
      length: length ?? this.length,
      driverOptions: driverOptions ?? this.driverOptions,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('PDOParam(');
    if (name != null) {
      buffer.write('name: $name, ');
    }
    buffer.write('position: $position, ');
    buffer.write('value: ${_safeToString(value)}, ');
    buffer.write('type: $type');
    if (length != null) {
      buffer.write(', length: $length');
    }
    if (driverOptions != null) {
      buffer.write(', driverOptions: ${_safeToString(driverOptions)}');
    }
    buffer.write(')');
    return buffer.toString();
  }

  /// Safely converts a value to string
  String _safeToString(dynamic val) {
    String result;
    try {
      if (val == null) {
        result = 'null';
      } else if (val is String) {
        result = "'$val'";
      } else if (val is num || val is bool) {
        result = val.toString();
      } else if (val is List) {
        result = '[...]';
      } else if (val is Map) {
        result = '{...}';
      } else {
        result = val.toString();
      }
    } catch (_) {
      result = '<unprintable>';
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DBOParam &&
        other.name == name &&
        other.position == position &&
        other.value == value &&
        other.type == type &&
        other.length == length &&
        other.driverOptions == driverOptions;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      position,
      value,
      type,
      length,
      driverOptions,
    );
  }
}
