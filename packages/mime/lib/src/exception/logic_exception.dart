import 'package:protevus_mime/src/exception/exception_interface.dart';

class LogicException extends StateError implements ExceptionInterface {
  LogicException(super.message);
}
