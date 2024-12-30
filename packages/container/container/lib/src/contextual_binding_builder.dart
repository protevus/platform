/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'container.dart';
import 'exception.dart';
import 'reflector.dart';

/// A builder class for defining contextual bindings in the container.
///
/// This class provides a fluent interface for defining how abstract types should
/// be resolved in specific contexts. It allows for different implementations of
/// an interface to be used depending on where they are being injected.
class ContextualBindingBuilder {
  /// The container instance this builder is associated with
  final Container container;

  /// The concrete type that needs a contextual binding
  final List<Type> concrete;

  /// Creates a new contextual binding builder
  ContextualBindingBuilder(this.container, this.concrete);

  /// Define the abstract type that should be bound differently in this context
  ContextualImplementationBuilder needs<T>() {
    return ContextualImplementationBuilder(container, concrete, T);
  }

  /// Bind directly to a concrete implementation
  void to(Type implementation) {
    for (var concreteType in concrete) {
      container.addContextualBinding(
          concreteType, concreteType, implementation);
    }
  }
}

/// A builder class for defining the implementation for a contextual binding.
///
/// This class completes the contextual binding definition by specifying what
/// implementation should be used for the abstract type in the given context.
class ContextualImplementationBuilder {
  /// The container instance this builder is associated with
  final Container container;

  /// The concrete type that needs a contextual binding
  final List<Type> concrete;

  /// The abstract type that needs to be bound
  final Type abstract;

  /// Creates a new contextual implementation builder
  ContextualImplementationBuilder(
      this.container, this.concrete, this.abstract) {
    // Register an empty binding by default
    for (var concreteType in concrete) {
      container.addContextualBinding(concreteType, abstract, null);
    }
  }

  /// Specify the implementation that should be used
  void give<T>() {
    for (var concreteType in concrete) {
      container.addContextualBinding(concreteType, abstract, T);
    }
  }

  /// Bind to a concrete implementation type
  // void to(Type implementation) {
  //   for (var concreteType in concrete) {
  //     // Add contextual binding with implementation as the value
  //     container.addContextualBinding(
  //         concreteType, concreteType, implementation);
  //     // Also add a contextual binding with implementation as the key
  //     container.addContextualBinding(
  //         implementation, concreteType, implementation);
  //     // Also register a singleton for direct resolution
  //     container.registerSingleton(container.make(implementation),
  //         as: concreteType);
  //   }
  // }

  // void to(Type implementation) {
  //   for (var concreteType in concrete) {
  //     // Register a factory that creates the implementation
  //     container.registerFactory(
  //         (c) => c.withParameters({}, () {
  //               var reflectedType = c.reflector.reflectType(implementation);
  //               if (reflectedType is ReflectedClass) {
  //                 bool isDefault(String name) {
  //                   return name.isEmpty || name == reflectedType.name;
  //                 }

  //                 var constructor = reflectedType.constructors.firstWhere(
  //                     (c) => isDefault(c.name),
  //                     orElse: (() => throw BindingResolutionException(
  //                         '${reflectedType.name} has no default constructor')));

  //                 return reflectedType.newInstance(
  //                     isDefault(constructor.name) ? '' : constructor.name,
  //                     [],
  //                     {},
  //                     []).reflectee;
  //               }
  //               throw BindingResolutionException(
  //                   '$implementation is not a class, and therefore cannot be instantiated.');
  //             }),
  //         as: concreteType);
  //   }
  // }

  // void to(Type implementation) {
  //   for (var concreteType in concrete) {
  //     // Keep existing contextual binding
  //     container.addContextualBinding(
  //         concreteType, concreteType, implementation);

  //     // Add factory that returns implementation instance
  //     container.registerFactory((c) {
  //       // Create implementation instance
  //       var reflectedType = c.reflector.reflectType(implementation);
  //       if (reflectedType is ReflectedClass) {
  //         bool isDefault(String name) {
  //           return name.isEmpty || name == reflectedType.name;
  //         }

  //         var constructor = reflectedType.constructors.firstWhere(
  //             (c) => isDefault(c.name),
  //             orElse: (() => throw BindingResolutionException(
  //                 '${reflectedType.name} has no default constructor')));

  //         // Get all parameter overrides
  //         var positional = [];
  //         var named = <String, Object>{};
  //         for (var param in constructor.parameters) {
  //           var override = c.getParameterOverride(param.name);
  //           if (override != null) {
  //             if (param.isNamed) {
  //               named[param.name] = override;
  //             } else {
  //               positional.add(override);
  //             }
  //           }
  //         }

  //         return reflectedType.newInstance(
  //             isDefault(constructor.name) ? '' : constructor.name,
  //             positional,
  //             named, []).reflectee;
  //       }

  //       return c.make(implementation);
  //     }, as: concreteType);
  //   }
  // }

  // void to(Type implementation) {
  //   for (var concreteType in concrete) {
  //     // Register a factory that returns implementation instance
  //     container.registerFactory((c) {
  //       // Get parameter overrides
  //       var overrides = c.getParameterOverride('name');
  //       if (overrides != null) {
  //         return c.withParameters({'name': overrides}, () {
  //           // Create a new instance of the implementation
  //           var reflectedType = c.reflector.reflectType(implementation);
  //           if (reflectedType is ReflectedClass) {
  //             bool isDefault(String name) {
  //               return name.isEmpty || name == reflectedType.name;
  //             }

  //             var constructor = reflectedType.constructors.firstWhere(
  //                 (c) => isDefault(c.name),
  //                 orElse: (() => throw BindingResolutionException(
  //                     '${reflectedType.name} has no default constructor')));

  //             return reflectedType.newInstance(
  //                 isDefault(constructor.name) ? '' : constructor.name,
  //                 [],
  //                 {'name': overrides},
  //                 []).reflectee;
  //           }
  //           throw BindingResolutionException(
  //               '$implementation is not a class, and therefore cannot be instantiated.');
  //         });
  //       }

  //       // Create a new instance of the implementation
  //       var reflectedType = c.reflector.reflectType(implementation);
  //       if (reflectedType is ReflectedClass) {
  //         bool isDefault(String name) {
  //           return name.isEmpty || name == reflectedType.name;
  //         }

  //         var constructor = reflectedType.constructors.firstWhere(
  //             (c) => isDefault(c.name),
  //             orElse: (() => throw BindingResolutionException(
  //                 '${reflectedType.name} has no default constructor')));

  //         return reflectedType.newInstance(
  //             isDefault(constructor.name) ? '' : constructor.name,
  //             [],
  //             {},
  //             []).reflectee;
  //       }
  //       throw BindingResolutionException(
  //           '$implementation is not a class, and therefore cannot be instantiated.');
  //     }, as: concreteType);
  //   }
  // }

  // void to(Type implementation) {
  //   for (var concreteType in concrete) {
  //     // Add contextual binding with a factory function
  //     container.addContextualBinding(
  //         concreteType, concreteType, (c) => c.make(implementation));
  //   }
  // }

  // void to(Type implementation) {
  //   for (var concreteType in concrete) {
  //     // Add contextual binding with a factory function that handles both cases
  //     container.addContextualBinding(concreteType, concreteType, (c) {
  //       try {
  //         return c.make(implementation);
  //       } catch (e) {
  //         if (e.toString().contains('Cannot instantiate abstract class')) {
  //           return null;
  //         }
  //         rethrow;
  //       }
  //     });
  //   }
  // }

  // void to(Type implementation) {
  //   for (var concreteType in concrete) {
  //     // Add contextual binding with a factory function
  //     container.addContextualBinding(implementation, concreteType, (c) {
  //       // Get parameter overrides first
  //       var overrides = c.getParameterOverride('name');
  //       if (overrides != null) {
  //         return c.withParameters({'name': overrides}, () {
  //           return c.make(implementation);
  //         });
  //       }
  //       return c.make(implementation);
  //     });
  //   }
  // }

  // void to(Type implementation) {
  //   for (var abstractType in concrete) {
  //     // Register a factory that returns implementation instance
  //     container.registerFactory((c) {
  //       // Get parameter overrides first
  //       var overrides = c.getParameterOverride('name');
  //       if (overrides != null) {
  //         return c.withParameters({'name': overrides}, () {
  //           // Create a new instance of the implementation
  //           var reflectedType = c.reflector.reflectType(implementation);
  //           if (reflectedType is ReflectedClass) {
  //             bool isDefault(String name) {
  //               return name.isEmpty || name == reflectedType.name;
  //             }

  //             var constructor = reflectedType.constructors.firstWhere(
  //                 (c) => isDefault(c.name),
  //                 orElse: (() => throw BindingResolutionException(
  //                     '${reflectedType.name} has no default constructor')));

  //             return reflectedType.newInstance(
  //                 isDefault(constructor.name) ? '' : constructor.name,
  //                 [],
  //                 {'name': overrides},
  //                 []).reflectee;
  //           }
  //           throw BindingResolutionException(
  //               '$implementation is not a class, and therefore cannot be instantiated.');
  //         });
  //       }

  //       // Create a new instance of the implementation
  //       var reflectedType = c.reflector.reflectType(implementation);
  //       if (reflectedType is ReflectedClass) {
  //         bool isDefault(String name) {
  //           return name.isEmpty || name == reflectedType.name;
  //         }

  //         var constructor = reflectedType.constructors.firstWhere(
  //             (c) => isDefault(c.name),
  //             orElse: (() => throw BindingResolutionException(
  //                 '${reflectedType.name} has no default constructor')));

  //         return reflectedType.newInstance(
  //             isDefault(constructor.name) ? '' : constructor.name,
  //             [],
  //             {},
  //             []).reflectee;
  //       }
  //       throw BindingResolutionException(
  //           '$implementation is not a class, and therefore cannot be instantiated.');
  //     }, as: abstractType);
  //   }
  // }

  // void to(Type implementation) {
  //   for (var abstractType in concrete) {
  //     // Add contextual binding from abstract to implementation
  //     container.addContextualBinding(
  //         abstractType, abstractType, implementation);

  //     // Register a factory that handles parameter overrides
  //     container.registerFactory((c) {
  //       // Get parameter overrides
  //       var nameOverride = c.getParameterOverride('name');
  //       if (nameOverride != null) {
  //         return c.withParameters(
  //             {'name': nameOverride}, () => c.make(implementation));
  //       }
  //       return c.make(implementation);
  //     }, as: abstractType);
  //   }
  // }

  // void to(Type implementation) {
  //   for (var abstractType in concrete) {
  //     // Add contextual binding with a factory function
  //     container.addContextualBinding(abstractType, abstractType, (c) {
  //       // Get parameter overrides first
  //       var nameOverride = c.getParameterOverride('name');
  //       if (nameOverride != null) {
  //         return c.withParameters({'name': nameOverride}, () {
  //           var reflectedType = c.reflector.reflectType(implementation);
  //           if (reflectedType is ReflectedClass) {
  //             bool isDefault(String name) {
  //               return name.isEmpty || name == reflectedType.name;
  //             }

  //             var constructor = reflectedType.constructors.firstWhere(
  //                 (c) => isDefault(c.name),
  //                 orElse: (() => throw BindingResolutionException(
  //                     '${reflectedType.name} has no default constructor')));

  //             return reflectedType.newInstance(
  //                 isDefault(constructor.name) ? '' : constructor.name,
  //                 [],
  //                 {'name': nameOverride},
  //                 []).reflectee;
  //           }
  //           throw BindingResolutionException(
  //               '$implementation is not a class, and therefore cannot be instantiated.');
  //         });
  //       }

  //       // Create implementation instance
  //       var reflectedType = c.reflector.reflectType(implementation);
  //       if (reflectedType is ReflectedClass) {
  //         bool isDefault(String name) {
  //           return name.isEmpty || name == reflectedType.name;
  //         }

  //         var constructor = reflectedType.constructors.firstWhere(
  //             (c) => isDefault(c.name),
  //             orElse: (() => throw BindingResolutionException(
  //                 '${reflectedType.name} has no default constructor')));

  //         return reflectedType.newInstance(
  //             isDefault(constructor.name) ? '' : constructor.name,
  //             [],
  //             {},
  //             []).reflectee;
  //       }
  //       throw BindingResolutionException(
  //           '$implementation is not a class, and therefore cannot be instantiated.');
  //     });
  //   }
  // }

  // void to(Type implementation) {
  //   for (var abstractType in concrete) {
  //     // Register a factory that handles parameter overrides
  //     container.registerFactory((c) => c.make(implementation),
  //         as: abstractType);
  //   }
  // }

  void to(Type implementation) {
    for (var abstractType in concrete) {
      // Add contextual binding with a factory function
      container.addContextualBinding(
          abstractType, abstractType, (c) => c.make(implementation));
    }
  }

  /// Specify a factory function that should be used to create the implementation
  void giveFactory(dynamic Function(Container container) factory) {
    for (var concreteType in concrete) {
      container.addContextualBinding(concreteType, abstract, factory);
    }
  }

  /// Specify that the implementation should be resolved from a tagged binding
  void giveTagged(String tag) {
    giveFactory((container) {
      var tagged = container.tagged(tag);
      if (tagged.isEmpty) {
        throw BindingResolutionException(
            'No implementations found for tag: $tag');
      }
      return tagged.first;
    });
  }

  /// Specify the implementation type and its configuration
  void giveConfig(Type implementation, Map<String, dynamic> config) {
    giveFactory((container) {
      // Get reflected type to validate required parameters
      var reflectedType = container.reflector.reflectType(implementation);
      if (reflectedType is ReflectedClass) {
        var constructor = reflectedType.constructors.firstWhere(
            (c) => c.name.isEmpty || c.name == reflectedType.name,
            orElse: () => reflectedType.constructors.first);

        // Check required parameters
        for (var param in constructor.parameters) {
          if (param.isRequired &&
              param.isNamed &&
              !config.containsKey(param.name)) {
            throw BindingResolutionException(
                'Required parameter ${param.name} is missing for ${reflectedType.name}');
          }
        }
      }

      return container.withParameters(config, () {
        return container.make(implementation);
      });
    });
  }
}
