import 'dart:async';
import 'dart:collection';

/// A rate limiter that uses the token bucket algorithm.
///
/// The rate limiter controls how frequently operations can be performed by
/// maintaining a bucket of tokens that are replenished at a fixed rate.
class RateLimiter {
  final int _maxTokens;
  final Duration _interval;
  double _tokens;
  DateTime _lastRefill;
  final Queue<Completer<void>> _waiters = Queue();
  Timer? _timer;

  /// Creates a new rate limiter.
  ///
  /// [tokensPerInterval] specifies how many tokens are added per interval.
  /// [interval] specifies how often tokens are replenished.
  /// [maxBurst] optionally limits the maximum number of tokens that can accumulate.
  RateLimiter({
    required int tokensPerInterval,
    required Duration interval,
    int? maxBurst,
  })  : _maxTokens = maxBurst ?? tokensPerInterval,
        _interval = interval,
        _tokens = maxBurst?.toDouble() ?? tokensPerInterval.toDouble(),
        _lastRefill = DateTime.now() {
    // Start token replenishment timer
    _startTimer();
  }

  /// Creates a rate limiter that allows a specified number of operations per second.
  factory RateLimiter.perSecond(int operations, {int? maxBurst}) {
    return RateLimiter(
      tokensPerInterval: operations,
      interval: const Duration(seconds: 1),
      maxBurst: maxBurst,
    );
  }

  /// Creates a rate limiter that allows a specified number of operations per minute.
  factory RateLimiter.perMinute(int operations, {int? maxBurst}) {
    return RateLimiter(
      tokensPerInterval: operations,
      interval: const Duration(minutes: 1),
      maxBurst: maxBurst,
    );
  }

  /// Creates a rate limiter that allows a specified number of operations per hour.
  factory RateLimiter.perHour(int operations, {int? maxBurst}) {
    return RateLimiter(
      tokensPerInterval: operations,
      interval: const Duration(hours: 1),
      maxBurst: maxBurst,
    );
  }

  /// The current number of available tokens.
  double get availableTokens {
    _refillTokens();
    return _tokens;
  }

  /// Whether the rate limiter currently has any available tokens.
  bool get hasTokens => availableTokens >= 1;

  /// Attempts to acquire a token immediately.
  ///
  /// Returns true if a token was acquired, false otherwise.
  bool tryAcquire() {
    _refillTokens();
    if (_tokens >= 1) {
      _tokens -= 1;
      return true;
    }
    return false;
  }

  /// Acquires a token, waiting if necessary.
  ///
  /// If [timeout] is specified and no token becomes available within that
  /// duration, throws a [RateLimitExceededException].
  Future<void> acquire({Duration? timeout}) {
    _refillTokens();
    if (_tokens >= 1) {
      _tokens -= 1;
      return Future.value();
    }

    final completer = Completer<void>();
    _waiters.add(completer);

    if (timeout != null) {
      return Future.any([
        completer.future,
        Future.delayed(timeout).then((_) {
          _waiters.remove(completer);
          throw RateLimitExceededException(
            'Failed to acquire token: timeout after ${timeout.inSeconds} seconds',
          );
        }),
      ]);
    }

    return completer.future;
  }

  /// Executes a task with rate limiting.
  ///
  /// Acquires a token before executing the task. If no token is available,
  /// waits until one becomes available.
  ///
  /// If [timeout] is specified and no token becomes available within that
  /// duration, throws a [RateLimitExceededException].
  Future<T> execute<T>(
    FutureOr<T> Function() task, {
    Duration? timeout,
  }) async {
    await acquire(timeout: timeout);
    return await task();
  }

  void _refillTokens() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill);
    if (elapsed >= _interval) {
      final periods = elapsed.inMicroseconds / _interval.inMicroseconds;
      _tokens = (_tokens + periods).clamp(0, _maxTokens.toDouble());
      _lastRefill = now;

      // Grant tokens to waiters
      while (_tokens >= 1 && _waiters.isNotEmpty) {
        _tokens -= 1;
        _waiters.removeFirst().complete();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      _refillTokens();
    });
  }

  /// Releases resources used by the rate limiter.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    for (final waiter in _waiters) {
      waiter.completeError(
        RateLimitExceededException('Rate limiter was disposed'),
      );
    }
    _waiters.clear();
  }
}

/// Exception thrown when rate limits are exceeded.
class RateLimitExceededException implements Exception {
  final String message;

  RateLimitExceededException(this.message);

  @override
  String toString() => 'RateLimitExceededException: $message';
}
