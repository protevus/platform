import 'package:platform_pipeline/pipeline.dart';
import 'package:platform_container/container.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';

class GreetingPipe {
  dynamic handle(dynamic input, Function next) {
    return next('Hello, $input');
  }
}

class ExclamationPipe {
  dynamic handle(dynamic input, Function next) {
    return next('$input!');
  }
}

class UppercasePipe {
  dynamic handle(dynamic input, Function next) async {
    await Future.delayed(
        Duration(milliseconds: 500)); // Small delay to demonstrate async
    return next(input.toString().toUpperCase());
  }
}

void main() async {
  // Create application with empty reflector
  var app = Application(reflector: EmptyReflector());

  // Create HTTP server
  var http = PlatformHttp(app);

  // Define routes
  app.get('/', (RequestContext req, ResponseContext res) {
    res.write('Try visiting /greet/world to see the pipeline in action');
    return false;
  });

  app.get('/greet/:name', (RequestContext req, ResponseContext res) async {
    var name = req.params['name'] ?? 'guest';

    var pipeline = Pipeline(app.container);
    var result = await pipeline.send(name).through([
      GreetingPipe(),
      ExclamationPipe(),
      UppercasePipe(),
    ]).then((result) => result);

    res.write(result);
    return false;
  });

  // Start server
  await http.startServer('localhost', 3000);
  print('Server running at http://localhost:3000');
  print('Visit http://localhost:3000/greet/world to see pipeline in action');
}
