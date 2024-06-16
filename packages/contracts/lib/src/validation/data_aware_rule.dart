abstract class DataAwareRule {
  /// Sets the data under validation.
  ///
  /// @param Map<String, dynamic> data - The data to be validated.
  /// @return DataAwareRule - The instance of the implementing class.
  DataAwareRule setData(Map<String, dynamic> data);
}
