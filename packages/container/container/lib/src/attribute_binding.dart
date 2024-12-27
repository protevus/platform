/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'attributes.dart';
import 'container.dart';
import 'reflector.dart';

/// Extension methods for attribute-based binding support
extension AttributeBindingExtension on Container {
  /// Register all attribute-based bindings for a type
  void registerAttributeBindings(Type type) {
    var annotations = reflector.getAnnotations(type);
    for (var annotation in annotations) {
      var value = annotation.reflectee;
      if (value is Injectable) {
        // Register the binding
        if (value.bindTo != null) {
          bind(value.bindTo!).to(type);
        }

        // Apply tags
        if (value.tags.isNotEmpty) {
          tag([type], value.tags.join(','));
        }

        // Make it a singleton if requested
        if (value.singleton) {
          singleton(type);
        }
      }
    }
  }

  /// Resolve constructor parameters using attribute-based injection
  List<dynamic> resolveConstructorParameters(
      Type type, String constructorName, List<ReflectedParameter> parameters) {
    var result = <dynamic>[];

    for (var param in parameters) {
      var annotations =
          reflector.getParameterAnnotations(type, constructorName, param.name);

      // Find injection annotation
      ReflectedInstance? injectAnnotation;
      try {
        injectAnnotation = annotations.firstWhere(
            (a) => a.reflectee is Inject || a.reflectee is InjectTagged);
      } catch (_) {
        try {
          injectAnnotation =
              annotations.firstWhere((a) => a.reflectee is InjectAll);
        } catch (_) {
          // No injection annotation found
        }
      }

      if (injectAnnotation != null) {
        var value = injectAnnotation.reflectee;
        if (value is Inject) {
          // Inject specific implementation with config
          result.add(
              withParameters(value.config, () => make(value.implementation)));
        } else if (value is InjectTagged) {
          // Inject tagged implementation
          var tagged = this.tagged(value.tag);
          if (tagged.isEmpty) {
            throw Exception('No implementations found for tag: ${value.tag}');
          }
          result.add(tagged.first);
        } else if (value is InjectAll) {
          // Inject all implementations
          if (value.tag != null) {
            result.add(tagged(value.tag!).toList());
          } else {
            result.add(makeAll(param.type.reflectedType));
          }
        }
      } else {
        // No injection annotation, use default resolution
        result.add(make(param.type.reflectedType));
      }
    }

    return result;
  }

  /// Make all instances of a type
  List<dynamic> makeAll(Type type) {
    var reflectedType = reflector.reflectType(type);
    if (reflectedType == null) {
      throw Exception('Type not found: $type');
    }

    return reflector
        .getAnnotations(type)
        .where((a) => a.reflectee is Injectable)
        .map((a) => make(type))
        .toList();
  }
}
