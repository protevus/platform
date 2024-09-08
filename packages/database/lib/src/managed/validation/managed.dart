/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_database/src/managed/managed.dart';
import 'package:protevus_database/src/managed/validation/impl.dart';
import 'package:protevus_database/src/query/query.dart';

/// Validates properties of [ManagedObject] before an insert or update [Query].
///
/// Instances of this type are created during [ManagedDataModel] compilation.
class ManagedValidator {
  /// Constructs a [ManagedValidator] instance with the specified [definition] and [state].
  ///
  /// The [definition] parameter contains the metadata associated with this instance, while
  /// the [state] parameter holds a dynamic value that can be used during the validation process.
  ManagedValidator(this.definition, this.state);

  /// Executes all [Validate]s for [object].
  ///
  /// Validates the properties of [object] according to its validator annotations. Validators
  /// are added to properties using [Validate] metadata.
  ///
  /// This method does not invoke [ManagedObject.validate] - any customization provided
  /// by a [ManagedObject] subclass that overrides this method will not be invoked.
  static ValidationContext run(
    ManagedObject object, {
    Validating event = Validating.insert,
  }) {
    final context = ValidationContext();

    for (final validator in object.entity.validators) {
      context.property = validator.property;
      context.event = event;
      context.state = validator.state;
      if (!validator.definition.runOnInsert && event == Validating.insert) {
        continue;
      }

      if (!validator.definition.runOnUpdate && event == Validating.update) {
        continue;
      }

      var contents = object.backing.contents;
      String key = validator.property!.name;

      if (validator.definition.type == ValidateType.present) {
        if (validator.property is ManagedRelationshipDescription) {
          final inner = object[validator.property!.name] as ManagedObject?;
          if (inner == null ||
              !inner.backing.contents.containsKey(inner.entity.primaryKey)) {
            context.addError("key '${validator.property!.name}' is required "
                "for ${_getEventName(event)}s.");
          }
        } else if (!contents.containsKey(key)) {
          context.addError("key '${validator.property!.name}' is required "
              "for ${_getEventName(event)}s.");
        }
      } else if (validator.definition.type == ValidateType.absent) {
        if (validator.property is ManagedRelationshipDescription) {
          final inner = object[validator.property!.name] as ManagedObject?;
          if (inner != null) {
            context.addError("key '${validator.property!.name}' is not allowed "
                "for ${_getEventName(event)}s.");
          }
        } else if (contents.containsKey(key)) {
          context.addError("key '${validator.property!.name}' is not allowed "
              "for ${_getEventName(event)}s.");
        }
      } else {
        if (validator.property is ManagedRelationshipDescription) {
          final inner = object[validator.property!.name] as ManagedObject?;
          if (inner == null ||
              inner.backing.contents[inner.entity.primaryKey] == null) {
            continue;
          }
          contents = inner.backing.contents;
          key = inner.entity.primaryKey;
        }

        final value = contents[key];
        if (value != null) {
          validator.validate(context, value);
        }
      }
    }

    return context;
  }

  /// The property being validated.
  ///
  /// This property represents the [ManagedPropertyDescription] that is being
  /// validated by the current instance of [ManagedValidator]. It is used to
  /// retrieve information about the property, such as its name, type, and
  /// relationship details.
  ManagedPropertyDescription? property;

  /// The metadata associated with this instance.
  ///
  /// The `definition` property contains the metadata associated with this instance of `ManagedValidator`.
  /// This metadata is used to define the validation rules that will be applied to the properties
  /// of a `ManagedObject` during an insert or update operation.
  final Validate definition;

  /// The dynamic state associated with this validator.
  ///
  /// This property holds a dynamic value that can be used during the validation process.
  /// The state is provided when the [ManagedValidator] is constructed and can be used
  /// by the validation logic to customize the validation behavior.
  final dynamic state;

  /// Validates the property according to the validation rules defined in the [definition] property.
  ///
  /// This method is called by the [run] method of the [ManagedValidator] class to perform the actual
  /// validation of a property value. The [context] parameter is used to store the validation results,
  /// and the [value] parameter is the value of the property being validated.
  ///
  /// The validation logic is defined in the [definition] property, which is an instance of the [Validate]
  /// class. This class contains the metadata that describes the validation rules to be applied to the
  /// property.
  void validate(ValidationContext context, dynamic value) {
    definition.validate(context, value);
  }

  /// Returns a string representation of the given validation event.
  ///
  /// This method is a helper function that takes a [Validating] event and
  /// returns a string describing the event.
  ///
  /// Parameters:
  /// - `op`: The [Validating] event to be described.
  ///
  /// Returns:
  /// A string representing the given validation event. The possible return
  /// values are "insert", "update", or "unknown" if the event is not
  /// recognized.
  static String _getEventName(Validating op) {
    switch (op) {
      case Validating.insert:
        return "insert";
      case Validating.update:
        return "update";
      default:
        return "unknown";
    }
  }
}
