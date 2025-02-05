import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_foundation/storage/local_storage_driver.dart';

FileStorageConfig storage = FileStorageConfig(
  /// default storage driver
  defaultDriver: Env.get('STORAGE_DRIVER', 'local'),

  // register storage driver list
  drivers: <String, StorageDriverInterface>{
    'local': LocalStorageDriver(),
  },
);
