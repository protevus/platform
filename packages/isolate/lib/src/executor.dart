/*
 * This file is part of the Protevus Platform.
 *
 * (C) Protevus <developers@protevus.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:protevus_isolate/isolate.dart';

/// A class that manages the execution of code in an isolate.
///
/// This class provides functionality to run code in a separate isolate,
/// allowing for concurrent execution and isolation of resources.
/// It handles the creation of the isolate, communication between the
/// main isolate and the spawned isolate, and manages the lifecycle
/// of the execution.
class IsolateExecutor<U> {
  /// Creates an instance of IsolateExecutor.
  ///
  /// [generator] is the [SourceGenerator] that provides the source code
  /// to be executed in the isolate.
  /// [packageConfigURI] is the optional URI of the package configuration file.
  /// If provided, it will be used for package resolution in the isolate.
  /// [message] is an optional map of data to be passed to the isolate.
  /// This data will be available to the code running in the isolate.
  IsolateExecutor(
    this.generator, {
    this.packageConfigURI,
    this.message = const {},
  });

  /// The source generator that provides the code to be executed.
  final SourceGenerator generator;

  /// A map of data to be passed to the isolate.
  final Map<String, dynamic> message;

  /// The URI of the package configuration file.
  final Uri? packageConfigURI;

  /// A completer that completes when the isolate execution is finished.
  final Completer completer = Completer();

  /// Stream of events from the isolate.
  ///
  /// This stream emits any custom events sent from the isolate during execution.
  Stream<dynamic> get events => _eventListener.stream;

  /// Stream of console output from the isolate.
  ///
  /// This stream emits any console output (print statements, etc.) from the isolate.
  Stream<String> get console => _logListener.stream;

  /// StreamController for managing console output from the isolate.
  final StreamController<String> _logListener = StreamController<String>();

  /// StreamController for managing custom events from the isolate.
  final StreamController<dynamic> _eventListener = StreamController<dynamic>();

  /// Executes the code in the isolate and returns the result.
  ///
  /// This method spawns a new isolate, runs the provided code, and returns
  /// the result. It handles error cases and ensures proper cleanup of resources.
  ///
  /// Throws a [StateError] if the package configuration file is not found.
  ///
  /// Returns a [Future] that completes with the result of the isolate execution.
  Future<U> execute() async {
    if (packageConfigURI != null &&
        !File.fromUri(packageConfigURI!).existsSync()) {
      throw StateError(
        "Package file '$packageConfigURI' not found. Run 'pub get' and retry.",
      );
    }

    final scriptSource = Uri.encodeComponent(await generator.scriptSource);

    final onErrorPort = ReceivePort()
      ..listen((err) async {
        if (err is List) {
          final stack =
              StackTrace.fromString(err.last.replaceAll(scriptSource, ""));

          completer.completeError(StateError(err.first), stack);
        } else {
          completer.completeError(err);
        }
      });

    final controlPort = ReceivePort()
      ..listen((results) {
        if (results is Map && results.length == 1) {
          if (results.containsKey("_result")) {
            completer.complete(results['_result']);
            return;
          } else if (results.containsKey("_line_")) {
            _logListener.add(results["_line_"]);
            return;
          }
        }
        _eventListener.add(results);
      });
    try {
      message["_sendPort"] = controlPort.sendPort;

      final dataUri = Uri.parse(
        "data:application/dart;charset=utf-8,$scriptSource",
      );

      await Isolate.spawnUri(
        dataUri,
        [],
        message,
        onError: onErrorPort.sendPort,
        packageConfig: packageConfigURI,
        automaticPackageResolution: packageConfigURI == null,
      );
      return await completer.future;
    } catch (e) {
      print(e);
      rethrow;
    } finally {
      onErrorPort.close();
      controlPort.close();
      _eventListener.close();
      _logListener.close();
    }
  }

  /// Runs an executable in an isolate.
  ///
  /// This static method provides a convenient way to execute code in an isolate.
  /// It creates a [SourceGenerator], sets up an [IsolateExecutor], and manages
  /// the execution process.
  ///
  /// [executable] is an instance of [Executable<T>] containing the code to be executed.
  /// [imports] is an optional list of import statements to be included in the isolate.
  /// [packageConfigURI] is the optional URI of the package configuration file.
  /// [additionalContents] is optional additional code to be included in the isolate.
  /// [additionalTypes] is an optional list of additional types to be included in the isolate.
  /// [eventHandler] is an optional function to handle events from the isolate.
  /// [logHandler] is an optional function to handle console output from the isolate.
  ///
  /// Returns a [Future] that completes with the result of type [T] from the isolate execution.
  static Future<T> run<T>(
    Executable<T> executable, {
    List<String> imports = const [],
    Uri? packageConfigURI,
    String? additionalContents,
    List<Type> additionalTypes = const [],
    void Function(dynamic event)? eventHandler,
    void Function(String line)? logHandler,
  }) async {
    final source = SourceGenerator(
      executable.runtimeType,
      imports: imports,
      additionalContents: additionalContents,
      additionalTypes: additionalTypes,
    );

    final executor = IsolateExecutor<T>(
      source,
      packageConfigURI: packageConfigURI,
      message: executable.message,
    );

    if (eventHandler != null) {
      executor.events.listen(eventHandler);
    }

    if (logHandler != null) {
      executor.console.listen(logHandler);
    }

    return executor.execute();
  }
}
