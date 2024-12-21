library mirrors;

import 'package:platform_contracts/contracts.dart';

import 'src/mirrors/mirror_system.dart';
import 'src/mirrors/instance_mirror.dart';

/// Core
export 'src/core/library_scanner.dart';
export 'src/core/reflector.dart';
export 'src/core/runtime_reflector.dart';
export 'src/core/scanner.dart';

/// MirrorSystem
export 'src/mirrors/mirror_system.dart';

/// Mirrors
export 'src/mirrors/base_mirror.dart';
export 'src/mirrors/class_mirror.dart';
export 'src/mirrors/combinator_mirror.dart';
export 'src/mirrors/instance_mirror.dart';
export 'src/mirrors/isolate_mirror.dart';
export 'src/mirrors/library_dependency_mirror.dart';
export 'src/mirrors/library_mirror.dart';
export 'src/mirrors/method_mirror.dart';
export 'src/mirrors/parameter_mirror.dart';
export 'src/mirrors/type_mirror.dart';
export 'src/mirrors/type_variable_mirror.dart';
export 'src/mirrors/variable_mirror.dart';

/// Types
export 'src/mirrors/special_types.dart';

/// Metadata and Annotations
export 'src/annotations.dart';
export 'src/metadata.dart';

/// Exceptions
export 'src/exceptions.dart';

/// Reflects an instance.
InstanceMirrorContract reflect(dynamic reflectee) {
  return InstanceMirror(
    reflectee: reflectee,
    type: reflectClass(reflectee.runtimeType),
  );
}

/// Reflects a class.
ClassMirrorContract reflectClass(Type key) {
  return MirrorSystem.instance.reflectClass(key);
}

/// Reflects a type.
TypeMirrorContract reflectType(Type key) {
  return MirrorSystem.instance.reflectType(key);
}

/// Returns the current mirror system.
MirrorSystemContract currentMirrorSystem() => MirrorSystem.current();
