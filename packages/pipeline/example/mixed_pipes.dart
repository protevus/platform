import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_pipeline/pipeline.dart';

class GreetingPipe {
  dynamic handle(String input, Function next) {
    return next('Hello, $input');
  }
}

void main() async {
  var app = Application(reflector: MirrorsReflector());
  var http = PlatformHttp(app);

  app.container.registerSingleton((c) => Pipeline(c));

  app.get('/', (req, res) async {
    var pipeline = app.container.make<Pipeline>();
    var result = await pipeline.send('World').through([
      'GreetingPipe',
      (String input, Function next) => next('$input!'),
      (String input, Function next) async {
        await Future.delayed(Duration(seconds: 1));
        return next(input.toUpperCase());
      },
    ]).then((result) => 'Final result: $result');

    res.write(
        result); // Outputs: "Final result: HELLO, WORLD!" (after 1 second)
  });

  await http.startServer('localhost', 3000);
  print('Server started on http://localhost:3000');
}
