/// Interface for maintenance mode management.
abstract class MaintenanceMode {
  /// Take the application down for maintenance.
  void activate(Map<String, dynamic> payload);

  /// Take the application out of maintenance.
  void deactivate();

  /// Determine if the application is currently down for maintenance.
  bool active();

  /// Get the data array which was provided when the application was placed into maintenance.
  Map<String, dynamic> data();
}
