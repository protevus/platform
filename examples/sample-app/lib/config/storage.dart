import 'package:illuminate_config/config.dart';
import 'package:illuminate_contracts/contracts.dart';
import 'package:illuminate_foundation/foundation.dart';
import 'package:illuminate_storage/storage.dart';

FileStorageConfig storage = FileStorageConfig(
  /// default storage driver
  defaultDriver: Env.get('STORAGE_DRIVER', 'local'),

  // register storage driver list
  drivers: <String, StorageDriverInterface>{
    'local': LocalStorageDriver(),
  },
);
