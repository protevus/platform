import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_security/angel3_security.dart';
import 'package:logging/logging.dart';
import 'package:belatuk_pretty_logging/belatuk_pretty_logging.dart';

void main() async {
  // Logging boilerplate.
  Logger.root.onRecord.listen(prettyLog);

  // Create an app, and HTTP driver.
  var app = Application(logger: Logger('rate_limit'));
  var http = PlatformHttp(app);

  // Create a simple in-memory rate limiter that limits users to 5
  // queries per 30 seconds.
  //
  // In this case, we rate limit users by IP address.
  var rateLimiter =
      InMemoryRateLimiter(5, Duration(seconds: 30), (req, res) => req.ip);

  // `RateLimiter.handleRequest` is a middleware, and can be used anywhere
  // a middleware can be used. In this case, we apply the rate limiter to
  // *all* incoming requests.
  app.fallback(rateLimiter.handleRequest);

  // Basic routes.
  app
    ..get('/', (req, res) => 'Hello!')
    ..fallback((req, res) => throw PlatformHttpException.notFound());

  // Start the server.
  await http.startServer('127.0.0.1', 3000);
  print('Rate limiting example listening at ${http.uri}');
}
