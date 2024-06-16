// import statements for required packages
import 'mailer.dart';

abstract class Factory {
  /// Get a mailer instance by name.
  ///
  /// @param [name] The name of the mailer instance.
  /// @return An instance of [Mailer].
  Mailer mailer([String? name]);
}
