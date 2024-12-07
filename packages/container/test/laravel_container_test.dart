import 'package:platform_contracts/contracts.dart' hide ContainerContract;
import 'package:platform_container/platform_container.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'laravel_container_test.mocks.dart';

// Test classes
abstract class PaymentGateway {}

class StripeGateway implements PaymentGateway {}

class PayPalGateway implements PaymentGateway {}

class Service {}

class SpecialService extends Service {}

class Client {
  final Service service;
  Client(this.service);
}

@GenerateMocks([
  ReflectorContract,
  ClassMirror,
  InstanceMirror,
  MethodMirror,
  TypeMirror,
  ParameterMirror
])
void main() {
  late Container container;
  late MockReflectorContract reflector;
  late MockClassMirror classMirror;
  late MockInstanceMirror instanceMirror;
  late MockMethodMirror methodMirror;
  late MockTypeMirror typeMirror;
  late MockParameterMirror parameterMirror;

  setUp(() {
    reflector = MockReflectorContract();
    classMirror = MockClassMirror();
    instanceMirror = MockInstanceMirror();
    methodMirror = MockMethodMirror();
    typeMirror = MockTypeMirror();
    parameterMirror = MockParameterMirror();
    container = Container(reflector);

    // Setup default reflection behavior
    when(reflector.reflectClass(any)).thenReturn(null);
    when(reflector.reflect(any)).thenReturn(instanceMirror);
    when(reflector.reflectType(any)).thenReturn(typeMirror);

    // Setup class mirror behavior
    when(classMirror.newInstance(any, any, any)).thenReturn(instanceMirror);
    when(classMirror.instanceMembers)
        .thenReturn({Symbol('call'): methodMirror});

    // Setup instance mirror behavior
    when(instanceMirror.type).thenReturn(classMirror);
    when(instanceMirror.reflectee).thenReturn(null);
    when(instanceMirror.hasReflectee).thenReturn(true);

    // Setup method mirror behavior
    when(methodMirror.parameters).thenReturn([parameterMirror]);
    when(methodMirror.isRegularMethod).thenReturn(true);
    when(methodMirror.name).thenReturn('call');

    // Setup parameter mirror behavior
    when(parameterMirror.type).thenReturn(typeMirror);

    // Setup type mirror behavior
    when(typeMirror.reflectedType).thenReturn(Service);
  });

  group('Laravel Container', () {
    test('contextual binding with when/needs/give', () {
      // When we set up a contextual binding
      container.when(Client).needs<Service>().give(SpecialService());

      // Then the contextual binding should be used
      when(reflector.reflectClass(Client)).thenReturn(classMirror);
      when(classMirror.newInstance(Symbol.empty, []))
          .thenReturn(instanceMirror);
      when(instanceMirror.reflectee).thenReturn(Client(SpecialService()));

      final client = container.make<Client>();
      expect(client.service, isA<SpecialService>());
    });

    test('method injection with call', () {
      void method(Service service) {}

      // Setup reflection mocks
      when(reflector.reflect(method)).thenReturn(instanceMirror);
      when(instanceMirror.type).thenReturn(classMirror);
      when(classMirror.instanceMembers)
          .thenReturn({Symbol('call'): methodMirror});
      when(methodMirror.parameters).thenReturn([parameterMirror]);
      when(parameterMirror.type).thenReturn(typeMirror);
      when(typeMirror.reflectedType).thenReturn(Service);

      // Register service
      final service = Service();
      container.registerSingleton(service);

      // When we call the method through the container
      container.call(method);

      // Then dependencies should be injected
      verify(reflector.reflect(method)).called(1);
    });

    test('resolution hooks', () {
      // Given some resolution hooks
      final resolving = <String>[];
      final testValue = 'test';

      // Register hooks with explicit type parameters
      void beforeCallback(ContainerBase c, String? i) =>
          resolving.add('before');
      void resolvingCallback(ContainerBase c, String i) =>
          resolving.add('resolving');
      void afterCallback(ContainerBase c, String i) => resolving.add('after');

      container.beforeResolving<String>(beforeCallback);
      container.resolving<String>(resolvingCallback);
      container.afterResolving<String>(afterCallback);

      // Register a value to resolve
      container.registerSingleton<String>(testValue);

      // When we resolve a type
      container.make<String>();

      // Then hooks should be called in order
      expect(resolving, equals(['before', 'resolving', 'after']));
    });

    test('method binding', () {
      // Setup reflection mocks
      when(reflector.reflect(any)).thenReturn(instanceMirror);
      when(methodMirror.parameters).thenReturn([]);

      // Register a method
      String boundMethod() => 'bound';
      container.bindMethod('test', boundMethod);

      // Call a test method
      String testMethod() => 'test';
      final result = container.call(testMethod);

      // Verify the method was called
      verify(reflector.reflect(any)).called(1);
      expect(result, equals('test'));
    });

    test('tagged bindings', () {
      // Create gateway instances
      final stripeGateway = StripeGateway();
      final paypalGateway = PayPalGateway();

      // Register factories for concrete types
      container.registerFactory<StripeGateway>((c) => stripeGateway);
      container.registerFactory<PayPalGateway>((c) => paypalGateway);

      // Register types in order
      container.tag([StripeGateway, PayPalGateway], 'gateways');

      // When we resolve tagged bindings
      final gateways = container.tagged<PaymentGateway>('gateways');

      // Then all tagged instances should be returned in order
      expect(gateways.length, equals(2));
      expect(gateways[0], same(stripeGateway));
      expect(gateways[1], same(paypalGateway));
    });

    test('shared bindings', () {
      // Given a shared binding
      container.bind<String>((c) => 'test', shared: true);

      // When we resolve multiple times
      final first = container.make<String>();
      final second = container.make<String>();

      // Then the same instance should be returned
      expect(identical(first, second), isTrue);
    });

    test('child container inherits bindings', () {
      // Given a parent binding
      container.bind<String>((c) => 'parent');

      // When we create a child container
      final child = container.createChild();

      // Then the child should inherit bindings
      expect(child.make<String>(), equals('parent'));
    });

    test('child container can override bindings', () {
      // Given a parent binding
      container.registerFactory<String>((c) => 'parent');

      // When we override in child
      final child = container.createChild();
      child.registerFactory<String>((c) => 'child');

      // Then child should use its own binding
      expect(child.make<String>(), equals('child'));
      expect(container.make<String>(), equals('parent'));
    });

    test('scoped bindings', () {
      // Given a scoped binding
      var counter = 0;
      container.scoped<String>((c) => 'scoped${counter++}');

      // When we resolve multiple times
      final first = container.make<String>();
      final second = container.make<String>();

      // Then the same instance should be returned
      expect(first, equals(second));

      // When we forget scoped instances
      container.forgetScopedInstances();

      // Then a new instance should be created
      final third = container.make<String>();
      expect(third, isNot(equals(second)));
    });

    test('type aliases', () {
      // Given a binding and an alias
      container.bind<PaymentGateway>((c) => StripeGateway());
      container.alias(PaymentGateway, StripeGateway);

      // When we check if it's an alias
      final isAlias = container.isAlias('StripeGateway');

      // Then it should be true
      expect(isAlias, isTrue);

      // And the alias should resolve to the original type
      expect(container.getAlias(StripeGateway), equals(PaymentGateway));
    });

    test('extending instances', () {
      print('Starting extending instances test');

      // Given a binding and an extender
      var extended = false;
      print('Setting up binding and extender');
      container.bind<Service>((c) => Service());
      container.extend(Service, (instance) {
        print('Extender called');
        extended = true;
      });

      print('Making instance');
      // When we make an instance
      container.make<Service>();

      print('Extended value: $extended');
      // Then the extender should be called
      expect(extended, isTrue);

      // And we can get the extenders
      expect(container.getExtenders(Service).length, equals(1));

      // And we can forget them
      container.forgetExtenders(Service);
      expect(container.getExtenders(Service).length, equals(0));
    });

    test('rebinding callbacks', () {
      // Given a binding and a rebind callback
      var rebound = false;
      container.bind<Service>((c) => Service());
      container.rebinding(Service, (c, i) => rebound = true);

      // When we refresh an instance
      final target = {'method': (Service s) {}};
      container.refresh(Service, target, 'method');

      // Then the callback should be called
      expect(rebound, isTrue);
    });

    test('container flushing', () {
      // Given some bindings and instances
      container.bind<Service>((c) => Service());
      container.registerSingleton(PayPalGateway());
      container.registerNamedSingleton('test', 'value');
      container.tag([Service], 'services');
      container.when(Client).needs<Service>().give(SpecialService());
      container.bindMethod('test', () {});
      container.alias(PaymentGateway, PayPalGateway);
      container.extend(Service, (i) {});
      container.rebinding(Service, (c, i) {});
      container.scoped<String>((c) => 'scoped');
      container.beforeResolving<Service>((c, i) {});

      // When we flush the container
      container.flush();

      // Then everything should be cleared
      expect(container.has<Service>(), isFalse);
      expect(container.hasNamed('test'), isFalse);
      expect(() => container.tagged('services'), throwsStateError);
      expect(container.getExtenders(Service).length, equals(0));
    });
  });
}
