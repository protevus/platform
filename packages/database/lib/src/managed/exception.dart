/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_http/http.dart';

/// An exception thrown when an ORM property validator is violated.
///
/// This exception behaves the same as [SerializableException]. It is used to
/// indicate that a validation error has occurred, such as when a property
/// value does not meet the expected criteria.
class ValidationException extends SerializableException {
  ValidationException(super.errors);
}
