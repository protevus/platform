# Directory Structure

This guide explains the directory structure of our monorepo, which is managed using Melos. Understanding this structure is crucial for effective development and contribution.

## Root Directory

```
platform/
├── apps/               # Application projects
├── packages/           # Core packages
├── examples/           # Example applications
├── docs/              # Documentation
├── helpers/           # Development helper scripts
├── scripts/           # Build and maintenance scripts
├── templates/         # Project templates
├── tests/            # Global test utilities
├── resources/        # Shared resources
├── devops/           # DevOps configurations
│   ├── docker/       # Docker configurations
│   ├── k8s/          # Kubernetes configurations
│   └── scripts/      # DevOps scripts
├── config/           # Global configuration
├── melos.yaml        # Monorepo configuration
└── mkdocs.yml        # Documentation site configuration
```

## Core Directories

### Packages Directory (`packages/`)

Contains all core packages of the platform:

```
packages/
├── auth/             # Authentication package
├── broadcasting/     # Broadcasting system
├── builder/         # Build system tools
├── bus/             # Message bus implementation
├── cache/           # Caching system
├── cli/             # Command-line tools
├── collections/     # Collection utilities
├── concurrency/     # Concurrency utilities
├── conditionable/   # Conditional logic
├── config/          # Configuration management
├── console/         # Console application tools
├── container/       # Service container
├── contracts/       # Core interfaces
├── cookie/          # Cookie handling
├── database/        # Database abstraction
├── dbo/             # Database operations
├── encryption/      # Encryption utilities
├── events/          # Event system
├── filesystem/      # File system operations
├── foundation/      # Core foundation
├── hashing/         # Hashing utilities
├── http/            # HTTP client/server
├── log/             # Logging system
├── macroable/       # Macro functionality
├── mail/            # Email handling
├── migration/       # Database migrations
├── mirrors/         # Reflection system
├── notifications/   # Notification system
├── pagination/      # Pagination handling
├── pipeline/        # Pipeline pattern
├── process/         # Process management
├── queue/           # Queue system
├── routing/         # Routing system
├── session/         # Session handling
├── storage/         # File storage
├── support/         # Support utilities
├── testing/         # Testing framework
├── translation/     # Internationalization
├── validation/      # Validation system
├── view/            # View rendering
└── websocket/       # WebSocket handling
```

### Applications Directory (`apps/`)

Contains full applications built with the platform:

```
apps/
├── api/            # API applications
├── web/            # Web applications
├── mobile/         # Mobile applications
└── desktop/        # Desktop applications
```

### Examples Directory (`examples/`)

Contains example applications and usage demonstrations:

```
examples/
├── example-app/    # Full example application
└── sample-app/     # Simple sample application
```

### Documentation Directory (`docs/`)

Organized documentation structure:

```
docs/
├── assets/         # Documentation assets
├── blog/           # Blog posts
├── developers/     # Developer guides
├── documentation/  # Main documentation
├── ecosystem/      # Platform ecosystem
├── foundation/     # Foundation concepts
├── insiders/       # Insiders program
├── notes/          # Development notes
└── releases/       # Release information
```

### Helper Scripts (`helpers/`)

Development utilities and tools:

```
helpers/
├── config/         # Helper configurations
├── tools/          # Development tools
├── utils/          # Utility scripts
└── README.md       # Helper documentation
```

### Build Scripts (`scripts/`)

Essential build and maintenance scripts:

```
scripts/
├── bootstrap       # Project bootstrap
├── cibuild        # CI build script
├── console        # Console utilities
├── server         # Development server
├── setup          # Environment setup
├── test           # Test runner
└── update         # Update script
```

## Configuration Files

### Melos Configuration (`melos.yaml`)

Defines monorepo management:
- Package locations
- Script definitions
- Version management
- Publishing configuration

### Documentation Configuration (`mkdocs.yml`)

Controls documentation site:
- Site structure
- Navigation
- Themes
- Plugins

## Development Workflow

1. **Package Development**
   - Work in `packages/` directory
   - Follow package structure
   - Use Melos commands

2. **Application Development**
   - Work in `apps/` directory
   - Use platform packages
   - Follow app structure

3. **Example Development**
   - Work in `examples/` directory
   - Demonstrate features
   - Provide usage patterns

4. **Documentation**
   - Update relevant docs
   - Follow doc structure
   - Use MkDocs format

## Best Practices

1. **Package Organization**
   - Keep related code together
   - Follow naming conventions
   - Maintain separation of concerns

2. **Resource Management**
   - Use shared resources
   - Follow asset structure
   - Maintain consistency

3. **Documentation**
   - Update as you code
   - Follow doc standards
   - Keep examples current

4. **Script Management**
   - Use helper scripts
   - Follow script patterns
   - Document usage

## Common Operations

### Creating New Components

1. **New Package**
   ```bash
   melos run create -- --type dart --category package --name my_package
   ```

2. **New Application**
   ```bash
   melos run create -- --type flutter --category app --name my_app
   ```

3. **From Template**
   ```bash
   melos run template template_name:bloc_app type:flutter name:my_new_app
   ```

### Managing Structure

1. **Clean Project**
   ```bash
   melos run clean
   ```

2. **Update Dependencies**
   ```bash
   melos run deps:upgrade
   ```

3. **Generate Documentation**
   ```bash
   melos run docs:generate
   ```

## Additional Resources

- [Configuration Guide](/documentation/getting-started/configuration.md)
- [Package Development](/documentation/digging-deeper/package-development.md)
- [Contributing Guide](/documentation/prologue/contributing-guide.md)
- [Melos Documentation](https://melos.invertase.dev/)
