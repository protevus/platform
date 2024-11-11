import 'package:platform_support/src/exceptions/http_exception.dart';

void main() =>
    throw PlatformHttpException.notFound(message: "Can't find that page!");
