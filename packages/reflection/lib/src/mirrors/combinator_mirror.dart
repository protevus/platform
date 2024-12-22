import 'package:platform_contracts/contracts.dart';

/// Implementation of [CombinatorMirrorContract] that provides reflection on show/hide combinators.
class CombinatorMirror implements CombinatorMirrorContract {
  final List<Symbol> _identifiers;
  final bool _isShow;

  CombinatorMirror({
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
    if (other is! CombinatorMirror) return false;

    return _identifiers == other._identifiers && _isShow == other._isShow;
  }

  @override
  int get hashCode => Object.hash(_identifiers, _isShow);

  @override
  String toString() {
    return '${_isShow ? 'show' : 'hide'} ${_identifiers.join(', ')}';
  }
}
