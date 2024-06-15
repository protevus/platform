
class LockTimeoutException implements Exception {
  final String message;
  
  LockTimeoutException([this.message = '']);
  
  @override
  String toString() {
    return 'LockTimeoutException: $message';
  }
}
