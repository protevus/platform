/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// This library provides hashing functionality for the Protevus Platform.
///
/// It exports two main components:
/// - PBKDF2 (Password-Based Key Derivation Function 2) implementation
/// - Salt generation utilities
///
/// These components are essential for secure password hashing and storage.
library hashing;

export 'package:protevus_hashing/src/pbkdf2.dart';
export 'package:protevus_hashing/src/salt.dart';
