import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:ioc_container/container.dart';
import 'package:platform_contracts/contracts.dart';

class MockContainer extends Mock implements Container {}

class TestClass {
  String testMethod(String param) => 'Test: $param';
  static String staticMethod(String param) => 'Static: $param';
  String __invoke(String param) => 'Invoke: $param';
}

class DependencyClass {
  final String value;
  DependencyClass(this.value);
}

class ClassWithDependency {
  String methodWithDependency(DependencyClass dep, String param) =>
      '${dep.value}: $param';
}

class NestedDependency {
  final DependencyClass dep;
  NestedDependency(this.dep);
  String nestedMethod(String param) => '${dep.value} nested: $param';
}

class ClassWithOptionalParam {
  String methodWithOptional(String required, [String optional = 'default']) =>
      '$required - $optional';
}

void main() {
  group('Container.call', () {
    late MockContainer container;

    setUp(() {
      container = MockContainer();
    });

    test('call with Function', () {
      var result = container.call((String s) => 'Hello $s', ['World']);
      expect(result, equals('Hello World'));
    });

    test('call with class@method string', () {
      when(container.make('TestClass')).thenReturn(TestClass());
      var result = container.call('TestClass@testMethod', ['World']);
      expect(result, equals('Test: World'));
    });

    test('call with List callback', () {
      when(container.make('TestClass')).thenReturn(TestClass());
      var result = container.call(['TestClass', 'testMethod'], ['World']);
      expect(result, equals('Test: World'));
    });

    test('call with static method', () {
      when(container.make('TestClass')).thenReturn(TestClass);
      var result = container.call(['TestClass', 'staticMethod'], ['World']);
      expect(result, equals('Static: World'));
    });

    test('call with Map instance and method key', () {
      var mapInstance = {'testMethod': (String s) => 'Map: $s'};
      when(container.make('TestMap')).thenReturn(mapInstance);
      var result = container.call(['TestMap', 'testMethod'], ['World']);
      expect(result, equals('Map: World'));
    });

    test('call with global function', () {
      when(container.make('globalFunction')).thenReturn(globalFunction);
      var result = container.call('globalFunction', ['World']);
      expect(result, equals('Global: World'));
    });

    test('call with default method', () {
      when(container.make('TestClass')).thenReturn(TestClass());
      var result = container.call('TestClass', ['World'], '__invoke');
      expect(result, equals('Invoke: World'));
    });

    test('call with __invoke method', () {
      when(container.make('TestClass')).thenReturn(TestClass());
      var result = container.call('TestClass', ['World']);
      expect(result, equals('Invoke: World'));
    });

    test('call with non-existent method throws BindingResolutionException', () {
      when(container.make('TestClass')).thenReturn(TestClass());
      expect(() => container.call('TestClass@nonExistentMethod', ['World']),
          throwsA(isA<BindingResolutionException>()));
    });

    test('call with invalid callback type throws ArgumentError', () {
      expect(
          () => container.call(123, ['World']), throwsA(isA<ArgumentError>()));
    });

    test('call method with dependencies', () {
      when(container.make('ClassWithDependency'))
          .thenReturn(ClassWithDependency());
      when(container.make('DependencyClass'))
          .thenReturn(DependencyClass('Dependency'));
      var result = container
          .call(['ClassWithDependency', 'methodWithDependency'], ['World']);
      expect(result, equals('Dependency: World'));
    });

    test('call method with overridden dependency', () {
      when(container.make('ClassWithDependency'))
          .thenReturn(ClassWithDependency());
      when(container.make('DependencyClass'))
          .thenReturn(DependencyClass('Dependency'));
      var result = container.call(
          ['ClassWithDependency', 'methodWithDependency'],
          [DependencyClass('Override'), 'World']);
      expect(result, equals('Override: World'));
    });

    test('call method with nested dependency', () {
      when(container.make('NestedDependency'))
          .thenReturn(NestedDependency(DependencyClass('NestedDep')));
      var result =
          container.call(['NestedDependency', 'nestedMethod'], ['World']);
      expect(result, equals('NestedDep nested: World'));
    });

    test('call method with optional parameter - provided', () {
      when(container.make('ClassWithOptionalParam'))
          .thenReturn(ClassWithOptionalParam());
      var result = container.call(
          ['ClassWithOptionalParam', 'methodWithOptional'],
          ['Required', 'Provided']);
      expect(result, equals('Required - Provided'));
    });

    test('call method with optional parameter - default', () {
      when(container.make('ClassWithOptionalParam'))
          .thenReturn(ClassWithOptionalParam());
      var result = container
          .call(['ClassWithOptionalParam', 'methodWithOptional'], ['Required']);
      expect(result, equals('Required - default'));
    });

    test(
        'call method with missing required dependency throws BindingResolutionException',
        () {
      when(container.make('ClassWithDependency'))
          .thenReturn(ClassWithDependency());
      when(container.make('DependencyClass'))
          .thenThrow(BindingResolutionException('DependencyClass not found'));
      expect(
          () => container
              .call(['ClassWithDependency', 'methodWithDependency'], ['World']),
          throwsA(isA<BindingResolutionException>()));
    });
  });
}

String globalFunction(String param) => 'Global: $param';
