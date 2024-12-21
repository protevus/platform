import 'package:platform_contracts/contracts.dart';
import 'package:platform_reflection/mirrors.dart';

/// Implementation of [MethodMirrorContract] that provides reflection on methods.
class MethodMirror extends TypedMirror implements MethodMirrorContract {
  final TypeMirrorContract _returnType;
  final List<ParameterMirrorContract> _parameters;
  final bool _isStatic;
  final bool _isAbstract;
  final bool _isSynthetic;
  final bool _isConstructor;
  final Symbol _constructorName;
  final bool _isConstConstructor;
  final bool _isGenerativeConstructor;
  final bool _isRedirectingConstructor;
  final bool _isFactoryConstructor;
  final String? _source;

  MethodMirror({
    required String name,
    required DeclarationMirrorContract? owner,
    required TypeMirrorContract returnType,
    required List<ParameterMirrorContract> parameters,
    bool isStatic = false,
    bool isAbstract = false,
    bool isSynthetic = false,
    bool isConstructor = false,
    Symbol? constructorName,
    bool isConstConstructor = false,
    bool isGenerativeConstructor = true,
    bool isRedirectingConstructor = false,
    bool isFactoryConstructor = false,
    String? source,
    List<InstanceMirrorContract> metadata = const [],
  })  : _returnType = returnType,
        _parameters = parameters,
        _isStatic = isStatic,
        _isAbstract = isAbstract,
        _isSynthetic = isSynthetic,
        _isConstructor = isConstructor,
        _constructorName = constructorName ?? const Symbol(''),
        _isConstConstructor = isConstConstructor,
        _isGenerativeConstructor = isGenerativeConstructor,
        _isRedirectingConstructor = isRedirectingConstructor,
        _isFactoryConstructor = isFactoryConstructor,
        _source = source,
        super(
          type: Function,
          name: name,
          owner: owner,
          metadata: metadata,
        );

  @override
  TypeMirrorContract get returnType => _returnType;

  @override
  List<ParameterMirrorContract> get parameters =>
      List.unmodifiable(_parameters);

  @override
  bool get isStatic => _isStatic;

  @override
  bool get isAbstract => _isAbstract;

  @override
  bool get isSynthetic => _isSynthetic;

  @override
  bool get isRegularMethod =>
      !isConstructor && !isGetter && !isSetter && !isOperator;

  @override
  bool get isOperator => name.startsWith('operator ');

  @override
  bool get isGetter => name.startsWith('get ');

  @override
  bool get isSetter => name.startsWith('set ');

  @override
  bool get isConstructor => _isConstructor;

  @override
  Symbol get constructorName => _constructorName;

  @override
  bool get isConstConstructor => _isConstConstructor;

  @override
  bool get isGenerativeConstructor => _isGenerativeConstructor;

  @override
  bool get isRedirectingConstructor => _isRedirectingConstructor;

  @override
  bool get isFactoryConstructor => _isFactoryConstructor;

  @override
  String? get source => _source;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MethodMirror) return false;

    return name == other.name &&
        owner == other.owner &&
        returnType == other.returnType &&
        _parameters == other._parameters &&
        _isStatic == other._isStatic &&
        _isAbstract == other._isAbstract &&
        _isSynthetic == other._isSynthetic &&
        _isConstructor == other._isConstructor &&
        _constructorName == other._constructorName &&
        _isConstConstructor == other._isConstConstructor &&
        _isGenerativeConstructor == other._isGenerativeConstructor &&
        _isRedirectingConstructor == other._isRedirectingConstructor &&
        _isFactoryConstructor == other._isFactoryConstructor;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      owner,
      returnType,
      Object.hashAll(_parameters),
      _isStatic,
      _isAbstract,
      _isSynthetic,
      _isConstructor,
      _constructorName,
      _isConstConstructor,
      _isGenerativeConstructor,
      _isRedirectingConstructor,
      _isFactoryConstructor,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if (isStatic) buffer.write('static ');
    if (isAbstract) buffer.write('abstract ');
    if (isConstructor) {
      buffer.write('constructor ');
      if (_constructorName != const Symbol('')) {
        buffer.write('$_constructorName ');
      }
    }
    buffer.write('$name(');
    buffer.write(_parameters.join(', '));
    buffer.write(')');
    if (!isConstructor) {
      buffer.write(' -> ${returnType.name}');
    }
    return buffer.toString();
  }
}
