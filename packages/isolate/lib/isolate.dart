/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// This library provides functionality for working with isolates in Dart.
/// It exports three main components:
/// 1. Executable: Defines the structure for tasks that can be executed in isolates.
/// 2. Executor: Provides mechanisms for running executables in isolates.
/// 3. SourceGenerator: Offers utilities for generating source code for isolates.
///
/// These components work together to facilitate concurrent programming and
/// improve performance in Dart applications by leveraging isolates.
library isolate;

export 'package:protevus_isolate/src/executable.dart';
export 'package:protevus_isolate/src/executor.dart';
export 'package:protevus_isolate/src/source_generator.dart';
