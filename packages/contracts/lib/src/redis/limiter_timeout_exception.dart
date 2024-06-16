//import 'package:redis/redis.dart';

class LimiterTimeoutException implements Exception {
  final String message;

  LimiterTimeoutException([this.message = '']);

  @override
  String toString() => message.isEmpty ? 'LimiterTimeoutException' : 'LimiterTimeoutException: $message';
}
