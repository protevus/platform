import '../mirrors.dart';

/// Implementation of [CombinatorMirror] that provides reflection on show/hide combinators.
class CombinatorMirrorImpl implements CombinatorMirror {
  final List<Symbol> _identifiers;
  final bool _isShow;

  CombinatorMirrorImpl({
    required List<Symbol> identifiers,
    required bool isShow,
  })  : _identifiers = identifiers,
        _isShow = isShow;

  @override
  List<Symbol> get identifiers => List.unmodifiable(_identifiers);

  @override
  bool get isShow => _isShow;

  @override
  bool get isHide => !_isShow;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CombinatorMirrorImpl) return false;

    return _identifiers == other._identifiers && _isShow == other._isShow;
  }

  @override
  int get hashCode => Object.hash(_identifiers, _isShow);

  @override
  String toString() {
    return '${_isShow ? 'show' : 'hide'} ${_identifiers.join(', ')}';
  }
}
