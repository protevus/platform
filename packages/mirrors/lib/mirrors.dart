library mirrors;

import 'package:illuminate_contracts/contracts.dart';

import 'src/core/mirror_system.dart';
import 'src/mirrors/instance_mirror.dart';
import 'src/reflector/runtime_reflector.dart';

/// Annotations
export 'src/annotations/reflectable.dart';

/// Core
export 'src/core/mirror_system.dart';

/// Discovery
export 'src/discovery/analyzers/library_analyzer.dart';
export 'src/discovery/analyzers/type_analyzer.dart';
export 'src/discovery/analyzers/package_analyzer.dart';
export 'src/discovery/runtime_library_discoverer.dart';
export 'src/discovery/runtime_type_discoverer.dart';

/// Discovery Models
export 'src/discovery/models/models.dart';

/// Exceptions
export 'src/exceptions/invalid_arguments_exception.dart';
export 'src/exceptions/member_not_found_exception.dart';
export 'src/exceptions/not_reflectable_exception.dart';
export 'src/exceptions/reflection_exception.dart';

/// Metadata
export 'src/metadata/class_metadata.dart';
export 'src/metadata/constructor_metadata.dart';
export 'src/metadata/extended_method_metadata.dart';
export 'src/metadata/function_metadata.dart';
export 'src/metadata/method_metadata.dart';
export 'src/metadata/parameter_metadata.dart';
export 'src/metadata/property_metadata.dart';
export 'src/metadata/type_metadata.dart';
export 'src/metadata/type_parameter_metadata.dart';

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

/// Reflector
export 'src/reflector/runtime_reflector.dart';

/// Registry
export 'src/registry/reflection_registry.dart';

/// Types
export 'src/types/special_types.dart';

// Export the runtime reflector instance globally
final reflector = RuntimeReflector.instance;

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
