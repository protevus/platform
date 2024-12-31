import 'package:platform_pipeline/pipeline.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';

class ErrorPipe {
  dynamic handle(dynamic input, Function next) {
    throw Exception('Simulated error in pipeline');
  }
}

void main() async {
  var container = Container(MirrorsReflector());
  var pipeline = Pipeline(container);

  try {
    var result = await pipeline.send('World').through([ErrorPipe()]).then(
        (result) => result.toString().toUpperCase());

    print('This should not be printed');
  } catch (e) {
    print('Caught error: $e');
  }
}
