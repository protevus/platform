import 'dart:async';

/// Interface for command bus dispatching.
///
/// This contract defines how commands should be dispatched to their handlers.
/// It provides methods for both synchronous and asynchronous command handling,
/// as well as configuration of command handling pipelines.
abstract class Dispatcher {
  /// Dispatch a command to its appropriate handler.
  ///
  /// Example:
  /// ```dart
  /// var result = await dispatcher.dispatch(
  ///   CreateOrderCommand(items: items),
  /// );
  /// ```
  FutureOr<T> dispatch<T>(dynamic command);

  /// Dispatch a command to its appropriate handler in the current process.
  ///
  /// Queueable jobs will be dispatched to the "sync" queue.
  ///
  /// Example:
  /// ```dart
  /// var result = await dispatcher.dispatchSync(
  ///   CreateOrderCommand(items: items),
  /// );
  /// ```
  FutureOr<T> dispatchSync<T>(dynamic command, [dynamic handler]);

  /// Dispatch a command to its appropriate handler in the current process.
  ///
  /// Example:
  /// ```dart
  /// var result = await dispatcher.dispatchNow(
  ///   CreateOrderCommand(items: items),
  /// );
  /// ```
  FutureOr<T> dispatchNow<T>(dynamic command, [dynamic handler]);

  /// Determine if the given command has a handler.
  ///
  /// Example:
  /// ```dart
  /// if (dispatcher.hasCommandHandler(command)) {
  ///   print('Handler exists for command');
  /// }
  /// ```
  bool hasCommandHandler(dynamic command);

  /// Retrieve the handler for a command.
  ///
  /// Example:
  /// ```dart
  /// var handler = dispatcher.getCommandHandler(command);
  /// if (handler != null) {
  ///   print('Found handler: ${handler.runtimeType}');
  /// }
  /// ```
  dynamic getCommandHandler(dynamic command);

  /// Set the pipes commands should be piped through before dispatching.
  ///
  /// Example:
  /// ```dart
  /// dispatcher.pipeThrough([
  ///   TransactionPipe(),
  ///   LoggingPipe(),
  /// ]);
  /// ```
  Dispatcher pipeThrough(List<dynamic> pipes);

  /// Map a command to a handler.
  ///
  /// Example:
  /// ```dart
  /// dispatcher.map({
  ///   CreateOrderCommand: CreateOrderHandler,
  ///   UpdateOrderCommand: UpdateOrderHandler,
  /// });
  /// ```
  Dispatcher map(Map<Type, dynamic> commandMap);
}
