import 'dart:async';
import 'package:path/path.dart' as path;
import 'deferred/deferred_callback.dart';
import 'deferred/deferred_callback_collection.dart';
import 'process/executable_finder.dart';

/// A class that provides function utilities.
class Functions {
  /// The executable finder instance.
  static final _executableFinder = ExecutableFinder();

  /// Create a deferred callback from a function.
  static DeferredCallback defer(
    Function callback, [
    List<dynamic> arguments = const [],
    Map<Symbol, dynamic> namedArguments = const {},
  ]) {
    return DeferredCallback(callback, arguments, namedArguments);
  }

  /// Create a collection of deferred callbacks.
  static DeferredCallbackCollection collection([
    Iterable<DeferredCallback>? callbacks,
  ]) {
    return DeferredCallbackCollection(callbacks);
  }

  /// Create a callback that will be executed only once.
  static DeferredCallback once(Function callback) {
    return DeferredCallback.once(callback);
  }

  /// Create a callback that will be debounced.
  static DeferredCallback debounce(
    Function callback,
    Duration duration, {
    bool leading = false,
  }) {
    return DeferredCallback.debounce(callback, duration, leading: leading);
  }

  /// Create a callback that will be throttled.
  static DeferredCallback throttle(
    Function callback,
    Duration duration, {
    bool leading = true,
    bool trailing = true,
  }) {
    return DeferredCallback.throttle(
      callback,
      duration,
      leading: leading,
      trailing: trailing,
    );
  }

  /// Create a callback that will be memoized.
  static DeferredCallback memoize(
    Function callback, {
    Duration? maxAge,
    int? maxSize,
  }) {
    final cache = <String, dynamic>{};
    var keys = <String>[];

    String _generateKey(List<dynamic> args) {
      return args.toString();
    }

    void _cleanCache() {
      if (maxSize != null && keys.length > maxSize) {
        final removeCount = keys.length - maxSize;
        for (var i = 0; i < removeCount; i++) {
          cache.remove(keys.removeAt(0));
        }
      }
    }

    return DeferredCallback((List<dynamic> args) {
      final key = _generateKey(args);
      _cleanCache();

      if (cache.containsKey(key)) {
        return cache[key];
      }

      final result = callback is Function()
          ? callback()
          : callback is Function(List<dynamic>)
              ? callback(args[0] as List<dynamic>)
              : Function.apply(callback, args[0] as List<dynamic>);

      cache[key] = result;
      keys.add(key);

      return result;
    });
  }

  /// Execute a callback after a delay.
  static Future<T> after<T>(
    Duration delay,
    FutureOr<T> Function() callback,
  ) async {
    await Future.delayed(delay);
    return await callback();
  }

  /// Execute a callback periodically.
  static Timer every(
    Duration interval,
    void Function() callback, {
    bool immediate = false,
  }) {
    if (immediate) {
      callback();
    }
    return Timer.periodic(interval, (_) => callback());
  }

  /// Execute a callback with retry logic.
  static Future<T> retry<T>(
    FutureOr<T> Function() callback, {
    int maxAttempts = 3,
    Duration delay = const Duration(milliseconds: 100),
    bool Function(Object)? retryIf,
  }) async {
    return await defer(callback).executeWithRetry(
      maxAttempts: maxAttempts,
      delay: delay,
      retryIf: retryIf,
    ) as T;
  }

  /// Execute a callback with a timeout.
  static Future<T> timeout<T>(
    FutureOr<T> Function() callback,
    Duration timeout,
  ) async {
    return await defer(callback).executeWithTimeout(timeout) as T;
  }

  /// Execute a callback safely, catching any errors.
  static Future<T?> safely<T>(
    FutureOr<T> Function() callback, [
    Function(Object error)? onError,
  ]) async {
    return await defer(callback).executeSafely(onError) as T?;
  }

  /// Execute multiple callbacks in parallel.
  static Future<List<T>> parallel<T>(
    Iterable<FutureOr<T> Function()> callbacks,
  ) async {
    final results = await DeferredCallback.executeParallel(
      callbacks.map((callback) => defer(callback)).toList(),
    );
    return results.cast<T>();
  }

  /// Execute multiple callbacks in sequence.
  static Future<List<T>> sequence<T>(
    Iterable<FutureOr<T> Function()> callbacks,
  ) async {
    final results = await DeferredCallback.executeSequential(
      callbacks.map((callback) => defer(callback)).toList(),
    );
    return results.cast<T>();
  }

  /// Execute multiple callbacks and return when any completes.
  static Future<T> any<T>(Iterable<FutureOr<T> Function()> callbacks) async {
    return await DeferredCallback.executeAny(
      callbacks.map((callback) => defer(callback)).toList(),
    ) as T;
  }

  /// Find an executable in the system PATH.
  static String? executable(String name) {
    return _executableFinder.find(name);
  }

  /// Find all matching executables in the system PATH.
  static List<String> executables(String pattern) {
    return _executableFinder.findAll(pattern);
  }

  /// Find an executable with a specific version requirement.
  static String? executableWithVersion(String name, String version) {
    return _executableFinder.findWithVersion(name, version);
  }

  /// Check if an executable exists.
  static bool hasExecutable(String name) {
    return _executableFinder.exists(name);
  }

  /// Get the default executable search path.
  static List<String> defaultPath() {
    return _executableFinder.getDefaultPath();
  }

  /// Create a callback that will be rate limited.
  static DeferredCallback rateLimit(
    Function callback,
    int maxPerInterval,
    Duration interval,
  ) {
    var lastRun = DateTime.fromMillisecondsSinceEpoch(0);
    var count = 0;

    return DeferredCallback(() async {
      final now = DateTime.now();
      if (now.difference(lastRun) >= interval) {
        count = 0;
        lastRun = now;
      }

      if (count >= maxPerInterval) {
        return null;
      }

      count++;
      final result = Function.apply(callback, const [], const {});
      return result is Future ? await result : result;
    });
  }

  /// Create a callback that will be executed on the next event loop iteration.
  static DeferredCallback nextTick(Function callback) {
    return DeferredCallback(() async {
      await Future.microtask(() {});
      final result = Function.apply(callback, const [], const {});
      return result is Future ? await result : result;
    });
  }

  /// Create a callback that will be executed with a specific error handler.
  static DeferredCallback withErrorHandler(
    Function callback,
    Function(Object error) onError,
  ) {
    return DeferredCallback(() async {
      try {
        final result = Function.apply(callback, const [], const {});
        return result is Future ? await result : result;
      } catch (e) {
        onError(e);
        rethrow;
      }
    });
  }

  /// Create a callback that will be executed with a specific completion handler.
  static DeferredCallback withCompletion(
    Function callback,
    void Function() onComplete,
  ) {
    return DeferredCallback(() async {
      try {
        final result = Function.apply(callback, const [], const {});
        final finalResult = result is Future ? await result : result;
        onComplete();
        return finalResult;
      } finally {
        onComplete();
      }
    });
  }
}
