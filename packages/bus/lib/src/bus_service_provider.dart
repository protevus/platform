// // lib/src/bus_service_provider.dart

// import 'package:angel3_framework/angel3_framework.dart';
// import 'package:angel3_event_bus/angel3_event_bus.dart';
// import 'package:angel3_mq/angel3_mq.dart';
// import 'dispatcher.dart';

// class BusServiceProvider extends Provider {
//   @override
//   Future<void> boot(Angel app) async {
//     // Register EventBus
//     app.container.registerSingleton<EventBus>(EventBus());

//     // Register Queue
//     app.container.registerSingleton<Queue>(MemoryQueue());

//     // Create and register the Dispatcher
//     final dispatcher = Dispatcher(app.container);
//     app.container.registerSingleton<Dispatcher>(dispatcher);

//     // Register any global middleware or mappings
//     dispatcher.pipeThrough([
//       // Add any global middleware here
//     ]);

//     // Register command-to-handler mappings
//     dispatcher.map({
//       // Add your command-to-handler mappings here
//       // Example: ExampleCommand: ExampleCommandHandler,
//     });
//   }
// }

// class MemoryQueue implements Queue {
//   final List<Command> _queue = [];

//   @override
//   Future<void> push(Command command) async {
//     _queue.add(command);
//   }

//   @override
//   Future<void> later(Duration delay, Command command) async {
//     await Future.delayed(delay);
//     _queue.add(command);
//   }

//   @override
//   Future<void> pushOn(String queue, Command command) async {
//     // For simplicity, ignoring the queue parameter in this implementation
//     _queue.add(command);
//   }

//   @override
//   Future<void> laterOn(String queue, Duration delay, Command command) async {
//     // For simplicity, ignoring the queue parameter in this implementation
//     await Future.delayed(delay);
//     _queue.add(command);
//   }
// }
