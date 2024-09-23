import 'package:platform_exceptions/http_exception.dart';

void main() => throw HttpException.notFound(message: "Can't find that page!");
