import 'dart:io';

/// A file that can be locked for exclusive or shared access.
class LockableFile {
  /// The file handle.
  RandomAccessFile? _handle;

  /// The file path.
  final String path;

  /// Indicates if the file is locked.
  bool _isLocked = false;

  /// Create a new LockableFile instance.
  ///
  /// @param path The file path
  /// @param mode The file mode (r, w, etc)
  LockableFile(this.path, String mode) {
    _ensureDirectoryExists(path);
    _createResource(path, mode);
  }

  /// Create the file's directory if necessary.
  void _ensureDirectoryExists(String path) {
    final dir = Directory(path).parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// Create the file resource.
  void _createResource(String path, String mode) {
    final file = File(path);
    FileMode fileMode;

    switch (mode) {
      case 'r':
        fileMode = FileMode.read;
        break;
      case 'w':
        fileMode = FileMode.write;
        break;
      case 'a':
        fileMode = FileMode.append;
        break;
      case 'r+':
        fileMode = FileMode.append; // Best approximation for read/write
        break;
      default:
        throw ArgumentError('Invalid file mode: $mode');
    }

    _handle = file.openSync(mode: fileMode);
  }

  /// Read the file contents.
  ///
  /// @param length The number of bytes to read (null for entire file)
  /// @return The file contents
  List<int> read([int? length]) {
    _checkHandle();

    // Clear stat cache
    FileStat.statSync(path);

    length ??= size();
    return _handle!.readSync(length);
  }

  /// Get the file size.
  ///
  /// @return The file size in bytes
  int size() {
    return File(path).lengthSync();
  }

  /// Write to the file.
  ///
  /// @param contents The contents to write
  /// @return this
  LockableFile write(String contents) {
    _checkHandle();

    final bytes = contents.codeUnits;
    _handle!.writeFromSync(bytes);
    _handle!.flushSync();

    return this;
  }

  /// Truncate the file.
  ///
  /// @return this
  LockableFile truncate() {
    _checkHandle();

    _handle!.setPositionSync(0);
    _handle!.truncateSync(0);

    return this;
  }

  /// Static map to track locked files
  static final Map<String, bool> _lockedFiles = {};

  /// Get a shared lock on the file.
  ///
  /// @param block Whether to block until lock is acquired
  /// @return this
  /// @throws LockTimeoutException
  LockableFile getSharedLock([bool block = false]) {
    _checkHandle();

    if (!block && _lockedFiles.containsKey(path)) {
      throw LockTimeoutException(
          'Unable to acquire file lock at path [$path].');
    }

    try {
      if (block) {
        _handle!.lockSync();
        _isLocked = true;
        _lockedFiles[path] = true;
      } else {
        // Try non-blocking lock
        try {
          _handle!.lockSync();
          _isLocked = true;
          _lockedFiles[path] = true;
        } catch (e) {
          throw LockTimeoutException(
              'Unable to acquire file lock at path [$path].');
        }
      }
    } catch (e) {
      throw LockTimeoutException(
          'Unable to acquire file lock at path [$path].');
    }

    return this;
  }

  /// Get an exclusive lock on the file.
  ///
  /// @param block Whether to block until lock is acquired
  /// @return this
  /// @throws LockTimeoutException
  LockableFile getExclusiveLock([bool block = false]) {
    // In Dart, all locks are exclusive
    return getSharedLock(block);
  }

  /// Release the lock on the file.
  ///
  /// @return this
  LockableFile releaseLock() {
    _checkHandle();

    if (_isLocked) {
      _handle!.unlockSync();
      _isLocked = false;
      _lockedFiles.remove(path);
    }

    return this;
  }

  /// Close the file.
  ///
  /// @return true if closed successfully
  bool close() {
    if (_handle == null) return false;

    if (_isLocked) {
      releaseLock();
    }

    _handle!.closeSync();
    _handle = null;
    _lockedFiles.remove(path);
    return true;
  }

  /// Check if handle is valid.
  void _checkHandle() {
    if (_handle == null) {
      throw StateError('File handle is not open');
    }
  }
}

/// Exception thrown when a file lock cannot be acquired.
class LockTimeoutException implements Exception {
  final String message;
  LockTimeoutException(this.message);

  @override
  String toString() => message;
}
