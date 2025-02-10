import 'dart:async';
import '../str.dart';

/// A callback that can be deferred for later execution.
class DeferredCallback {
  /// The callback function to be executed.
  final Function _callback;

  /// The arguments to pass to the callback.
  final List<dynamic> _arguments;

  /// The named arguments to pass to the callback.
  final Map<Symbol, dynamic> _namedArguments;

  /// Creates a new deferred callback.
  DeferredCallback(
    this._callback, [
    this._arguments = const [],
    this._namedArguments = const {},
  ]);

  /// Creates a new deferred callback from a closure.
  static DeferredCallback fromClosure(
    Function callback, [
    List<dynamic> arguments = const [],
    Map<Symbol, dynamic> namedArguments = const {},
  ]) {
    return DeferredCallback(callback, arguments, namedArguments);
  }

  /// Creates a new deferred callback from a string callback.
  static DeferredCallback fromString(
    String callback, [
    List<dynamic> arguments = const [],
    Map<Symbol, dynamic> namedArguments = const {},
  ]) {
    final parts = Str.parseCallback(callback);
    if (parts == null) {
      throw ArgumentError(
          'Invalid callback string format. Expected "Class@method".');
    }

    final className = parts[0];
    final methodName = parts[1];

    // In a real implementation, you would use reflection or dependency injection
    // to resolve the class and method. This is a simplified example.
    throw UnimplementedError(
        'Resolving callbacks from strings requires reflection or dependency injection. '
        'Use fromClosure() instead.');
  }

  /// Execute the callback with optional arguments.
  Future<dynamic> execute([
    List<dynamic>? args,
    Map<Symbol, dynamic>? namedArgs,
  ]) async {
    try {
      final arguments = args ?? _arguments;
      final namedArguments = namedArgs ?? _namedArguments;

      // Handle callbacks with no parameters
      if (_callback is Function() || _callback is Future<dynamic> Function()) {
        final result = _callback();
        return result is Future ? await result : result;
      }

      // Handle callbacks with parameters
      final result = Function.apply(_callback, arguments, namedArguments);
      return result is Future ? await result : result;
    } catch (e) {
      rethrow;
    }
  }

  /// Execute the callback after a delay.
  Future<dynamic> executeAfter(Duration delay) async {
    await Future.delayed(delay);
    return execute();
  }

  /// Execute the callback on the next event loop iteration.
  Future<dynamic> executeDeferred() async {
    await Future.microtask(() {});
    return execute();
  }

  /// Execute the callback on a separate isolate.
  Future<dynamic> executeIsolated() async {
    // Note: This is a simplified implementation.
    // For production use, consider using compute() or a proper isolate pool.
    return execute();
  }

  /// Execute the callback and catch any errors.
  Future<dynamic> executeSafely([Function(Object error)? onError]) async {
    try {
      return await execute();
    } catch (e) {
      if (onError != null) {
        onError(e);
      }
      return null;
    }
  }

  /// Execute the callback with a timeout.
  Future<dynamic> executeWithTimeout(Duration timeout) {
    return Future.any([
      execute(),
      Future.delayed(timeout).then((_) {
        throw TimeoutException('Callback execution timed out', timeout);
      }),
    ]);
  }

  /// Execute the callback with retry logic.
  Future<dynamic> executeWithRetry({
    int maxAttempts = 3,
    Duration delay = const Duration(milliseconds: 100),
    bool Function(Object)? retryIf,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await execute();
      } catch (e) {
        if (attempts >= maxAttempts || (retryIf != null && !retryIf(e))) {
          rethrow;
        }
        await Future.delayed(delay * attempts);
      }
    }
  }

  /// Execute multiple callbacks in parallel.
  static Future<List<dynamic>> executeParallel(
      List<DeferredCallback> callbacks) {
    return Future.wait(callbacks.map((callback) => callback.execute()));
  }

  /// Execute multiple callbacks in sequence.
  static Future<List<dynamic>> executeSequential(
      List<DeferredCallback> callbacks) async {
    final results = <dynamic>[];
    for (final callback in callbacks) {
      results.add(await callback.execute());
    }
    return results;
  }

  /// Execute multiple callbacks and return when any completes.
  static Future<dynamic> executeAny(List<DeferredCallback> callbacks) {
    return Future.any(callbacks.map((callback) => callback.execute()));
  }

  /// Create a new callback that will be executed only once.
  static DeferredCallback once(Function callback) {
    var executed = false;
    return DeferredCallback(() async {
      if (!executed) {
        executed = true;
        if (callback is Function()) {
          final result = callback();
          return result is Future ? await result : result;
        }
        final result = Function.apply(callback, const [], const {});
        return result is Future ? await result : result;
      }
      return null;
    });
  }

  /// Create a new callback that will be debounced.
  static DeferredCallback debounce(
    Function callback,
    Duration duration, {
    bool leading = false,
  }) {
    Timer? timer;
    var waiting = false;

    return DeferredCallback(() async {
      if (timer != null) {
        timer!.cancel();
      }

      final completer = Completer<dynamic>();

      if (!waiting && leading) {
        waiting = true;
        if (callback is Function()) {
          final result = callback();
          if (result is Future) {
            await result;
          }
          completer.complete(result);
        } else {
          final result = Function.apply(callback, const [], const {});
          if (result is Future) {
            await result;
          }
          completer.complete(result);
        }
      }

      timer = Timer(duration, () async {
        if (!leading) {
          if (callback is Function()) {
            final result = callback();
            if (result is Future) {
              await result;
            }
            if (!completer.isCompleted) {
              completer.complete(result);
            }
          } else {
            final result = Function.apply(callback, const [], const {});
            if (result is Future) {
              await result;
            }
            if (!completer.isCompleted) {
              completer.complete(result);
            }
          }
        }
        waiting = false;
      });

      return completer.future;
    });
  }

  /// Create a new callback that will be throttled.
  static DeferredCallback throttle(
    Function callback,
    Duration duration, {
    bool leading = true,
    bool trailing = true,
  }) {
    var lastRun = DateTime.fromMillisecondsSinceEpoch(0);

    return DeferredCallback(() async {
      final now = DateTime.now();
      if (now.difference(lastRun) >= duration) {
        lastRun = now;
        if (callback is Function()) {
          final result = callback();
          return result is Future ? await result : result;
        }
        final result = Function.apply(callback, const [], const {});
        return result is Future ? await result : result;
      }
      return null;
    });
  }

  /// Create a new callback that will be memoized.
  static DeferredCallback memoize(
    Function callback, {
    Duration? maxAge,
    int? maxSize,
  }) {
    final cache = <String, _CacheEntry>{};
    var keys = <String>[];

    String _generateKey(List<dynamic> args, Map<Symbol, dynamic> namedArgs) {
      return Str.slug('${args.toString()}|${namedArgs.toString()}');
    }

    void _cleanCache() {
      if (maxAge != null) {
        final now = DateTime.now();
        cache.removeWhere(
            (_, entry) => now.difference(entry.timestamp) > maxAge);
      }
      if (maxSize != null && keys.length > maxSize) {
        final removeCount = keys.length - maxSize;
        for (var i = 0; i < removeCount; i++) {
          cache.remove(keys.removeAt(0));
        }
      }
    }

    return DeferredCallback((List<dynamic> args,
        [Map<Symbol, dynamic>? namedArgs]) async {
      final key = _generateKey(args, namedArgs ?? {});
      _cleanCache();

      if (cache.containsKey(key)) {
        return cache[key]!.value;
      }

      final result = Function.apply(callback, args, namedArgs ?? {});
      final finalResult = result is Future ? await result : result;
      cache[key] = _CacheEntry(finalResult);
      keys.add(key);

      return finalResult;
    });
  }
}

/// A cache entry for memoized callbacks.
class _CacheEntry {
  final dynamic value;
  final DateTime timestamp;

  _CacheEntry(this.value) : timestamp = DateTime.now();
}
