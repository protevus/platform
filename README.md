<p align="center"><a href="https://protevus.com" target="_blank"><img src="https://git.protevus.com/protevus/branding/raw/branch/main/protevus-logo-bg.png"></a></p>

# Protevus Platform

[![Dart Version](https://img.shields.io/badge/Dart-%3E%3D3.3.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/build-failing-red.svg)]()

## 📖 Overview

Protevus Platform is a high-performance, modular unified full-stack platform for Dart that provides a comprehensive suite of tools for building scalable web applications, APIs, and microservices. Built on the Dox framework, it combines modern architecture patterns with Dart's powerful async/await capabilities and strong typing.

### 🌟 Key Features

- **High Performance**: Built on Dart's efficient runtime
- **Type Safety**: Leverages Dart's strong type system for compile-time error catching
- **Modular Architecture**: Highly extensible with independent, composable packages
- **Developer Friendly**: Intuitive API design with extensive documentation
- **Enterprise Ready**: Built-in support for authentication, caching, and database operations

## 🏗️ Architecture

Protevus Platform uses a modular architecture where each component is a separate package, allowing for flexible composition and minimal dependencies.

### Core Components

#### 🚀 Foundation
The heart of the framework, providing core HTTP server functionality:

```dart
import 'package:dox/dox.dart';

void main() async {
  var app = Application();
  
  // Route handling
  Route.get('/api/users', [
    AuthMiddleware(),
    userController.index
  ]);

  await app.startServer();
}
```

Key features:
- HTTP server support
- Middleware pipeline
- Request/Response abstraction
- Error handling

#### 🛣️ Routing
Advanced routing system with expressive syntax:

```dart
// Route groups with shared middleware
Route.group('/api/v1', () {
  // Resource routes
  Route.resource('users', UserController());
  
  // Protected routes
  Route.middleware([AuthMiddleware()], () {
    Route.get('/profile', userController.profile);
    Route.post('/logout', authController.logout);
  });
  
  // Parameter routes
  Route.get('/posts/{id}', postController.show);
});
```

Features:
- Named routes
- Route parameters
- Route groups and prefixing
- Middleware attachment
- RESTful resource routing

#### 🔐 Authentication
Comprehensive authentication system:

```dart
// Auth configuration
Auth.initialize(AuthConfig(
  defaultGuard: 'web',
  guards: {
    'web': AuthGuard(
      driver: JwtAuthDriver(secret: SecretKey(Env.get('APP_KEY'))),
      provider: AuthProvider(
        model: () => User(),
      ),
    ),
  },
));

// Auth middleware
Route.get('/protected', [
  AuthMiddleware(), 
  controller.method
]);

// Login attempt
String? token = await auth.attempt(credentials);
if(token != null) {
  User? user = auth.user<User>();
  return user;
}
```

Features:
- JWT authentication
- Guard system
- Provider system
- Middleware integration
- Token management

#### 📊 Database
Powerful database abstraction layer:

```dart
// Query builder
var users = await User()
  .select(['id', 'name', 'email'])
  .where('active', true)
  .whereIn('role', ['admin', 'moderator'])
  .orderBy('created_at', 'desc')
  .get();

// Create
await User().create({
  'name': 'John Doe',
  'email': 'john@example.com'
});

// Relationships
class User extends Model {
  @override
  String get table => 'users';
  
  Future<List<Post>> posts() {
    return hasMany(Post);
  }
}
```

Features:
- Query builder
- Model system
- Relationships
- Soft deletes
- Debug mode
- Raw queries

## 🚀 Getting Started

### Prerequisites

```bash
# Install Dart SDK (>=3.3.0)
curl -fsSL https://dart.dev/get-dart | bash

# Install Dox CLI
dart pub global activate dox
```

### Creating a New Project

```bash
# Create new project
dox create my_app

# Start development server
cd my_app
dox s

# Or with Docker
docker-compose up -d --build
```

### Environment Configuration

```bash
# Development mode (hot reload)
APP_ENV=development

# Production mode (compiled)
APP_ENV=production
```

## 🛠️ Development Tools

### CLI Commands

```bash
# Development server
dox s

# Watch mode for code generation
dox build_runner:watch

# Create new project
dox create project_name

# Create new project with specific version
dox create project_name --version v2.0.0
```

## 📚 Documentation

- [Installation](docs/documentation/the-basic/installation.md)
- [Routing](docs/documentation/the-basic/routing.md)
- [Controllers](docs/documentation/the-basic/controller.md)
- [Database](docs/documentation/database/query-builder.md)
- [Authentication](docs/documentation/security/authentication.md)
- [Deployment](docs/documentation/digging-deeper/deployment.md)

## 🔧 Troubleshooting

### Common Issues

1. **Server won't start**:
   - Check port availability
   - Verify environment variables
   - Check logs

2. **Database connection issues**:
   - Verify connection string
   - Check database credentials
   - Ensure database service is running

3. **Authentication failures**:
   - Verify JWT secret
   - Check token expiration
   - Validate middleware order

### Debug Mode

```dart
// Enable query debugging
await User().debug(true).all();
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
