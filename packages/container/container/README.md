# Protevus Container

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/platform_container?include_prereleases)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Gitter](https://img.shields.io/gitter/room/angel_dart/discussion)](https://gitter.im/angel_dart/discussion)
[![License](https://img.shields.io/github/license/dart-backend/angel)](https://github.com/dart-backend/angel/tree/master/packages/container/angel_container/LICENSE)

A better IoC container for Protevus, ultimately allowing Protevus to be used with or without `dart:mirrors` package.

```dart
    import 'package:platform_container/mirrors.dart';
    import 'package:platform_core/core.dart';
    import 'package:platform_core/http.dart';

    @Expose('/sales', middleware: [process1])
    class SalesController extends Controller {
        @Expose('/', middleware: [process2])
        Future<String> route1(RequestContext req, ResponseContext res) async {
            return "Sales route";
        }
    }

    bool process1(RequestContext req, ResponseContext res) {
        res.write('Hello, ');
        return true;
    }

    bool process2(RequestContext req, ResponseContext res) {
        res.write('From Sales, ');
        return true;
    }

    void main() async {
        // Using Mirror Reflector
        var app = Protevus(reflector: MirrorsReflector());

        // Sales Controller
        app.container.registerSingleton<SalesController>(SalesController());
        await app.mountController<SalesController>();

        var http = PlatformHttp(app);
        var server = await http.startServer('localhost', 3000);
        print("Protevus server listening at ${http.uri}");
    }
```
