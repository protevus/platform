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
import 'dart:mirrors';

/// An abstract class representing an executable task in an isolate.
///
/// This class provides a framework for executing tasks in separate isolates,
/// with built-in communication capabilities.
abstract class Executable<T extends Object?> {
  /// Constructor for the Executable class.
  ///
  /// @param message A map containing the message data, including a SendPort.
  Executable(this.message) : _sendPort = message["_sendPort"];

  /// Abstract method to be implemented by subclasses.
  ///
  /// This method should contain the main logic of the task to be executed.
  /// @returns A Future that completes with the result of type T.
  Future<T> execute();

  /// The message data passed to the Executable.
  final Map<String, dynamic> message;

  /// A SendPort for communicating back to the main isolate.
  final SendPort? _sendPort;

  /// Creates an instance of a specified type using reflection.
  ///
  /// @param typeName The name of the type to instantiate.
  /// @param positionalArguments List of positional arguments for the constructor.
  /// @param namedArguments Map of named arguments for the constructor.
  /// @param constructorName The name of the constructor to use.
  /// @returns An instance of the specified type U.
  U instanceOf<U>(
    String typeName, {
    List positionalArguments = const [],
    Map<Symbol, dynamic> namedArguments = const {},
    Symbol constructorName = Symbol.empty,
  }) {
    // Try to find the ClassMirror in the root library
    ClassMirror? typeMirror = currentMirrorSystem()
        .isolate
        .rootLibrary
        .declarations[Symbol(typeName)] as ClassMirror?;

    // If not found in the root library, search in all libraries
    typeMirror ??= currentMirrorSystem()
        .libraries
        .values
        .where((lib) => lib.uri.scheme == "package" || lib.uri.scheme == "file")
        .expand((lib) => lib.declarations.values)
        .firstWhere(
          (decl) =>
              decl is ClassMirror &&
              MirrorSystem.getName(decl.simpleName) == typeName,
          orElse: () => throw ArgumentError(
            "Unknown type '$typeName'. Did you forget to import it?",
          ),
        ) as ClassMirror?;

    // Create and return a new instance of the specified type
    return typeMirror!
        .newInstance(
          constructorName,
          positionalArguments,
          namedArguments,
        )
        .reflectee as U;
  }

  /// Sends a message back to the main isolate.
  ///
  /// @param message The message to be sent.
  void send(dynamic message) {
    _sendPort!.send(message);
  }

  /// Logs a message by sending it back to the main isolate.
  ///
  /// @param message The message to be logged.
  void log(String message) {
    _sendPort!.send({"_line_": message});
  }
}
