import 'casts_attributes.dart';
import 'casts_inbound_attributes.dart';

/// Interface for classes that can specify their own casting behavior.
///
/// This contract defines how a class can specify which caster should be used
/// when casting its values to and from the database.
abstract class Castable {
  /// Get the name of the caster class to use when casting from / to this cast target.
  ///
  /// Example:
  /// ```dart
  /// class Location implements Castable {
  ///   final double lat;
  ///   final double lng;
  ///
  ///   Location(this.lat, this.lng);
  ///
  ///   @override
  ///   dynamic castUsing(List<dynamic> arguments) {
  ///     return LocationCaster();
  ///   }
  /// }
  ///
  /// class LocationCaster implements CastsAttributes<Location, Map<String, dynamic>> {
  ///   @override
  ///   Location? get(dynamic model, String key, dynamic value, Map<String, dynamic> attributes) {
  ///     if (value == null) return null;
  ///     return Location(value['lat'], value['lng']);
  ///   }
  ///
  ///   @override
  ///   dynamic set(dynamic model, String key, Location? value, Map<String, dynamic> attributes) {
  ///     if (value == null) return null;
  ///     return {'lat': value.lat, 'lng': value.lng};
  ///   }
  /// }
  /// ```
  dynamic castUsing(List<dynamic> arguments);
}
