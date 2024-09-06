/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'dart:isolate';

import 'package:protevus_application/application.dart';

/*
  Warning: do not remove. This method is invoked by a generated script.

 */

/// Starts the application either on the current isolate or across multiple isolates.
///
/// This function initializes and starts the application, setting up communication
/// between isolates using ports. It responds to stop commands and reports the
/// application's status back to the parent isolate.
///
/// Parameters:
/// - app: The Application instance to be started.
/// - isolateCount: The number of isolates to start the application on. If 0, starts on the current isolate.
/// - parentPort: The SendPort of the parent isolate for communication.
///
/// The function sets up a ReceivePort to listen for commands, particularly the "stop" command.
/// It then starts the application either on the current isolate or across multiple isolates
/// based on the isolateCount parameter. Finally, it sends a status message back to the parent isolate.
Future startApplication<T extends ApplicationChannel>(
  Application<T> app,
  int isolateCount,
  SendPort parentPort,
) async {
  final port = ReceivePort();

  port.listen((msg) {
    if (msg["command"] == "stop") {
      port.close();
      app.stop().then((_) {
        parentPort.send({"status": "stopped"});
      });
    }
  });

  if (isolateCount == 0) {
    await app.startOnCurrentIsolate();
  } else {
    await app.start(numberOfInstances: isolateCount);
  }
  parentPort.send({"status": "ok", "port": port.sendPort});
}
