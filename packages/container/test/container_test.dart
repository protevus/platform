import 'package:platform_contracts/contracts.dart';
import 'package:platform_container/platform_container.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'container_test.mocks.dart';

@GenerateMocks(
    [ReflectorContract, ReflectedTypeContract, ReflectedInstanceContract])
void main() {
  late IlluminateContainer container;
  late MockReflectorContract reflector;
  late MockReflectedTypeContract reflectedType;
  late MockReflectedInstanceContract reflectedInstance;

  setUp(() {
    reflector = MockReflectorContract();
    reflectedType = MockReflectedTypeContract();
    reflectedInstance = MockReflectedInstanceContract();
    container = IlluminateContainer(reflector);

    // Setup default reflection behavior
    when(reflector.reflectClass(any)).thenReturn(null);
  });

  group('Container', () {
    test('isRoot returns true for root container', () {
      expect(container.isRoot, isTrue);
    });

    test('isRoot returns false for child container', () {
      final child = container.createChild();
      expect(child.isRoot, isFalse);
    });

    test('has returns true for registered singleton', () {
      container.registerSingleton<String>('test');
      expect(container.has<String>(), isTrue);
    });

    test('has returns true for registered factory', () {
      container.registerFactory<String>((c) => 'test');
      expect(container.has<String>(), isTrue);
    });

    test('has returns true for registered lazy singleton', () {
      container.registerLazySingleton<String>((c) => 'test');
      expect(container.has<String>(), isTrue);
    });

    test('hasNamed returns true for registered named singleton', () {
      container.registerNamedSingleton<String>('test.name', 'test');
      expect(container.hasNamed('test.name'), isTrue);
    });

    test('make returns singleton instance', () {
      container.registerSingleton<String>('test');
      expect(container.make<String>(), equals('test'));
    });

    test('make creates new instance for factory', () {
      var count = 0;
      container.registerFactory<String>((c) => 'test${count++}');
      expect(container.make<String>(), equals('test0'));
      expect(container.make<String>(), equals('test1'));
    });

    test('make returns same instance for lazy singleton', () {
      var count = 0;
      container.registerLazySingleton<String>((c) => 'test${count++}');
      expect(container.make<String>(), equals('test0'));
      expect(container.make<String>(), equals('test0'));
    });

    test('makeAsync returns Future for async dependency', () async {
      // Setup mock behavior
      when(reflector.reflectFutureOf(String)).thenReturn(reflectedType);
      when(reflectedType.newInstance('', [])).thenReturn(reflectedInstance);
      when(reflectedInstance.reflectee).thenAnswer((_) => Future.value('test'));

      final result = await container.makeAsync<String>();
      expect(result, equals('test'));
    });

    test('findByName returns named singleton', () {
      container.registerNamedSingleton<String>('test.name', 'test');
      expect(container.findByName<String>('test.name'), equals('test'));
    });

    test('child container inherits parent bindings', () {
      container.registerSingleton<String>('test');
      final child = container.createChild();
      expect(child.make<String>(), equals('test'));
    });

    test('child container can override parent bindings', () {
      container.registerSingleton<String>('parent');
      final child = container.createChild() as IlluminateContainer;
      child.registerSingleton<String>('child');
      expect(child.make<String>(), equals('child'));
      expect(container.make<String>(), equals('parent'));
    });

    test('throws when making unregistered type without reflection', () {
      expect(() => container.make<String>(), throwsStateError);
    });

    test('throws when making named singleton that does not exist', () {
      expect(() => container.findByName<String>('missing'), throwsStateError);
    });

    test('throws when registering duplicate singleton', () {
      container.registerSingleton<String>('test');
      expect(
          () => container.registerSingleton<String>('test2'), throwsStateError);
    });

    test('throws when registering duplicate named singleton', () {
      container.registerNamedSingleton<String>('test.name', 'test');
      expect(
          () => container.registerNamedSingleton<String>('test.name', 'test2'),
          throwsStateError);
    });
  });
}
