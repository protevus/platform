import 'package:platform_contracts/contracts.dart'
    hide PropertyMetadata, MethodMetadata, ConstructorMetadata;
import 'package:platform_reflection/mirrors.dart';

/// Implementation of [TypeVariableMirrorContract] that provides reflection on type variables.
class TypeVariableMirror extends TypedMirror
    implements TypeVariableMirrorContract {
  final TypeMirrorContract _upperBound;

  TypeVariableMirror({
    required Type type,
    required String name,
    required TypeMirrorContract upperBound,
    DeclarationMirrorContract? owner,
    List<InstanceMirrorContract> metadata = const [],
  })  : _upperBound = upperBound,
        super(
          type: type,
          name: name,
          owner: owner,
          metadata: metadata,
        );

  @override
  TypeMirrorContract get upperBound => _upperBound;

  @override
  bool get hasReflectedType => true;

  @override
  Type get reflectedType => type;

  @override
  List<TypeVariableMirrorContract> get typeVariables => const [];

  @override
  List<TypeMirrorContract> get typeArguments => const [];

  @override
  bool get isOriginalDeclaration => true;

  @override
  TypeMirrorContract get originalDeclaration => this;

  @override
  bool isSubtypeOf(TypeMirrorContract other) {
    if (identical(this, other)) return true;
    return _upperBound.isSubtypeOf(other);
  }

  @override
  bool isAssignableTo(TypeMirrorContract other) {
    if (identical(this, other)) return true;
    return _upperBound.isAssignableTo(other);
  }

  Map<String, PropertyMetadata> get properties => const {};

  Map<String, MethodMetadata> get methods => const {};

  List<ConstructorMetadata> get constructors => const [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TypeVariableMirror) return false;

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
