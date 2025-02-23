<p align="center"><a href="https://protevus.com" target="_blank"><img src="https://raw.githubusercontent.com/dartondox/assets/main/dox-logo.png" width="70"></a></p>

# Protevus Platform

[![Dart Version](https://img.shields.io/badge/Dart-%3E%3D3.3.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-failing-red.svg)]()


- ***NOTE: THIS REPO IS NOT STABLE AND IS UNDER HEAVY DEVELOPMENT AND TESTING***
- ***FAST MOVING CODEBASE: NOTHING THAT YOU SEE HERE TODAY MAY BE HERE TOMMORROW***
- ***PREVIEW RELEASE: DATE TO BE DETERMINED***
- ***DISCLOSURE: EXAMPLES IN THIS DOCUMENT ARE TEMPORARY BOILERPLATE EXAMPLES***

## 📖 Overview

Protevus Platform is a high-performance, modular unified full-stack platform for Dart that provides a comprehensive suite of tools for building scalable web applications, APIs, and microservices. Built with a focus on Laravel's architecture patterns while embracing Dart's powerful features, it offers a robust foundation for modern application development.

### 🌟 Key Features

- **Pure Dart Implementation**: No VM dependencies, cross-platform support
- **Laravel-Inspired Architecture**: Familiar patterns in a Dart context
- **Comprehensive Package Ecosystem**: 35+ specialized packages
- **Modern Development Tools**: Melos-powered monorepo management
- **Enterprise Ready**: Built for scalability and maintainability

## 🏗️ Architecture

Our platform uses a modular architecture with 35+ specialized packages, each focusing on specific functionality while maintaining high cohesion and loose coupling.

### Core Packages

#### 🔄 Mirrors Package
Pure Dart reflection without VM dependencies:

```dart
import 'package:illuminate_mirrors/mirrors.dart';

// Cross-platform reflection
final reflector = Reflector();
final metadata = reflector.reflect(MyClass);
final methods = metadata.methods;
```

Features:
- VM-independent reflection
- Cross-platform support
- Type information
- Method inspection
- Property access

#### 📊 DBO (Database Operations)
PDO-inspired database operations:

```dart
import 'package:illuminate_dbo/dbo.dart';

// Database operations
final connection = DBO.connection();
await connection.execute('SELECT * FROM users WHERE active = ?', [true]);

// Transaction support
await connection.transaction((tx) async {
  await tx.execute('INSERT INTO users (name) VALUES (?)', ['John']);
  await tx.execute('INSERT INTO profiles (user_id) VALUES (?)', [1]);
});
```

Features:
- PDO-style operations
- Transaction support
- Multiple connections
- Prepared statements
- Error handling

#### 🔄 Event System
Robust event handling:

```dart
import 'package:illuminate_events/events.dart';

// Event definition
class UserRegistered extends Event {
  final User user;
  UserRegistered(this.user);
}

// Event listening
EventManager.listen<UserRegistered>((event) {
  // Handle user registration
});

// Event dispatch
await EventManager.dispatch(UserRegistered(newUser));
```

Features:
- Type-safe events
- Async handling
- Event queuing
- Conditional dispatch
- Error handling

#### 🌐 WebSocket
Advanced WebSocket implementation:

```dart
import 'package:illuminate_websocket/websocket.dart';

// Server setup
final server = WebsocketServer();
server.on('connection', (socket) {
  socket.on('message', (data) {
    // Handle message
  });
});

// Channel management
final channel = server.channel('notifications');
channel.broadcast('update', {'type': 'new_message'});
```

Features:
- Channel system
- Real-time events
- Connection management
- Authentication
- Redis adapter

## 📦 Package Ecosystem

### Application Core
- **illuminate_foundation**: Core framework functionality
- **illuminate_container**: Service container implementation
- **illuminate_contracts**: Interface definitions
- **illuminate_support**: Utility functions and helpers

### HTTP & Routing
- **illuminate_http**: HTTP client/server implementation
- **illuminate_routing**: Advanced routing system
- **illuminate_session**: Session management
- **illuminate_cookie**: Cookie handling
- **illuminate_websocket**: WebSocket implementation

### Database & Storage
- **illuminate_database**: Database abstraction layer
- **illuminate_dbo**: PDO-inspired database operations
- **illuminate_migration**: Database migrations
- **illuminate_pagination**: Query result pagination
- **illuminate_storage**: File storage abstraction

### Authentication & Security
- **illuminate_auth**: Authentication system
- **illuminate_encryption**: Data encryption
- **illuminate_hashing**: Cryptographic hashing

### Messaging & Events
- **illuminate_events**: Event dispatch system
- **illuminate_broadcasting**: Event broadcasting
- **illuminate_bus**: Message bus implementation
- **illuminate_queue**: Queue management
- **illuminate_notifications**: Notification system

### Development Tools
- **illuminate_testing**: Testing framework
- **illuminate_validation**: Data validation
- **illuminate_translation**: Internationalization
- **illuminate_view**: Template rendering
- **illuminate_cache**: Data caching

## 🚀 Getting Started

### Prerequisites

```bash
# Install Dart SDK (>=3.3.0)
curl -fsSL https://dart.dev/get-dart | bash

# Install Melos
dart pub global activate melos
```

### Project Setup

```bash
# Clone repository
git clone https://github.com/protevus/platform.git
cd platform

# Bootstrap project
melos bs

# Run tests
melos test
```

### Development Workflow

```bash
# Create new package
melos run create -- --type dart --category package --name my_package

# Run specific package tests
MELOS_SCOPE="package_name" melos run test:custom

# Generate documentation
melos run docs:generate
```

## 📚 Documentation

- [Getting Started](/docs/documentation/getting-started/installation.md)
- [Architecture Concepts](/docs/documentation/architecture-concepts/index.md)
- [Package Development](/docs/documentation/digging-deeper/package-development.md)
- [Contributing Guide](/docs/documentation/prologue/contributing-guide.md)
- [API Reference](/docs/documentation/api-documentation/index.md)

## 🔧 Troubleshooting

### Common Issues

1. **Bootstrap Issues**:
   ```bash
   melos clean
   melos bootstrap
   ```

2. **Generation Issues**:
   ```bash
   melos run clean
   melos run generate
   ```

3. **Dependency Conflicts**:
   ```bash
   melos run deps:check
   ```

### Debug Commands

```bash
# Debug package names
melos run debug_pkg_name

# Check reflectable files
MELOS_SCOPE="package_name" melos run debug:reflectable
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Add tests for new features
- Update documentation
- Keep PRs focused and atomic

## 📄 License

Protevus Platform is open-source software licensed under the MIT license.

---

<p align="center">Built with ❤️ by the Protevus Team</p>
