import 'repository.dart';

abstract class Factory {
  /// Get a cache store instance by name.
  ///
  /// @param  String?  name
  /// @return Repository
  Repository store([String? name]);
}
