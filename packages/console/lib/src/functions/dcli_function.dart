/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 * (C) S. Brett Sutton <bsutton@onepub.dev>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_console/core.dart';

/// Base class for the classes that implement
/// the public DCli functions.
class DCliFunction {}

/// Base class for all dcli function exceptions.
class DCliFunctionException extends DCliException {
  /// Base class for all dcli function exceptions.
  DCliFunctionException(super.message, [super.stackTrace]);
}
