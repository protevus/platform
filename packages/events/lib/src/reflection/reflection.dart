import 'package:illuminate_container/container.dart';
import 'package:illuminate_contracts/contracts.dart';

/// A simpler reflection abstraction that works without dart:mirrors.
class EventReflection {
  /// The reflected instance.
  final dynamic instance;

  /// Create a new reflection instance.
  EventReflection(this.instance);

  /// Create a reflection for a class instance.
  static EventReflection? forInstance(Container container, dynamic instance) {
    if (instance == null) return null;
    return EventReflection(instance);
  }

  /// Create a reflection for a class type.
  static EventReflection? forClass(Container container, Type type) {
    final instance = container.make(type);
    if (instance == null) return null;
    return EventReflection(instance);
  }

  /// Create an instance of a class.
  static dynamic createInstance(Container container, String className) {
    final type = container.reflector.findTypeByName(className);
    if (type == null) return null;
    return container.make(type);
  }

  /// Get the type name of the reflected instance.
  String get typeName => instance.runtimeType.toString();

  /// Get the declarations for this instance.
  List<Declaration> get declarations {
    final methods = <Declaration>[];
    if (instance is HasHandle) methods.add(Declaration('handle'));
    if (instance is HasShouldQueue) methods.add(Declaration('shouldQueue'));
    if (instance is HasViaConnection) methods.add(Declaration('viaConnection'));
    if (instance is HasViaQueue) methods.add(Declaration('viaQueue'));
    if (instance is HasWithDelay) methods.add(Declaration('withDelay'));
    if (instance is HasThrough) methods.add(Declaration('through'));
    if (instance is HasAfterCommit) methods.add(Declaration('afterCommit'));
    return methods;
  }

  /// Check if the instance is assignable to a type.
  bool isAssignableTo(Type type) {
    if (type == ShouldQueue) return instance is ShouldQueue;
    if (type == ShouldBroadcast) return instance is ShouldBroadcast;
    if (type == ShouldHandleEventsAfterCommit) {
      return instance is ShouldHandleEventsAfterCommit;
    }
    return false;
  }

  /// Get a field value from the instance.
  dynamic getFieldValue(String name) {
    switch (name) {
      case 'afterCommit':
        return instance is ShouldHandleEventsAfterCommit;
      case 'connection':
        return instance is HasConnection ? instance.connection : null;
      case 'queue':
        return instance is HasQueue ? instance.queue : null;
      case 'delay':
        return instance is HasDelay ? instance.delay : null;
      case 'backoff':
        return instance is HasBackoff ? instance.backoff : null;
      case 'maxExceptions':
        return instance is HasMaxExceptions ? instance.maxExceptions : null;
      case 'timeout':
        return instance is HasTimeout ? instance.timeout : null;
      case 'failOnTimeout':
        return instance is HasFailOnTimeout ? instance.failOnTimeout : false;
      case 'tries':
        return instance is HasTries ? instance.tries : null;
      case 'middleware':
        return instance is HasMiddleware ? instance.middleware : null;
      case 'broadcastOn':
        return instance is ShouldBroadcast ? instance.broadcastOn() : null;
      case 'broadcastAs':
        return instance is ShouldBroadcast ? instance.broadcastAs() : null;
      case 'broadcastWith':
        return instance is ShouldBroadcast ? instance.broadcastWith() : null;
      default:
        throw ArgumentError('Unknown field: $name');
    }
  }

  /// Set a field value on the instance.
  void setFieldValue(String name, dynamic value) {
    switch (name) {
      case 'afterCommit':
        if (instance is HasAfterCommit) {
          (instance as HasAfterCommit).afterCommit = value as bool;
        }
        break;
      default:
        throw ArgumentError('Unknown field: $name');
    }
  }

  /// Check if a field exists.
  bool hasField(String name) {
    switch (name) {
      case 'afterCommit':
        return instance is HasAfterCommit;
      case 'connection':
        return instance is HasConnection;
      case 'queue':
        return instance is HasQueue;
      case 'delay':
        return instance is HasDelay;
      case 'backoff':
        return instance is HasBackoff;
      case 'maxExceptions':
        return instance is HasMaxExceptions;
      case 'timeout':
        return instance is HasTimeout;
      case 'failOnTimeout':
        return instance is HasFailOnTimeout;
      case 'tries':
        return instance is HasTries;
      case 'middleware':
        return instance is HasMiddleware;
      default:
        return false;
    }
  }

  /// Invoke a method on the instance.
  dynamic invoke(String name, [List<dynamic>? arguments]) {
    arguments ??= const [];
    switch (name) {
      case 'broadcastWhen':
        return instance is ShouldBroadcast ? instance.broadcastWhen() : true;
      case 'shouldQueue':
        return instance is HasShouldQueue
            ? instance.shouldQueue(arguments.first)
            : true;
      case 'viaConnection':
        return instance is HasViaConnection
            ? instance.viaConnection(arguments.first)
            : null;
      case 'viaQueue':
        return instance is HasViaQueue
            ? instance.viaQueue(arguments.first)
            : null;
      case 'withDelay':
        return instance is HasWithDelay
            ? instance.withDelay(arguments.first)
            : null;
      case 'through':
        if (instance is HasThrough && arguments.isNotEmpty) {
          instance.through(arguments.first as List);
        }
        return null;
      default:
        if (instance is HasHandle) {
          return instance.handle(arguments);
        }
        throw ArgumentError('Unknown method: $name');
    }
  }

  /// Clone the instance.
  dynamic clone() {
    if (instance is Cloneable) {
      return instance.clone();
    }
    return instance;
  }
}

/// A declaration in a reflected class.
class Declaration {
  /// The name of the declaration.
  final String name;

  /// Create a new declaration.
  Declaration(this.name);
}

/// Interface for objects that can be cloned.
abstract class Cloneable {
  dynamic clone();
}

/// Interface for objects that have a connection.
abstract class HasConnection {
  String? get connection;
}

/// Interface for objects that have a queue.
abstract class HasQueue {
  String? get queue;
}

/// Interface for objects that have a delay.
abstract class HasDelay {
  Duration? get delay;
}

/// Interface for objects that have a backoff.
abstract class HasBackoff {
  Duration? get backoff;
}

/// Interface for objects that have max exceptions.
abstract class HasMaxExceptions {
  int? get maxExceptions;
}

/// Interface for objects that have a timeout.
abstract class HasTimeout {
  Duration? get timeout;
}

/// Interface for objects that have fail on timeout.
abstract class HasFailOnTimeout {
  bool get failOnTimeout;
}

/// Interface for objects that have tries.
abstract class HasTries {
  int? get tries;
}

/// Interface for objects that have middleware.
abstract class HasMiddleware {
  List<dynamic>? get middleware;
}

/// Interface for objects that have through.
abstract class HasThrough {
  void through(List<dynamic> middleware);
}

/// Interface for objects that have handle.
abstract class HasHandle {
  dynamic handle(List<dynamic> arguments);
}

/// Interface for objects that have shouldQueue.
abstract class HasShouldQueue {
  bool shouldQueue(dynamic event);
}

/// Interface for objects that have viaConnection.
abstract class HasViaConnection {
  String? viaConnection(dynamic event);
}

/// Interface for objects that have viaQueue.
abstract class HasViaQueue {
  String? viaQueue(dynamic event);
}

/// Interface for objects that have withDelay.
abstract class HasWithDelay {
  Duration? withDelay(dynamic event);
}

/// Interface for objects that have afterCommit.
abstract class HasAfterCommit {
  bool get afterCommit;
  set afterCommit(bool value);
}
