/// coverage:ignore-file

import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_http/http.dart';
import 'package:illuminate_log/log.dart';
import 'package:illuminate_support/support.dart';

void defaultErrorHandler(Object? error, StackTrace stackTrace) {
  Logger.warn(error);
  Logger.danger(stackTrace.toString());
}

class AppConfig {
  final String appKey;
  final int serverPort;
  final int totalIsolate;
  final ResponseHandlerInterface? responseHandler;
  final Function(Object?, StackTrace) errorHandler;
  final Map<Type, FormRequest Function()> formRequests;
  final List<dynamic> globalMiddleware;
  final List<Router> routers;
  final CORSConfig cors;
  final CacheConfig cache;
  final FileStorageConfig fileStorage;
  final LoggerConfig logger;
  final List<Service> services;

  AppConfig({
    required this.appKey,
    this.serverPort = 3000,
    this.totalIsolate = 3,
    this.services = const <Service>[],
    this.formRequests = const <Type, FormRequest Function()>{},
    this.globalMiddleware = const <dynamic>[],
    this.routers = const <Router>[],
    this.cors = const CORSConfig(),
    this.logger = const LoggerConfig(),
    this.cache = const CacheConfig(),
    this.fileStorage = const FileStorageConfig(),
    this.errorHandler = defaultErrorHandler,
    this.responseHandler,
  });
}
