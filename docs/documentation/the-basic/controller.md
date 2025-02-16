# Controller

## Class based controller

```bash
artisan create:controller Blog
```

=== "Route"

    ```dart
    AppController controller = AppController()
    Route.get('/ping', controller.ping);
    ```

=== "Controller"

    ```dart
    class AppController {
        ping(Request req) {
            return 'pong';
        }
    }
    ```

!!! info "with static method"
    You can also use as static method in the controller.

=== "Route"

    ```dart
    Route.get('/ping', AppController.ping);
    ```

=== "Controller"

    ```dart
    class AppController {
        static ping(Request req) {
            return 'pong';
        }
    }
    ```

## Function based controller

=== "Route"

    ```dart
    Route.get('/ping', listBlog);
    ```

=== "Controller"

    ```dart
    listBlog(Request req) {
        return 'pong';
    }
    ```

## Resource controller

=== "Create"

    ```bash
    artisan create:controller Blog -r
    ```
######
=== "Sample"

    ```dart
    import 'package:illuminate_http/http.dart';

    class BlogController {
        /// GET /resource
        index(Request req) async {}

        /// GET /resource/create
        create(Request req) async {}

        /// POST /resource
        store(Request req) async {}

        /// GET /resource/{id}
        show(Request req, String id) async {}

        /// GET /resource/{id}/edit
        edit(Request req, String id) async {}

        /// PUT|PATCH /resource/{id}
        update(Request req, String id) async {}

        /// DELETE /resource/{id}
        destroy(Request req, String id) async {}
    }
    ```