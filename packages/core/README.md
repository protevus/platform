# Protevus Framework

[![Protevus Framework](../../angel3_logo.png)](https://github.com/dart-backend/angel)

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/angel3_framework?include_prereleases)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Gitter](https://img.shields.io/gitter/room/angel_dart/discussion)](https://gitter.im/angel_dart/discussion)
[![License](https://img.shields.io/github/license/dart-backend/angel)](https://github.com/dart-backend/angel/tree/master/packages/framework/LICENSE)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

Protevus framework is a high-powered HTTP server with support for dependency injection, sophisticated routing, authentication, ORM, graphql etc. It is designed to keep the core minimal but extensible through a series of plugin packages. It won't dictate which features, databases or web templating engine to use. This flexibility enable Protevus framework to grow with your application as new features can be added to handle the new use cases.

This package is the core package of [Protevus](https://github.com/dart-backend/angel). For more information, visit us at [Protevus Website](https://angel3-framework.web.app).

## Installation and Setup

### (Option 1) Create a new project by cloning from boilerplate templates

1. Download and install [Dart](https://dart.dev/get-dart)

2. Clone one of the following starter projects:
   * [Protevus Basic Template](https://github.com/dukefirehawk/boilerplates/tree/v7/angel3-basic)
   * [Protevus ORM Template](https://github.com/dukefirehawk/boilerplates/tree/v7/angel3-orm)
   * [Protevus ORM MySQL Template](https://github.com/dukefirehawk/boilerplates/tree/v7/angel3-orm-mysql)
   * [Protevus Graphql Template](https://github.com/dukefirehawk/boilerplates/tree/v7/angel3-graphql)

3. Run the project in development mode (*hot-reloaded* is enabled on file changes).

   ```bash
   dart --observe bin/dev.dart
   ```

4. Run the project in production mode (*hot-reloaded* is disabled).

   ```bash
   dart bin/prod.dart
   ```

5. Run as docker. Edit and build the image with the provided `Dockerfile` file.

### (Option 2) Create a new project with Protevus CLI

1. Download and install [Dart](https://dart.dev/get-dart)

2. Install the [Protevus CLI](https://pub.dev/packages/angel3_cli):

   ```bash
   dart pub global activate angel3_cli
   ```

3. On terminal, create a new project:

   ```bash
   angel3 init hello
   ```

4. Run the project in development mode (*hot-reloaded* is enabled on file changes).

   ```bash
   dart --observe bin/dev.dart
   ```

5. Run the project in production mode (*hot-reloaded* is disabled).

   ```bash
   dart bin/prod.dart
   ```

6. Run as docker. Edit and build the image with the provided `Dockerfile` file.

## Performance Benchmark

The performance benchmark can be found at

[TechEmpower Framework Benchmarks Round 21](https://www.techempower.com/benchmarks/#section=data-r21&test=composite)

### Migrating from Angel to Protevus

Check out [Migrating to Protevus](https://angel3-docs.dukefirehawk.com/migration/angel-2.x.x-to-angel3/migration-guide-3)

## Donation & Support

If you like this project and interested in supporting its development, you can make a donation using the following services:

* [![GitHub](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/dukefirehawk)
* [paypal](https://paypal.me/dukefirehawk?country.x=MY&locale.x=en_US) service