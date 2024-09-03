/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// Configuration library for the Protevus Platform.
///
/// This library exports various components related to configuration management,
/// including compiler, runtime, and default configurations. It also includes
/// utilities for handling intermediate exceptions and mirror properties.
///
/// The exported modules are:
/// - compiler: Handles compilation of configuration files.
/// - configuration: Defines the core configuration structure.
/// - default_configurations: Provides pre-defined default configurations.
/// - intermediate_exception: Manages exceptions during configuration processing.
/// - mirror_property: Utilities for reflection-based property handling.
/// - runtime: Manages runtime configuration aspects.
library config;

export 'package:protevus_config/src/compiler.dart';
export 'package:protevus_config/src/configuration.dart';
export 'package:protevus_config/src/default_configurations.dart';
export 'package:protevus_config/src/intermediate_exception.dart';
export 'package:protevus_config/src/mirror_property.dart';
export 'package:protevus_config/src/runtime.dart';
