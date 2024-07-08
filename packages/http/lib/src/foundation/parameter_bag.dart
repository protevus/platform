import 'package:protevus_http/foundation.dart';

abstract class ParameterBag extends ParameterBagBase {
  @override
  final Map<String, dynamic> parameters;

  ParameterBag([Map<String, dynamic> initialParameters = const {}])
      : parameters = Map<String, dynamic>.from(initialParameters);

  @override
  void replace(Map<String, dynamic> parameters) {
    parameters.clear();
    parameters.addAll(parameters);
  }

  @override
  void add(Map<String, dynamic> parameters) {
    parameters.addAll(parameters);
  }

  @override
  void set(String key, dynamic value) {
    parameters[key] = value;
  }

  @override
  void remove(String key) {
    parameters.remove(key);
  }
}
