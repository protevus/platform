import 'dart:convert';
import 'package:platform_foundation/core.dart';
import 'package:platform_foundation/http.dart';
import 'package:platform_seo/angel3_seo.dart';
import 'package:platform_static/angel3_static.dart';
import 'package:file/local.dart';
import 'package:http_parser/http_parser.dart';

void main() async {
  var app = Application();
  var fs = const LocalFileSystem();
  var http = PlatformHttp(app);

  // You can wrap a [VirtualDirectory]
  var vDir = inlineAssetsFromVirtualDirectory(
    VirtualDirectory(
      app,
      fs,
      source: fs.directory('web'),
    ),
  );

  app.fallback(vDir.handleRequest);

  // OR, just add a finalizer. Note that [VirtualDirectory] *streams* its response,
  // so a response finalizer does not touch its contents.
  //
  // You likely won't need to use both; it just depends on your use case.
  app.responseFinalizers.add(inlineAssets(fs.directory('web')));

  app.get('/using_response_buffer', (req, res) async {
    var indexHtml = fs.directory('web').childFile('index.html');
    var contents = await indexHtml.readAsString();
    res
      ..contentType = MediaType('text', 'html', {'charset': 'utf-8'})
      ..buffer!.add(utf8.encode(contents));
  });

  app.fallback((req, res) => throw PlatformHttpException.notFound());

  var server = await http.startServer('127.0.0.1', 3000);
  print('Listening at http://${server.address.address}:${server.port}');
}
