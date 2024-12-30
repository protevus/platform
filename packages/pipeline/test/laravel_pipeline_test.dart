import 'package:platform_container/container.dart';
import 'package:platform_pipeline/pipeline.dart';
import 'package:test/test.dart';

// Test pipe classes to match Laravel's test classes
class PipelineTestPipeOne {
  static String? testPipeOne;

  Future<dynamic> handle(dynamic piped, Function next) async {
    testPipeOne = piped.toString();
    return next(piped);
  }

  Future<dynamic> differentMethod(dynamic piped, Function next) async {
    return next(piped);
  }
}

class PipelineTestPipeTwo {
  static String? testPipeOne;

  Future<dynamic> call(dynamic piped, Function next) async {
    testPipeOne = piped.toString();
    return next(piped);
  }
}

class PipelineTestParameterPipe {
  static List<String>? testParameters;

  Future<dynamic> handle(dynamic piped, Function next,
      [String? parameter1, String? parameter2]) async {
    testParameters = [
      if (parameter1 != null) parameter1,
      if (parameter2 != null) parameter2
    ];
    return next(piped);
  }
}

void main() {
  group('Laravel Pipeline Tests', () {
    late Container container;
    late Pipeline pipeline;

    setUp(() {
      container = Container(const EmptyReflector());
      pipeline = Pipeline(container);

      // Register test classes with container
      container
          .registerFactory<PipelineTestPipeOne>((c) => PipelineTestPipeOne());
      container
          .registerFactory<PipelineTestPipeTwo>((c) => PipelineTestPipeTwo());
      container.registerFactory<PipelineTestParameterPipe>(
          (c) => PipelineTestParameterPipe());

      // Register types with pipeline
      pipeline.registerPipeType('PipelineTestPipeOne', PipelineTestPipeOne);
      pipeline.registerPipeType('PipelineTestPipeTwo', PipelineTestPipeTwo);
      pipeline.registerPipeType(
          'PipelineTestParameterPipe', PipelineTestParameterPipe);

      // Reset static test variables
      PipelineTestPipeOne.testPipeOne = null;
      PipelineTestPipeTwo.testPipeOne = null;
      PipelineTestParameterPipe.testParameters = null;
    });

    test('Pipeline basic usage', () async {
      String? testPipeTwo;
      final pipeTwo = (dynamic piped, Function next) {
        testPipeTwo = piped.toString();
        return next(piped);
      };

      final result = await Pipeline(container)
          .send('foo')
          .through([PipelineTestPipeOne(), pipeTwo]).then((piped) => piped);

      expect(result, equals('foo'));
      expect(PipelineTestPipeOne.testPipeOne, equals('foo'));
      expect(testPipeTwo, equals('foo'));
    });

    test('Pipeline usage with objects', () async {
      final result = await Pipeline(container)
          .send('foo')
          .through([PipelineTestPipeOne()]).then((piped) => piped);

      expect(result, equals('foo'));
      expect(PipelineTestPipeOne.testPipeOne, equals('foo'));
    });

    test('Pipeline usage with invokable objects', () async {
      final result = await Pipeline(container)
          .send('foo')
          .through([PipelineTestPipeTwo()]).then((piped) => piped);

      expect(result, equals('foo'));
      expect(PipelineTestPipeTwo.testPipeOne, equals('foo'));
    });

    test('Pipeline usage with callable', () async {
      String? testPipeOne;
      final function = (dynamic piped, Function next) {
        testPipeOne = 'foo';
        return next(piped);
      };

      var result = await Pipeline(container)
          .send('foo')
          .through([function]).then((piped) => piped);

      expect(result, equals('foo'));
      expect(testPipeOne, equals('foo'));

      testPipeOne = null;

      result =
          await Pipeline(container).send('bar').through(function).thenReturn();

      expect(result, equals('bar'));
      expect(testPipeOne, equals('foo'));
    });

    test('Pipeline usage with pipe', () async {
      final object = {'value': 0};

      final function = (dynamic obj, Function next) {
        obj['value']++;
        return next(obj);
      };

      final result = await Pipeline(container)
          .send(object)
          .through([function]).pipe([function]).then((piped) => piped);

      expect(result, equals(object));
      expect(object['value'], equals(2));
    });

    test('Pipeline usage with invokable class', () async {
      final result = await Pipeline(container)
          .send('foo')
          .through([PipelineTestPipeTwo()]).then((piped) => piped);

      expect(result, equals('foo'));
      expect(PipelineTestPipeTwo.testPipeOne, equals('foo'));
    });

    test('Then method is not called if the pipe returns', () async {
      String thenValue = '(*_*)';
      String secondValue = '(*_*)';

      final result = await Pipeline(container).send('foo').through([
        (value, next) => 'm(-_-)m',
        (value, next) {
          secondValue = 'm(-_-)m';
          return next(value);
        },
      ]).then((piped) {
        thenValue = '(0_0)';
        return piped;
      });

      expect(result, equals('m(-_-)m'));
      // The then callback is not called
      expect(thenValue, equals('(*_*)'));
      // The second pipe is not called
      expect(secondValue, equals('(*_*)'));
    });

    test('Then method input value', () async {
      String? pipeReturn;
      String? thenArg;

      final result = await Pipeline(container).send('foo').through([
        (value, next) async {
          final nextValue = await next('::not_foo::');
          pipeReturn = nextValue;
          return 'pipe::$nextValue';
        }
      ]).then((piped) {
        thenArg = piped;
        return 'then$piped';
      });

      expect(result, equals('pipe::then::not_foo::'));
      expect(thenArg, equals('::not_foo::'));
    });

    test('Pipeline usage with parameters', () async {
      final parameters = ['one', 'two'];

      final result = await Pipeline(container)
          .send('foo')
          .through('PipelineTestParameterPipe:${parameters.join(',')}')
          .then((piped) => piped);

      expect(result, equals('foo'));
      expect(PipelineTestParameterPipe.testParameters, equals(parameters));
    });

    test('Pipeline via changes the method being called on the pipes', () async {
      final result = await Pipeline(container)
          .send('data')
          .through(PipelineTestPipeOne())
          .via('differentMethod')
          .then((piped) => piped);

      expect(result, equals('data'));
    });

    test('Pipeline throws exception on resolve without container', () async {
      expect(
          () => Pipeline(null)
              .send('data')
              .through(PipelineTestPipeOne())
              .then((piped) => piped),
          throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains(
                  'A container instance has not been passed to the Pipeline'))));
    });

    test('Pipeline thenReturn method runs pipeline then returns passable',
        () async {
      final result = await Pipeline(container)
          .send('foo')
          .through([PipelineTestPipeOne()]).thenReturn();

      expect(result, equals('foo'));
      expect(PipelineTestPipeOne.testPipeOne, equals('foo'));
    });

    test('Pipeline conditionable', () async {
      var result = await Pipeline(container).send('foo').when(() => true,
          (Pipeline pipeline) {
        pipeline.pipe([PipelineTestPipeOne()]);
      }).then((piped) => piped);

      expect(result, equals('foo'));
      expect(PipelineTestPipeOne.testPipeOne, equals('foo'));

      PipelineTestPipeOne.testPipeOne = null;

      result = await Pipeline(container).send('foo').when(() => false,
          (Pipeline pipeline) {
        pipeline.pipe([PipelineTestPipeOne()]);
      }).then((piped) => piped);

      expect(result, equals('foo'));
      expect(PipelineTestPipeOne.testPipeOne, isNull);
    });
  });
}
