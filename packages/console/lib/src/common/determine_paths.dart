/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';

/// Determines the paths for source and backup directories based on the given parameters.
///
/// [path] is the relative or absolute path to the
/// file that we are going to backup. If [path] is
/// relative then it is relative to [workingDirectory].
/// [backupDir] is the temporary directory that we
/// are going to backup [path] to.
///
/// We use the following directory structure for the backup
/// relative/<path to [path]>
/// absolute/<path to [path]>
///
/// On Windows to accomodate drive letters we need a slightly
/// different directory structure
/// relative/<path to [path]>
/// absolute/<XDrive>/<path to [path]>
///
/// Where 'X' is the drive letter that [path] is located on.
///
Paths determinePaths({
  required String path,
  required String workingDirectory,
  required String backupDir,
}) {
  late final String sourcePath;
  late final String backupPath;

  /// we use two different directories for relative and absolute
  /// paths otherwise we can't differentiate when it comes time
  /// to restore.
  if (isRelative(path)) {
    backupPath = normalize(absolute(join(backupDir, 'relative', path)));
    sourcePath = join(workingDirectory, path);
  } else {
    sourcePath = normalize(absolute(path));
    final translatedPath =
        translateAbsolutePath(path, workingDirectory: workingDirectory);
    backupPath = join(backupDir, 'absolute', _stripRootPrefix(translatedPath));
  }

  return Paths(sourcePath, backupPath);
}

/// Represents a pair of paths for source and backup files.
///
/// This class is used to store and manage the paths for a source file
/// and its corresponding backup file.
///
/// [sourcePath] is the path to the original source file.
/// [backupPath] is the path where the backup of the source file will be stored.
class Paths {
  Paths(this.sourcePath, this.backupPath);

  String sourcePath;
  String backupPath;
}

/// Removes the root prefix (/ or \) from an absolute path
/// If there is no root prefix the original [absolutePath]
/// is returned untouched.
///
/// If the [absolutePath] only contains the root prefix
/// then a blank string is returned
///
///  /hellow -> hellow
///  hellow -> hellow
///  / ->
///
String? _stripRootPrefix(String absolutePath) {
  if (absolutePath.startsWith(r'\') || absolutePath.startsWith('/')) {
    if (absolutePath.length > 1) {
      return absolutePath.substring(1);
    } else {
      // the path only contained the root prefix and nothing else.
      return '';
    }
  }
  return absolutePath;
}

/// Translates an absolute path to a standardized format, primarily for Windows systems.
///
/// C:/abc -> /CDrive/abc
/// C:\abc -> /CDrive\abc
/// \\\abc -> \abc
/// \\abc -> abc
///
/// The [context] is only used for unit testing so
/// we can fake the platform separator.
String translateAbsolutePath(
  String absolutePath, {
  String? workingDirectory,
  p.Context? context,
}) {
  final windowsStyle = context != null && context.style == Style.windows;
  if (!windowsStyle && !Platform.isWindows) {
    return absolutePath;
  }

  context ??= p.context;

  // ignore: parameter_assignments
  workingDirectory ??= Directory.current.path;

  final parts = context.split(absolutePath);
  if (parts[0].contains(':')) {
    final index = parts[0].indexOf(':');

    final drive = parts[0][index - 1].toUpperCase();
    return context.joinAll(['\\${drive}Drive', ...parts.sublist(1)]);
  }

  if (parts[0].startsWith(r'\\')) {
    final uncparts = parts[0].split(r'\\');
    return context.joinAll([r'\UNC', ...uncparts.sublist(1)]);
  }

  if (absolutePath.startsWith(r'\') || absolutePath.startsWith('/')) {
    String drive;
    if (workingDirectory.contains(':')) {
      drive = workingDirectory[0].toUpperCase();
    } else {
      drive = Directory.current.path[0].toUpperCase();
    }
    return context.joinAll(['\\${drive}Drive', ...parts.sublist(1)]);
  }

  /// probably not an absolute path
  /// so just pass back what we were handed.
  return absolutePath;
}
