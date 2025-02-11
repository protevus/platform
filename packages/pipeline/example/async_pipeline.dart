import 'package:illuminate_pipeline/pipeline.dart';
import 'package:illuminate_container/container.dart';
import 'package:illuminate_container/mirrors.dart';

class AsyncGreetingPipe {
  dynamic handle(dynamic input, Function next) async {
    await Future.delayed(Duration(seconds: 1));
    return next('Hello, $input');
  }
}

class AsyncExclamationPipe {
  dynamic handle(dynamic input, Function next) async {
    await Future.delayed(Duration(seconds: 1));
    return next('$input!');
  }
}

void main() async {
  var container = Container(MirrorsReflector());

  var pipeline = Pipeline(container);
  var result = await pipeline
      .send('World')
      .through([AsyncGreetingPipe(), AsyncExclamationPipe()]).then(
          (result) => result.toString().toUpperCase());

  print(result); // Should output: "HELLO, WORLD!" (after 2 seconds)
}
