import 'package:platform_contracts/contracts.dart';
import 'package:platform_container/platform_container.dart';

// Example services
abstract class PaymentGateway {
  void processPayment(double amount);
}

class StripeGateway implements PaymentGateway {
  final String apiKey;

  StripeGateway(this.apiKey);

  @override
  void processPayment(double amount) {
    print('Stripe: Processing \$$amount');
  }
}

class PayPalGateway implements PaymentGateway {
  @override
  void processPayment(double amount) {
    print('PayPal: Processing \$$amount');
  }
}

class PaymentService {
  final PaymentGateway gateway;

  PaymentService(this.gateway);

  void pay(double amount) {
    print('Payment requested');
    gateway.processPayment(amount);
  }
}

void main() {
  // Create container
  final container = IlluminateContainer(ExampleReflector());

  print('1. Basic Binding');
  // Register API key
  container.instance<String>('stripe-key-123');

  // Register payment gateway
  container.bind<PaymentGateway>((c) => StripeGateway(c.make<String>()));

  // Use the gateway
  final gateway = container.make<PaymentGateway>();
  gateway.processPayment(99.99);

  print('\n2. Singleton');
  // Register payment service as singleton
  container.singleton<PaymentService>(
      (c) => PaymentService(c.make<PaymentGateway>()));

  // Get same instance twice
  final service1 = container.make<PaymentService>();
  final service2 = container.make<PaymentService>();
  print('Same instance: ${identical(service1, service2)}');

  print('\n3. Contextual Binding');
  // Use PayPal for specific service
  container.when(PaymentService).needs<PaymentGateway>().give(PayPalGateway());

  // New service uses PayPal
  final paypalService = container.make<PaymentService>();
  paypalService.pay(49.99);

  print('\n4. Tagged Services');
  // Register concrete implementations
  container.bind<StripeGateway>((c) => StripeGateway(c.make<String>()));
  container.bind<PayPalGateway>((c) => PayPalGateway());

  // Tag payment gateways
  container.tag([StripeGateway, PayPalGateway], 'gateways');

  // Get all gateways
  final gateways = container.tagged<PaymentGateway>('gateways');
  print('Found ${gateways.length} payment gateways');

  // Use each gateway
  for (final gateway in gateways) {
    gateway.processPayment(29.99);
  }

  print('\n5. Extending Instances');
  // Add logging to payment gateway
  container.extend(PaymentGateway, (gateway) {
    print('Payment gateway was created');
  });

  // Extension runs when making instance
  final extendedGateway = container.make<PaymentGateway>();
  extendedGateway.processPayment(199.99);
}

/// Example reflector implementation
class ExampleReflector implements ReflectorContract {
  @override
  String? getName(Symbol symbol) => null;

  @override
  ReflectedClassContract? reflectClass(Type clazz) => null;

  @override
  ReflectedFunctionContract? reflectFunction(Function function) => null;

  @override
  ReflectedInstanceContract? reflectInstance(Object object) => null;

  @override
  ReflectedTypeContract reflectFutureOf(Type type) {
    throw UnsupportedError('Future reflection not needed for example');
  }

  @override
  ReflectedTypeContract? reflectType(Type type) => null;
}
