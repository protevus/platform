import 'package:platform_database/eloquent.dart';

class InvalidArgumentException implements LogicException {
  String cause;
  InvalidArgumentException([this.cause = 'InvalidArgumentException']);
}
