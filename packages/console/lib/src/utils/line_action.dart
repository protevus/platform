/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 * (C) S. Brett Sutton <bsutton@onepub.dev>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Typedef for LineActions
typedef LineAction = void Function(String line);

/// Typedef for cancellable LineActions.
typedef CancelableLineAction = bool Function(String line);
