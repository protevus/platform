import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_pipeline/pipeline.dart';

class AsyncGreetingPipe {
  Future<dynamic> handle(String input, Function next) async {
    await Future.delayed(Duration(seconds: 1));
    return next('Hello, $input');
  }
}

class AsyncExclamationPipe {
  Future<dynamic> handle(String input, Function next) async {
    await Future.delayed(Duration(seconds: 1));
    return next('$input!');
  }
}

void main() async {
  var app = Application(reflector: MirrorsReflector());
  var http = PlatformHttp(app);

  app.container.registerSingleton((c) => Pipeline(c));

  app.get('/', (req, res) async {
    var pipeline = app.container.make<Pipeline>();
    var result = await pipeline
        .send('World')
        .through(['AsyncGreetingPipe', 'AsyncExclamationPipe']).then(
            (result) => result.toUpperCase());

    res.write(result); // Outputs: "HELLO, WORLD!" (after 2 seconds)
  });

  await http.startServer('localhost', 3000);
  print('Server started on http://localhost:3000');
}
