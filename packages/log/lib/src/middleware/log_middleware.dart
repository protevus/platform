import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_support/support.dart';

class LogMiddleware implements IDoxMiddleware {
  Map<String, dynamic> Function(Map<String, dynamic>)? filter;

  final bool withHeader;
  final bool enabled;

  LogMiddleware({
    required this.enabled,
    this.filter,
    this.withHeader = false,
  });

  @override
  IDoxRequest handle(IDoxRequest req) {
    if (!enabled) {
      return req;
    }
    Map<String, dynamic> payload = <String, dynamic>{
      'request': req.all(),
    };

    if (withHeader) {
      payload['headers'] = req.headers;
    }

    Map<String, dynamic> text = <String, dynamic>{
      'level': 'INFO',
      'message': '${req.method} ${req.uri.path}',
      'source_ip': req.ip(),
      'timestamp': DateTime.now().toIso8601String(),
      'payload': payload
    };
    if (filter != null) {
      text = filter!(text);
    }
    print(JSON.stringify(text));
    return req;
  }
}
