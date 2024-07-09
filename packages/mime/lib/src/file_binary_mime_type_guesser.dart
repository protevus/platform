import 'dart:io';
import 'package:protevus_mime/mime_exception.dart';
import 'package:protevus_mime/mime.dart';

/// This file is part of the Symfony package.
///
/// (c) Fabien Potencier <fabien@symfony.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.

/// Guesses the MIME type with the binary "file" (only available on *nix).
///
/// @author Bernhard Schussek <bschussek@gmail.com>
class FileBinaryMimeTypeGuesser implements MimeTypeGuesserInterface {
  /// The command to run to get the MIME type of a file.
  ///
  /// The $cmd pattern must contain a "%s" string that will be replaced
  /// with the file name to guess.
  ///
  /// The command output must start with the MIME type of the file.
  final String _cmd;

  /// Creates a new [FileBinaryMimeTypeGuesser] instance.
  ///
  /// [cmd] The command to run to get the MIME type of a file.
  FileBinaryMimeTypeGuesser([this._cmd = 'file -b --mime -- %s 2>/dev/null']);

  @override
  bool isGuesserSupported() {
    // Dart doesn't have a direct equivalent to PHP's static variables inside methods,
    // so we'll use a top-level variable instead.
    return isGuesserSupportedCached();
  }

  @override
  Future<String?> guessMimeType(String filePath) async {
    if (!File(filePath).existsSync() ||
        !File(filePath).statSync().modeString().contains('r')) {
      throw InvalidArgumentException(
          'The "$filePath" file does not exist or is not readable.');
    }

    if (!isGuesserSupported()) {
      throw LogicException(
          'The "${runtimeType.toString()}" guesser is not supported.');
    }

    final result = await Process.run(
        'sh', ['-c', _cmd.replaceFirst('%s', _escapeShellArg(filePath))]);

    if (result.exitCode > 0) {
      return null;
    }

    final type = result.stdout.toString().trim();
    final match =
        RegExp(r'^([a-z0-9\-]+/[a-z0-9\-\+\.]+)', caseSensitive: false)
            .firstMatch(type);

    if (match == null) {
      // it's not a type, but an error message
      return null;
    }

    return match.group(1);
  }

  String _escapeShellArg(String arg) {
    return "'${arg.replaceAll("'", "'\\''")}'";
  }
}

bool? _supportedCache;

bool isGuesserSupportedCached() {
  if (_supportedCache != null) {
    return _supportedCache!;
  }

  if (Platform.isWindows || !_hasCommand('file')) {
    return _supportedCache = false;
  }

  return _supportedCache = true;
}

bool _hasCommand(String command) {
  try {
    final result = Process.runSync('which', [command]);
    return result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty;
  } catch (e) {
    return false;
  }
}
