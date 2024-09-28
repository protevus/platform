import 'package:platform_exceptions/http_exception.dart';

void main() =>
    throw PlatformHttpException.notFound(message: "Can't find that page!");
