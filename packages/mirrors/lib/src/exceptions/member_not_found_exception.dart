import 'package:illuminate_mirrors/mirrors.dart';

/// Exception thrown when a member is not found during reflection.
class MemberNotFoundException extends ReflectionException {
  /// The name of the member that was not found.
  final String memberName;

  /// The type the member was looked up on.
  final Type type;

  /// Creates a new member not found exception.
  const MemberNotFoundException(this.memberName, this.type)
      : super('Member $memberName not found on type $type');
}
