import 'package:platform_validation/platform_validation.dart';

void main() {
  var bio = Validator({
    'age*': [isInt, greaterThanOrEqualTo(0)],
    'birthYear*': isInt,
    'countryOfOrigin': isString
  });

  var book = Validator({
    'title*': isString,
    'year*': [
      isNum,
      (year) {
        return year <= DateTime.now().year;
      }
    ]
  });

  // ignore: unused_local_variable
  var author = Validator({
    'bio*': bio,
    'books*': [isList, everyElement(book)]
  }, defaultValues: {
    'books': []
  });
}
