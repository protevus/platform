import 'package:meta/meta.dart';
import '../mirrors.dart';

/// Base class for mirrors that have an owner.
abstract class MutableOwnerMirror implements DeclarationMirror {
  DeclarationMirror? _owner;

  /// Sets the owner of this mirror.
  @protected
  void setOwner(DeclarationMirror? owner) {
    _owner = owner;
  }

  @override
  DeclarationMirror? get owner => _owner;
}

/// Base class for mirrors that have a type.
abstract class TypedMirror extends MutableOwnerMirror {
  final Type _type;
  final String _name;
  final List<InstanceMirror> _metadata;

  TypedMirror({
    required Type type,
    required String name,
    DeclarationMirror? owner,
    List<InstanceMirror> metadata = const [],
  })  : _type = type,
        _name = name,
        _metadata = metadata {
    setOwner(owner);
  }

  /// The type this mirror reflects.
  Type get type => _type;

  @override
  String get name => _name;

  @override
  Symbol get simpleName => Symbol(_name);

  @override
  Symbol get qualifiedName {
    if (owner == null) return simpleName;
    return Symbol('${owner!.qualifiedName}.${_name}');
  }

  @override
  bool get isPrivate => _name.startsWith('_');

  @override
  bool get isTopLevel => owner == null;

  @override
  List<InstanceMirror> get metadata => List.unmodifiable(_metadata);
}
