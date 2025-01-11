import 'package:platform_file_service/angel3_file_service.dart';
import 'package:platform_foundation/core.dart';
import 'package:file/local.dart';

void configureServer(Application app) async {
  // Just like a normal service
  app.use(
    '/api/todos',
    JsonFileService(const LocalFileSystem().file('todos_db.json')),
  );
}
