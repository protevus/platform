/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// This library exports various components and utilities for handling HTTP requests and responses,
/// including controllers, request/response processing, routing, and serialization.
///
/// It provides a comprehensive set of tools for building web applications and APIs, including:
/// - Request and response handling
/// - Body decoding and encoding
/// - Caching and CORS policies
/// - File handling
/// - Database object controllers
/// - Resource controllers with bindings and scopes
/// - Routing and request path processing
/// - Serialization utilities
library;

export 'src/body_decoder.dart';
export 'src/cache_policy.dart';
export 'src/controller.dart';
export 'src/cors_policy.dart';
export 'src/file_controller.dart';
export 'src/handler_exception.dart';
export 'src/http_codec_repository.dart';
export 'src/managed_object_controller.dart';
export 'src/query_controller.dart';
export 'src/request.dart';
export 'src/request_body.dart';
export 'src/request_path.dart';
export 'src/resource_controller.dart';
export 'src/resource_controller_bindings.dart';
export 'src/resource_controller_interfaces.dart';
export 'src/resource_controller_scope.dart';
export 'src/response.dart';
export 'src/route_node.dart';
export 'src/route_specification.dart';
export 'src/router.dart';
export 'src/serializable.dart';
