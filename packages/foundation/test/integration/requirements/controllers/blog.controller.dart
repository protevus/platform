import 'package:illuminate_http/http.dart';

class BlogController {
  /// GET /admins
  Future<String> index(Request req) async {
    return 'GET /admins';
  }

  /// GET /admins/create
  String create(Request req) {
    return 'GET /admins/create';
  }

  /// GET /admins/{id}
  Future<String> show(Request req, String id) async {
    return 'GET /admins/{id}';
  }

  /// GET /admins/{id}/edit
  Future<String> edit(Request req, String id) async {
    return 'GET /admins/{id}/edit';
  }

  /// PUT|PATCH /admins/{id}
  Future<String> update(Request req, String id) async {
    return 'PUT|PATCH /admins/{id}';
  }

  /// DELETE /admins/{id}
  Future<String> destroy(Request req, String id) async {
    return 'DELETE /admins/{id}';
  }
}
