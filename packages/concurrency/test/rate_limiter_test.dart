import 'dart:async';

import 'package:platform_concurrency/platform_concurrency.dart';
import 'package:test/test.dart';

void main() {
  group('RateLimiter', () {
    test('allows operations within rate limit', () async {
      final limiter = RateLimiter(
        tokensPerInterval: 2,
        interval: const Duration(milliseconds: 100),
      );

      // Should allow 2 operations immediately
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isFalse);

      // Wait for token replenishment
      await Future.delayed(const Duration(milliseconds: 150));

      // Should have tokens again
      expect(limiter.tryAcquire(), isTrue);
    });

    test('handles burst limits', () {
      final limiter = RateLimiter(
        tokensPerInterval: 1,
        interval: const Duration(seconds: 1),
        maxBurst: 3,
      );

      // Should allow up to maxBurst operations
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isTrue);
      expect(limiter.tryAcquire(), isFalse);
    });

    test('waits for available tokens', () async {
      final limiter = RateLimiter(
        tokensPerInterval: 1,
        interval: const Duration(milliseconds: 100),
      );

      // Use up available token
      expect(limiter.tryAcquire(), isTrue);

      // Start timing
      final startTime = DateTime.now();

      // Wait for next token
      await limiter.acquire();

      final duration = DateTime.now().difference(startTime);
      expect(duration.inMilliseconds, greaterThanOrEqualTo(90));
    });

    test('handles timeouts', () async {
      final limiter = RateLimiter(
        tokensPerInterval: 1,
        interval: const Duration(seconds: 1),
      );

      // Use up available token
      expect(limiter.tryAcquire(), isTrue);

      // Try to acquire with timeout
      expect(
        () => limiter.acquire(timeout: const Duration(milliseconds: 100)),
        throwsA(isA<RateLimitExceededException>()),
      );
    });

    test('executes tasks with rate limiting', () async {
      final limiter = RateLimiter(
        tokensPerInterval: 2,
        interval: const Duration(milliseconds: 100),
      );

      final results = <int>[];
      final startTime = DateTime.now();

      // Execute 3 tasks (should take 2 intervals)
      await Future.wait([
        limiter.execute(() async {
          results.add(1);
          return 1;
        }),
        limiter.execute(() async {
          results.add(2);
          return 2;
        }),
        limiter.execute(() async {
          results.add(3);
          return 3;
        }),
      ]);

      final duration = DateTime.now().difference(startTime);
      expect(duration.inMilliseconds, greaterThanOrEqualTo(90));
      expect(results.length, 3);
    });

    test('factory constructors create correct configurations', () {
      final perSecond = RateLimiter.perSecond(10);
      final perMinute = RateLimiter.perMinute(60);
      final perHour = RateLimiter.perHour(3600);

      expect(perSecond.availableTokens, 10);
      expect(perMinute.availableTokens, 60);
      expect(perHour.availableTokens, 3600);
    });

    test('maintains token count within bounds', () async {
      final limiter = RateLimiter(
        tokensPerInterval: 1,
        interval: const Duration(milliseconds: 100),
        maxBurst: 2,
      );

      // Wait for tokens to accumulate
      await Future.delayed(const Duration(milliseconds: 500));

      // Should still only have maxBurst tokens
      expect(limiter.availableTokens, 2);
    });

    test('handles concurrent acquire requests', () async {
      final limiter = RateLimiter(
        tokensPerInterval: 1,
        interval: const Duration(milliseconds: 100),
      );

      // Use up available token
      expect(limiter.tryAcquire(), isTrue);

      // Start multiple acquire requests
      final futures = List.generate(
        3,
        (_) => limiter.acquire(),
      );

      // Wait for some tokens to be replenished
      await Future.delayed(const Duration(milliseconds: 250));

      // Should have completed some but not all requests
      final completed = await Future.wait(
        futures.map((f) => f
            .timeout(
              Duration.zero,
              onTimeout: () => false,
            )
            .then((_) => true)
            .catchError((_) => false)),
      );

      expect(completed.where((success) => success).length, 2);
      expect(completed.where((success) => !success).length, 1);
    });
  });
}
