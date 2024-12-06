import 'package:platform_contracts/contracts.dart' hide Container;
import 'package:platform_container/platform_container.dart';

abstract class PaymentGateway {
  void processPayment(double amount);
}

class StripeGateway implements PaymentGateway {
  final String apiKey;

  StripeGateway(this.apiKey);

  @override
  void processPayment(double amount) {
    print('Processing \$$amount via Stripe');
  }
}

class PayPalGateway implements PaymentGateway {
  @override
  void processPayment(double amount) {
    print('Processing \$$amount via PayPal');
  }
}

class PaymentService {
  final PaymentGateway gateway;

  PaymentService(this.gateway);

  void makePayment(double amount) {
    gateway.processPayment(amount);
  }
}

/// Example reflector implementation
class ExampleReflector implements ReflectorContract {
  @override
  ClassMirror? reflectClass(Type type) {
    // Implementation
    return null;
  }

  @override
  TypeMirror reflectType(Type type) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  InstanceMirror reflect(Object object) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  LibraryMirror reflectLibrary(Uri uri) {
    // Implementation
    throw UnimplementedError();
  }

  @override
  dynamic createInstance(
    Type type, {
    List<dynamic>? positionalArgs,
    Map<String, dynamic>? namedArgs,
    String? constructorName,
  }) {
    // Implementation
    throw UnimplementedError();
  }
}

void main() {
  // Create container with example reflector
  final container = Container(ExampleReflector());

  // Register dependencies
  container.bind<PaymentGateway>((c) => StripeGateway('sk_test_123'));
  container.bind<PaymentService>((c) => PaymentService(
        c.make<PaymentGateway>(),
      ));

  // Resolve service and make payment
  final service = container.make<PaymentService>();
  service.makePayment(99.99);

  // Override gateway for testing
  final testContainer = container.createChild();
  testContainer.bind<PaymentGateway>((c) => PayPalGateway());

  // Test with PayPal gateway
  final testService = testContainer.make<PaymentService>();
  testService.makePayment(99.99);
}
