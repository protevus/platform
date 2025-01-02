import 'dart:async';

import 'package:platform_bus/platform_bus.dart';
import 'package:test/test.dart';

void main() {
  group('UniqueLock', () {
    setUp(() {
      UniqueLock.clear(); // Clear any existing locks before each test
    });

    test('acquires and releases lock', () {
      final expiration = Duration(seconds: 1);

      expect(UniqueLock.acquire('test-lock', expiration), isTrue);
      expect(UniqueLock.exists('test-lock', expiration), isTrue);

      UniqueLock.release('test-lock');
      expect(UniqueLock.exists('test-lock', expiration), isFalse);
    });

    test('prevents duplicate lock acquisition', () {
      final expiration = Duration(seconds: 1);

      expect(UniqueLock.acquire('test-lock', expiration), isTrue);
      expect(UniqueLock.acquire('test-lock', expiration), isFalse);
    });

    test('allows lock acquisition after expiration', () async {
      final expiration = Duration(milliseconds: 100);

      expect(UniqueLock.acquire('test-lock', expiration), isTrue);
      await Future.delayed(Duration(milliseconds: 150)); // Wait for expiration
      expect(UniqueLock.acquire('test-lock', expiration), isTrue);
    });

    test('allows different locks simultaneously', () {
      final expiration = Duration(seconds: 1);

      expect(UniqueLock.acquire('lock-1', expiration), isTrue);
      expect(UniqueLock.acquire('lock-2', expiration), isTrue);
    });

    test('tracks expiration time', () {
      final expiration = Duration(seconds: 1);
      final beforeAcquire = DateTime.now();

      UniqueLock.acquire('test-lock', expiration);
      final expirationTime = UniqueLock.expiresAt('test-lock');

      expect(expirationTime, isNotNull);
      expect(
        expirationTime!.isAfter(beforeAcquire) ||
            expirationTime.isAtSameMomentAs(beforeAcquire),
        isTrue,
      );
    });

    test('clears expired locks', () async {
      final shortExpiration = Duration(milliseconds: 100);
      final longExpiration = Duration(seconds: 1);

      UniqueLock.acquire('short-lock', shortExpiration);
      UniqueLock.acquire('long-lock', longExpiration);

      await Future.delayed(Duration(milliseconds: 150));
      UniqueLock.clearExpired(shortExpiration);

      expect(UniqueLock.exists('short-lock', shortExpiration), isFalse);
      expect(UniqueLock.exists('long-lock', longExpiration), isTrue);
    });

    test('clears all locks', () {
      final expiration = Duration(seconds: 1);

      UniqueLock.acquire('lock-1', expiration);
      UniqueLock.acquire('lock-2', expiration);

      UniqueLock.clear();

      expect(UniqueLock.exists('lock-1', expiration), isFalse);
      expect(UniqueLock.exists('lock-2', expiration), isFalse);
    });

    test('handles lock expiration check correctly', () {
      final expiration = Duration(seconds: 1);

      expect(UniqueLock.exists('nonexistent-lock', expiration), isFalse);

      UniqueLock.acquire('test-lock', expiration);
      expect(UniqueLock.exists('test-lock', expiration), isTrue);

      UniqueLock.release('test-lock');
      expect(UniqueLock.exists('test-lock', expiration), isFalse);
    });

    test('handles multiple lock operations', () async {
      final expiration = Duration(milliseconds: 100);

      // First acquisition
      expect(UniqueLock.acquire('test-lock', expiration), isTrue);
      expect(UniqueLock.exists('test-lock', expiration), isTrue);

      // Wait for expiration
      await Future.delayed(Duration(milliseconds: 150));
      expect(UniqueLock.exists('test-lock', expiration), isFalse);

      // Re-acquire
      expect(UniqueLock.acquire('test-lock', expiration), isTrue);
      expect(UniqueLock.exists('test-lock', expiration), isTrue);

      // Release and verify
      UniqueLock.release('test-lock');
      expect(UniqueLock.exists('test-lock', expiration), isFalse);
    });
  });
}
