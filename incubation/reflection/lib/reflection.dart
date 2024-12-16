/// A lightweight, cross-platform reflection system for Dart.
library reflection;

// Core functionality
export 'src/core/reflector.dart';
export 'src/core/scanner.dart';
export 'src/core/runtime_reflector.dart';

// Mirror API
export 'src/mirrors.dart';
export 'src/mirrors/isolate_mirror_impl.dart' show IsolateMirrorImpl;

// Metadata and annotations
export 'src/metadata.dart';
export 'src/annotations.dart' show reflectable;

// Exceptions
export 'src/exceptions.dart';
