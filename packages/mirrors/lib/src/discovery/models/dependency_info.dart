/// Information about a library dependency.
///
/// Contains metadata about a dependency including:
/// - The dependency's URI
/// - Import prefix (if any)
/// - Whether it's deferred
/// - Show/hide combinators
class DependencyInfo {
  /// The URI of the dependency
  final Uri uri;

  /// The prefix used for this dependency (e.g., 'as prefix')
  final String? prefix;

  /// Whether this dependency is deferred
  final bool isDeferred;

  /// List of identifiers shown from this dependency
  final List<String> showCombinators;

  /// List of identifiers hidden from this dependency
  final List<String> hideCombinators;

  /// Creates a new [DependencyInfo] instance.
  ///
  /// Required parameters:
  /// - [uri]: The dependency's URI
  /// - [prefix]: The prefix used for this dependency (can be null)
  /// - [isDeferred]: Whether the dependency is deferred
  /// - [showCombinators]: List of shown identifiers
  /// - [hideCombinators]: List of hidden identifiers
  const DependencyInfo({
    required this.uri,
    required this.prefix,
    required this.isDeferred,
    required this.showCombinators,
    required this.hideCombinators,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    if (isDeferred) buffer.write('deferred ');
    buffer.write('$uri');
    if (prefix != null) buffer.write(' as $prefix');
    if (showCombinators.isNotEmpty)
      buffer.write(' show ${showCombinators.join(", ")}');
    if (hideCombinators.isNotEmpty)
      buffer.write(' hide ${hideCombinators.join(", ")}');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DependencyInfo &&
        other.uri == uri &&
        other.prefix == prefix &&
        other.isDeferred == isDeferred &&
        _listEquals(other.showCombinators, showCombinators) &&
        _listEquals(other.hideCombinators, hideCombinators);
  }

  @override
  int get hashCode {
    return Object.hash(
      uri,
      prefix,
      isDeferred,
      Object.hashAll(showCombinators),
      Object.hashAll(hideCombinators),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
