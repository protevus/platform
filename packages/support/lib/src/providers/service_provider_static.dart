/// Mixin that provides static members for ServiceProvider
mixin ServiceProviderStatic {
  /// The paths that should be published.
  static final Map<String, Map<String, String>> publishes = {};

  /// The paths that should be published by group.
  static final Map<String, Map<String, String>> publishGroups = {};

  /// The migration paths available for publishing.
  static final List<String> publishableMigrationPaths = [];
}
