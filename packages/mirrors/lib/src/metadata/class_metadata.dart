import 'constructor_metadata.dart';
import 'method_metadata.dart';
import 'property_metadata.dart';

/// Metadata about a parsed class.
class ClassMetadata {
  /// The name of the class.
  final String name;

  /// The type parameters if this is a generic class (e.g., <T, U>).
  final List<String> typeParameters;

  /// The superclass this class extends, if any.
  final String? superclass;

  /// The interfaces this class implements.
  final List<String> interfaces;

  /// Whether this is an abstract class.
  final bool isAbstract;

  /// Whether this is a final class.
  final bool isFinal;

  /// The properties defined in this class.
  final Map<String, PropertyMetadata> properties;

  /// The methods defined in this class.
  final Map<String, MethodMetadata> methods;

  /// The constructors defined in this class.
  final List<ConstructorMetadata> constructors;

  ClassMetadata({
    required this.name,
    this.typeParameters = const [],
    this.superclass,
    this.interfaces = const [],
    this.isAbstract = false,
    this.isFinal = false,
    this.properties = const {},
    this.methods = const {},
    this.constructors = const [],
  });
}
