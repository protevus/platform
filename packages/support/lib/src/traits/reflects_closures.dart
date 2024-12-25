import 'package:platform_mirrors/mirrors.dart';

/// A trait that provides functionality to reflect on closures.
mixin ReflectsClosures {
  /// Get the number of parameters that a closure accepts.
  int getClosureParameterCount(Function closure) {
    try {
      final metadata =
          ReflectionRegistry.getMethodMetadata(closure.runtimeType);
      if (metadata == null || !metadata.containsKey('call')) {
        return 0;
      }

      return metadata['call']!.parameters.length;
    } catch (_) {
      return 0;
    }
  }

  /// Get the parameter names of a closure.
  List<String> getClosureParameterNames(Function closure) {
    try {
      final metadata =
          ReflectionRegistry.getMethodMetadata(closure.runtimeType);
      if (metadata == null || !metadata.containsKey('call')) {
        return [];
      }

      return metadata['call']!.parameters.map((param) => param.name).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get the parameter types of a closure.
  List<Type> getClosureParameterTypes(Function closure) {
    try {
      final metadata =
          ReflectionRegistry.getMethodMetadata(closure.runtimeType);
      if (metadata == null || !metadata.containsKey('call')) {
        return [];
      }

      return metadata['call']!.parameterTypes;
    } catch (_) {
      return [];
    }
  }

  /// Determine if a closure has a specific parameter.
  bool closureHasParameter(Function closure, String name) {
    return getClosureParameterNames(closure).contains(name);
  }

  /// Determine if a closure returns void.
  bool isClosureVoid(Function closure) {
    try {
      final metadata =
          ReflectionRegistry.getMethodMetadata(closure.runtimeType);
      if (metadata == null || !metadata.containsKey('call')) {
        return false;
      }

      return metadata['call']!.returnsVoid;
    } catch (_) {
      return false;
    }
  }

  /// Determine if a closure is nullable.
  bool isClosureNullable(Function closure) {
    try {
      final metadata =
          ReflectionRegistry.getMethodMetadata(closure.runtimeType);
      if (metadata == null || !metadata.containsKey('call')) {
        return true;
      }

      // In Dart, if a function doesn't explicitly return void,
      // and doesn't have a return statement, it returns null
      return !metadata['call']!.returnsVoid;
    } catch (_) {
      return true;
    }
  }

  /// Determine if a closure is async.
  bool isClosureAsync(Function closure) {
    try {
      // Check if the closure is an async function by checking its runtime type
      final isAsync = closure.runtimeType.toString().contains('Future');
      if (isAsync) {
        return true;
      }

      // Also check if it's marked as async in the metadata
      final metadata =
          ReflectionRegistry.getMethodMetadata(closure.runtimeType);
      if (metadata == null || !metadata.containsKey('call')) {
        return false;
      }

      return metadata['call']!.parameterTypes.any(
          (type) => type.toString().startsWith('Future<') || type == Future);
    } catch (_) {
      return false;
    }
  }
}
