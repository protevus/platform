import '../mirrors.dart';
import '../metadata.dart';
import 'base_mirror.dart';
import 'type_mirror_impl.dart';

/// Implementation of [TypeVariableMirror] that provides reflection on type variables.
class TypeVariableMirrorImpl extends TypedMirror implements TypeVariableMirror {
  final TypeMirror _upperBound;

  TypeVariableMirrorImpl({
    required Type type,
    required String name,
    required TypeMirror upperBound,
    DeclarationMirror? owner,
    List<InstanceMirror> metadata = const [],
  })  : _upperBound = upperBound,
        super(
          type: type,
          name: name,
          owner: owner,
          metadata: metadata,
        );

  @override
  TypeMirror get upperBound => _upperBound;

  @override
  bool get hasReflectedType => true;

  @override
  Type get reflectedType => type;

  @override
  List<TypeVariableMirror> get typeVariables => const [];

  @override
  List<TypeMirror> get typeArguments => const [];

  @override
  bool get isOriginalDeclaration => true;

  @override
  TypeMirror get originalDeclaration => this;

  @override
  bool isSubtypeOf(TypeMirror other) {
    if (identical(this, other)) return true;
    return _upperBound.isSubtypeOf(other);
  }

  @override
  bool isAssignableTo(TypeMirror other) {
    if (identical(this, other)) return true;
    return _upperBound.isAssignableTo(other);
  }

  @override
  Map<String, PropertyMetadata> get properties => const {};

  @override
  Map<String, MethodMetadata> get methods => const {};

  @override
  List<ConstructorMetadata> get constructors => const [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TypeVariableMirrorImpl) return false;

    return type == other.type &&
        name == other.name &&
        owner == other.owner &&
        _upperBound == other._upperBound;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      name,
      owner,
      _upperBound,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer(name);
    if (_upperBound.name != 'Object') {
      buffer.write(' extends ${_upperBound.name}');
    }
    return buffer.toString();
  }
}
