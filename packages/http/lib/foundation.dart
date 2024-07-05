/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// This library exports various foundation classes and utilities for web-related operations.
///
/// It includes:
/// - [CountableInterface] for objects that can be counted
/// - [Cookie] for handling HTTP cookies
/// - [HeaderUtils] for working with HTTP headers
/// - [HeaderBag] for managing collections of HTTP headers
/// - [ParameterBag] for handling request parameters
/// - [ResponseHeaderBag] for managing response headers
library;

export 'src/foundation/countable_interface.dart';
export 'src/foundation/stringable_interface.dart';
export 'src/foundation/cookie.dart';
export 'src/foundation/header_utils.dart';
export 'src/foundation/header_bag.dart';
export 'src/foundation/parameter_bag.dart';
export 'src/foundation/response_header_bag.dart';