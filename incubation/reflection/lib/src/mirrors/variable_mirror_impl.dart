import 'dart:core';
import '../mirrors.dart';
import 'base_mirror.dart';
import 'type_mirror_impl.dart';

/// Implementation of [VariableMirror] that provides reflection on variables.
class VariableMirrorImpl extends MutableOwnerMirror implements VariableMirror {
  final TypeMirror _type;
  final String _name;
  final bool _isStatic;
  final bool _isFinal;
  final bool _isConst;
  final List<InstanceMirror> _metadata;

  VariableMirrorImpl({
    required String name,
    required TypeMirror type,
    DeclarationMirror? owner,
    bool isStatic = false,
    bool isFinal = false,
    bool isConst = false,
    List<InstanceMirror> metadata = const [],
  })  : _name = name,
        _type = type,
        _isStatic = isStatic,
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
  bool get isTopLevel => owner is LibraryMirror;

  @override
  TypeMirror get type => _type;

  @override
  bool get isStatic => _isStatic;

  @override
  bool get isFinal => _isFinal;

  @override
  bool get isConst => _isConst;

  @override
  List<InstanceMirror> get metadata => List.unmodifiable(_metadata);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VariableMirrorImpl) return false;

    return _name == other._name &&
        _type == other._type &&
        owner == other.owner &&
        _isStatic == other._isStatic &&
        _isFinal == other._isFinal &&
        _isConst == other._isConst;
  }

  @override
  int get hashCode {
    return Object.hash(
      _name,
      _type,
      owner,
      _isStatic,
      _isFinal,
      _isConst,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if (_isStatic) buffer.write('static ');
    if (_isConst) buffer.write('const ');
    if (_isFinal) buffer.write('final ');
    buffer.write('$_type $_name');
    return buffer.toString();
  }
}

/// Implementation of [VariableMirror] specifically for fields.
class FieldMirrorImpl extends VariableMirrorImpl {
  final bool _isReadable;
  final bool _isWritable;

  FieldMirrorImpl({
    required String name,
    required TypeMirror type,
    DeclarationMirror? owner,
    bool isStatic = false,
    bool isFinal = false,
    bool isConst = false,
    bool isReadable = true,
    bool isWritable = true,
    List<InstanceMirror> metadata = const [],
  })  : _isReadable = isReadable,
        _isWritable = isWritable,
        super(
          name: name,
          type: type,
          owner: owner,
          isStatic: isStatic,
          isFinal: isFinal,
          isConst: isConst,
          metadata: metadata,
        );

  /// Whether this field can be read.
  bool get isReadable => _isReadable;

  /// Whether this field can be written to.
  bool get isWritable => _isWritable && !isFinal && !isConst;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FieldMirrorImpl) return false;
    if (!(super == other)) return false;

    return _isReadable == other._isReadable && _isWritable == other._isWritable;
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      _isReadable,
      _isWritable,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if (isStatic) buffer.write('static ');
    if (isConst) buffer.write('const ');
    if (isFinal) buffer.write('final ');
    buffer.write('$type $_name');
    if (!isReadable) buffer.write(' (write-only)');
    if (!isWritable) buffer.write(' (read-only)');
    return buffer.toString();
  }
}
