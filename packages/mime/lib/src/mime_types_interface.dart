// This file is part of the Symfony package.
//
// (c) Fabien Potencier <fabien@symfony.com>
//
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'package:protevus_mime/mime.dart';

/// @author Fabien Potencier <fabien@symfony.com>
abstract class MimeTypesInterface implements MimeTypeGuesserInterface {
  /// Gets the extensions for the given MIME type in decreasing order of preference.
  ///
  /// Returns a list of strings representing file extensions.
  List<String> getExtensions(String mimeType);

  /// Gets the MIME types for the given extension in decreasing order of preference.
  ///
  /// Returns a list of strings representing MIME types.
  List<String> getMimeTypes(String ext);
}
