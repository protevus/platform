import 'package:platformed_container/container.dart';

void main() {
  var reflector = const ThrowingReflector();
  reflector.reflectClass(StringBuffer);
}
