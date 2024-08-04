/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Removes null entries from a list of nullable strings and returns a new list of non-nullable strings.
///
/// This function takes a nullable list of nullable strings as input and performs two operations:
/// 1. It removes any null entries from the list.
/// 2. It converts the resulting list to a List<String>.
///
/// If the input list is null, the function returns null.
///
/// Parameters:
///   [list] - The input list of nullable strings (List<String?>?) that may contain null entries.
///
/// Returns:
///   A new List<String> with all non-null entries from the input list, or null if the input list is null.
List<String>? removeNullsFromList(List<String?>? list) {
  if (list == null) return null;

  // remove nulls and convert to List<String>
  return list.nonNulls.toList();
}
