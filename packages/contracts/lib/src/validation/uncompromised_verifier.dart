/// Interface for verifying data against known data leaks.
abstract class UncompromisedVerifier {
  /// Verify that the given data has not been compromised in data leaks.
  bool verify(Map<String, dynamic> data);
}
