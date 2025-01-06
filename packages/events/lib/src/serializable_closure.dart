/// A wrapper for serializable closures.
///
/// Note: Unlike Laravel's SerializableClosure which can serialize any closure,
/// this implementation requires closures to be registered with a unique identifier
/// that can be used to reconstruct them. This is because Dart does not provide
/// access to closure source code or scope through reflection.
class SerializableClosure {
  /// The closure to serialize.
  final Function closure;

  /// The unique identifier for this closure.
  final String identifier;

  /// Registry of closure factories.
  static final Map<String, Function Function()> _registry = {};

  /// Create a new serializable closure instance.
  SerializableClosure(this.closure, {String? identifier})
      : identifier = identifier ?? closure.hashCode.toString();

  /// Get the closure.
  Function getClosure() => closure;

  /// Convert the closure to a serializable format.
  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
    };
  }

  /// Register a closure factory.
  static void register(String identifier, Function Function() factory) {
    _registry[identifier] = factory;
  }

  /// Create a closure from serialized data.
  static Function fromJson(Map<String, dynamic> json) {
    final identifier = json['identifier'] as String;
    final factory = _registry[identifier];
    if (factory == null) {
      throw StateError(
        'No factory registered for closure with identifier: $identifier',
      );
    }
    return factory();
  }

  /// Create a serializable closure with a registered factory.
  static SerializableClosure create(
    Function closure,
    String identifier,
    Function Function() factory,
  ) {
    register(identifier, factory);
    return SerializableClosure(closure, identifier: identifier);
  }
}
