import 'package:meta/meta.dart';

abstract class UncompromisedVerifier {
  /// Verify that the given data has not been compromised in data leaks.
  ///
  /// @param List<String> data
  /// @return bool
  bool verify(List<String> data);
}
