// This file is part of the Symfony package.
//
// (c) Fabien Potencier <fabien@symfony.com>
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

// In Dart, we don't have a direct equivalent of PHP's namespace.
// Instead, we use library or part directives to organize code.
// For this example, we'll assume this is part of a library called 'symfony_mime'.

// Dart doesn't have a direct equivalent to PHP's Throwable interface.
// Instead, we'll use the Exception class as the base for our interface.

/// Exception interface for the Symfony MIME component.
///
/// This interface is used to mark exceptions specific to the MIME component.
/// It doesn't add any additional methods but serves as a marker interface.
///
/// @author Fabien Potencier <fabien@symfony.com>
abstract class ExceptionInterface implements Exception {
  // This interface doesn't declare any methods.
  // It's used as a marker interface in Dart, similar to its use in PHP.
}
