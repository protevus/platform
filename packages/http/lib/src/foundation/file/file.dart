import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:protevus_http/foundation_file_exception.dart';
import 'package:protevus_mime/mime.dart';

/// A file in the file system.
class File extends io.FileSystemEntity {
  late final io.File _dartFile;
  @override
  final String path;

  /// Constructs a new file from the given path.
  ///
  /// [path] The path to the file
  /// [checkPath] Whether to check the path or not
  ///
  /// Throws [FileNotFoundException] If the given path is not a file
  File(this.path, {bool checkPath = true}) {
    if (checkPath && !io.FileSystemEntity.isFileSync(path)) {
      throw FileNotFoundException(path);
    }
    _dartFile = io.File(path);
  }

  /// Returns the extension based on the mime type.
  ///
  /// If the mime type is unknown, returns null.
  ///
  /// This method uses the mime type as guessed by getMimeType()
  /// to guess the file extension.
  Future<String?> guessExtension() async {
    final mimeType = await getMimeType();
    if (mimeType == null) return null;

    final extensions = MimeTypes.getDefault().getExtensions(mimeType);
    return extensions.isNotEmpty ? extensions.first : null;
  }

  /// Returns the mime type of the file.
  ///
  /// The mime type is guessed using the MimeTypes class.
  Future<String?> getMimeType() {
    return MimeTypes.getDefault().guessMimeType(path);
  }

  /// Moves the file to a new location.
  ///
  /// Throws [FileException] if the target file could not be created
  File move(String directory, [String? name]) {
    final target = getTargetFile(directory, name);

    try {
      final newPath = target.path;
      _dartFile.renameSync(newPath);
      chmod(newPath, '0666');
      return target;
    } catch (e) {
      throw FileException(
          'Could not move the file "$path" to "${target.path}" ($e).');
    }
  }

  /// Returns the content of the file.
  String getContent() {
    try {
      return _dartFile.readAsStringSync();
    } catch (e) {
      throw FileException('Could not get the content of the file "$path".');
    }
  }

  /// Returns the target file for a move operation.
  File getTargetFile(String directory, [String? name]) {
    final dir = io.Directory(directory);
    if (!dir.existsSync()) {
      try {
        dir.createSync(recursive: true);
      } catch (e) {
        throw FileException('Unable to create the "$directory" directory.');
      }
    } else if (!dir.statSync().modeString().contains('w')) {
      throw FileException('Unable to write in the "$directory" directory.');
    }

    final targetPath = p.join(directory, name ?? p.basename(path));
    return File(targetPath, checkPath: false);
  }

  /// Returns locale independent base name of the given path.
  String getName(String name) {
    final normalizedName = name.replaceAll('\\', '/');
    final pos = normalizedName.lastIndexOf('/');
    return pos == -1 ? normalizedName : normalizedName.substring(pos + 1);
  }

  /// Changes the file permissions.
  ///
  /// [filePath] is the path to the file whose permissions should be changed.
  /// [mode] should be an octal string like '0644' for Unix-like systems.
  /// For Windows, use 'read' for read-only, 'write' for read/write, or 'full' for full control.
  static Future<void> chmod(String filePath, String mode) async {
    if (io.Platform.isWindows) {
      await _chmodWindows(filePath, mode);
    } else {
      await _chmodUnix(filePath, mode);
    }
  }

  static Future<void> _chmodUnix(String filePath, String mode) async {
    try {
      final result = await io.Process.run('chmod', [mode, filePath]);
      if (result.exitCode != 0) {
        throw FileException(
            'Failed to change permissions for $filePath: ${result.stderr}');
      }
    } catch (e) {
      if (e.toString().contains('Permission denied')) {
        // Optionally, you could try with sudo here, but that requires user interaction
        throw FileException(
            'Permission denied. You may need to run this with elevated privileges.');
      } else {
        throw FileException('Failed to change permissions for $filePath: $e');
      }
    }
  }

  static Future<void> _chmodWindows(String filePath, String mode) async {
    String permission;
    switch (mode.toLowerCase()) {
      case 'read':
        permission = '(R)';
        break;
      case 'write':
        permission = '(R,W)';
        break;
      case 'full':
        permission = '(F)';
        break;
      default:
        throw ArgumentError(
            'Invalid mode for Windows. Use "read", "write", or "full".');
    }

    final result = await io.Process.run(
        'icacls', [filePath, '/grant', '*S-1-1-0:$permission']);
    if (result.exitCode != 0) {
      throw FileException(
          'Failed to change permissions for $filePath: ${result.stderr}');
    }
  }

  @override
  io.FileSystemEntity get absolute => throw UnimplementedError();

  @override
  Future<bool> exists() {
    throw UnimplementedError();
  }

  @override
  bool existsSync() {
    throw UnimplementedError();
  }

  @override
  Future<io.FileSystemEntity> rename(String newPath) {
    throw UnimplementedError();
  }

  @override
  io.FileSystemEntity renameSync(String newPath) {
    throw UnimplementedError();
  }
}
