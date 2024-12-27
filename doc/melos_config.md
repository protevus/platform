```markdown
# Protevus Platform Melos Configuration Documentation

## Table of Contents
- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Setup and Configuration](#setup-and-configuration)
- [Version Control Integration](#version-control-integration)
- [Project Management](#project-management)
- [Development Workflow](#development-workflow)
- [Testing and Coverage](#testing-and-coverage)
- [Documentation](#documentation)
- [Code Generation](#code-generation)
- [Dependency Management](#dependency-management)
- [CI/CD](#cicd)
- [Debugging and Utilities](#debugging-and-utilities)
- [Advanced Usage](#advanced-usage)
- [Best Practices](#best-practices)

## Overview
The Protevus Platform uses Melos to manage our monorepo structure and automate various development tasks. This comprehensive guide outlines the features provided by our Melos configuration and provides detailed instructions on how to use them effectively.

### Project Information
- Project name: `protevus_platform`
- Repository: `https://github.com/protevus/platform`

### Directory Structure
```
project/
├── apps/        # Flutter applications
├── packages/    # Dart/Flutter packages
├── examples/    # Example projects
├── templates/   # Project templates
├── tools/       # Build and maintenance scripts
└── config/      # Configuration files
```

## Setup and Configuration

### Initial Setup
```bash
# Configure the entire development environment
melos run configure
```

This command performs a comprehensive setup:
1. Bootstraps the workspace
2. Generates code for platform_container_generator
3. Creates dummy tests for specific packages
4. Runs reflectable debugging
5. Executes test suite
6. Generates coverage reports
7. Creates API documentation

### IDE Integration
- IntelliJ integration is disabled to prevent conflicts with our custom setup.

### Configuration Management
```bash
# Combine configuration files
melos run combine_config
```

Combines multiple configuration files:
- analyze.yaml
- generate.yaml
- publish.yaml
- docs.yaml
- coverage.yaml
- clean.yaml
- configure.yaml
- test.yaml
- create.yaml
- dependencies.yaml
- ci.yaml
- debug.yaml
- utils.yaml

## Version Control Integration

### Version Management
- Version bump commit message format: "chore: Bump version to %v"
- Main versioning branch: `main`
- Changelog features:
  - Version commits are linked
  - Workspace-level changelog generation

Example version management:
```bash
# Standard version bump
melos version --yes

# Specific version bump
melos version 1.2.3 --yes

# Prerelease version
melos version prerelease --preid beta --yes
```


## Project Management

### Creating New Projects

#### Standard Project Creation
```bash
melos run create -- --type <dart|flutter> --category <category> --name <name>
```

##### Categories for Dart Projects:
- `package`: Standard Dart package
- `console`: Command-line application
- `server`: Server-side application with built-in dependencies:
  - shelf_router
  - dotenv
  - logger
- `desktop`: Desktop application with:
  - window_manager
  - screen_retriever
- `plugin`: Dart plugin package

##### Categories for Flutter Projects:
- `app`: Standard mobile application
- `web`: Web-optimized application
- `desktop`: Multi-platform desktop application
- `plugin`: Flutter plugin
- `module`: Add-to-app module
- `package`: Flutter-specific package

#### Template-Based Project Creation
```bash
melos run template template_name:<template> type:<dart|flutter> name:<project_name>
```

##### Template System Features:
- Templates stored in `templates/` directory
- Variable substitution using placeholders:
  - `{{PROJECT_NAME}}`: Raw project name
  - `{{PROJECT_NAME_SNAKE_CASE}}`: Snake case version
  - `{{PROJECT_NAME_PASCAL_CASE}}`: Pascal case version
  - `{{PROJECT_NAME_CAMEL_CASE}}`: Camel case version
  - `{{CREATION_TIMESTAMP}}`: Creation timestamp

Example template usage:
```bash
# Create a new Flutter app from the bloc_app template
melos run template template_name:bloc_app type:flutter name:my_new_app

# Create a new Dart package from a core template
melos run template template_name:core_package type:dart name:core_utils
```

## Development Workflow

### Static Analysis and Formatting

#### Code Analysis
```bash
# Run static analysis
melos run analyze
```

Example output:
```
Analyzing package_1...
No issues found!
Analyzing package_2...
info • Unused import • lib/src/unused_file.dart:3:8 • unused_import
```

#### Code Formatting
```bash
# Format all Dart files
melos run format

# Format and check for changes
melos run format -- -o write --set-exit-if-changed
```

### Code Generation

#### Generate for All Packages
```bash
# Run build_runner for all packages
melos run generate
```

Example output:
```
Running build_runner for package_1...
[INFO] Generating build script...
[INFO] Generating build script completed, took 304ms
[INFO] Running build...
[INFO] 5 outputs were generated
[INFO] Running build completed, took 2.8s
```

#### Generate for Specific Packages
```bash
# Run code generation for specified packages
MELOS_SCOPE="package_name1,package_name2" melos run generate:custom
```

#### Check Generation Status
```bash
# Check if code generation is needed
MELOS_SCOPE="package_name" melos run generate:check
```

Example output:
```
Checking auth_package...
Package auth_package needs code generation.
Checking user_package...
Package user_package does not use build_runner.
```

#### Generate Dummy Tests
```bash
# Generate dummy test files
MELOS_SCOPE="package_name" melos run generate:dummy:test
```

## Testing and Coverage

### Running Tests

#### All Packages
```bash
# Run all tests
melos run test
```

Example output:
```
Running tests for auth_package...
00:01 +10: All tests passed!
Running tests for user_package...
00:02 +15: All tests passed!
```

#### Specific Packages
```bash
# Run tests for specific packages
MELOS_SCOPE="package_name1,package_name2" melos run test:custom
```

### Coverage Tools

#### Generate Coverage
```bash
# Generate coverage reports
melos run coverage
```

Features:
- Adds coverage dependency temporarily
- Generates LCOV reports
- Removes coverage dependency after completion

#### Coverage Report
```bash
# Generate HTML coverage report
melos run coverage_report
```

Features:
- Generates HTML reports from LCOV data
- Creates detailed coverage visualization
- Provides package-level coverage metrics

## Documentation

### API Documentation Generation

#### Generate for All Packages

```bash
# Generate docs for all packages
melos run docs:generate


#### Generate for Specific Packages
```bash
# Generate docs for specific packages
MELOS_SCOPE="package_name1,package_name2" melos run docs:generate:custom

# Example
MELOS_SCOPE="core_package,utils_package" melos run docs:generate:custom
```

### Serving Documentation

#### Serve All Documentation
```bash
# Serve generated documentation
melos run docs:serve
```
After running, visit `http://localhost:8080` in your browser

#### Serve Specific Package Documentation
```bash
# Serve docs for specific packages with custom port
MELOS_SCOPE="package_name" DOC_PORT=8081 melos run docs:serve:custom

# Example
MELOS_SCOPE="api_package" DOC_PORT=8082 melos run docs:serve:custom
```

## Publishing

### Publishing Packages

#### Check Publication Status
```bash
# Dry run to check what would be published
melos run publish:check
```

Example output:
```
Would publish the following packages:
- auth_package (1.0.0 -> 1.0.1)
- user_package (2.1.0 -> 2.2.0)
```

#### Publish Packages
```bash
# Publish all changed packages
melos run publish
```

Recommended workflow:
```bash
# First, check what would be published
melos run publish:check
# If everything looks good, publish
melos run publish
```

## Dependency Management

### Checking Dependencies
```bash
# Check for outdated dependencies
melos run deps:check
```

Example output:
```
Checking dependencies for auth_package...
2 dependencies are out of date
Checking dependencies for user_package...
All dependencies up to date
```

### Upgrading Dependencies

#### All Packages
```bash
# Upgrade all dependencies
melos run deps:upgrade
```

#### Specific Packages
```bash
# Upgrade dependencies for specific packages
MELOS_SCOPE="package_name1,package_name2" melos run deps:upgrade:custom

# Example
MELOS_SCOPE="database_package,api_package" melos run deps:upgrade:custom
```

## CI/CD

### Continuous Integration
```bash
# Run full CI pipeline
melos run ci
```

This command runs:
1. Static analysis (`analyze`)
2. All tests (`test`)

Example GitHub Actions workflow:
```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: dart-lang/setup-dart@v1
      - run: dart pub global activate melos
      - run: melos bootstrap
      - run: melos run ci
```

### Maintenance and Cleanup

#### Clean Command
```bash
# Clean all generated files and build artifacts
melos run clean
```

The clean command removes:
- Build directories
- Generated files:
  - `.g.dart`
  - `.freezed.dart`
  - `.mocks.dart`
  - `.gr.dart`
  - `.config.dart`
  - `.reflectable.dart`
  - And many more
- Compilation artifacts:
  - `.g.aot`
  - `.g.ddc`
  - `.g.js`
  - `.g.js.map`
  - `.g.part`
  - `.g.sum`
  - `.g.txt`
- Coverage files and reports
- Documentation build files


## Debugging and Utility Scripts

### Package Information

#### Debug Package Names
```bash
# Show all package names
melos run debug_pkg_name
```

Example output:
```
Package name is auth_package
Package name is user_package
Package name is core_package
```

#### Debug Package Paths
```bash
# Show all package paths
melos run debug_pkg_path
```

Example output:
```
Package path is /home/user/protevus_platform/packages/auth_package
Package path is /home/user/protevus_platform/packages/user_package
```

### Code Analysis Tools

#### Debug Reflectable Files
```bash
# Find .reflectable.dart files
MELOS_SCOPE="package_name" melos run debug:reflectable

# Example
MELOS_SCOPE="core_package" melos run debug:reflectable
```

Example output:
```
Checking for .reflectable.dart files in core_package
/home/user/protevus_platform/packages/core_package/lib/src/models.reflectable.dart
```

#### List Dart Files
```bash
# List all Dart files in package(s)
MELOS_SCOPE="package_name" melos run list:dart:files
```

Example output:
```
Listing all Dart files in utils_package:
/home/user/protevus_platform/packages/utils_package/lib/src/string_utils.dart
/home/user/protevus_platform/packages/utils_package/lib/src/date_utils.dart
```

### Help System
```bash
# Display all available commands
melos run help
```

## Advanced Usage Examples

### Complex Workflows

#### Running Specific Test Patterns
```bash
# Run tests matching a pattern
MELOS_SCOPE="auth_package" melos run test:custom -- --name "login"
```

#### Documentation Workflow
```bash
# Generate and serve documentation
melos run docs:generate && melos run docs:serve
```

#### Dependency Update Workflow
```bash
# Check, upgrade, and test
melos run deps:check && melos run deps:upgrade && melos run test
```

#### Publishing Workflow
```bash
# Check and publish if everything is okay
melos run publish:check && melos run publish
```

#### CI and Documentation
```bash
# Run CI and generate docs if successful
melos run ci && melos run docs:generate
```

#### Multi-package Operations
```bash
# Upgrade dependencies and run tests for multiple packages
MELOS_SCOPE="auth_package,user_package,core_package" melos run deps:upgrade:custom && \
MELOS_SCOPE="auth_package,user_package,core_package" melos run test:custom
```

#### Code Generation and Verification
```bash
# Generate code, test, and check formatting
melos run generate && melos run test && melos run format -- -o none --set-exit-if-changed
```

## Best Practices

### Project Organization

1. **Directory Structure**
   - Place Flutter apps in `apps/`
   - Place packages in `packages/`
   - Keep examples in `examples/`
   - Store templates in `templates/`
   - Maintain tools in `tools/`

2. **Template Usage**
   - Use `.tmpl` extension for files requiring variable substitution
   - Document template variables in README files
   - Keep templates minimal and focused

3. **Configuration Management**
   - Keep configuration files modular in `config/` directory
   - Run `melos combine_config` after configuration changes
   - Use environment variables for flexible configuration

### Development Workflow

1. **Before Committing**
   ```bash
   melos run format
   melos run analyze
   melos run test
   ```

2. **After Dependency Changes**
   ```bash
   melos bootstrap
   melos run deps:check
   ```

3. **Before Publishing**
   ```bash
   melos run publish:check
   melos run test
   melos run docs:generate
   ```

### Code Quality

1. **Testing**
   - Maintain high test coverage
   - Run `melos run coverage` regularly
   - Review coverage reports

2. **Documentation**
   - Document all public APIs
   - Keep README files updated
   - Generate and review documentation

3. **Code Generation**
   - Check generation status before commits
   - Keep generated files up to date
   - Validate generated code

### Environment Variables

Key environment variables used across commands:
- `MELOS_SCOPE`: Target specific packages
- `DOC_PORT`: Custom documentation server port
- `MELOS_ROOT_PATH`: Root directory path
- `MELOS_PACKAGE_NAME`: Current package name
- `MELOS_PACKAGE_PATH`: Current package path

## Support and Resources

### Getting Help
1. Run `melos run help` for command documentation
2. Check package-specific README files
3. Review generated documentation
4. Consult the Melos documentation

### Common Issues
1. **Missing Dependencies**
   ```bash
   melos bootstrap
   ```

2. **Outdated Generated Code**
   ```bash
   melos run generate
   ```

3. **Configuration Issues**
   ```bash
   melos run combine_config
   ```

### Maintenance Tasks

Regular maintenance checklist:
1. Update dependencies regularly
2. Clean generated files periodically
3. Review and update documentation
4. Monitor test coverage
5. Validate templates
6. Check for outdated configurations

This completes the comprehensive documentation of the Protevus Platform Melos configuration system.
