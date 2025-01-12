import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import '../contracts/session_driver.dart';

/// A session driver that stores sessions in files.
class FileSessionDriver implements SessionDriver {
  final String _directory;
  final JsonCodec _json;

  /// Creates a new file session driver.
  ///
  /// The [directory] parameter specifies where session files will be stored.
  /// If not provided, defaults to 'storage/framework/sessions' in the current directory.
  FileSessionDriver({
    String? directory,
    JsonCodec? json,
  })  : _directory = directory ?? 'storage/framework/sessions',
        _json = json ?? const JsonCodec() {
    Directory(_directory).createSync(recursive: true);
  }

  String _getPath(String id) => path.join(_directory, '$id.session');

  @override
  Future<Map<String, dynamic>?> read(String id) async {
    final file = File(_getPath(id));
    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final data = _json.decode(content) as Map<String, dynamic>;

      // Check if session has expired
      final expiry = DateTime.parse(data['_expires'] as String);
      if (DateTime.now().isAfter(expiry)) {
        await destroy(id);
        return null;
      }

      data.remove('_expires');
      return data;
    } catch (_) {
      await destroy(id);
      return null;
    }
  }

  @override
  Future<void> write(String id, Map<String, dynamic> data) async {
    final file = File(_getPath(id));
    final sessionData = Map<String, dynamic>.from(data)
      ..['_expires'] =
          DateTime.now().add(const Duration(hours: 2)).toIso8601String();

    await file.writeAsString(_json.encode(sessionData));
  }

  @override
  Future<void> destroy(String id) async {
    final file = File(_getPath(id));
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<List<String>> all() async {
    final dir = Directory(_directory);
    if (!await dir.exists()) {
      return [];
    }

    final List<String> sessions = [];
    await for (final entity in dir.list()) {
      if (entity is File && path.extension(entity.path) == '.session') {
        final id = path.basenameWithoutExtension(entity.path);
        sessions.add(id);
      }
    }
    return sessions;
  }

  @override
  Future<void> gc(Duration lifetime) async {
    final dir = Directory(_directory);
    if (!await dir.exists()) {
      return;
    }

    await for (final entity in dir.list()) {
      if (entity is File && path.extension(entity.path) == '.session') {
        try {
          final content = await entity.readAsString();
          final data = _json.decode(content) as Map<String, dynamic>;
          final expiry = DateTime.parse(data['_expires'] as String);

          if (DateTime.now().isAfter(expiry)) {
            await entity.delete();
          }
        } catch (_) {
          // If we can't read the file or it's invalid, delete it
          await entity.delete();
        }
      }
    }
  }
}
