import 'dart:async';
import 'package:platform_foundation/core.dart';
import 'package:belatuk_html_builder/belatuk_html_builder.dart';

/// Returns a [RequestMiddleware] that allows you to return `html_builder` [Node]s as responses.
///
/// You can provide a custom [renderer]. The default renders minified HTML5 pages.
///
/// Set [enforceAcceptHeader] to `true` to throw a `406 Not Acceptable` if the client doesn't accept HTML responses.
RequestHandler renderHtml(
    {StringRenderer? renderer, bool? enforceAcceptHeader}) {
  renderer ??= StringRenderer(pretty: false, html5: true);

  return (RequestContext req, ResponseContext res) {
    var oldSerializer = res.serializer;

    res.serializer = (data) {
      if (data is! Node) {
        return oldSerializer(data);
      } else {
        if (enforceAcceptHeader == true && !req.accepts('text/html')) {
          throw PlatformHttpException.notAcceptable();
        }

        var content = renderer!.render(data);
        res
          ..headers['content-type'] = 'text/html'
          ..write(content);
        res.close();
        return '';
      }
    };

    return Future<bool>.value(true);
  };
}
