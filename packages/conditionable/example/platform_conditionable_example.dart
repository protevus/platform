import 'package:platform_conditionable/platform_conditionable.dart';

// A simple builder class that demonstrates Conditionable usage
class QueryBuilder with Conditionable {
  final List<String> _conditions = [];

  void addCondition(String condition) {
    _conditions.add(condition);
  }

  String build() => _conditions.join(' AND ');
}

// A configuration class showing conditional setup
class Config with Conditionable {
  String environment = 'development';
  bool debugMode = false;
  List<String> features = [];

  @override
  String toString() {
    return 'Config(environment: $environment, '
        'debugMode: $debugMode, features: $features)';
  }
}

void main() {
  // Example 1: Conditional Query Building
  print('Example 1: Conditional Query Building');
  final query = QueryBuilder();

  final hasStatus = true;
  final status = 'active';
  final minAge = 21;
  final category = null;

  query
    ..when(hasStatus, (self, _) {
      (self as QueryBuilder).addCondition("status = '$status'");
    })
    ..when(minAge >= 18, (self, _) {
      (self as QueryBuilder).addCondition('age >= $minAge');
    })
    ..unless(category == null, (self, value) {
      (self as QueryBuilder).addCondition("category = '$value'");
    });

  print('Generated query: ${query.build()}');
  print('---\n');

  // Example 2: Configuration Setup
  print('Example 2: Configuration Setup');
  final config = Config();

  // Using when with direct conditions
  config
    ..when(true, (self, _) {
      (self as Config).debugMode = true;
    })
    ..whenThen(
      config.environment == 'development',
      () => config.features.add('debug-toolbar'),
    );

  // Using unless with closures
  config.unless(() => config.environment == 'production', (self, _) {
    (self as Config).features.add('detailed-logs');
  });

  print('Final config: $config');
  print('---\n');

  // Example 3: Conditional Value Resolution
  print('Example 3: Conditional Value Resolution');
  final mode = config.when(
    config.debugMode,
    (self, _) => 'Debug Mode Active',
    orElse: (self, _) => 'Production Mode',
  );
  print('Current mode: $mode');

  final featureStatus = config.unless(
    config.features.isEmpty,
    (self, _) => 'Active features: ${config.features}',
    orElse: (self, _) => 'No features enabled',
  );
  print('Features: $featureStatus');
  print('---\n');

  // Example 4: Using orElse handlers with cascade notation
  print('Example 4: Using orElse Handlers');
  config
    ..whenThen(
      false,
      () => print('This will not execute'),
      orElse: () => print('Using fallback configuration'),
    )
    ..unlessThen(
      config.environment == 'production',
      () => print('Running in development mode'),
      orElse: () => print('Running in production mode'),
    );
}
