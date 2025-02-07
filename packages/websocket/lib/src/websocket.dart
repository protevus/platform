import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_websocket/src/adapters/websocket_adapter.dart';
import 'package:illuminate_websocket/src/websocket_event.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = Uuid();

class WebsocketServer implements WebsocketInterface {
  // Parameter for the singleton class
  final ApplicationInterface? dox;

  // Static instance variable for the singleton
  static WebsocketServer? _instance;

  WebsocketServer._internal([this.dox]);

  factory WebsocketServer([ApplicationInterface? d]) {
    if (_instance == null) {
      _instance = WebsocketServer._internal(d);
      _instance!._initialize();
    }
    return _instance!;
  }

  WebsocketAdapterInterface? _adaptor;

  _initialize() {
    if (dox != null) {
      dox?.setWebsocket(this);
    }
  }

  @override
  WebsocketEventHandler create() {
    return WebsocketEventHandler();
  }

  adapter(WebsocketAdapterInterface adaptor) {
    _adaptor = adaptor;
  }

  WebsocketAdapterInterface? getAdapter() {
    return _adaptor;
  }
}
