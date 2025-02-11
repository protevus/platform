import 'package:test/test.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_container/container.dart';
import 'package:illuminate_container/mirrors.dart';
import 'package:illuminate_pipeline/pipeline.dart';

class AddExclamationPipe {
  Future<String> handle(String input, Function next) async {
    return await next('$input!');
  }
}

class UppercasePipe {
  Future<String> handle(String input, Function next) async {
    return await next(input.toUpperCase());
  }
}

void main() {
  late Application app;
  late Container container;
  late Pipeline pipeline;

  setUp(() {
    app = Application(reflector: MirrorsReflector());
    container = app.container;
    container.registerSingleton(AddExclamationPipe());
    container.registerSingleton(UppercasePipe());
    pipeline = Pipeline(container);
    pipeline.registerPipeType('AddExclamationPipe', AddExclamationPipe);
    pipeline.registerPipeType('UppercasePipe', UppercasePipe);
  });

  test('Pipeline should process simple string pipes', () async {
    var result = await pipeline.send('hello').through(
        ['AddExclamationPipe', 'UppercasePipe']).then((res) async => res);
    expect(result, equals('HELLO!'));
  });

  test('Pipeline should process function pipes', () async {
    var result = await pipeline.send('hello').through([
      (String input, Function next) async {
        var result = await next('$input, WORLD');
        return result;
      },
      (String input, Function next) async {
        var result = await next(input.toUpperCase());
        return result;
      },
    ]).then((res) async => res as String);

    expect(result, equals('HELLO, WORLD'));
  });

  test('Pipeline should handle mixed pipe types', () async {
    var result = await pipeline.send('hello').through([
      'AddExclamationPipe',
      (String input, Function next) async {
        var result = await next(input.toUpperCase());
        return result;
      },
    ]).then((res) async => res as String);
    expect(result, equals('HELLO!'));
  });

  test('Pipeline should handle async pipes', () async {
    var result = await pipeline.send('hello').through([
      'UppercasePipe',
      (String input, Function next) async {
        await Future.delayed(Duration(milliseconds: 100));
        return next('$input, WORLD');
      },
    ]).then((res) async => res as String);
    expect(result, equals('HELLO, WORLD'));
  });

  test('Pipeline should throw exception for unresolvable pipe', () {
    expect(
      () => pipeline
          .send('hello')
          .through(['NonExistentPipe']).then((res) => res),
      throwsA(isA<Exception>()),
    );
  });

  test('Pipeline should allow chaining of pipes', () async {
    var result = await pipeline
        .send('hello')
        .pipe('AddExclamationPipe')
        .pipe('UppercasePipe')
        .then((res) async => res as String);
    expect(result, equals('HELLO!'));
  });

  test('Pipeline should respect the order of pipes', () async {
    var result1 = await pipeline
        .send('hello')
        .through(['AddExclamationPipe', 'UppercasePipe']).then((res) => res);
    var result2 = await pipeline
        .send('hello')
        .through(['UppercasePipe', 'AddExclamationPipe']).then((res) => res);
    expect(result1, equals('HELLO!'));
    expect(result2, equals('HELLO!!'));
    expect(result1, isNot(equals(result2)));
  });
}
