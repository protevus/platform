import 'package:illuminate_container/container.dart';

void main() {
  var reflector = const ThrowingReflector();
  reflector.reflectClass(StringBuffer);
}
