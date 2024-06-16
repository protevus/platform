abstract class MaintenanceMode {
  /// Take the application down for maintenance.
  ///
  /// [payload] - The payload containing maintenance details.
  void activate(Map<String, dynamic> payload);

  /// Take the application out of maintenance.
  void deactivate();

  /// Determine if the application is currently down for maintenance.
  ///
  /// Returns `true` if the application is in maintenance mode, `false` otherwise.
  bool active();

  /// Get the data map which was provided when the application was placed into maintenance.
  ///
  /// Returns a map containing maintenance data.
  Map<String, dynamic> data();
}
