import 'package:illuminate_collections/collections.dart';
import 'deferred_callback.dart';

/// A collection of deferred callbacks that can be executed together.
class DeferredCallbackCollection extends Collection<DeferredCallback> {
  /// Creates a new deferred callback collection.
  DeferredCallbackCollection([Iterable<DeferredCallback>? callbacks])
      : super(callbacks);

  /// Execute all callbacks in parallel.
  Future<List<dynamic>> executeParallel() {
    return DeferredCallback.executeParallel(all());
  }

  /// Execute all callbacks in sequence.
  Future<List<dynamic>> executeSequential() {
    return DeferredCallback.executeSequential(all());
  }

  /// Execute callbacks until one completes successfully.
  Future<dynamic> executeUntilSuccess() async {
    for (final callback in all()) {
      try {
        return await callback.execute();
      } catch (_) {
        continue;
      }
    }
    throw StateError('No callback completed successfully');
  }

  /// Execute callbacks until one fails.
  Future<List<dynamic>> executeUntilFailure() async {
    final results = <dynamic>[];
    for (final callback in all()) {
      try {
        results.add(await callback.execute());
      } catch (e) {
        return results;
      }
    }
    return results;
  }

  /// Execute callbacks with a delay between each execution.
  Future<List<dynamic>> executeWithDelay(Duration delay) async {
    final results = <dynamic>[];
    final callbacks = all();
    for (var i = 0; i < callbacks.length; i++) {
      results.add(await callbacks[i].execute());
      if (i < callbacks.length - 1) {
        await Future.delayed(delay);
      }
    }
    return results;
  }

  /// Execute callbacks with a timeout for each execution.
  Future<List<dynamic>> executeWithTimeout(Duration timeout) async {
    final results = <dynamic>[];
    for (final callback in all()) {
      try {
        results.add(await callback.executeWithTimeout(timeout));
      } catch (e) {
        results.add(e);
      }
    }
    return results;
  }

  /// Execute callbacks safely, catching any errors.
  Future<List<dynamic>> executeSafely([Function(Object error)? onError]) async {
    final results = <dynamic>[];
    for (final callback in all()) {
      results.add(await callback.executeSafely(onError));
    }
    return results;
  }

  /// Execute callbacks with retry logic.
  Future<List<dynamic>> executeWithRetry({
    int maxAttempts = 3,
    Duration delay = const Duration(milliseconds: 100),
    bool Function(Object)? retryIf,
  }) async {
    final results = <dynamic>[];
    for (final callback in all()) {
      results.add(await callback.executeWithRetry(
        maxAttempts: maxAttempts,
        delay: delay,
        retryIf: retryIf,
      ));
    }
    return results;
  }

  /// Execute a specific number of callbacks in parallel.
  Future<List<dynamic>> executeParallelLimit(int limit) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be greater than 0');
    }

    final callbacks = all();
    final results = List<dynamic>.filled(callbacks.length, null);
    var index = 0;

    await Future.wait(
      List.generate(limit.clamp(0, callbacks.length), (i) async {
        while (index < callbacks.length) {
          final currentIndex = index++;
          results[currentIndex] = await callbacks[currentIndex].execute();
        }
      }),
    );

    return results;
  }

  /// Execute callbacks with a rate limit.
  Future<List<dynamic>> executeRateLimited(
    int maxPerInterval,
    Duration interval,
  ) async {
    if (maxPerInterval <= 0) {
      throw ArgumentError('Max per interval must be greater than 0');
    }

    final results = <dynamic>[];
    var executed = 0;
    var lastIntervalStart = DateTime.now();

    for (final callback in all()) {
      final now = DateTime.now();
      if (now.difference(lastIntervalStart) >= interval) {
        executed = 0;
        lastIntervalStart = now;
      }

      if (executed >= maxPerInterval) {
        final waitTime = interval - now.difference(lastIntervalStart);
        if (waitTime.isNegative == false) {
          await Future.delayed(waitTime);
        }
        executed = 0;
        lastIntervalStart = DateTime.now();
      }

      results.add(await callback.execute());
      executed++;
    }

    return results;
  }

  /// Filter the collection to only include callbacks that match the predicate.
  @override
  DeferredCallbackCollection where(bool Function(DeferredCallback) test) {
    return DeferredCallbackCollection(super.where(test));
  }

  /// Map each callback to a new callback.
  @override
  Collection<R> mapItems<R>(R Function(DeferredCallback element) toElement) {
    return Collection(super.mapItems(toElement));
  }

  /// Get a new collection with the specified callbacks.
  @override
  DeferredCallbackCollection only(List<int> indices) {
    return DeferredCallbackCollection(super.only(indices));
  }

  /// Get a new collection without the specified callbacks.
  @override
  DeferredCallbackCollection except(List<int> indices) {
    return DeferredCallbackCollection(super.except(indices));
  }

  /// Get a random callback from the collection.
  @override
  DeferredCallback random() {
    return super.random();
  }

  /// Get a new collection with unique callbacks.
  @override
  DeferredCallbackCollection unique() {
    return DeferredCallbackCollection(super.unique());
  }
}
