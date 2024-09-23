import 'dart:async';
import 'package:platform_mock_request/platform_mock_request.dart';

Future<void> main() async {
  var rq =
      MockHttpRequest('GET', Uri.parse('/foo'), persistentConnection: false);
  await rq.close();
}
