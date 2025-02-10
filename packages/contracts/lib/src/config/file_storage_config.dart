import '../storage/storage_driver_interface.dart';

class FileStorageConfig {
  final String defaultDriver;
  final Map<String, StorageDriverInterface> drivers;

  const FileStorageConfig({
    this.defaultDriver = 'local',
    this.drivers = const <String, StorageDriverInterface>{},
  });
}
