import 'dart:core';
import 'dart:isolate' as isolate;
import 'package:illuminate_contracts/contracts.dart';

/// Implementation of [IsolateMirrorContract] that provides reflection on isolates.
class IsolateMirror implements IsolateMirrorContract {
  final String _debugName;
  final bool _isCurrent;
  final LibraryMirrorContract _rootLibrary;
  final isolate.Isolate? _underlyingIsolate;

  IsolateMirror({
    required String debugName,
    required bool isCurrent,
    required LibraryMirrorContract rootLibrary,
    isolate.Isolate? underlyingIsolate,
  })  : _debugName = debugName,
        _isCurrent = isCurrent,
        _rootLibrary = rootLibrary,
        _underlyingIsolate = underlyingIsolate;

  /// Creates a mirror for the current isolate.
  factory IsolateMirror.current(LibraryMirrorContract rootLibrary) {
    return IsolateMirror(
      debugName: 'main',
      isCurrent: true,
      rootLibrary: rootLibrary,
      underlyingIsolate: null,
    );
  }

  /// Creates a mirror for another isolate.
  factory IsolateMirror.other(
    isolate.Isolate underlyingIsolate,
    String debugName,
    LibraryMirrorContract rootLibrary,
  ) {
    return IsolateMirror(
      debugName: debugName,
      isCurrent: false,
      rootLibrary: rootLibrary,
      underlyingIsolate: underlyingIsolate,
    );
  }

  @override
  String get debugName => _debugName;

  @override
  bool get isCurrent => _isCurrent;

  @override
  LibraryMirrorContract get rootLibrary => _rootLibrary;

  /// The underlying isolate, if this mirror reflects a non-current isolate.
  isolate.Isolate? get underlyingIsolate => _underlyingIsolate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IsolateMirror) return false;

    // Only compare debug name and isCurrent flag
    // Two mirrors pointing to the same isolate should be equal
    return _debugName == other._debugName && _isCurrent == other._isCurrent;
  }

  @override
  int get hashCode {
    // Hash code should be consistent with equals
    return Object.hash(_debugName, _isCurrent);
  }

  @override
  String toString() {
    final buffer = StringBuffer('IsolateMirror');
    if (_debugName.isNotEmpty) {
      buffer.write(' "$_debugName"');
    }
    if (_isCurrent) {
      buffer.write(' (current)');
    }
    return buffer.toString();
  }

  /// Kills the isolate if this mirror reflects a non-current isolate.
  Future<void> kill() async {
    if (!_isCurrent && _underlyingIsolate != null) {
      _underlyingIsolate!.kill();
    }
  }

  /// Pauses the isolate if this mirror reflects a non-current isolate.
  Future<void> pause() async {
    if (!_isCurrent && _underlyingIsolate != null) {
      _underlyingIsolate!.pause();
    }
  }

  /// Resumes the isolate if this mirror reflects a non-current isolate.
  Future<void> resume() async {
    if (!_isCurrent && _underlyingIsolate != null) {
      _underlyingIsolate!.resume(_underlyingIsolate!.pauseCapability!);
    }
  }

  /// Adds an error listener to the isolate if this mirror reflects a non-current isolate.
  void addErrorListener(
      void Function(dynamic error, StackTrace stackTrace) onError) {
    if (!_isCurrent && _underlyingIsolate != null) {
      _underlyingIsolate!
          .addErrorListener(isolate.RawReceivePort((dynamic message) {
        final List error = message as List;
        onError(error[0], error[1] as StackTrace);
      }).sendPort);
    }
  }

  /// Adds an exit listener to the isolate if this mirror reflects a non-current isolate.
  void addExitListener(void Function(dynamic message) onExit) {
    if (!_isCurrent && _underlyingIsolate != null) {
      _underlyingIsolate!
          .addOnExitListener(isolate.RawReceivePort((dynamic message) {
        onExit(message);
      }).sendPort);
    }
  }
}
