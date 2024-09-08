/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_openapi/documentable.dart';
import 'package:protevus_database/db.dart';
import 'package:protevus_database/src/managed/validation/impl.dart';
import 'package:protevus_openapi/v3.dart';

/// Types of operations [ManagedValidator]s will be triggered for.
///
/// - [update]: The validation is triggered during an update operation.
/// - [insert]: The validation is triggered during an insert operation.
enum Validating { update, insert }

/// Information about a validation being performed.
class ValidationContext {
  /// Whether this validation is occurring during update or insert.
  late Validating event;

  /// The property being validated.
  ManagedPropertyDescription? property;

  /// State associated with the validator being run.
  ///
  /// Use this property in a custom validator to access compiled state. Compiled state
  /// is a value that has been computed from the arguments to the validator. For example,
  /// a 'greater than 1' validator, the state is an expression object that evaluates
  /// a value is greater than 1.
  ///
  /// Set this property by returning the desired value from [Validate.compare].
  dynamic state;

  /// Errors that have occurred in this context.
  List<String> errors = [];

  /// Adds a validation error to the context.
  ///
  /// A validation will fail if this method is invoked.
  void addError(String reason) {
    final p = property;
    if (p is ManagedRelationshipDescription) {
      errors.add(
        "${p.entity.name}.${p.name}.${p.destinationEntity.primaryKey}: $reason",
      );
    } else {
      errors.add("${p!.entity.name}.${p.name}: $reason");
    }
  }

  /// Whether this validation context passed all validations.
  bool get isValid => errors.isEmpty;
}

/// An error thrown during validator compilation.
///
/// If you override [Validate.compile], throw errors of this type if a validator
/// is applied to an invalid property.
class ValidateCompilationError extends Error {
  ValidateCompilationError(this.reason);

  /// The reason for the [ValidateCompilationError].
  final String reason;
}

/// Add as metadata to persistent properties to validate their values before insertion or updating.
///
/// When executing update or insert queries, any properties with this metadata will be validated
/// against the condition declared by this instance. Example:
///
///         class Person extends ManagedObject<_Person> implements _Person {}
///         class _Person {
///           @primaryKey
///           int id;
///
///           @Validate.length(greaterThan: 10)
///           String name;
///         }
///
/// Properties may have more than one metadata of this type. All validations must pass
/// for an insert or update to be valid.
///
/// By default, validations occur on update and insert queries. Constructors have arguments
/// for only running a validation on insert or update. See [runOnUpdate] and [runOnInsert].
///
/// This class may be subclassed to create custom validations. Subclasses must override [validate].
class Validate {
  /// Invoke this constructor when creating custom subclasses.
  ///
  /// This constructor is used so that subclasses can pass [onUpdate] and [onInsert] values to control when
  /// the validation is performed. For example:
  ///
  /// Example:
  ///         class CustomValidate extends Validate<String> {
  ///           CustomValidate({bool onUpdate: true, bool onInsert: true})
  ///             : super(onUpdate: onUpdate, onInsert: onInsert);
  ///
  ///            bool validate(
  ///              ValidateOperation operation,
  ///              ManagedAttributeDescription property,
  ///              String value,
  ///              List<String> errors) {
  ///                return someCondition;
  ///            }
  ///         }
  const Validate({bool onUpdate = true, bool onInsert = true})
      : runOnUpdate = onUpdate,
        runOnInsert = onInsert,
        _value = null,
        _lessThan = null,
        _lessThanEqualTo = null,
        _greaterThan = null,
        _greaterThanEqualTo = null,
        _equalTo = null,
        type = null;

  /// A private constructor used to create instances of the [Validate] class.
  ///
  /// This constructor is used by the various named constructors of the [Validate] class to set the instance
  /// variables with the provided values.
  ///
  /// - [onUpdate]: Whether the validation should be performed during update operations.
  /// - [onInsert]: Whether the validation should be performed during insert operations.
  /// - [validator]: The type of validation to perform.
  /// - [value]: A value used by the validation.
  /// - [greaterThan]: A value to compare the input value against using the "greater than" operator.
  /// - [greaterThanEqualTo]: A value to compare the input value against using the "greater than or equal to" operator.
  /// - [equalTo]: A value to compare the input value against using the "equal to" operator.
  /// - [lessThan]: A value to compare the input value against using the "less than" operator.
  /// - [lessThanEqualTo]: A value to compare the input value against using the "less than or equal to" operator.
  const Validate._({
    bool onUpdate = true,
    bool onInsert = true,
    ValidateType? validator,
    dynamic value,
    Comparable? greaterThan,
    Comparable? greaterThanEqualTo,
    Comparable? equalTo,
    Comparable? lessThan,
    Comparable? lessThanEqualTo,
  })  : runOnUpdate = onUpdate,
        runOnInsert = onInsert,
        type = validator,
        _value = value,
        _greaterThan = greaterThan,
        _greaterThanEqualTo = greaterThanEqualTo,
        _equalTo = equalTo,
        _lessThan = lessThan,
        _lessThanEqualTo = lessThanEqualTo;

  /// A validator for matching an input String against a regular expression.
  ///
  /// Values passing through validators of this type must match a regular expression
  /// created by [pattern]. See [RegExp] in the Dart standard library for behavior.
  ///
  /// This validator is only valid for [String] properties.
  ///
  /// If [onUpdate] is true (the default), this validation is run on update queries.
  /// If [onInsert] is true (the default), this validation is run on insert queries.
  const Validate.matches(
    String pattern, {
    bool onUpdate = true,
    bool onInsert = true,
  }) : this._(
          value: pattern,
          onUpdate: onUpdate,
          onInsert: onInsert,
          validator: ValidateType.regex,
        );

  /// A validator for comparing a value.
  ///
  /// Values passing through validators of this type must be [lessThan],
  /// [greaterThan], [lessThanEqualTo], [equalTo], or [greaterThanEqualTo
  /// to the value provided for each argument.
  ///
  /// Any argument not specified is not evaluated. A typical validator
  /// only uses one argument:
  ///
  ///         @Validate.compare(lessThan: 10.0)
  ///         double value;
  ///
  /// All provided arguments are evaluated. Therefore, the following
  /// requires an input value to be between 6 and 10:
  ///
  ///         @Validate.compare(greaterThanEqualTo: 6, lessThanEqualTo: 10)
  ///         int value;
  ///
  /// This validator can be used for [String], [double], [int] and [DateTime] properties.
  ///
  /// When creating a validator for [DateTime] properties, the value for an argument
  /// is a [String] that will be parsed by [DateTime.parse].
  ///
  ///       @Validate.compare(greaterThan: "2017-02-11T00:30:00Z")
  ///       DateTime date;
  ///
  /// If [onUpdate] is true (the default), this validation is run on update queries.
  /// If [onInsert] is true (the default), this validation is run on insert queries.
  const Validate.compare({
    Comparable? lessThan,
    Comparable? greaterThan,
    Comparable? equalTo,
    Comparable? greaterThanEqualTo,
    Comparable? lessThanEqualTo,
    bool onUpdate = true,
    bool onInsert = true,
  }) : this._(
          lessThan: lessThan,
          lessThanEqualTo: lessThanEqualTo,
          greaterThan: greaterThan,
          greaterThanEqualTo: greaterThanEqualTo,
          equalTo: equalTo,
          onUpdate: onUpdate,
          onInsert: onInsert,
          validator: ValidateType.comparison,
        );

  /// A validator for validating the length of a [String].
  ///
  /// Values passing through validators of this type must a [String] with a length that is[lessThan],
  /// [greaterThan], [lessThanEqualTo], [equalTo], or [greaterThanEqualTo
  /// to the value provided for each argument.
  ///
  /// Any argument not specified is not evaluated. A typical validator
  /// only uses one argument:
  ///
  ///         @Validate.length(lessThan: 10)
  ///         String foo;
  ///
  /// All provided arguments are evaluated. Therefore, the following
  /// requires an input string to have a length to be between 6 and 10:
  ///
  ///         @Validate.length(greaterThanEqualTo: 6, lessThanEqualTo: 10)
  ///         String foo;
  ///
  /// If [onUpdate] is true (the default), this validation is run on update queries.
  /// If [onInsert] is true (the default), this validation is run on insert queries.
  const Validate.length({
    int? lessThan,
    int? greaterThan,
    int? equalTo,
    int? greaterThanEqualTo,
    int? lessThanEqualTo,
    bool onUpdate = true,
    bool onInsert = true,
  }) : this._(
          lessThan: lessThan,
          lessThanEqualTo: lessThanEqualTo,
          greaterThan: greaterThan,
          greaterThanEqualTo: greaterThanEqualTo,
          equalTo: equalTo,
          onUpdate: onUpdate,
          onInsert: onInsert,
          validator: ValidateType.length,
        );

  /// A validator for ensuring a property always has a value when being inserted or updated.
  ///
  /// This metadata requires that a property must be set in [Query.values] before an update
  /// or insert. The value may be null, if the property's [Column.isNullable] allow it.
  ///
  /// If [onUpdate] is true (the default), this validation requires a property to be present for update queries.
  /// If [onInsert] is true (the default), this validation requires a property to be present for insert queries.
  const Validate.present({bool onUpdate = true, bool onInsert = true})
      : this._(
          onUpdate: onUpdate,
          onInsert: onInsert,
          validator: ValidateType.present,
        );

  /// A validator for ensuring a property does not have a value when being inserted or updated.
  ///
  /// This metadata requires that a property must NOT be set in [Query.values] before an update
  /// or insert.
  ///
  /// This validation is used to restrict input during either an insert or update query. For example,
  /// a 'dateCreated' property would use this validator to ensure that property isn't set during an update.
  ///
  ///       @Validate.absent(onUpdate: true, onInsert: false)
  ///       DateTime dateCreated;
  ///
  /// If [onUpdate] is true (the default), this validation requires a property to be absent for update queries.
  /// If [onInsert] is true (the default), this validation requires a property to be absent for insert queries.
  const Validate.absent({bool onUpdate = true, bool onInsert = true})
      : this._(
          onUpdate: onUpdate,
          onInsert: onInsert,
          validator: ValidateType.absent,
        );

  /// A validator for ensuring a value is one of a set of values.
  ///
  /// An input value must be one of [values].
  ///
  /// [values] must be homogenous - every value must be the same type -
  /// and the property with this metadata must also match the type
  /// of the objects in [values].
  ///
  /// This validator can be used for [String] and [int] properties.
  ///
  ///         @Validate.oneOf(const ["A", "B", "C")
  ///         String foo;
  ///
  /// If [onUpdate] is true (the default), this validation is run on update queries.
  /// If [onInsert] is true (the default), this validation is run on insert queries.
  const Validate.oneOf(
    List<dynamic> values, {
    bool onUpdate = true,
    bool onInsert = true,
  }) : this._(
          value: values,
          onUpdate: onUpdate,
          onInsert: onInsert,
          validator: ValidateType.oneOf,
        );

  /// A validator that ensures a value cannot be modified after insertion.
  ///
  /// This is equivalent to `Validate.absent(onUpdate: true, onInsert: false)`.
  ///
  /// This validator is used to ensure that a property, once set during the initial
  /// insertion of a record, cannot be updated. For example, you might use this
  /// validator on a `dateCreated` property to ensure that the creation date
  /// cannot be changed after the record is inserted.
  const Validate.constant() : this.absent(onUpdate: true, onInsert: false);

  /// Whether or not this validation is checked on update queries.
  ///
  /// This property determines whether the validation will be performed during update operations on the database.
  /// If `true`, the validation will be executed during update queries. If `false`, the validation will be skipped
  /// during update queries.
  final bool runOnUpdate;

  /// Whether or not this validation is checked on insert queries.
  ///
  /// This property determines whether the validation will be performed during insert operations on the database.
  /// If `true`, the validation will be executed during insert queries. If `false`, the validation will be skipped
  /// during insert queries.
  final bool runOnInsert;

  /// The value associated with the validator.
  ///
  /// The meaning of this value depends on the type of validator. For example, for a
  /// [Validate.matches] validator, this value would be the regular expression pattern to
  /// match against. For a [Validate.oneOf] validator, this value would be the list of
  /// allowed values.
  final dynamic _value;

  /// The greater than value for the comparison validation.
  final Comparable? _greaterThan;

  /// The greater than or equal to value for the comparison validation.
  final Comparable? _greaterThanEqualTo;

  /// The value to compare the input value against using the "equal to" operator.
  ///
  /// This value is used in the [_comparisonCompiler] method to create a [ValidationExpression]
  /// with the [ValidationOperator.equalTo] operator.
  final Comparable? _equalTo;

  /// The "less than" value for the comparison validation.
  final Comparable? _lessThan;

  /// The "less than or equal to" value for the comparison validation.
  ///
  /// This value is used in the [_comparisonCompiler] method to create a [ValidationExpression]
  /// with the [ValidationOperator.lessThanEqualTo] operator.
  final Comparable? _lessThanEqualTo;

  /// The type of validation to be performed.
  ///
  /// This can be one of the following values:
  ///
  /// - `ValidateType.absent`: The property must not be present in the update or insert query.
  /// - `ValidateType.present`: The property must be present in the update or insert query.
  /// - `ValidateType.oneOf`: The property value must be one of the values in the provided list.
  /// - `ValidateType.comparison`: The property value must meet the comparison conditions specified.
  /// - `ValidateType.regex`: The property value must match the provided regular expression.
  /// - `ValidateType.length`: The length of the property value must meet the specified length conditions.
  final ValidateType? type;

  /// Subclasses override this method to perform any one-time initialization tasks and check for correctness.
  ///
  /// Use this method to ensure a validator is being applied to a property correctly. For example, a
  /// [Validate.compare] builds a list of expressions and ensures each expression's values are the
  /// same type as the property being validated.
  ///
  /// The value returned from this method is available in [ValidationContext.state] when this
  /// instance's [validate] method is called.
  ///
  /// [typeBeingValidated] is the type of the property being validated. If [relationshipInverseType] is not-null,
  /// it is a [ManagedObject] subclass and [typeBeingValidated] is the type of its primary key.
  ///
  /// If compilation fails, throw a [ValidateCompilationError] with a message describing the issue. The entity
  /// and property will automatically be added to the error.
  dynamic compile(
    ManagedType typeBeingValidated, {
    Type? relationshipInverseType,
  }) {
    switch (type) {
      case ValidateType.absent:
        return null;
      case ValidateType.present:
        return null;
      case ValidateType.oneOf:
        {
          return _oneOfCompiler(
            typeBeingValidated,
            relationshipInverseType: relationshipInverseType,
          );
        }
      case ValidateType.comparison:
        return _comparisonCompiler(
          typeBeingValidated,
          relationshipInverseType: relationshipInverseType,
        );
      case ValidateType.regex:
        return _regexCompiler(
          typeBeingValidated,
          relationshipInverseType: relationshipInverseType,
        );
      case ValidateType.length:
        return _lengthCompiler(
          typeBeingValidated,
          relationshipInverseType: relationshipInverseType,
        );
      default:
        return null;
    }
  }

  /// Validates the [input] value.
  ///
  /// Subclasses override this method to provide validation behavior.
  ///
  /// [input] is the value being validated. If the value is invalid, the reason
  /// is added to [context] via [ValidationContext.addError].
  ///
  /// Additional information about the validation event and the attribute being evaluated
  /// is available in [context].
  /// in [context].
  ///
  /// This method is not run when [input] is null.
  ///
  /// The type of [input] will have already been type-checked prior to executing this method.
  void validate(ValidationContext context, dynamic input) {
    switch (type!) {
      case ValidateType.absent:
        {}
        break;
      case ValidateType.present:
        {}
        break;
      case ValidateType.comparison:
        {
          final expressions = context.state as List<ValidationExpression>;
          for (final expr in expressions) {
            expr.compare(context, input);
          }
        }
        break;
      case ValidateType.regex:
        {
          final regex = context.state as RegExp;
          if (!regex.hasMatch(input as String)) {
            context.addError("does not match pattern ${regex.pattern}");
          }
        }
        break;
      case ValidateType.oneOf:
        {
          final options = context.state as List<dynamic>;
          if (options.every((v) => input != v)) {
            context.addError(
              "must be one of: ${options.map((v) => "'$v'").join(",")}.",
            );
          }
        }
        break;
      case ValidateType.length:
        {
          final expressions = context.state as List<ValidationExpression>;
          for (final expr in expressions) {
            expr.compare(context, (input as String).length);
          }
        }
        break;
    }
  }

  /// Adds constraints to an [APISchemaObject] imposed by this validator.
  ///
  /// Used during documentation process. When creating custom validator subclasses, override this method
  /// to modify [object] for any constraints the validator imposes.
  /// This method is used during the documentation process. When creating custom validator subclasses,
  /// override this method to modify the [object] parameter for any constraints the validator imposes.
  ///
  /// The constraints added to the [APISchemaObject] depend on the type of validator:
  ///
  /// - For `ValidateType.regex` validators, the `pattern` property of the [APISchemaObject] is set to the
  ///   regular expression pattern specified in the validator.
  /// - For `ValidateType.comparison` validators, the `minimum`, `maximum`, `exclusiveMinimum`, and
  ///   `exclusiveMaximum` properties of the [APISchemaObject] are set based on the comparison values
  ///   specified in the validator.
  /// - For `ValidateType.length` validators, the `minLength`, `maxLength`, and `maximum` properties
  ///   of the [APISchemaObject] are set based on the length-related values specified in the validator.
  /// - For `ValidateType.present` and `ValidateType.absent` validators, no constraints are added to the
  ///   [APISchemaObject].
  /// - For `ValidateType.oneOf` validators, the `enumerated` property of the [APISchemaObject] is set
  ///   to the list of allowed values specified in the validator.
  ///
  /// @param context The [APIDocumentContext] being used to document the API.
  /// @param object The [APISchemaObject] to which constraints should be added.
  void constrainSchemaObject(
    /// Adds constraints to an [APISchemaObject] imposed by this validator.
    ///
    /// This method is used during the documentation process. When creating custom validator subclasses,
    /// override this method to modify the [object] parameter for any constraints the validator imposes.
    ///
    /// The constraints added to the [APISchemaObject] depend on the type of validator:
    ///
    /// - For `ValidateType.regex` validators, the `pattern` property of the [APISchemaObject] is set to the
    ///   regular expression pattern specified in the validator.
    /// - For `ValidateType.comparison` validators, the `minimum`, `maximum`, `exclusiveMinimum`, and
    ///   `exclusiveMaximum` properties of the [APISchemaObject] are set based on the comparison values
    ///   specified in the validator.
    /// - For `ValidateType.length` validators, the `minLength`, `maxLength`, and `maximum` properties
    ///   of the [APISchemaObject] are set based on the length-related values specified in the validator.
    /// - For `ValidateType.present` and `ValidateType.absent` validators, no constraints are added to the
    ///   [APISchemaObject].
    /// - For `ValidateType.oneOf` validators, the `enumerated` property of the [APISchemaObject] is set
    ///   to the list of allowed values specified in the validator.
    ///
    /// @param context The [APIDocumentContext] being used to document the API.
    /// @param object The [APISchemaObject] to which constraints should be added.
    APIDocumentContext context,

    /// Adds constraints to an [APISchemaObject] imposed by this validator.
    ///
    /// This method is used during the documentation process. When creating custom validator subclasses,
    /// override this method to modify the [object] parameter for any constraints the validator imposes.
    ///
    /// The constraints added to the [APISchemaObject] depend on the type of validator:
    ///
    /// - For `ValidateType.regex` validators, the `pattern` property of the [APISchemaObject] is set to the
    ///   regular expression pattern specified in the validator.
    /// - For `ValidateType.comparison` validators, the `minimum`, `maximum`, `exclusiveMinimum`, and
    ///   `exclusiveMaximum` properties of the [APISchemaObject] are set based on the comparison values
    ///   specified in the validator.
    /// - For `ValidateType.length` validators, the `minLength`, `maxLength`, and `maximum` properties
    ///   of the [APISchemaObject] are set based on the length-related values specified in the validator.
    /// - For `ValidateType.present` and `ValidateType.absent` validators, no constraints are added to the
    ///   [APISchemaObject].
    /// - For `ValidateType.oneOf` validators, the `enumerated` property of the [APISchemaObject] is set
    ///   to the list of allowed values specified in the validator.
    ///
    /// @param context The [APIDocumentContext] being used to document the API.
    /// @param object The [APISchemaObject] to which constraints should be added.
    APISchemaObject object,
  ) {
    /// Adds constraints to an [APISchemaObject] imposed by this validator.
    ///
    /// This method is used during the documentation process. When creating custom validator subclasses,
    /// override this method to modify the [object] parameter for any constraints the validator imposes.
    ///
    /// The constraints added to the [APISchemaObject] depend on the type of validator:
    ///
    /// - For `ValidateType.regex` validators, the `pattern` property of the [APISchemaObject] is set to the
    ///   regular expression pattern specified in the validator.
    /// - For `ValidateType.comparison` validators, the `minimum`, `maximum`, `exclusiveMinimum`, and
    ///   `exclusiveMaximum` properties of the [APISchemaObject] are set based on the comparison values
    ///   specified in the validator.
    /// - For `ValidateType.length` validators, the `minLength`, `maxLength`, and `maximum` properties
    ///   of the [APISchemaObject] are set based on the length-related values specified in the validator.
    /// - For `ValidateType.present` and `ValidateType.absent` validators, no constraints are added to the
    ///   [APISchemaObject].
    /// - For `ValidateType.oneOf` validators, the `enumerated` property of the [APISchemaObject] is set
    ///   to the list of allowed values specified in the validator.
    ///
    /// @param context The [APIDocumentContext] being used to document the API.
    /// @param object The [APISchemaObject] to which constraints should be added.
    ///
    /// The implementation of this method is as follows:
    switch (type!) {
      case ValidateType.regex:
        {
          object.pattern = _value as String?;
        }
        break;
      case ValidateType.comparison:
        {
          if (_greaterThan is num) {
            object.exclusiveMinimum = true;
            object.minimum = _greaterThan as num?;
          } else if (_greaterThanEqualTo is num) {
            object.exclusiveMinimum = false;
            object.minimum = _greaterThanEqualTo as num?;
          }

          if (_lessThan is num) {
            object.exclusiveMaximum = true;
            object.maximum = _lessThan as num?;
          } else if (_lessThanEqualTo is num) {
            object.exclusiveMaximum = false;
            object.maximum = _lessThanEqualTo as num?;
          }
        }
        break;
      case ValidateType.length:
        {
          if (_equalTo != null) {
            object.maxLength = _equalTo as int;
            object.minLength = _equalTo;
          } else {
            if (_greaterThan is int) {
              object.minLength = 1 + (_greaterThan);
            } else if (_greaterThanEqualTo is int) {
              object.minLength = _greaterThanEqualTo as int?;
            }

            if (_lessThan is int) {
              object.maxLength = (-1) + (_lessThan);
            } else if (_lessThanEqualTo != null) {
              object.maximum = _lessThanEqualTo as int?;
            }
          }
        }
        break;
      case ValidateType.present:
        {}
        break;
      case ValidateType.absent:
        {}
        break;
      case ValidateType.oneOf:
        {
          object.enumerated = _value as List<dynamic>?;
        }
        break;
    }
  }

  /// Compiles the [Validate.oneOf] validator.
  ///
  /// The [Validate.oneOf] validator ensures that the value of a property is one of a set of allowed values.
  ///
  /// This method checks the following:
  ///
  /// - The `_value` property must be a `List`.
  /// - The type of the property being validated must be either `String`, `int`, or `bigint`.
  /// - The list of allowed values must all be assignable to the type of the property being validated.
  /// - The list of allowed values must not be empty.
  ///
  /// If any of these conditions are not met, a [ValidateCompilationError] is thrown with a descriptive error message.
  ///
  /// The compiled result is the list of allowed values, which will be stored in the [ValidationContext.state] property
  /// during validation.
  ///
  /// @param typeBeingValidated The [ManagedType] of the property being validated.
  /// @param relationshipInverseType If the property is a relationship, the type of the inverse property.
  /// @return The list of allowed values for the [Validate.oneOf] validator.
  dynamic _oneOfCompiler(
    ManagedType typeBeingValidated, {
    Type? relationshipInverseType,
  }) {
    if (_value is! List) {
      throw ValidateCompilationError(
        "Validate.oneOf value must be a List<T>, where T is the type of the property being validated.",
      );
    }

    final options = _value;
    final supportedOneOfTypes = [
      ManagedPropertyType.string,
      ManagedPropertyType.integer,
      ManagedPropertyType.bigInteger
    ];
    if (!supportedOneOfTypes.contains(typeBeingValidated.kind) ||
        relationshipInverseType != null) {
      throw ValidateCompilationError(
        "Validate.oneOf is only valid for String or int types.",
      );
    }

    if (options.any((v) => !typeBeingValidated.isAssignableWith(v))) {
      throw ValidateCompilationError(
        "Validate.oneOf value must be a List<T>, where T is the type of the property being validated.",
      );
    }

    if (options.isEmpty) {
      throw ValidateCompilationError(
        "Validate.oneOf must have at least one element.",
      );
    }

    return options;
  }

  /// A list of [ValidationExpression] objects representing the various comparison
  /// conditions specified for this validator.
  ///
  /// The [ValidationExpression] objects are created based on the values of the
  /// `_equalTo`, `_lessThan`, `_lessThanEqualTo`, `_greaterThan`, and
  /// `_greaterThanEqualTo` instance variables.
  ///
  /// This method is used by the `_comparisonCompiler` method to compile the
  /// comparison validator.
  List<ValidationExpression> get _expressions {
    final comparisons = <ValidationExpression>[];
    if (_equalTo != null) {
      comparisons
          .add(ValidationExpression(ValidationOperator.equalTo, _equalTo));
    }
    if (_lessThan != null) {
      comparisons
          .add(ValidationExpression(ValidationOperator.lessThan, _lessThan));
    }
    if (_lessThanEqualTo != null) {
      comparisons.add(
        ValidationExpression(
          ValidationOperator.lessThanEqualTo,
          _lessThanEqualTo,
        ),
      );
    }
    if (_greaterThan != null) {
      comparisons.add(
        ValidationExpression(ValidationOperator.greaterThan, _greaterThan),
      );
    }
    if (_greaterThanEqualTo != null) {
      comparisons.add(
        ValidationExpression(
          ValidationOperator.greaterThanEqualTo,
          _greaterThanEqualTo,
        ),
      );
    }

    return comparisons;
  }

  /// Compiles the comparison validator.
  ///
  /// This method is responsible for creating a list of [ValidationExpression] objects
  /// that represent the various comparison conditions specified for this validator.
  ///
  /// The method performs the following tasks:
  ///
  /// 1. Retrieves the list of comparison expressions from the `_expressions` getter.
  /// 2. For each expression, it calls the `_parseComparisonValue` method to parse and validate
  ///    the comparison value based on the type of the property being validated.
  ///
  /// The compiled result is the list of [ValidationExpression] objects, which will be stored
  /// in the [ValidationContext.state] property during validation.
  ///
  /// @param typeBeingValidated The [ManagedType] of the property being validated.
  /// @param relationshipInverseType If the property is a relationship, the type of the inverse property.
  /// @return The list of [ValidationExpression] objects representing the comparison conditions.
  dynamic _comparisonCompiler(
    ManagedType? typeBeingValidated, {
    Type? relationshipInverseType,
  }) {
    final exprs = _expressions;
    for (final expr in exprs) {
      expr.value = _parseComparisonValue(
        expr.value,
        typeBeingValidated,
        relationshipInverseType: relationshipInverseType,
      );
    }
    return exprs;
  }

  /// Parses the comparison value for the [Validate.compare] validator.
  ///
  /// This method is responsible for validating the type of the comparison value
  /// and converting it to the appropriate type if necessary.
  ///
  /// If the property being validated is of type [DateTime], the method attempts to
  /// parse the [referenceValue] as a [DateTime] using [DateTime.parse]. If the
  /// parsing fails, a [ValidateCompilationError] is thrown.
  ///
  /// If the property being validated is not of type [DateTime], the method checks
  /// if the [referenceValue] is assignable to the type of the property being
  /// validated. If the types are not compatible, a [ValidateCompilationError] is
  /// thrown.
  ///
  /// If the [relationshipInverseType] is not null, the method checks if the
  /// [referenceValue] is assignable to the primary key type of the relationship
  /// being validated.
  ///
  /// @param referenceValue The value to be used for the comparison.
  /// @param typeBeingValidated The [ManagedType] of the property being validated.
  /// @param relationshipInverseType If the property is a relationship, the type of the inverse property.
  /// @return The parsed comparison value as a [Comparable] object.
  Comparable? _parseComparisonValue(
    dynamic referenceValue,
    ManagedType? typeBeingValidated, {
    Type? relationshipInverseType,
  }) {
    if (typeBeingValidated?.kind == ManagedPropertyType.datetime) {
      if (referenceValue is String) {
        try {
          return DateTime.parse(referenceValue);
        } on FormatException {
          throw ValidateCompilationError(
            "Validate.compare value '$referenceValue' cannot be parsed as expected DateTime type.",
          );
        }
      }

      throw ValidateCompilationError(
        "Validate.compare value '$referenceValue' is not expected DateTime type.",
      );
    }

    if (relationshipInverseType == null) {
      if (!typeBeingValidated!.isAssignableWith(referenceValue)) {
        throw ValidateCompilationError(
          "Validate.compare value '$referenceValue' is not assignable to type of attribute being validated.",
        );
      }
    } else {
      if (!typeBeingValidated!.isAssignableWith(referenceValue)) {
        throw ValidateCompilationError(
          "Validate.compare value '$referenceValue' is not assignable to primary key type of relationship being validated.",
        );
      }
    }

    return referenceValue as Comparable?;
  }

  /// Compiles the regular expression validator.
  ///
  /// This method is responsible for compiling the regular expression pattern specified
  /// in the `Validate.matches` validator.
  ///
  /// The method performs the following tasks:
  ///
  /// 1. Checks that the property being validated is of type `String`. If not, a `ValidateCompilationError`
  ///    is thrown with an appropriate error message.
  /// 2. Checks that the `_value` property, which should contain the regular expression pattern,
  ///    is of type `String`. If not, a `ValidateCompilationError` is thrown with an appropriate
  ///    error message.
  /// 3. Creates a `RegExp` object using the regular expression pattern specified in the `_value`
  ///    property, and returns it as the compiled result.
  ///
  /// The compiled `RegExp` object will be stored in the `ValidationContext.state` property
  /// during validation.
  ///
  /// @param typeBeingValidated The [ManagedType] of the property being validated.
  /// @param relationshipInverseType If the property is a relationship, the type of the inverse property.
  /// @return The compiled `RegExp` object representing the regular expression pattern.
  dynamic _regexCompiler(
    ManagedType? typeBeingValidated, {
    Type? relationshipInverseType,
  }) {
    if (typeBeingValidated?.kind != ManagedPropertyType.string) {
      throw ValidateCompilationError(
        "Validate.matches is only valid for 'String' properties.",
      );
    }

    if (_value is! String) {
      throw ValidateCompilationError(
        "Validate.matches argument must be 'String'.",
      );
    }

    return RegExp(_value);
  }

  /// Compiles the length validator.
  ///
  /// This method is responsible for creating a list of [ValidationExpression] objects
  /// that represent the various length-based conditions specified for this validator.
  ///
  /// The method performs the following tasks:
  ///
  /// 1. Checks that the property being validated is of type `String`. If not, a
  ///    `ValidateCompilationError` is thrown with an appropriate error message.
  /// 2. Retrieves the list of length-based expressions from the `_expressions` getter.
  /// 3. Checks that all the values in the expressions are of type `int`. If not, a
  ///    `ValidateCompilationError` is thrown with an appropriate error message.
  ///
  /// The compiled result is the list of [ValidationExpression] objects, which will be
  /// stored in the [ValidationContext.state] property during validation.
  ///
  /// @param typeBeingValidated The [ManagedType] of the property being validated.
  /// @param relationshipInverseType If the property is a relationship, the type of the inverse property.
  /// @return The list of [ValidationExpression] objects representing the length-based conditions.
  dynamic _lengthCompiler(
    ManagedType typeBeingValidated, {
    Type? relationshipInverseType,
  }) {
    if (typeBeingValidated.kind != ManagedPropertyType.string) {
      throw ValidateCompilationError(
        "Validate.length is only valid for 'String' properties.",
      );
    }
    final expressions = _expressions;
    if (expressions.any((v) => v.value is! int)) {
      throw ValidateCompilationError(
        "Validate.length arguments must be 'int's.",
      );
    }
    return expressions;
  }
}
