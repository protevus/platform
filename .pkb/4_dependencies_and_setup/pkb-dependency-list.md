# Protevus Platform Dependency List

This document outlines the dependencies required for the Protevus Platform and its various components. It serves as a reference for developers and maintainers to ensure that all necessary dependencies are installed and up-to-date.

## Core Dependencies

The following dependencies are required for the core functionality of the Protevus Platform:

- **Dart SDK** (version X.X.X or later)
- **package:http** (version X.X.X)
- **package:path** (version X.X.X)
- **package:logging** (version X.X.X)
- **package:yaml** (version X.X.X)

## Database Dependencies

If you plan to use the database functionality of the Protevus Platform, you will need the following additional dependencies:

- **package:sqflite** (version X.X.X)
- **package:sqlite3** (version X.X.X)
- **package:mysql1** (version X.X.X)
- **package:postgresql** (version X.X.X)

## Web Server Dependencies

For running the Protevus Platform as a web server, you will need the following dependencies:

- **package:shelf** (version X.X.X)
- **package:shelf_router** (version X.X.X)
- **package:shelf_static** (version X.X.X)

## Templating Dependencies

If you plan to use the templating engine of the Protevus Platform, you will need the following additional dependencies:

- **package:mustache** (version X.X.X)
- **package:jinja** (version X.X.X)

## Testing Dependencies

For running tests and ensuring code quality, you will need the following dependencies:

- **package:test** (version X.X.X)
- **package:mockito** (version X.X.X)
- **package:coverage** (version X.X.X)

## Development Dependencies

The following dependencies are recommended for development purposes:

- **package:build_runner** (version X.X.X)
- **package:build_web_compilers** (version X.X.X)
- **package:webdev** (version X.X.X)

Please note that the specific versions of these dependencies may change over time. It is recommended to refer to the project's documentation or the `pubspec.yaml` file for the most up-to-date version information.

Additionally, some dependencies may have transitive dependencies that will be automatically installed when you install the listed dependencies.

