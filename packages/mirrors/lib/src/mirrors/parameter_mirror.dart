import 'dart:core';
import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_mirrors/mirrors.dart';

/// Implementation of [ParameterMirrorContract] that provides reflection on parameters.
class ParameterMirror extends MutableOwnerMirror
    implements ParameterMirrorContract {
  final String _name;
  final TypeMirrorContract _type;
  final bool _isOptional;
  final bool _isNamed;
  final bool _hasDefaultValue;
  final InstanceMirrorContract? _defaultValue;
  final bool _isFinal;
  final bool _isConst;
  final List<InstanceMirrorContract> _metadata;

  ParameterMirror({
    required String name,
    required TypeMirrorContract type,
    required DeclarationMirrorContract owner,
    bool isOptional = false,
    bool isNamed = false,
    bool hasDefaultValue = false,
    InstanceMirrorContract? defaultValue,
    bool isFinal = false,
    bool isConst = false,
    List<InstanceMirrorContract> metadata = const [],
  })  : _name = name,
        _type = type,
        _isOptional = isOptional,
        _isNamed = isNamed,
        _hasDefaultValue = hasDefaultValue,
        _defaultValue = defaultValue,
        _isFinal = isFinal,
        _isConst = isConst,
        _metadata = metadata {
    setOwner(owner);
  }

  @override
  String get name => _name;

  @override
  Symbol get simpleName => Symbol(_name);

  @override
  Symbol get qualifiedName {
    if (owner == null) return simpleName;
    return Symbol('${owner!.qualifiedName}.$_name');
  }

  @override
  bool get isPrivate => _name.startsWith('_');

  @override
  bool get isTopLevel => false;

  @override
  TypeMirrorContract get type => _type;

  @override
  bool get isStatic => false;

  @override
  bool get isFinal => _isFinal;

  @override
  bool get isConst => _isConst;

  @override
  bool get isOptional => _isOptional;

  @override
  bool get isNamed => _isNamed;

  @override
  bool get hasDefaultValue => _hasDefaultValue;

  @override
  InstanceMirrorContract? get defaultValue => _defaultValue;

  @override
  List<InstanceMirrorContract> get metadata => List.unmodifiable(_metadata);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ParameterMirror) return false;

    return _name == other._name &&
        _type == other._type &&
        owner == other.owner &&
        _isOptional == other._isOptional &&
        _isNamed == other._isNamed &&
        _hasDefaultValue == other._hasDefaultValue &&
        _defaultValue == other._defaultValue &&
        _isFinal == other._isFinal &&
        _isConst == other._isConst;
  }

  @override
  int get hashCode {
    return Object.hash(
      _name,
      _type,
      owner,
      _isOptional,
      _isNamed,
      _hasDefaultValue,
      _defaultValue,
      _isFinal,
      _isConst,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if (isNamed) buffer.write('{');
    if (isOptional && !isNamed) buffer.write('[');

    buffer.write('$_type $_name');

    if (hasDefaultValue) {
      buffer.write(' = $_defaultValue');
    }

    if (isNamed) buffer.write('}');
    if (isOptional && !isNamed) buffer.write(']');

    return buffer.toString();
  }
}
