import 'package:illuminate_cache/cache.dart';
import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_http/http.dart';

import 'router.dart';

class ResponseHandler extends ResponseHandlerInterface {
  @override
  Response handle(Response res) {
    return res;
  }
}

AppConfig appConfig = AppConfig(
  /// application key
  appKey: '4HyiSrq4N5Nfg6bOadIhbFEI8zbUkpxt',

  /// application server port
  serverPort: 3004,

  /// total multi-thread isolate to run
  totalIsolate: 1,

  // cors configuration
  cors: CORSConfig(
    origin: '*',
    methods: '*',
    credentials: true,
  ),

  /// response handler
  responseHandler: ResponseHandler(),

  /// global middleware
  globalMiddleware: <dynamic>[],

  /// routers
  routers: <Router>[
    WebsocketRouter(),
  ],

  /// cache driver configuration
  cache: CacheConfig(
    drivers: <String, CacheDriverInterface>{
      'file': FileCacheDriver(),
    },
  ),
);
