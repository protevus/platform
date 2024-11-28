import 'package:meta/meta.dart';

/// Contract for base model functionality.
///
/// Laravel-compatible: Provides core model functionality similar to Laravel's
/// Model class, adapted for Dart's type system and patterns.
@sealed
abstract class ModelContract {
  /// Gets the model's unique identifier.
  ///
  /// Laravel-compatible: Primary key accessor.
  /// Extended with nullable String type for flexibility.
  String? get id;

  /// Sets the model's unique identifier.
  ///
  /// Laravel-compatible: Primary key mutator.
  /// Extended with nullable String type for flexibility.
  set id(String? value);

  /// Gets the creation timestamp.
  ///
  /// Laravel-compatible: Created at timestamp accessor.
  /// Uses Dart's DateTime instead of Carbon.
  DateTime? get createdAt;

  /// Sets the creation timestamp.
  ///
  /// Laravel-compatible: Created at timestamp mutator.
  /// Uses Dart's DateTime instead of Carbon.
  set createdAt(DateTime? value);

  /// Gets the last update timestamp.
  ///
  /// Laravel-compatible: Updated at timestamp accessor.
  /// Uses Dart's DateTime instead of Carbon.
  DateTime? get updatedAt;

  /// Sets the last update timestamp.
  ///
  /// Laravel-compatible: Updated at timestamp mutator.
  /// Uses Dart's DateTime instead of Carbon.
  set updatedAt(DateTime? value);

  /// Gets the ID as an integer.
  ///
  /// Platform-specific: Provides integer ID conversion.
  /// Returns -1 if ID is null or not a valid integer.
  int get idAsInt;

  /// Gets the ID as a string.
  ///
  /// Platform-specific: Provides string ID conversion.
  /// Returns empty string if ID is null.
  String get idAsString;
}

/// Contract for auditable model functionality.
///
/// Laravel-compatible: Similar to Laravel's auditable trait,
/// providing user tracking for model changes.
@sealed
abstract class AuditableModelContract extends ModelContract {
  /// Gets the ID of user who created the record.
  ///
  /// Laravel-compatible: Created by user tracking.
  /// Uses String ID instead of user model reference.
  String? get createdBy;

  /// Sets the ID of user who created the record.
  ///
  /// Laravel-compatible: Created by user tracking.
  /// Uses String ID instead of user model reference.
  set createdBy(String? value);

  /// Gets the ID of user who last updated the record.
  ///
  /// Laravel-compatible: Updated by user tracking.
  /// Uses String ID instead of user model reference.
  String? get updatedBy;

  /// Sets the ID of user who last updated the record.
  ///
  /// Laravel-compatible: Updated by user tracking.
  /// Uses String ID instead of user model reference.
  set updatedBy(String? value);
}

/// Optional contract for model serialization.
///
/// Laravel-compatible: Similar to Laravel's serialization features,
/// adapted for Dart's type system.
@sealed
abstract class SerializableModelContract {
  /// Converts model to a map.
  ///
  /// Laravel-compatible: Similar to toArray() method.
  Map<String, dynamic> toMap();

  /// Creates model from a map.
  ///
  /// Laravel-compatible: Similar to fill() method.
  void fromMap(Map<String, dynamic> map);
}

/// Optional contract for model validation.
///
/// Platform-specific: Provides built-in validation support,
/// inspired by Laravel's validation but adapted for Dart.
@sealed
abstract class ValidatableModelContract {
  /// Validates the model.
  ///
  /// Platform-specific: Returns validation errors if invalid.
  Map<String, List<String>>? validate();

  /// Gets validation rules.
  ///
  /// Platform-specific: Defines validation rules.
  Map<String, List<String>> get rules;

  /// Gets custom error messages.
  ///
  /// Platform-specific: Defines custom validation messages.
  Map<String, String> get messages;
}

/// Optional contract for model events.
///
/// Laravel-compatible: Similar to Laravel's model events,
/// adapted for Dart's event system.
@sealed
abstract class ObservableModelContract {
  /// Gets the event name.
  ///
  /// Laravel-compatible: Defines event identifier.
  String get eventName;

  /// Gets the event timestamp.
  ///
  /// Platform-specific: Adds timestamp tracking to events.
  DateTime get eventTimestamp;

  /// Gets event data.
  ///
  /// Laravel-compatible: Provides event payload.
  Map<String, dynamic> get eventData;
}
