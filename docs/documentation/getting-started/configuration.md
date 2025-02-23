# Configuration

This guide explains how to configure and manage your development environment using Melos, our monorepo management tool.

## Melos Overview

We use Melos to manage our monorepo, which contains multiple packages and applications. Melos provides powerful tools for:
- Managing dependencies
- Running scripts across packages
- Coordinating builds
- Handling versioning
- Generating documentation
- Running tests

## Initial Setup

1. **Install Melos**
   ```bash
   dart pub global activate melos
   ```

2. **Bootstrap the Project**
   ```bash
   melos bs
   ```
   This command:
   - Links local dependencies
   - Sets up package dependencies
   - Prepares the development environment

## Available Commands

### Development Workflow

#### Analysis and Formatting
```bash
# Run static analysis
melos run analyze

# Format code
melos run format

# Check dependencies
melos run deps:check

# Upgrade dependencies
melos run deps:upgrade
```

#### Testing
```bash
# Run all tests
melos run test

# Run tests for specific packages
MELOS_SCOPE="package_name" melos run test:custom

# Run tests with coverage
melos run coverage

# Generate coverage report
melos run coverage_report
```

#### Code Generation
```bash
# Generate code for all packages
melos run generate

# Generate for specific packages
MELOS_SCOPE="package_name" melos run generate:custom

# Check if generation is needed
MELOS_SCOPE="package_name" melos run generate:check
```

### Documentation

#### API Documentation
```bash
# Generate docs for all packages
melos run docs:generate

# Generate docs for specific packages
MELOS_SCOPE="package_name" melos run docs:generate:custom

# Serve documentation
melos run docs:serve

# Serve docs for specific packages
MELOS_SCOPE="package_name" DOC_PORT=8080 melos run docs:serve:custom
```

### Project Creation

#### New Package or Application
```bash
# Create new package
melos run create -- --type dart --category package --name my_package

# Create new Flutter app
melos run create -- --type flutter --category app --name my_app
```

#### From Template
```bash
# Create from template
melos run template template_name:bloc_app type:flutter name:my_new_app
```

### Maintenance

#### Cleaning
```bash
# Clean all build artifacts and generated files
melos run clean
```

#### Publishing
```bash
# Check what would be published
melos run publish:check

# Publish packages
melos run publish
```

## Configuration File

Our `melos.yaml` defines the project structure and available commands:

```yaml
name: protevus_platform
repository: https://github.com/protevus/platform

# Package locations
packages:
  - packages/**
  - apps/**
  - examples/**

# Command configuration
command:
  version:
    linkToCommits: true
    message: "chore: Bump version to %v"
    branch: dmz
    workspaceChangelog: true
```

## Package Categories

### Dart Packages
- **package**: Basic Dart package
- **console**: Command-line application
- **server**: Server-side application
- **desktop**: Desktop application
- **plugin**: Dart plugin

### Flutter Packages
- **app**: Mobile application
- **web**: Web application
- **desktop**: Desktop application
- **plugin**: Flutter plugin
- **module**: Flutter module
- **package**: Flutter package

## Environment Variables

### MELOS_SCOPE
Used to target specific packages:
```bash
MELOS_SCOPE="package_name" melos run test:custom
```

### DOC_PORT
Configure documentation server port:
```bash
DOC_PORT=8080 melos run docs:serve:custom
```

## Continuous Integration

Run the full CI pipeline:
```bash
melos run ci
```

This executes:
- Static analysis
- Tests
- Coverage reporting

## Best Practices

1. **Package Organization**
   - Keep related packages together
   - Use consistent naming
   - Follow standard layouts

2. **Dependency Management**
   - Regularly check for updates
   - Maintain version constraints
   - Use override carefully

3. **Code Generation**
   - Run generation after changes
   - Verify generated files
   - Keep generators updated

4. **Testing**
   - Write comprehensive tests
   - Maintain coverage
   - Test across packages

## Troubleshooting

### Common Issues

1. **Bootstrap Failures**
   ```bash
   melos clean
   melos bootstrap
   ```

2. **Generation Issues**
   ```bash
   # Clean generated files
   melos run clean
   # Regenerate
   melos run generate
   ```

3. **Dependency Conflicts**
   ```bash
   # Check outdated deps
   melos run deps:check
   # Update selectively
   MELOS_SCOPE="package_name" melos run deps:upgrade:custom
   ```

### Debug Commands

```bash
# Debug package names
melos run debug_pkg_name

# Debug package paths
melos run debug_pkg_path

# Debug reflectable files
MELOS_SCOPE="package_name" melos run debug:reflectable
```

## Additional Resources

- [Melos Documentation](https://melos.invertase.dev/)
- [Package Development Guide](/documentation/digging-deeper/package-development.md)
- [Contributing Guide](/documentation/prologue/contributing-guide.md)
- [Release Process](/releases/release-process.md)
