/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 * (C) S. Brett Sutton <bsutton@onepub.dev>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

///
/// devNull is a convenience function which you can use
/// if you want to ignore the output of a LineAction.
/// Its typical useage is a forEach where you don't want
/// to see any stdout but you still want to see errors
/// printed to stderr.
///
/// ```dart
/// 'git pull'.forEach(devNull, stderr: (line) => printerr(line));
/// ```
///
/// use this to consume the output.
void devNull(String? line) {}
