import 'package:platform_config/platform_config.dart';

void main() {
  // Create a new Repository instance with some initial configuration
  final config = Repository({
    'app': {
      'name': 'Protevus Demo App',
      'version': '1.0.0',
      'debug': true,
    },
    'database': {
      'default': 'mysql',
      'connections': {
        'mysql': {
          'host': 'localhost',
          'port': 3306,
          'database': 'protevus_demo',
          'username': 'demo_user',
          'password': 'secret',
        },
        'redis': {
          'host': 'localhost',
          'port': 6379,
        },
      },
    },
    'cache': {
      'default': 'redis',
      'stores': {
        'redis': {
          'driver': 'redis',
          'connection': 'default',
        },
        'file': {
          'driver': 'file',
          'path': '/tmp/cache',
        },
      },
    },
    'logging': {
      'channels': ['file', 'console'],
      'level': 'info',
    },
  });

  // Demonstrate usage of various methods
  print('Application Name: ${config.string('app.name')}');
  print('Debug Mode: ${config.boolean('app.debug') ? 'Enabled' : 'Disabled'}');

  // Using get with a default value
  print('API Version: ${config.get('app.api_version', 'v1')}');

  // Accessing nested configuration
  final dbConfig = config.get('database.connections.mysql');
  print('Database Configuration:');
  print('  Host: ${dbConfig['host']}');
  print('  Port: ${dbConfig['port']}');
  print('  Database: ${dbConfig['database']}');

  // Using type-specific getters
  final redisPort = config.integer('database.connections.redis.port');
  print('Redis Port: $redisPort');

  // Checking for existence of a key
  if (config.has('cache.stores.memcached')) {
    print('Memcached configuration exists');
  } else {
    print('Memcached configuration does not exist');
  }

  // Setting a new value
  config.set('app.timezone', 'UTC');
  print('Timezone: ${config.string('app.timezone')}');

  // Getting multiple values at once
  final loggingConfig = config.getMany(['logging.channels', 'logging.level']);
  print('Logging Configuration:');
  print('  Channels: ${loggingConfig['logging.channels']}');
  print('  Level: ${loggingConfig['logging.level']}');

  // Using array method
  final logChannels = config.array('logging.channels');
  print('Log Channels: $logChannels');

  // Demonstrating error handling
  try {
    config.integer('app.name');
  } catch (e) {
    print('Error: $e');
  }

  // Using the Repository as a Map
  config['new.feature.enabled'] = true;
  print('New Feature Enabled: ${config['new.feature.enabled']}');

  // Demonstrating Macroable functionality
  Repository.macro('getConnectionUrl', (Repository repo, String connection) {
    final conn = repo.get('database.connections.$connection');
    return 'mysql://${conn['username']}:${conn['password']}@${conn['host']}:${conn['port']}/${conn['database']}';
  });

  final mysqlUrl = config.callMacro('getConnectionUrl', ['mysql']);
  print('MySQL Connection URL: $mysqlUrl');
}
