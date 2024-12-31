import 'package:platform_pipeline/pipeline.dart';
import 'package:platform_container/container.dart';
import 'package:platform_container/mirrors.dart';

void main() async {
  var container = Container(MirrorsReflector());

  var result = await Pipeline(container).send('Hello').through([
    (value, next) => next('$value World'),
    (value, next) => next('$value!'),
  ]).then((value) => value);

  print(result); // Should output: Hello World!
}
