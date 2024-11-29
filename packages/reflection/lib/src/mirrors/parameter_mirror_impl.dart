import 'dart:core';
import '../mirrors.dart';
import 'base_mirror.dart';
import 'type_mirror_impl.dart';

/// Implementation of [ParameterMirror] that provides reflection on parameters.
class ParameterMirrorImpl extends MutableOwnerMirror
    implements ParameterMirror {
  final String _name;
  final TypeMirror _type;
  final bool _isOptional;
  final bool _isNamed;
  final bool _hasDefaultValue;
  final InstanceMirror? _defaultValue;
  final bool _isFinal;
  final bool _isConst;
  final List<InstanceMirror> _metadata;

  ParameterMirrorImpl({
    required String name,
    required TypeMirror type,
    required DeclarationMirror owner,
    bool isOptional = false,
    bool isNamed = false,
    bool hasDefaultValue = false,
    InstanceMirror? defaultValue,
    bool isFinal = false,
    bool isConst = false,
    List<InstanceMirror> metadata = const [],
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
  TypeMirror get type => _type;

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
  InstanceMirror? get defaultValue => _defaultValue;

  @override
  List<InstanceMirror> get metadata => List.unmodifiable(_metadata);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ParameterMirrorImpl) return false;

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
