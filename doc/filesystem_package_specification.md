# FileSystem Package Specification

## Overview

The FileSystem package provides a robust abstraction layer for file operations, matching Laravel's filesystem functionality. It supports local and cloud storage systems through a unified API, with support for streaming, visibility control, and metadata management.

> **Related Documentation**
> - See [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md) for implementation status
> - See [Foundation Integration Guide](foundation_integration_guide.md) for integration patterns
> - See [Testing Guide](testing_guide.md) for testing approaches
> - See [Getting Started Guide](getting_started.md) for development setup
> - See [Contracts Package Specification](contracts_package_specification.md) for filesystem contracts

## Core Features

### 1. Filesystem Manager

```dart
/// Manages filesystem drivers
class FilesystemManager implements FilesystemFactory {
  /// Available filesystem drivers
  final Map<String, FilesystemDriver> _drivers = {};
  
  /// Default driver name
  final String _defaultDriver;
  
  /// Configuration repository
  final ConfigContract _config;
  
  FilesystemManager(this._config)
      : _defaultDriver = _config.get('filesystems.default', 'local');
  
  @override
  Filesystem disk([String? name]) {
    name ??= _defaultDriver;
    
    return _drivers.putIfAbsent(name, () {
      var config = _getConfig(name!);
      var driver = _createDriver(config);
      return Filesystem(driver);
    });
  }
  
  /// Creates a driver instance
  FilesystemDriver _createDriver(Map<String, dynamic> config) {
    switch (config['driver']) {
      case 'local':
        return LocalDriver(config);
      case 's3':
        return S3Driver(config);
      case 'gcs':
        return GoogleCloudDriver(config);
      default:
        throw UnsupportedError(
          'Unsupported filesystem driver: ${config['driver']}'
        );
    }
  }
  
  /// Gets configuration for driver
  Map<String, dynamic> _getConfig(String name) {
    var config = _config.get<Map>('filesystems.disks.$name');
    if (config == null) {
      throw ArgumentError('Disk [$name] not configured.');
    }
    return config;
  }
}
```

### 2. Filesystem Implementation

```dart
/// Core filesystem implementation
class Filesystem implements FilesystemContract {
  /// The filesystem driver
  final FilesystemDriver _driver;
  
  Filesystem(this._driver);
  
  @override
  Future<bool> exists(String path) {
    return _driver.exists(path);
  }
  
  @override
  Future<String> get(String path) {
    return _driver.get(path);
  }
  
  @override
  Stream<List<int>> readStream(String path) {
    return _driver.readStream(path);
  }
  
  @override
  Future<void> put(String path, dynamic contents, [Map<String, String>? options]) {
    return _driver.put(path, contents, options);
  }
  
  @override
  Future<void> putStream(String path, Stream<List<int>> contents, [Map<String, String>? options]) {
    return _driver.putStream(path, contents, options);
  }
  
  @override
  Future<void> delete(String path) {
    return _driver.delete(path);
  }
  
  @override
  Future<void> copy(String from, String to) {
    return _driver.copy(from, to);
  }
  
  @override
  Future<void> move(String from, String to) {
    return _driver.move(from, to);
  }
  
  @override
  Future<String> url(String path) {
    return _driver.url(path);
  }
  
  @override
  Future<Map<String, String>> metadata(String path) {
    return _driver.metadata(path);
  }
  
  @override
  Future<int> size(String path) {
    return _driver.size(path);
  }
  
  @override
  Future<String> mimeType(String path) {
    return _driver.mimeType(path);
  }
  
  @override
  Future<DateTime> lastModified(String path) {
    return _driver.lastModified(path);
  }
}
```

### 3. Local Driver

```dart
/// Local filesystem driver
class LocalDriver implements FilesystemDriver {
  /// Root path for local filesystem
  final String _root;
  
  /// Default visibility
  final String _visibility;
  
  LocalDriver(Map<String, dynamic> config)
      : _root = config['root'],
        _visibility = config['visibility'] ?? 'private';
  
  @override
  Future<bool> exists(String path) async {
    return File(_fullPath(path)).exists();
  }
  
  @override
  Future<String> get(String path) async {
    return File(_fullPath(path)).readAsString();
  }
  
  @override
  Stream<List<int>> readStream(String path) {
    return File(_fullPath(path)).openRead();
  }
  
  @override
  Future<void> put(String path, dynamic contents, [Map<String, String>? options]) async {
    var file = File(_fullPath(path));
    await file.create(recursive: true);
    
    if (contents is String) {
      await file.writeAsString(contents);
    } else if (contents is List<int>) {
      await file.writeAsBytes(contents);
    } else {
      throw ArgumentError('Invalid content type');
    }
    
    await _setVisibility(file, options?['visibility'] ?? _visibility);
  }
  
  @override
  Future<void> putStream(String path, Stream<List<int>> contents, [Map<String, String>? options]) async {
    var file = File(_fullPath(path));
    await file.create(recursive: true);
    
    var sink = file.openWrite();
    await contents.pipe(sink);
    await sink.close();
    
    await _setVisibility(file, options?['visibility'] ?? _visibility);
  }
  
  /// Gets full path for file
  String _fullPath(String path) {
    return p.join(_root, path);
  }
  
  /// Sets file visibility
  Future<void> _setVisibility(File file, String visibility) async {
    // Set file permissions based on visibility
    if (visibility == 'public') {
      await file.setPermissions(
        unix: 0644,
        windows: FilePermissions.readWrite
      );
    } else {
      await file.setPermissions(
        unix: 0600,
        windows: FilePermissions.readWriteExecute
      );
    }
  }
}
```

### 4. Cloud Drivers

```dart
/// Amazon S3 driver
class S3Driver implements FilesystemDriver {
  /// S3 client
  final S3Client _client;
  
  /// Bucket name
  final String _bucket;
  
  /// Optional path prefix
  final String? _prefix;
  
  S3Driver(Map<String, dynamic> config)
      : _client = S3Client(
          region: config['region'],
          credentials: AWSCredentials(
            accessKey: config['key'],
            secretKey: config['secret']
          )
        ),
        _bucket = config['bucket'],
        _prefix = config['prefix'];
  
  @override
  Future<bool> exists(String path) async {
    try {
      await _client.headObject(
        bucket: _bucket,
        key: _prefixPath(path)
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> put(String path, dynamic contents, [Map<String, String>? options]) async {
    await _client.putObject(
      bucket: _bucket,
      key: _prefixPath(path),
      body: contents,
      acl: options?['visibility'] == 'public'
          ? 'public-read'
          : 'private'
    );
  }
  
  /// Adds prefix to path
  String _prefixPath(String path) {
    return _prefix != null ? '$_prefix/$path' : path;
  }
}

/// Google Cloud Storage driver
class GoogleCloudDriver implements FilesystemDriver {
  /// Storage client
  final Storage _storage;
  
  /// Bucket name
  final String _bucket;
  
  GoogleCloudDriver(Map<String, dynamic> config)
      : _storage = Storage(
          projectId: config['project_id'],
          credentials: config['credentials']
        ),
        _bucket = config['bucket'];
  
  @override
  Future<bool> exists(String path) async {
    try {
      await _storage.bucket(_bucket).file(path).exists();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> put(String path, dynamic contents, [Map<String, String>? options]) async {
    var file = _storage.bucket(_bucket).file(path);
    
    if (contents is String) {
      await file.writeAsString(contents);
    } else if (contents is List<int>) {
      await file.writeAsBytes(contents);
    } else {
      throw ArgumentError('Invalid content type');
    }
    
    if (options?['visibility'] == 'public') {
      await file.makePublic();
    }
  }
}
```

## Integration with Container

```dart
/// Registers filesystem services
class FilesystemServiceProvider extends ServiceProvider {
  @override
  void register() {
    // Register filesystem factory
    container.singleton<FilesystemFactory>((c) {
      return FilesystemManager(c.make<ConfigContract>());
    });
    
    // Register default filesystem
    container.singleton<FilesystemContract>((c) {
      return c.make<FilesystemFactory>().disk();
    });
  }
}
```

## Usage Examples

### Basic File Operations
```dart
// Get default disk
var storage = Storage.disk();

// Check if file exists
if (await storage.exists('file.txt')) {
  // Read file contents
  var contents = await storage.get('file.txt');
  
  // Write file contents
  await storage.put('new-file.txt', contents);
  
  // Delete file
  await storage.delete('file.txt');
}
```

### Stream Operations
```dart
// Read file as stream
var stream = storage.readStream('large-file.txt');

// Write stream to file
await storage.putStream(
  'output.txt',
  stream,
  {'visibility': 'public'}
);
```

### Cloud Storage
```dart
// Use S3 disk
var s3 = Storage.disk('s3');

// Upload file
await s3.put(
  'uploads/image.jpg',
  imageBytes,
  {'visibility': 'public'}
);

// Get public URL
var url = await s3.url('uploads/image.jpg');
```

### File Metadata
```dart
// Get file metadata
var meta = await storage.metadata('document.pdf');
print('Size: ${meta['size']}');
print('Type: ${meta['mime_type']}');
print('Modified: ${meta['last_modified']}');
```

## Testing

```dart
void main() {
  group('Filesystem Tests', () {
    late Filesystem storage;
    
    setUp(() {
      storage = Filesystem(MockDriver());
    });
    
    test('should check file existence', () async {
      expect(await storage.exists('test.txt'), isTrue);
      expect(await storage.exists('missing.txt'), isFalse);
    });
    
    test('should read and write files', () async {
      await storage.put('test.txt', 'contents');
      var contents = await storage.get('test.txt');
      expect(contents, equals('contents'));
    });
    
    test('should handle streams', () async {
      var input = Stream.fromIterable([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      
      await storage.putStream('test.bin', input);
      var output = storage.readStream('test.bin');
      
      expect(
        await output.toList(),
        equals([[1, 2, 3], [4, 5, 6]])
      );
    });
  });
}
```

## Performance Considerations

1. **Streaming Large Files**
```dart
// Use streams for large files
class Filesystem {
  Future<void> copyLarge(String from, String to) async {
    await readStream(from)
        .pipe(writeStream(to));
  }
}
```

2. **Caching URLs**
```dart
class CachingFilesystem implements FilesystemContract {
  final Cache _cache;
  final Duration _ttl;
  
  @override
  Future<String> url(String path) async {
    var key = 'file_url:$path';
    return _cache.remember(key, _ttl, () {
      return _driver.url(path);
    });
  }
}
```

3. **Batch Operations**
```dart
class Filesystem {
  Future<void> putMany(Map<String, dynamic> files) async {
    await Future.wait(
      files.entries.map((e) =>
        put(e.key, e.value)
      )
    );
  }
}
```

## Next Steps

1. Implement core filesystem
2. Add local driver
3. Add cloud drivers
4. Create manager
5. Write tests
6. Add benchmarks

Would you like me to focus on implementing any specific part of these packages or continue with other documentation?

## Development Guidelines

### 1. Getting Started
Before implementing filesystem features:
1. Review [Getting Started Guide](getting_started.md)
2. Check [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Follow [Testing Guide](testing_guide.md)
4. Use [Foundation Integration Guide](foundation_integration_guide.md)
5. Understand [Contracts Package Specification](contracts_package_specification.md)

### 2. Implementation Process
For each filesystem feature:
1. Write tests following [Testing Guide](testing_guide.md)
2. Implement following Laravel patterns
3. Document following [Getting Started Guide](getting_started.md#documentation)
4. Integrate following [Foundation Integration Guide](foundation_integration_guide.md)

### 3. Quality Requirements
All implementations must:
1. Pass all tests (see [Testing Guide](testing_guide.md))
2. Meet Laravel compatibility requirements
3. Follow integration patterns (see [Foundation Integration Guide](foundation_integration_guide.md))
4. Implement required contracts (see [Contracts Package Specification](contracts_package_specification.md))

### 4. Integration Considerations
When implementing filesystem features:
1. Follow patterns in [Foundation Integration Guide](foundation_integration_guide.md)
2. Ensure Laravel compatibility per [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md)
3. Use testing approaches from [Testing Guide](testing_guide.md)
4. Follow development setup in [Getting Started Guide](getting_started.md)
5. Implement all contracts from [Contracts Package Specification](contracts_package_specification.md)

### 5. Performance Guidelines
Filesystem system must:
1. Handle large files efficiently
2. Use streaming where appropriate
3. Minimize memory usage
4. Support concurrent operations
5. Meet performance targets in [Laravel Compatibility Roadmap](laravel_compatibility_roadmap.md#performance-benchmarks)

### 6. Testing Requirements
Filesystem tests must:
1. Cover all file operations
2. Test streaming behavior
3. Verify cloud storage
4. Check metadata handling
5. Follow patterns in [Testing Guide](testing_guide.md)

### 7. Documentation Requirements
Filesystem documentation must:
1. Explain filesystem patterns
2. Show driver examples
3. Cover error handling
4. Include performance tips
5. Follow standards in [Getting Started Guide](getting_started.md#documentation)
