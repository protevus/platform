import 'package:illuminate_pipeline/pipeline.dart';
import 'package:illuminate_container/container.dart';
import 'package:illuminate_container/mirrors.dart';

class AsyncTransformPipe {
  dynamic handle(dynamic value, Function next) async {
    // Simulate async operation
    await Future.delayed(Duration(seconds: 1));
    var upperValue = (value as String).toUpperCase();
    return next(upperValue);
  }
}

void main() async {
  var container = Container(MirrorsReflector());

  print('Starting pipeline...');

  var result = await Pipeline(container)
      .send('hello')
      .through([AsyncTransformPipe()]).then((value) => value as String);

  print(result); // Should output HELLO after 1 second
}
