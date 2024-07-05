/*
 * This file is part of the Protevus Platform.
 * This file is a port of the symfony RequestExceptionInterface.php class to Dart
 *
 * (C) Protevus <developers@protevus.com>
 * (C) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// An interface for exceptions related to HTTP requests.
///
/// Implementations of this interface are intended to be used for exceptions
/// that should trigger an HTTP 400 (Bad Request) response in the application.
///
/// This interface doesn't declare any methods, but serves as a marker
/// to identify exceptions specifically related to request handling.
abstract class RequestExceptionInterface {
  
}

