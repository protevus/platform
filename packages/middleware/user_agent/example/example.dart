//import 'dart:io';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
//import 'package:angel3_user_agent/angel3_user_agent.dart';
//import 'package:user_agent_analyzer/user_agent_analyzer.dart';

void main() async {
  var app = Application();
  // ignore: unused_local_variable
  var http = PlatformHttp(app);

  //TODO: To be reviewed
  /*
  app.get(
    '/',
    waterfall([
      parseUserAgent,
      (req, res) {
        var ua = req.container.make<UserAgent>() as UserAgent;
        return ua.isChrome
            ? 'Woohoo! You are running Chrome.'
            : 'Sorry, we only support Google Chrome.';
      },
    ]),
  );

  var server = await http.startServer(InternetAddress.anyIPv4, 3000);
  print('Listening at http://${server.address.address}:${server.port}');
  */
}
