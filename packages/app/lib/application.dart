/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

/// This library exports various components of the application framework.
///
/// It includes:
/// - Application and ApplicationServer classes for managing the application lifecycle
/// - Channel for handling request/response cycles
/// - IsolateApplicationServer and IsolateSupervisor for managing isolates
/// - Options for configuring the application
/// - Starter for initializing and running the application
library;

export 'src/application.dart';
export 'src/application_server.dart';
export 'src/channel.dart';
export 'src/isolate_application_server.dart';
export 'src/isolate_supervisor.dart';
export 'src/options.dart';
export 'src/starter.dart';
