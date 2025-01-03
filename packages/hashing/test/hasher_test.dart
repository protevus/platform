import 'package:platform_contracts/contracts.dart';
import 'package:platform_hashing/platform_hashing.dart';
import 'package:test/test.dart';

void main() {
  group('BcryptHasher', () {
    late BcryptHasher hasher;

    setUp(() {
      hasher = BcryptHasher();
    });

    test('empty hashed value returns false', () {
      expect(hasher.check('password', ''), isFalse);
    });

    test('basic bcrypt hashing', () {
      final value = hasher.make('password');

      expect(value, isNot(equals('password')));
      expect(hasher.check('password', value), isTrue);
      expect(hasher.needsRehash(value), isFalse);
      expect(hasher.needsRehash(value, {'rounds': 1}), isTrue);

      final info = hasher.info(value);
      expect(info['algoName'], equals('bcrypt'));
      expect((info['options'] as Map)['rounds'] >= 12, isTrue);
    });

    test('bcrypt verification with argon2i hash throws', () {
      final argonHasher = ArgonHasher({'verify': true});
      final argonHashed = argonHasher.make('password');
      final bcryptHasher = BcryptHasher({'verify': true});

      expect(
        () => bcryptHasher.check('password', argonHashed),
        throwsStateError,
      );
    });
  });

  group('ArgonHasher', () {
    late ArgonHasher hasher;

    setUp(() {
      hasher = ArgonHasher();
    });

    test('empty hashed value returns false', () {
      expect(hasher.check('password', ''), isFalse);
    });

    test('basic argon2i hashing', () {
      final value = hasher.make('password');

      expect(value, isNot(equals('password')));
      expect(hasher.check('password', value), isTrue);
      expect(hasher.needsRehash(value), isFalse);
      expect(hasher.needsRehash(value, {'threads': 1}), isTrue);

      final info = hasher.info(value);
      expect(info['algoName'], equals('argon2i'));
    });

    test('argon2i verification with bcrypt hash throws', () {
      final bcryptHasher = BcryptHasher({'verify': true});
      final bcryptHashed = bcryptHasher.make('password');
      final argonHasher = ArgonHasher({'verify': true});

      expect(
        () => argonHasher.check('password', bcryptHashed),
        throwsStateError,
      );
    });
  });

  group('Argon2IdHasher', () {
    late Argon2IdHasher hasher;

    setUp(() {
      hasher = Argon2IdHasher();
    });

    test('empty hashed value returns false', () {
      expect(hasher.check('password', ''), isFalse);
    });

    test('basic argon2id hashing', () {
      final value = hasher.make('password');

      expect(value, isNot(equals('password')));
      expect(hasher.check('password', value), isTrue);
      expect(hasher.needsRehash(value), isFalse);
      expect(hasher.needsRehash(value, {'threads': 1}), isTrue);

      final info = hasher.info(value);
      expect(info['algoName'], equals('argon2id'));
    });

    test('argon2id verification with bcrypt hash throws', () {
      final bcryptHasher = BcryptHasher({'verify': true});
      final bcryptHashed = bcryptHasher.make('password');
      final argon2idHasher = Argon2IdHasher({'verify': true});

      expect(
        () => argon2idHasher.check('password', bcryptHashed),
        throwsStateError,
      );
    });
  });
}
