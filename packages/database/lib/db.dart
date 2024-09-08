/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// This library provides core functionality for data management and persistence.
///
/// It exports several modules:
/// - `managed`: Handles managed objects and their lifecycle.
/// - `persistent_store`: Provides interfaces for data persistence.
/// - `query`: Offers query building and execution capabilities.
/// - `schema`: Defines schema-related structures and operations.
///
/// These modules collectively form a framework for efficient data handling,
/// storage, and retrieval within the Protevus Platform.
library;

export 'src/managed/managed.dart';
export 'src/persistent_store/persistent_store.dart';
export 'src/query/query.dart';
export 'src/schema/schema.dart';
