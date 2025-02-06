import 'package:illuminate_foundation/dox_core.dart';
import 'package:illuminate_http/http.dart';

class BlogRequest extends FormRequest {
  String? title;

  String? description;

  @override
  void setUp() {
    title = input('title');
    description = input('description');
  }

  @override
  Map<String, String> rules() {
    return <String, String>{
      'title': 'required',
      'description': 'required',
    };
  }

  @override
  Map<String, String> messages() {
    return <String, String>{};
  }
}
