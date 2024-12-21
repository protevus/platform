# Platform Contracts Package

The Platform Contracts package provides a set of interfaces and abstract classes that define the core contracts for various components of the Platform framework. These contracts ensure consistency and interoperability across different implementations.

## Table of Contents

- [Installation](#installation)
- [Features](#features)
- [Usage](#usage)
- [Package Structure](#package-structure)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  platform_contracts: ^1.0.0
```

This package requires Dart SDK version 3.0.0 or later.

Dependencies:
- meta: ^1.9.0
- dsr_container: ^1.0.0
- dsr_simple_cache: ^1.0.0

Then run:

```
dart pub get
```

## Features

The Platform Contracts package includes contracts for various components of a web application framework, including:

- Authentication and Authorization
- Broadcasting
- Caching
- Configuration
- Console Applications
- Container (Dependency Injection)
- Database and ORM
- Encryption
- Event Handling
- Filesystem
- HTTP Handling
- Mailing
- Notifications
- Pagination
- Queues
- Redis Integration
- Routing
- Session Management
- Validation
- View Rendering

## Usage

Import the package in your Dart code:

```dart
import 'package:platform_contracts/contracts.dart';
```

Then implement the desired interfaces or extend the abstract classes to create your own implementations that adhere to the defined contracts.

## Package Structure

The package is organized into several subdirectories under `lib/src/`, each focusing on a specific area of functionality:

- `auth/`: Authentication and authorization contracts
- `broadcasting/`: Contracts for event broadcasting
- `cache/`: Caching system contracts
- `config/`: Configuration management contracts
- `console/`: Console application contracts
- `container/`: Dependency injection container contracts
- `database/`: Database and ORM contracts
- `encryption/`: Encryption service contracts
- `events/`: Event dispatching contracts
- `filesystem/`: Filesystem interaction contracts
- `http/`: HTTP request and response contracts
- `mail/`: Mailing service contracts
- `notifications/`: Notification system contracts
- `pagination/`: Pagination contracts
- `queue/`: Queue system contracts
- `redis/`: Redis integration contracts
- `routing/`: Routing system contracts
- `session/`: Session management contracts
- `validation/`: Validation system contracts
- `view/`: View rendering contracts

Each subdirectory contains interfaces and abstract classes that define the contracts for their respective areas.

## Examples

Here are a few examples of how to use the contracts in this package:

### Implementing an Authenticatable User

```dart
import 'package:platform_contracts/contracts.dart';

class User implements Authenticatable {
  @override
  String getAuthIdentifierName() => 'id';

  @override
  String getAuthIdentifier() => '12345';

  @override
  String getAuthPassword() => 'hashed_password';

  // Implement other methods...
}
```

### Creating a Custom Cache Store

```dart
import 'package:platform_contracts/contracts.dart';

class CustomCacheStore implements Store {
  @override
  Future<dynamic> get(String key) {
    // Implementation
  }

  @override
  Future<bool> put(String key, dynamic value, Duration? ttl) {
    // Implementation
  }

  // Implement other methods...
}
```

For more examples, please refer to the `example/` directory in this package.

## Contributing

Contributions are welcome! Here's how you can contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please read our [Contributing Guide](CONTRIBUTING.md) for more details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the [MIT License](LICENSE.md).

## Support

If you encounter any problems or have any questions, please open an issue in the [issue tracker](https://github.com/your-repo/platform_contracts/issues).
