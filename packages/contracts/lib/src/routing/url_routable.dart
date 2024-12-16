/// Interface for URL routable models.
abstract class UrlRoutable {
  /// Get the value of the model's route key.
  dynamic getRouteKey();

  /// Get the route key for the model.
  String getRouteKeyName();

  /// Retrieve the model for a bound value.
  dynamic resolveRouteBinding(dynamic value, [String? field]);

  /// Retrieve the child model for a bound value.
  dynamic resolveChildRouteBinding(String childType, dynamic value,
      [String? field]);
}
