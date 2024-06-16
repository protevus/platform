import 'package:your_project/attachment.dart';

// TODO: Check imports

abstract class Attachable {
  /// Get an attachment instance for this entity.
  ///
  /// @return Attachment
  Attachment toMailAttachment();
}
