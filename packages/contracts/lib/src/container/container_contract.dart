import 'package:meta/meta.dart';
import '../reflection/reflector_contract.dart';

/// Core container contract defining dependency injection functionality.
///
/// This contract defines the interface that all dependency injection containers
/// must implement. It provides methods for registering and resolving dependencies,
/// creating child containers, and managing named instances.
@sealed
abstract class ContainerContract {
  /// Gets the reflector instance used by this container.
  ReflectorContract get reflector;

  /// Whether this is a root container (has no parent).
  bool get isRoot;

  /// Creates a child container that inherits from this container.
  ///
  /// The child container can access all dependencies registered in its parent containers,
  /// but can also define its own dependencies that override or extend the parent's.
  /// This enables scoped dependency injection contexts.
  ContainerContract createChild();

  /// Checks if a type is registered in this container or its parents.
  ///
  /// Parameters:
  ///   - [T]: The type to check for. If [T] is dynamic, [t] must be provided.
  ///   - [t]: Optional type parameter that overrides [T] if provided.
  ///
  /// Returns true if the type is registered, false otherwise.
  bool has<T>([Type? t]);

  /// Checks if a named instance exists in this container or its parents.
  ///
  /// Parameters:
  ///   - [name]: The name to check for.
  ///
  /// Returns true if a named instance exists, false otherwise.
  bool hasNamed(String name);

  /// Makes an instance of type [T].
  ///
  /// This will:
  /// 1. Return a singleton if registered
  /// 2. Create an instance via factory if registered
  /// 3. Use reflection to create a new instance
  ///
  /// Parameters:
  ///   - [type]: Optional type parameter that overrides [T] if provided.
  ///
  /// Throws:
  ///   - ReflectionException if [T] is not a class or has no default constructor
  T make<T>([Type? type]);

  /// Makes an instance of type [T] asynchronously.
  ///
  /// This will attempt to resolve a Future<T> in the following order:
  /// 1. Wrap a synchronous [T] in Future
  /// 2. Return a registered Future<T>
  /// 3. Create a Future<T> via reflection
  ///
  /// Parameters:
  ///   - [type]: Optional type parameter that overrides [T] if provided.
  ///
  /// Throws:
  ///   - ReflectionException if no suitable injection is found
  Future<T> makeAsync<T>([Type? type]);

  /// Registers a singleton instance.
  ///
  /// The instance will be shared across the container hierarchy.
  ///
  /// Parameters:
  ///   - [object]: The singleton instance to register.
  ///   - [as]: Optional type to register the singleton as.
  ///
  /// Returns the registered instance.
  ///
  /// Throws:
  ///   - StateError if a singleton is already registered for the type
  T registerSingleton<T>(T object, {Type? as});

  /// Registers a factory function.
  ///
  /// The factory will be called each time an instance is needed.
  ///
  /// Parameters:
  ///   - [factory]: Function that creates instances.
  ///   - [as]: Optional type to register the factory as.
  ///
  /// Returns the factory function.
  ///
  /// Throws:
  ///   - StateError if a factory is already registered for the type
  T Function(ContainerContract) registerFactory<T>(
      T Function(ContainerContract) factory,
      {Type? as});

  /// Registers a lazy singleton.
  ///
  /// The singleton will be created on first use.
  ///
  /// Parameters:
  ///   - [factory]: Function that creates the singleton.
  ///   - [as]: Optional type to register the singleton as.
  ///
  /// Returns the factory function.
  T Function(ContainerContract) registerLazySingleton<T>(
      T Function(ContainerContract) factory,
      {Type? as});

  /// Gets a named singleton.
  ///
  /// Parameters:
  ///   - [name]: The name of the singleton to retrieve.
  ///
  /// Returns the named singleton instance.
  ///
  /// Throws:
  ///   - StateError if no singleton exists with the given name
  T findByName<T>(String name);

  /// Registers a named singleton.
  ///
  /// Parameters:
  ///   - [name]: The name to register the singleton under.
  ///   - [object]: The singleton instance.
  ///
  /// Returns the registered instance.
  ///
  /// Throws:
  ///   - StateError if a singleton already exists with the given name
  T registerNamedSingleton<T>(String name, T object);
}
