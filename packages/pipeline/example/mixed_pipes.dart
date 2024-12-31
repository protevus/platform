import 'package:platform_pipeline/pipeline.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';

class GreetingPipe {
  dynamic handle(dynamic input, Function next) {
    return next('Hello, $input');
  }
}

void main() async {
  var container = Container(MirrorsReflector());
  var pipeline = Pipeline(container);

  print('Starting mixed pipeline...');

  var result = await pipeline.send('World').through([
    GreetingPipe(),
    // Closure-based pipe
    (dynamic input, Function next) => next('$input!'),
    // Async closure-based pipe
    (dynamic input, Function next) async {
      await Future.delayed(Duration(seconds: 1));
      return next(input.toString().toUpperCase());
    },
  ]).then((result) => 'Final result: $result');

  print(
      result); // Should output: "Final result: HELLO, WORLD!" (after 1 second)
}
