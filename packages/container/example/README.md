# Laravel Container Examples

These examples demonstrate how to use the Laravel-style dependency injection container in Dart.

## Basic Container Features (container_usage.dart)

Shows core container features using a payment processing example:

```dart
// Basic binding
container.bind<PaymentGateway>((c) => StripeGateway(c.make<String>()));

// Singleton registration
container.singleton<PaymentService>((c) => PaymentService(c.make<PaymentGateway>()));

// Contextual binding
container.when(PaymentService)
  .needs<PaymentGateway>()
  .give(PayPalGateway());

// Tagged services
container.tag([StripeGateway, PayPalGateway], 'gateways');
final gateways = container.tagged<PaymentGateway>('gateways');

// Instance extending
container.extend(PaymentGateway, (gateway) {
  print('Payment gateway was created');
});
```

Run with:
```bash
dart run container_usage.dart
```

## Advanced Container Features (advanced_usage.dart)

Demonstrates advanced container capabilities:

```dart
// Child containers
final rootContainer = IlluminateContainer(reflector);
rootContainer.singleton<Logger>((c) => ProductionLogger());

final testContainer = rootContainer.createChild();
testContainer.singleton<Logger>((c) => TestLogger());

// Scoped bindings
container.scoped<RequestScope>((c) => RequestScope());
container.bind<UserRepository>((c) => UserRepository(
  c.make<Logger>(),
  c.make<RequestScope>()
));

// Scope lifecycle
final repo1 = container.make<UserRepository>();
final repo2 = container.make<UserRepository>();
assert(identical(repo1.scope, repo2.scope)); // Same scope

container.forgetScopedInstances(); // Clear scope

final repo3 = container.make<UserRepository>();
assert(!identical(repo1.scope, repo3.scope)); // New scope
```

Run with:
```bash
dart run advanced_usage.dart
```

## Application Architecture (app_example.dart)

Shows how to use the container in a real application:

```dart
// Register repositories
container.singleton<UserRepository>((c) => DatabaseUserRepository());

// Register services
container.singleton<EmailService>((c) => EmailService());
container.singleton<UserService>((c) => UserService(
  c.make<UserRepository>(),
  c.make<EmailService>()
));

// Register controllers
container.singleton<UserController>((c) => UserController(
  c.make<UserService>()
));

// Use the application
final controller = container.make<UserController>();
controller.createUser('John Doe', 'john@example.com');
```

Run with:
```bash
dart run app_example.dart
```

## Key Features Demonstrated

1. Dependency Registration
   - Basic bindings
   - Singleton registration
   - Factory bindings
   - Instance registration
   - Scoped bindings

2. Service Resolution
   - Automatic dependency injection
   - Contextual binding
   - Tagged services
   - Instance extending

3. Container Features
   - Child containers
   - Scope management
   - Service location
   - Interface binding

4. Architecture Patterns
   - Repository pattern
   - Service layer
   - Dependency injection
   - Interface segregation
