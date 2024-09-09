/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'package:protevus_http/http.dart';

/// A custom exception class for handling HTTP-related errors.
///
/// This exception is typically thrown when an HTTP handler encounters an error
/// and needs to provide a specific [Response] object as part of the exception.
class HandlerException implements Exception {
  /// Constructs a [HandlerException] with the given [Response].
  ///
  /// @param _response The HTTP response associated with this exception.
  HandlerException(this._response);

  /// Gets the [Response] object associated with this exception.
  ///
  /// This getter provides read-only access to the internal [_response] field.
  ///
  /// @return The [Response] object containing details about the HTTP error.
  Response get response => _response;

  /// The private field storing the HTTP response associated with this exception.
  final Response _response;
}
