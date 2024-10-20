<p align="center"><a href="https://protevus.com" target="_blank"><img src="https://git.protevus.com/protevus/branding/raw/branch/main/protevus-logo-bg.png"></a></p>

# Protevus Platform

Protevus Platform is a highly versatile and extensible application server platform for the Dart programming language. It is a hard fork of the Angel3 core, inspired by Express.js and Laravel, aiming to provide a familiar and Laravel-compatible API while leveraging the power of Dart.

> **Note:** This repository contains the core code of the Protevus Platform. If you want to build an application using Protevus, visit the main [Protevus repository](https://github.com/protevus/protevus).

## About Protevus

Protevus Platform allows developers to leverage their existing Laravel knowledge and experience in the Dart ecosystem. It combines the best features of Angel3 with Laravel-inspired design patterns and APIs, creating a powerful and familiar environment for web application development.

## AI Assistance

The Protevus Platform project utilizes AI assistance in various aspects of its development process. We believe in leveraging the capabilities of AI to enhance productivity, code quality, and overall project progress while maintaining transparency and adhering to ethical practices.

### AI Tools and Models

The following AI tools and models have been primarily employed in the development of the Protevus Platform:

- **Cursor** (cursor.com)
- **Continue** (continue.dev)
- **OpenRouter** (openrouter.ai)
- **Claude** (claude.ai)
- **Codestral** (mistral.ai)
- **Voyage** (voyage.ai)
- Other tools and LLMs

### Guidelines and Limitations

While AI assistance has been invaluable in accelerating certain aspects of development, we adhere to strict guidelines to ensure quality, security, and ethical use of AI in our development process.

## Features

- **Laravel API Compatibility**: Familiar API for Laravel developers
- **Modular Architecture**: Separating core components and libraries
- **High Performance**: Leverages Dart's efficient event-driven model and isolates for concurrent processing.
- **Asynchronous Processing**: Built on Dart's async-await paradigm for non-blocking operations.
- **Extensibility**: Support for custom extensions
- **Community-Driven**: Open-source principles and community contributions
- **Modular Packages**: Standalone Dart packages for each component
- **Comprehensive Routing**: Powerful routing capabilities
- **Dependency Injection**: Built-in support
- **Middleware Support**: For filtering HTTP requests
- **Authentication & Authorization**: Robust tools
- **Database Abstraction**: Query builder and ORM
- **Queueing System**: Manage background tasks
- **Event Broadcasting**: Real-time event capabilities
- **Full-Stack Experience**: Server-side views and Flutter support for frontends
- **WebSocket Support**: Real-time communication
- **ORM and Database Integration**: Work with various database systems
- **Templating Engine**: For server-side rendering
- **Static File Serving**: Built-in middleware
- **Scalability**: Designed to handle multiple concurrent connections efficiently.
- **Testing Utilities**: Comprehensive testing support

## Getting Started

To get started with Protevus Platform, follow these steps:

1. **Install Dart**: Ensure you have the Dart SDK installed on your system.

2. **Create a new project**:
   - dart create -t console my_protevus_app cd
   - my_protevus_app

3. **Add Protevus dependencies**: Add the following to your `pubspec.yaml`:
```yaml
dependencies:
  protevus_core: ^1.0.0
  protevus_configuration: ^1.0.0
```
4. **Run pub get**:
```shell
dart pub get
```
5. **Create your first Protevus application**: Replace the contents of bin/my_protevus_app.dart with:
```dart
import 'package:protevus_core/protevus_core.dart';
import 'package:protevus_core/http.dart';

void main() async {
  var app = Protevus();
  var http = ProtevusHttp(app);

  app.get('/', (req, res) => res.write('Hello, Protevus!'));

  await http.startServer('localhost', 3000);
  print('Server listening at http://localhost:3000');
}
```
6. **Run your application**:
```shell
dart run bin/my_protevus_app.dart
```
Visit http://localhost:3000 in your browser to see your Protevus app in action!

## Documentation
Comprehensive documentation for Protevus Platform is available at protevus.com/docs/platform. The documentation covers installation, configuration, usage, and advanced topics, including guides and examples.

## Plugins and Packages
Protevus Platform offers a wide range of official plugins and packages to extend its functionality, building upon the Angel3 ecosystem and introducing new Laravel-inspired components.

## Community and Support
GitHub Discussions: github.com/protevus/platform/discussions
Twitter: @Protevus
Contributing
We welcome contributions from the community! Please read our CONTRIBUTING.md for guidelines on how to contribute to Protevus Platform.

## License
Protevus Platform is open-source software licensed under the MIT license.

## Acknowledgements
Protevus Platform is built upon the foundation of Angel3 and inspired by Laravel. We'd like to thank the creators and contributors of both these frameworks for their invaluable work in the web development ecosystem.