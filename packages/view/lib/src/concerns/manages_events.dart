import 'package:illuminate_container/container.dart';
import 'package:illuminate_events/events.dart';
import '../contracts/view.dart';

/// A mixin that provides event management functionality.
mixin ManagesEvents {
  /// The event dispatcher instance.
  EventDispatcher get events;

  /// The IoC container instance.
  Container get container;

  /// Register a view creator event.
  List<Function> creator(dynamic views, dynamic callback) {
    final creators = <Function>[];

    final viewsList = views is List ? views : [views];
    for (final view in viewsList) {
      creators.add(_addViewEvent(view, callback, 'creating: '));
    }

    return creators;
  }

  /// Register multiple view composers via an array.
  List<Function> composers(Map<Function, List<String>> composers) {
    final registered = <Function>[];

    composers.forEach((callback, views) {
      registered.addAll(composer(views, callback));
    });

    return registered;
  }

  /// Register a view composer event.
  List<Function> composer(dynamic views, dynamic callback) {
    final composers = <Function>[];

    final viewsList = views is List ? views : [views];
    for (final view in viewsList) {
      // Support both class names and callbacks
      if (callback is String) {
        composers.add(_addViewEvent(view, [callback.runtimeType, callback]));
      } else {
        composers.add(_addViewEvent(view, callback));
      }
    }

    return composers;
  }

  /// Register a one-time view composer event.
  List<Function> composerOnce(dynamic views, dynamic callback) {
    final composers = <Function>[];

    final viewsList = views is List ? views : [views];
    for (final view in viewsList) {
      final eventName = 'composing: ${normalizeName(view)}';
      wrappedCallback(String event, List<dynamic> args) {
        // Support both class names and callbacks
        if (callback is String) {
          final instance = container.make(callback.runtimeType);
          if (instance != null) {
            instance.compose(args[0]);
          }
        } else {
          callback(event, args);
        }
        events.forget(eventName);
      }

      events.listen(eventName, wrappedCallback);
      composers.add(wrappedCallback);
    }

    return composers;
  }

  /// Add an event for a given view.
  Function _addViewEvent(String view, dynamic callback,
      [String prefix = 'composing: ']) {
    final normalizedView = normalizeName(view);
    final eventName = prefix + normalizedView;

    // If callback is a class name string, it will be handled by the EventDispatcher
    events.listen(eventName, callback);
    return callback;
  }

  /// Call the composer for a given view.
  void callComposer(View view) {
    final event = 'composing: ${view.name}';
    if (events.hasListeners(event)) {
      events.dispatch(event, [view]);
    }
  }

  /// Call the creator for a given view.
  void callCreator(View view) {
    final event = 'creating: ${view.name}';
    if (events.hasListeners(event)) {
      events.dispatch(event, [view]);
    }
  }

  /// Normalize a view name.
  String normalizeName(String name);
}
