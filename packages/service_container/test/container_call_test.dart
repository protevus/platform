import 'package:test/test.dart';
import 'package:platform_service_container/service_container.dart';
import 'package:platform_contracts/contracts.dart';

void main() {
  group('ContainerCallTest', () {
    late Container container;

    setUp(() {
      container = Container();
    });

    test('testCallWithAtSignBasedClassReferencesWithoutMethodThrowsException',
        () {
      expect(() => container.call('ContainerCallTest@'),
          throwsA(isA<BindingResolutionException>()));
    });

    test('testCallWithAtSignBasedClassReferences', () {
      container.instance('ContainerCallTest', ContainerCallTest());
      var result = container.call('ContainerCallTest@work', ['foo', 'bar']);
      expect(result, equals('foobar'));
    });

    test('testCallWithAtSignBasedClassReferencesWithoutMethodCallsRun', () {
      container.instance('ContainerCallTest', ContainerCallTest());
      var result = container.call('ContainerCallTest');
      expect(result, equals('run'));
    });

    test('testCallWithCallableArray', () {
      var result =
          container.call([ContainerCallTest(), 'work'], ['foo', 'bar']);
      expect(result, equals('foobar'));
    });

    test('testCallWithStaticMethodNameString', () {
      expect(
          () => container.call('ContainerCallTest::staticWork', ['foo', 'bar']),
          throwsA(isA<BindingResolutionException>()));
    });

    test('testCallWithGlobalMethodNameString', () {
      expect(() => container.call('globalTestMethod', ['foo', 'bar']),
          throwsA(isA<BindingResolutionException>()));
    });

    test('testCallWithBoundMethod', () {
      container.bindMethod('work', (container, params) => 'foobar');
      var result = container.call('work', ['foo', 'bar']);
      expect(result, equals('foobar'));
    });

    test('testCallWithBoundMethodAndArrayOfParameters', () {
      container.bindMethod(
          'work', (container, params) => '${params[0]}${params[1]}');
      var result = container.call('work', ['foo', 'bar']);
      expect(result, equals('foobar'));
    });

    test('testCallWithBoundMethodAndArrayOfParametersWithOptionalParameters',
        () {
      container.bindMethod(
          'work',
          (container, params) =>
              '${params[0]}${params[1]}${params[2] ?? 'baz'}');
      var result = container.call('work', ['foo', 'bar']);
      expect(result, equals('foobarbaz'));
    });

    test('testCallWithBoundMethodAndDependencies', () {
      container.bind('foo', (container) => 'bar');
      container.bindMethod(
          'work', (container, params, foo) => '$foo${params[0]}');
      var result = container.call('work', ['baz']);
      expect(result, equals('barbaz'));
    });
  });
}

class ContainerCallTest {
  String work(String param1, String param2) => '$param1$param2';

  String run() => 'run';

  static String staticWork(String param1, String param2) => '$param1$param2';
}

String globalTestMethod(String param1, String param2) => '$param1$param2';
