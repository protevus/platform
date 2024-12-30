import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_container/mirrors.dart';
import 'package:platform_pipeline/pipeline.dart';

class ErrorPipe {
  dynamic handle(String input, Function next) {
    throw Exception('Simulated error');
  }
}

void main() async {
  var app = Application(reflector: MirrorsReflector());
  var http = PlatformHttp(app);

  app.container.registerSingleton((c) => Pipeline(c));

  app.get('/', (req, res) async {
    var pipeline = app.container.make<Pipeline>();
    try {
      await pipeline
          .send('World')
          .through(['ErrorPipe']).then((result) => result.toUpperCase());
    } catch (e) {
      res.write('Error occurred: ${e.toString()}');
      return;
    }

    res.write('This should not be reached');
  });

  await http.startServer('localhost', 3000);
  print('Server started on http://localhost:3000');
}
