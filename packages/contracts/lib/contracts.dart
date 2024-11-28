/// Platform Contracts Library
///
/// This library provides the core contracts (interfaces) that define
/// the Platform framework's API. These contracts ensure consistency
/// and interoperability between components while enabling loose coupling
/// and dependency injection.

// Level 0: Core Foundation Contracts

// Container contracts (from packages/container)
export 'src/container/container.dart';

// Reflection contracts (from packages/container)
export 'src/reflection/reflection.dart';

// Pipeline contracts (from packages/pipeline)
export 'src/pipeline/pipeline.dart';

// Level 1: Infrastructure Contracts

// Events contracts (from packages/events)
export 'src/events/events.dart';

// Bus contracts (from packages/bus)
export 'src/bus/bus.dart';

// Model contracts (from packages/model)
export 'src/model/model.dart';

// Process contracts (from packages/process)
export 'src/process/process.dart';

// Support contracts (from packages/support)
export 'src/support/support.dart';

// Level 2: Core Services Contracts

// Queue contracts (from packages/queue)
export 'src/queue/queue.dart';

// Level 3: HTTP Layer Contracts

// Routing contracts (from packages/route)
export 'src/routing/routing.dart';

// HTTP contracts (from packages/core)
export 'src/http/http.dart';

// Testing Contracts

// Testing contracts (from packages/testing)
export 'src/testing/testing.dart';

// All contracts have been extracted from implemented packages:
// - Container & Reflection (Level 0)
// - Pipeline (Level 0)
// - Events (Level 1)
// - Bus (Level 1)
// - Model (Level 1)
// - Process (Level 1)
// - Support (Level 1)
// - Queue (Level 2)
// - Route (Level 3)
// - HTTP (Level 3)
// - Testing

// Next steps:
// 1. Update package dependencies to use these contracts
// 2. Implement contracts in each package
// 3. Add contract compliance tests
// 4. Document contract usage and patterns
