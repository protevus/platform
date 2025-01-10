import 'package:platform_redis/angel3_redis.dart';
import 'package:platform_foundation/core.dart';
import 'package:platform_production/angel3_production.dart';
import 'package:platform_security/angel3_security.dart';
import 'package:resp_client/resp_client.dart';
import 'package:resp_client/resp_commands.dart';
import 'package:resp_client/resp_server.dart';

// We run this through angel_production, so that we can have
// multiple instances, all using the same Redis queue.
void main(List<String> args) =>
    Runner('rate_limit_redis', configureServer).run(args);

void configureServer(Application app) async {
  // Create a simple rate limiter that limits users to 10
  // queries per 30 seconds.
  //
  // In this case, we rate limit users by IP address.
  //
  // Our Redis store will be used to manage windows.
  var connection = await connectSocket('localhost');
  var client = RespClient(connection);
  var service = RedisService(RespCommandsTier2(client),
      prefix: 'rate_limit_redis_example');
  var rateLimiter = ServiceRateLimiter(
      10, Duration(seconds: 30), service, (req, res) => req.ip);

  // `RateLimiter.handleRequest` is a middleware, and can be used anywhere
  // a middleware can be used. In this case, we apply the rate limiter to
  // *all* incoming requests.
  app.fallback(rateLimiter.handleRequest);

  // Basic routes.
  app
    ..get('/', (req, res) {
      var instance = req.container!.make<InstanceInfo>();
      res.writeln('This is instance ${instance.id}.');
    })
    ..fallback((req, res) => throw PlatformHttpException.notFound());
}
