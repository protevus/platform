import 'package:illuminate_contracts/contracts.dart';

/// Implementation of [LibraryDependencyMirrorContract] that provides reflection on library dependencies.
class LibraryDependencyMirror implements LibraryDependencyMirrorContract {
  final bool _isImport;
  final bool _isDeferred;
  final LibraryMirrorContract _sourceLibrary;
  final LibraryMirrorContract? _targetLibrary;
  final Symbol? _prefix;
  final List<CombinatorMirrorContract> _combinators;

  LibraryDependencyMirror({
    required bool isImport,
    required bool isDeferred,
    required LibraryMirrorContract sourceLibrary,
    LibraryMirrorContract? targetLibrary,
    Symbol? prefix,
    List<CombinatorMirrorContract> combinators = const [],
  })  : _isImport = isImport,
        _isDeferred = isDeferred,
        _sourceLibrary = sourceLibrary,
        _targetLibrary = targetLibrary,
        _prefix = prefix,
        _combinators = combinators;

  @override
  bool get isImport => _isImport;

  @override
  bool get isExport => !_isImport;

  @override
  bool get isDeferred => _isDeferred;

  @override
  LibraryMirrorContract get sourceLibrary => _sourceLibrary;

  @override
  LibraryMirrorContract? get targetLibrary => _targetLibrary;

  @override
  Symbol? get prefix => _prefix;

  @override
  List<CombinatorMirrorContract> get combinators =>
      List.unmodifiable(_combinators);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LibraryDependencyMirror) return false;

    return _isImport == other._isImport &&
        _isDeferred == other._isDeferred &&
        _sourceLibrary == other._sourceLibrary &&
        _targetLibrary == other._targetLibrary &&
        _prefix == other._prefix &&
        _combinators == other._combinators;
  }

  @override
  int get hashCode {
    return Object.hash(
      _isImport,
      _isDeferred,
      _sourceLibrary,
      _targetLibrary,
      _prefix,
      Object.hashAll(_combinators),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(_isImport ? 'import' : 'export');
    if (_isDeferred) buffer.write(' deferred');
    if (_prefix != null) buffer.write(' as $_prefix');
    if (_combinators.isNotEmpty) {
      buffer.write(' with ');
      buffer.write(_combinators.join(' '));
    }
    return buffer.toString();
  }
}
