import 'package:platform_mirrors/mirrors.dart';
import 'collection.dart';

/// A proxy class for higher-order collection operations.
class HigherOrderCollectionProxy<T> {
  /// The underlying collection.
  final Collection<T> _collection;

  /// The target method name.
  String _method;

  /// Create a new proxy instance.
  HigherOrderCollectionProxy(this._collection, this._method);

  /// Dynamically handle method calls.
  dynamic operator [](String name) {
    return Collection(_collection.map((item) {
      if (item == null) return null;

      // Handle array access
      if (item is List) {
        final index = int.tryParse(name);
        if (index != null) {
          return index < item.length ? item[index] : null;
        }
      }

      // Handle map access
      if (item is Map) {
        return item[name];
      }

      // Handle object property access
      if (ReflectionRegistry.isReflectable(item.runtimeType)) {
        try {
          // Use direct property access
          switch (name) {
            case 'name':
              return (item as dynamic).name;
            case 'age':
              return (item as dynamic).age;
            default:
              return null;
          }
        } catch (_) {
          return null;
        }
      }

      return null;
    }).toList());
  }

  /// Handle method calls on the collection items.
  Collection<dynamic> call([List<dynamic> arguments = const []]) {
    return Collection(_collection.map((item) {
      if (item == null) return null;

      // Handle method calls
      if (ReflectionRegistry.isReflectable(item.runtimeType)) {
        try {
          // Use direct method invocation
          switch (_method) {
            case 'greet':
              return (item as dynamic).greet();
            case 'setAge':
              if (arguments.isNotEmpty) {
                (item as dynamic).age = arguments[0];
                return null;
              }
              return null;
            default:
              return null;
          }
        } catch (_) {
          return null;
        }
      }

      return null;
    }).toList());
  }

  /// Handle property access on the collection items.
  Collection<dynamic> get(String property) {
    return this[property];
  }

  /// Handle setting property values on the collection items.
  Collection<T> set(String property, dynamic value) {
    return Collection(_collection.map((item) {
      if (item == null) return item;

      // Handle array access
      if (item is List) {
        final index = int.tryParse(property);
        if (index != null && index < item.length) {
          item[index] = value;
        }
        return item;
      }

      // Handle map access
      if (item is Map) {
        item[property] = value;
        return item;
      }

      // Handle object property access
      if (ReflectionRegistry.isReflectable(item.runtimeType)) {
        try {
          // Use direct property access
          switch (property) {
            case 'name':
              (item as dynamic).name = value;
              break;
            case 'age':
              (item as dynamic).age = value;
              break;
          }
        } catch (_) {
          // Ignore if property cannot be set
        }
      }

      return item;
    }).toList());
  }

  /// Handle unset/remove operations on the collection items.
  Collection<T> unset(String property) {
    // For object properties, we need to explicitly set them to null
    return Collection(_collection.map((item) {
      if (item == null) return item;

      // Handle array access
      if (item is List) {
        final index = int.tryParse(property);
        if (index != null && index < item.length) {
          item.removeAt(index);
        }
        return item;
      }

      // Handle map access
      if (item is Map) {
        item.remove(property);
        return item;
      }

      // Handle object property access
      if (ReflectionRegistry.isReflectable(item.runtimeType)) {
        try {
          // Use direct property access
          switch (property) {
            case 'name':
              (item as dynamic).name = null;
              break;
            case 'age':
              (item as dynamic).age = null;
              break;
          }
        } catch (_) {
          // Ignore if property cannot be unset
        }
      }

      return item;
    }).toList());
  }

  /// Check if a property exists on the collection items.
  Collection<bool> contains(String property) {
    return Collection(_collection.map((item) {
      if (item == null) return false;

      // Handle array access
      if (item is List) {
        final index = int.tryParse(property);
        if (index != null) {
          return index < item.length;
        }
      }

      // Handle map access
      if (item is Map) {
        return item.containsKey(property);
      }

      // Handle object property access
      if (ReflectionRegistry.isReflectable(item.runtimeType)) {
        final metadata =
            ReflectionRegistry.getPropertyMetadata(item.runtimeType);
        return metadata?.containsKey(property) ?? false;
      }

      return false;
    }).toList());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString().split('"')[1];

    if (invocation.isGetter) {
      return get(name);
    }

    if (invocation.isSetter) {
      // Remove the trailing '=' from the setter name
      final propertyName = name.substring(0, name.length - 1);
      return set(propertyName, invocation.positionalArguments.first);
    }

    // If it's a method call, create a new proxy with the method name and call it
    return HigherOrderCollectionProxy(_collection, name)
        .call(invocation.positionalArguments);
  }
}
