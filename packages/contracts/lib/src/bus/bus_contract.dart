import 'package:meta/meta.dart';

/// Contract for commands.
///
/// Laravel-compatible: Base interface for command objects that can be
/// dispatched through the command bus.
@sealed
abstract class CommandContract {}

/// Contract for queueable commands.
///
/// Laravel-compatible: Marks commands that should be processed
/// through the queue system.
@sealed
abstract class ShouldQueueCommand implements CommandContract {}

/// Contract for command handlers.
///
/// Laravel-compatible: Defines how command handlers should process
/// their associated commands, with platform-specific typing.
@sealed
abstract class HandlerContract {
  /// Handles a command.
  ///
  /// Laravel-compatible: Core handler method with platform-specific
  /// return type for more flexibility.
  ///
  /// Parameters:
  ///   - [command]: The command to handle.
  Future<dynamic> handle(CommandContract command);
}

/// Type definition for command pipe functions.
///
/// Platform-specific: Defines transformation functions that can modify
/// commands as they flow through the pipeline.
typedef CommandPipe = CommandContract Function(CommandContract);

/// Contract for command dispatching.
///
/// This contract defines the core interface for dispatching
/// and processing commands through the command bus.
@sealed
abstract class CommandDispatcherContract {
  /// Dispatches a command.
  ///
  /// Laravel-compatible: Core dispatch method.
  ///
  /// Parameters:
  ///   - [command]: The command to dispatch.
  Future<dynamic> dispatch(CommandContract command);

  /// Dispatches a command synchronously.
  ///
  /// Platform-specific: Provides explicit sync dispatch with optional handler.
  ///
  /// Parameters:
  ///   - [command]: The command to dispatch.
  ///   - [handler]: Optional specific handler.
  Future<dynamic> dispatchSync(CommandContract command,
      [HandlerContract? handler]);

  /// Dispatches a command immediately.
  ///
  /// Laravel-compatible: Immediate dispatch without queueing.
  /// Extended with optional handler parameter.
  ///
  /// Parameters:
  ///   - [command]: The command to dispatch.
  ///   - [handler]: Optional specific handler.
  Future<dynamic> dispatchNow(CommandContract command,
      [HandlerContract? handler]);

  /// Dispatches a command to queue.
  ///
  /// Laravel-compatible: Queue-based dispatch.
  ///
  /// Parameters:
  ///   - [command]: The command to queue.
  Future<dynamic> dispatchToQueue(CommandContract command);

  /// Finds a command batch.
  ///
  /// Platform-specific: Provides batch lookup functionality.
  ///
  /// Parameters:
  ///   - [batchId]: The batch ID to find.
  Future<CommandBatchContract?> findBatch(String batchId);

  /// Creates a command batch.
  ///
  /// Laravel-compatible: Creates command batches.
  /// Extended with platform-specific batch contract.
  ///
  /// Parameters:
  ///   - [commands]: Commands to include in batch.
  PendingCommandBatchContract batch(List<CommandContract> commands);

  /// Creates a command chain.
  ///
  /// Laravel-compatible: Creates command chains.
  /// Extended with platform-specific chain contract.
  ///
  /// Parameters:
  ///   - [commands]: Commands to chain.
  CommandChainContract chain(List<CommandContract> commands);

  /// Maps command types to handlers.
  ///
  /// Platform-specific: Provides explicit handler mapping.
  ///
  /// Parameters:
  ///   - [handlers]: Map of command types to handler types.
  CommandDispatcherContract map(Map<Type, Type> handlers);

  /// Applies transformation pipes to commands.
  ///
  /// Platform-specific: Adds pipeline transformation support.
  ///
  /// Parameters:
  ///   - [pipes]: List of command transformation functions.
  CommandDispatcherContract pipeThrough(List<CommandPipe> pipes);

  /// Dispatches after current response.
  ///
  /// Laravel-compatible: Delayed dispatch after response.
  ///
  /// Parameters:
  ///   - [command]: Command to dispatch later.
  void dispatchAfterResponse(CommandContract command);
}

/// Contract for command batches.
///
/// Laravel-compatible: Defines batch structure and operations.
/// Extended with additional status tracking.
@sealed
abstract class CommandBatchContract {
  /// Gets the batch ID.
  String get id;

  /// Gets commands in the batch.
  List<CommandContract> get commands;

  /// Gets batch status.
  ///
  /// Platform-specific: Provides detailed status tracking.
  String get status;

  /// Whether batch allows failures.
  ///
  /// Laravel-compatible: Controls batch failure handling.
  bool get allowsFailures;

  /// Gets finished command count.
  ///
  /// Platform-specific: Tracks completion progress.
  int get finished;

  /// Gets failed command count.
  ///
  /// Platform-specific: Tracks failure count.
  int get failed;

  /// Gets pending command count.
  ///
  /// Platform-specific: Tracks remaining commands.
  int get pending;
}

/// Contract for pending command batches.
///
/// Laravel-compatible: Defines batch configuration and dispatch.
@sealed
abstract class PendingCommandBatchContract {
  /// Allows failures in batch.
  ///
  /// Laravel-compatible: Configures failure handling.
  PendingCommandBatchContract allowFailures();

  /// Dispatches the batch.
  ///
  /// Laravel-compatible: Executes the batch.
  Future<void> dispatch();
}

/// Contract for command chains.
///
/// Laravel-compatible: Defines sequential command execution.
@sealed
abstract class CommandChainContract {
  /// Dispatches the chain.
  ///
  /// Laravel-compatible: Executes commands in sequence.
  Future<void> dispatch();
}
