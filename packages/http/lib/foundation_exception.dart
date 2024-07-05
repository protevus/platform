/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// This library exports various exception classes and interfaces.
///
/// The exported classes include:
/// - `BadRequestException`: Used for handling bad HTTP requests.
/// - `RequestExceptionInterface`: An interface for request-related exceptions.
/// - `UnexpectedValueException`: Used when an unexpected value is encountered.
///
/// These exports allow other parts of the application to use these
/// exception classes and interfaces without needing to import them directly.
library;

export 'src/foundation/exception/bad_request_exception.dart';
export 'src/foundation/exception/request_exception_interface.dart';
export 'src/foundation/exception/unexpected_value_exception.dart';