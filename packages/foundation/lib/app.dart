import 'package:illuminate_config/config.dart';
import 'package:illuminate_container/container.dart';
import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_foundation/isolate/platform_isolate.dart';
import 'package:illuminate_foundation/server/server.dart';
import 'package:illuminate_log/log.dart';
import 'package:illuminate_routing/routing.dart';
import 'package:sprintf/sprintf.dart';

Container _ioc = Container();

class Application implements ApplicationInterface {
  /// setup singleton
  static Application? _singleton;

  factory Application() {
    if (_singleton == null) {
      Env().load();
      _singleton = Application._internal();
    }
    return _singleton!;
  }

  Application._internal();

  /// get dox http server
  Server get server => Server();

  /// get app config
  late AppConfig config;

  /// global dox ioc containers
  Container ioc = _ioc;

  /// isolate Id
  int isolateId = 1;

  /// websocket
  WebsocketInterface? websocket;

  /// total isolate to spawn
  int? _totalIsolate;

  /// list of services that need to run when
  /// creating isolate
  List<Service> doxServices = <Service>[];

  /// initialize dox application
  /// it load env and set config
  /// ```
  /// Dox().initialize(config);
  /// ```
  void initialize(AppConfig appConfig) async {
    config = appConfig;
  }

  /// override total isolate from config
  /// default is 3
  void totalIsolate(int value) {
    _totalIsolate = value;
  }

  /// set websocket
  /// ```
  /// Dox().initialize(config)
  /// Dox().setWebsocket(DoxWebsocket())
  /// ```
  @override
  void setWebsocket(WebsocketInterface ws) {
    websocket = ws;
  }

  /// start dox server
  /// ```
  /// await Dox().startServer();
  /// ```
  Future<void> startServer() async {
    addServices(config.services);
    _totalIsolate ??= Application().config.totalIsolate;
    int isolatesToSpawn = _totalIsolate ?? 1;

    if (isolatesToSpawn > 1) {
      await PlatformIsolate().spawn(isolatesToSpawn);
    }

    await startServices();
    Server().setResponseHandler(config.responseHandler);
    await Server().listen(config.serverPort, isolateId: 1);

    Logger.info(sprintf(
      'Server started at http://127.0.0.1:%s with $isolatesToSpawn isolate',
      <dynamic>[Application().config.serverPort],
    ));
  }

  /// ####### functions need to run on isolate #######

  /// add services that need to run on isolate spawn
  void addServices(List<Service> services) {
    doxServices.addAll(services);
  }

  /// add service that need to run on isolate spawn
  void addService(Service service) {
    doxServices.add(service);
  }

  /// start service registered to dox
  /// this is internal core use only
  /// your app do not need to call this function
  Future<void> startServices() async {
    for (Service service in doxServices) {
      await service.setup();
    }
    _registerFormRequests();
    _registerRoute();
  }

  /// ################ end ###########

  /// register form request assign in app config
  void _registerFormRequests() {
    config.formRequests.forEach((Type key, Function() value) {
      Application().ioc.registerRequest(key.toString(), value);
    });
  }

  /// register routes assign in app config
  void _registerRoute() {
    List<Router> routers = config.routers;
    for (Router router in routers) {
      Route.prefix(router.prefix);
      Route.resetWithNewMiddleware(<dynamic>[
        ...config.globalMiddleware,
        ...router.middleware,
      ]);
      router.register();
    }
    Route.prefix('');
    Route.resetWithNewMiddleware(<dynamic>[]);
  }
}
