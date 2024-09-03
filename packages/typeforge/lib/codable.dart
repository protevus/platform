/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// The `codable` library provides functionality for encoding and decoding objects.
///
/// This library exports several core components:
/// - `referenceable.dart`: Defines objects that can be referenced.
/// - `coding.dart`: Contains encoding and decoding interfaces.
/// - `keyed_archive.dart`: Implements a key-value storage for encoded objects.
/// - `list_archive.dart`: Implements a list-based storage for encoded objects.
/// - `reference_resolver.dart`: Handles resolving references within encoded data.
///
/// These components work together to provide a robust system for object serialization
/// and deserialization, supporting both simple and complex data structures.
library codable;

export 'src/referenceable.dart';
export 'src/coding.dart';
export 'src/keyed_archive.dart';
export 'src/list_archive.dart';
export 'src/reference_resolver.dart';
