import 'package:dsr_container/container.dart';

class EntryNotFoundException implements Exception, NotFoundExceptionInterface {
  @override
  final String message;

  EntryNotFoundException([this.message = '']);

  @override
  String get id => message;

  @override
  String toString() => 'EntryNotFoundException: $message';
}
