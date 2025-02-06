import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_storage/storage.dart';

FileStorageConfig storage = FileStorageConfig(
  /// default storage driver
  defaultDriver: Env.get('STORAGE_DRIVER', 'local'),

  // register storage driver list
  drivers: <String, StorageDriverInterface>{
    'local': LocalStorageDriver(),
  },
);
