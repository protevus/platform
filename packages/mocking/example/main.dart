import 'dart:async';
import 'package:platform_mocking/mocking.dart';

Future<void> main() async {
  var rq =
      MockHttpRequest('GET', Uri.parse('/foo'), persistentConnection: false);
  await rq.close();
}
