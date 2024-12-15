part of '../platform_driver_rethinkdb.dart';

class Query extends RqlQuery {
  final p.Query_QueryType _type;
  final int _token;
  final RqlQuery? _term;
  late final Map? _globalOptargs;
  Cursor? _cursor;
  final Completer _queryCompleter = Completer();

  Query(this._type, this._token, [this._term, this._globalOptargs]);

  serialize() {
    List res = [_type.value];
    if (_term != null) {
      res.add(_term.build());
    }
    if (_globalOptargs != null) {
      Map optargs = {};
      _globalOptargs.forEach((k, v) {
        optargs[k] = v is RqlQuery ? v.build() : v;
      });

      res.add(optargs);
    }
    return json.encode(res);
  }
}

class Response {
  final int _token;
  late int _type;
  dynamic _data;
  dynamic _backtrace;
  dynamic _profile;
  late int? _errorType;
  List? _notes = [];

  Response(this._token, String jsonStr) {
    if (jsonStr.isNotEmpty) {
      Map fullResponse = json.decode(jsonStr);
      _type = fullResponse['t'];
      _data = fullResponse['r'];
      _backtrace = fullResponse['b'];
      _profile = fullResponse['p'];
      _notes = fullResponse['n'];
      _errorType = fullResponse['e'];
    }
  }
}

class Connection {
  Socket? _socket;
  static int _nextToken = 0;
  final String _host;
  final int _port;
  String _db;
  final String _user;
  final String _password;
  final int _protocolVersion = 0;
  late String _clientFirstMessage;
  late Digest _serverSignature;
  late final Map? _sslOpts;

  final Completer<Connection> _completer = Completer();

  int _responseLength = 0;
  final List<int> _responseBuffer = [];

  final Map _replyQueries = {};
  final Queue<dynamic> _sendQueue = Queue<Query>();

  final Map<String, List> _listeners = <String, List>{};

  Connection(
    this._db,
    this._host,
    this._port,
    this._user,
    this._password,
    this._sslOpts,
  );

  // ignore: unnecessary_null_comparison
  get isClosed => _socket == null;

  void use(String db) {
    _db = db;
  }

  Future server() {
    // RqlQuery query =
    RqlQuery query =
        Query(p.Query_QueryType.SERVER_INFO, _getToken(), null, null);
    _sendQueue.add(query);
    return _start(query);
  }

  Future<Connection> connect([bool noreplyWait = true]) {
    return (reconnect(noreplyWait));
  }

  Future<Connection> reconnect([bool noreplyWait = true]) {
    close(noreplyWait);

    if (_listeners["connect"] != null) {
      for (var func in _listeners["connect"]!) {
        func();
      }
    }
    var sock = Socket.connect(_host, _port);

    if (_sslOpts != null && _sslOpts.containsKey('ca')) {
      SecurityContext context = SecurityContext()
        ..setTrustedCertificates(_sslOpts['ca']);
      sock = SecureSocket.connect(_host, _port, context: context);
    }

    sock.then((socket) {
      // ignore: unnecessary_null_comparison
      if (socket != null) {
        _socket = socket;
        _socket!.listen(_handleResponse, onDone: () {
          if (_listeners["close"] != null) {
            for (var func in _listeners["close"]!) {
              func();
            }
          }
        });

        _clientFirstMessage = "n=$_user,r=${_makeSalt()}";
        String message = json.encode({
          'protocol_version': _protocolVersion,
          'authentication_method': "SCRAM-SHA-256",
          // ignore: unnecessary_brace_in_string_interps
          'authentication': "n,,${_clientFirstMessage}"
        });
        List<int> handshake =
            List.from(_toBytes(p.VersionDummy_Version.V1_0.value))
              ..addAll(message.codeUnits)
              ..add(0);

        _socket!.add(handshake);
      }
    }).catchError((err) {
      _completer.completeError(
        RqlDriverError("Could not connect to $_host:$_port.  Error $err"),
      );
    });

    return _completer.future;
  }

  _handleResponse(List<int> bytes) {
    if (!_completer.isCompleted) {
      _handleAuthResponse(bytes);
    } else {
      _readResponse(bytes);
    }
  }

  _handleAuthResponse(List<int> res) {
    List<int> response = [];
    for (final byte in res) {
      if (byte == 0) {
        _doHandshake(response);
        response.clear();
      } else {
        response.add(byte);
      }
    }
  }

  _handleAuthError(Exception error) {
    if (_listeners["error"] != null) {
      for (var func in _listeners["error"]!) {
        func(error);
      }
    }
    _completer.completeError(error);
  }

  _doHandshake(List<int> response) {
    Map responseJSON = json.decode(utf8.decode(response));

    if (responseJSON.containsKey('success') && responseJSON['success']) {
      if (responseJSON.containsKey('max_protocol_version')) {
        int max = responseJSON['max_protocol_version'];
        int min = responseJSON['min_protocol_version'];
        if (min > _protocolVersion || max < _protocolVersion) {
          //We don't actually support changing the protocol yet, so just error.
          _handleAuthError(
              RqlDriverError("""Unsupported protocol version $_protocolVersion,
                  expected between $min and $max."""));
        }
      } else if (responseJSON.containsKey('authentication')) {
        String authString = responseJSON['authentication'];
        Map authMap = {};
        List<String> authPieces = authString.split(',');

        for (var piece in authPieces) {
          int i = piece.indexOf('=');
          String key = piece.substring(0, i);
          String val = piece.substring(i + 1);
          authMap[key] = val;
        }

        if (authMap.containsKey('r')) {
          String salt = String.fromCharCodes(base64.decode(authMap['s']));

          int i = int.parse(authMap['i']);
          String clientFinalMessageWithoutProof = "c=biws,r=${authMap['r']}";

          //PBKDF2NS gen = PBKDF2NS(hash: sha256);
          //List<int> saltedPassword = gen.generateKey(_password, salt, i, 32);
          var saltedPassword =
              hashlib.pbkdf2(_password.codeUnits, salt.codeUnits, i, 32);

          Digest clientKey = Hmac(sha256, saltedPassword.bytes)
              .convert("Client Key".codeUnits);
          Digest storedKey = sha256.convert(clientKey.bytes);

          String authMessage =
              "$_clientFirstMessage,$authString,$clientFinalMessageWithoutProof";

          Digest clientSignature =
              Hmac(sha256, storedKey.bytes).convert(authMessage.codeUnits);

          List<int> clientProof = _xOr(clientKey.bytes, clientSignature.bytes);

          Digest serverKey = Hmac(sha256, saltedPassword.bytes)
              .convert("Server Key".codeUnits);

          _serverSignature =
              Hmac(sha256, serverKey.bytes).convert(authMessage.codeUnits);

          String message = json.encode({
            'authentication':
                "$clientFinalMessageWithoutProof,p=${base64.encode(clientProof)}"
          });

          List<int> messageBytes = List.from(message.codeUnits)..add(0);

          _socket!.add(messageBytes);
        } else if (authMap.containsKey('v')) {
          if (base64.encode(_serverSignature.bytes) != authMap['v']) {
            _handleAuthError(RqlDriverError("Invalid server signature"));
          } else {
            _completer.complete(this);
          }
        }
      }
    } else {
      _handleAuthError(RqlDriverError(
          "Server dropped connection with message: ${responseJSON['error']}"));
    }
  }

  _handleQueryResponse(Response response) {
    Query query = _replyQueries.remove(response._token);

    Exception? hasError = _checkErrorResponse(response, query._term);
    // ignore: unnecessary_null_comparison
    if (hasError != null) {
      query._queryCompleter.completeError(hasError);
    }
    dynamic value;

    if (response._type == p.Response_ResponseType.SUCCESS_PARTIAL.value) {
      _replyQueries[response._token] = query;
      dynamic cursor;
      for (var note in response._notes!) {
        if (note == p.Response_ResponseNote.SEQUENCE_FEED.value) {
          cursor = cursor ?? Feed(this, query, query.optargs);
        } else if (note == p.Response_ResponseNote.UNIONED_FEED.value) {
          cursor = cursor ?? UnionedFeed(this, query, query.optargs);
        } else if (note == p.Response_ResponseNote.ATOM_FEED.value) {
          cursor = cursor ?? AtomFeed(this, query, query.optargs);
        } else if (note == p.Response_ResponseNote.ORDER_BY_LIMIT_FEED.value) {
          cursor = cursor ?? OrderByLimitFeed(this, query, query.optargs);
        }
      }
      cursor = cursor ?? Cursor(this, query, query.optargs);

      value = cursor;
      query._cursor = value;
      value._extend(response);
    } else if (response._type ==
        p.Response_ResponseType.SUCCESS_SEQUENCE.value) {
      value = Cursor(this, query, {});
      query._cursor = value;
      value._extend(response);
    } else if (response._type == p.Response_ResponseType.SUCCESS_ATOM.value) {
      if (response._data.length < 1) {
        value = null;
      }
      value = query._recursivelyConvertPseudotypes(response._data.first, null);
    } else if (response._type == p.Response_ResponseType.WAIT_COMPLETE.value) {
      //Noreply_wait response
      value = null;
    } else if (response._type == p.Response_ResponseType.SERVER_INFO.value) {
      query._queryCompleter.complete(response._data.first);
    } else {
      if (!query._queryCompleter.isCompleted) {
        query._queryCompleter
            .completeError(RqlDriverError("Error: ${response._data}."));
      }
    }

    if (response._profile != null) {
      value = {"value": value, "profile": response._profile};
    }
    if (!query._queryCompleter.isCompleted) {
      query._queryCompleter.complete(value);
    }
  }

  void close([bool noreplyWait = true]) {
    // ignore: unnecessary_null_comparison
    if (_socket != null) {
      if (noreplyWait) this.noreplyWait();
      try {
        _socket!.close();
      } catch (err) {
        // TODO: do something with err.
      }

      _socket!.destroy();
      _socket = null;
    }
  }

  /// Alias for addListener
  void on(String key, Function val) {
    addListener(key, val);
  }

  /// Adds a listener to the connection.
  void addListener(String key, Function val) {
    List currentListeners = [];
    // ignore: unnecessary_null_comparison
    if (_listeners != null && _listeners[key] != null) {
      for (var element in _listeners[key]!) {
        currentListeners.add(element);
      }
    }

    currentListeners.add(val);
    _listeners[key] = currentListeners;
  }

  _getToken() {
    return ++_nextToken;
  }

  clientPort() {
    return _socket!.port;
  }

  clientAddress() {
    return _socket!.address.address;
  }

  noreplyWait() {
    // RqlQuery query =
    RqlQuery query =
        Query(p.Query_QueryType.NOREPLY_WAIT, _getToken(), null, null);

    _sendQueue.add(query);
    return _start(query);
  }

  _handleCursorResponse(Response response) {
    Cursor cursor = _replyQueries[response._token]._cursor;
    cursor._extend(response);
    cursor._outstandingRequests--;

    if (response._type != p.Response_ResponseType.SUCCESS_PARTIAL.value &&
        cursor._outstandingRequests == 0) {
      _replyQueries[response._token]._cursor = null;
    }
  }

  _readResponse(res) {
    int responseToken;
    String responseBuf;
    int responseLen;

    _responseBuffer.addAll(List<int>.from(res));

    _responseLength = _responseBuffer.length;

    if (_responseLength >= 12) {
      responseToken = _fromBytes(_responseBuffer.sublist(0, 8));
      responseLen = _fromBytes(_responseBuffer.sublist(8, 12));
      if (_responseLength >= responseLen + 12) {
        responseBuf =
            utf8.decode(_responseBuffer.sublist(12, responseLen + 12));

        _responseBuffer.removeRange(0, responseLen + 12);
        _responseLength = _responseBuffer.length;

        Response response = Response(responseToken, responseBuf);

        if (_replyQueries[response._token]._cursor != null) {
          _handleCursorResponse(response);
        }
        //if for some reason there are other queries on the line...

        if (_replyQueries.containsKey(response._token)) {
          _handleQueryResponse(response);
        } else {
          throw RqlDriverError("Unexpected response received.");
        }

        if (_responseLength > 0) {
          _readResponse([]);
        }
      }
    }
  }

  _checkErrorResponse(Response response, RqlQuery? term) {
    dynamic message;
    dynamic frames;
    if (response._type == p.Response_ResponseType.RUNTIME_ERROR.value) {
      message = response._data.first;
      frames = response._backtrace;
      int? errType = response._errorType;
      if (errType == p.Response_ErrorType.INTERNAL.value) {
        return ReqlInternalError(message, term, frames);
      } else if (errType == p.Response_ErrorType.RESOURCE_LIMIT.value) {
        return ReqlResourceLimitError(message, term, frames);
      } else if (errType == p.Response_ErrorType.QUERY_LOGIC.value) {
        return ReqlQueryLogicError(message, term, frames);
      } else if (errType == p.Response_ErrorType.NON_EXISTENCE.value) {
        return ReqlNonExistenceError(message, term, frames);
      } else if (errType == p.Response_ErrorType.OP_FAILED.value) {
        return ReqlOpFailedError(message, term, frames);
      } else if (errType == p.Response_ErrorType.OP_INDETERMINATE.value) {
        return ReqlOpIndeterminateError(message, term, frames);
      } else if (errType == p.Response_ErrorType.USER.value) {
        return ReqlUserError(message, term, frames);
      } else if (errType == p.Response_ErrorType.PERMISSION_ERROR.value) {
        return ReqlPermissionError(message, term, frames);
      } else {
        return RqlRuntimeError(message, term, frames);
      }
    } else if (response._type == p.Response_ResponseType.COMPILE_ERROR.value) {
      message = response._data.first;
      frames = response._backtrace;
      return RqlCompileError(message, term, frames);
    } else if (response._type == p.Response_ResponseType.CLIENT_ERROR.value) {
      message = response._data.first;
      frames = response._backtrace;
      return RqlClientError(message, term, frames);
    }
    return null;
  }

  _sendQuery() {
    if (_sendQueue.isNotEmpty) {
      Query query = _sendQueue.removeFirst();

      // Error if this connection has closed
      if (_socket == null) {
        query._queryCompleter
            .completeError(RqlDriverError("Connection is closed."));
      } else {
        // Send json
        List<int> queryStr = utf8.encode(query.serialize());
        List<int> queryHeader = List.from(_toBytes8(query._token))
          ..addAll(_toBytes(queryStr.length))
          ..addAll(queryStr);
        _socket!.add(queryHeader);

        _replyQueries[query._token] = query;
        return query._queryCompleter.future;
      }
    }
  }

  _start(RqlQuery term, [Map? globalOptargs]) {
    globalOptargs ??= {};
    if (globalOptargs.containsKey('db')) {
      globalOptargs['db'] = DB(globalOptargs['db']);
    } else {
      globalOptargs['db'] = DB(_db);
    }

    Query query =
        Query(p.Query_QueryType.START, _getToken(), term, globalOptargs);
    _sendQueue.addLast(query);
    return _sendQuery();
  }

  Uint8List _toBytes(int data) {
    ByteBuffer buffer = Uint8List(4).buffer;
    ByteData bdata = ByteData.view(buffer);
    bdata.setInt32(0, data, Endian.little);
    return Uint8List.view(buffer);
  }

  Uint8List _toBytes8(int data) {
    ByteBuffer buffer = Uint8List(8).buffer;
    ByteData bdata = ByteData.view(buffer);
    bdata.setInt32(0, data, Endian.little);
    return Uint8List.view(buffer);
  }

  int _fromBytes(List<int> data) {
    Uint8List buf = Uint8List.fromList(data);
    ByteData bdata = ByteData.view(buf.buffer);
    return bdata.getInt32(0, Endian.little);
  }

  String _makeSalt() {
    List<int> randomBytes = [];
    math.Random random = math.Random.secure();

    for (int i = 0; i < randomBytes.length; ++i) {
      randomBytes[i] = random.nextInt(255);
    }

    return base64.encode(randomBytes);
  }

  List<int> _xOr(List<int> result, List<int> next) {
    for (int i = 0; i < result.length; i++) {
      result[i] ^= next[i];
    }
    return result;
  }
}
