/// Interface for validation rules that need access to all data being validated.
abstract class DataAwareRule {
  /// Set the data under validation.
  DataAwareRule setData(Map<String, dynamic> data);
}
