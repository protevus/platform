import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  setUp(() {
    // Reset any custom rules before each test
    Pluralizer.addRule('reset', 'resets');
  });

  group('Pluralizer', () {
    test('pluralizes regular words', () {
      expect(Pluralizer.plural('book'), equals('books'));
      expect(Pluralizer.plural('cat'), equals('cats'));
      expect(Pluralizer.plural('dog'), equals('dogs'));
    });

    test('handles words ending in s, ss, sh, ch, x, z', () {
      expect(Pluralizer.plural('bus'), equals('buses'));
      expect(Pluralizer.plural('class'), equals('classes'));
      expect(Pluralizer.plural('dish'), equals('dishes'));
      expect(Pluralizer.plural('watch'), equals('watches'));
      expect(Pluralizer.plural('box'), equals('boxes'));
      expect(Pluralizer.plural('quiz'), equals('quizzes'));
    });

    test('handles words ending in y', () {
      expect(Pluralizer.plural('city'), equals('cities'));
      expect(Pluralizer.plural('puppy'), equals('puppies'));
      expect(Pluralizer.plural('boy'), equals('boys')); // y after vowel
      expect(Pluralizer.plural('day'), equals('days')); // y after vowel
    });

    test('handles irregular plurals', () {
      expect(Pluralizer.plural('child'), equals('children'));
      expect(Pluralizer.plural('person'), equals('people'));
      expect(Pluralizer.plural('foot'), equals('feet'));
      expect(Pluralizer.plural('goose'), equals('geese'));
      expect(Pluralizer.plural('criterion'), equals('criteria'));
    });

    test('handles uncountable words', () {
      expect(Pluralizer.plural('equipment'), equals('equipment'));
      expect(Pluralizer.plural('information'), equals('information'));
      expect(Pluralizer.plural('rice'), equals('rice'));
      expect(Pluralizer.plural('money'), equals('money'));
      expect(Pluralizer.plural('species'), equals('species'));
    });

    test('handles count parameter', () {
      expect(Pluralizer.plural('book', 1), equals('book'));
      expect(Pluralizer.plural('book', 2), equals('books'));
      expect(Pluralizer.plural('child', 1), equals('child'));
      expect(Pluralizer.plural('child', 2), equals('children'));
    });

    test('singularizes regular words', () {
      expect(Pluralizer.singular('books'), equals('book'));
      expect(Pluralizer.singular('cats'), equals('cat'));
      expect(Pluralizer.singular('dogs'), equals('dog'));
    });

    test('singularizes words ending in es', () {
      expect(Pluralizer.singular('buses'), equals('bus'));
      expect(Pluralizer.singular('classes'), equals('class'));
      expect(Pluralizer.singular('dishes'), equals('dish'));
      expect(Pluralizer.singular('watches'), equals('watch'));
      expect(Pluralizer.singular('boxes'), equals('box'));
    });

    test('singularizes words ending in ies', () {
      expect(Pluralizer.singular('cities'), equals('city'));
      expect(Pluralizer.singular('puppies'), equals('puppy'));
    });

    test('singularizes irregular plurals', () {
      expect(Pluralizer.singular('children'), equals('child'));
      expect(Pluralizer.singular('people'), equals('person'));
      expect(Pluralizer.singular('feet'), equals('foot'));
      expect(Pluralizer.singular('geese'), equals('goose'));
      expect(Pluralizer.singular('criteria'), equals('criterion'));
    });

    test('handles custom rules', () {
      Pluralizer.addRule('custom', 'customs');
      expect(Pluralizer.plural('custom'), equals('customs'));
      expect(Pluralizer.singular('customs'), equals('custom'));
    });

    test('handles custom irregular words', () {
      Pluralizer.addIrregular('octopus', 'octopi');
      expect(Pluralizer.plural('octopus'), equals('octopi'));
      expect(Pluralizer.singular('octopi'), equals('octopus'));
    });

    test('handles custom uncountable words', () {
      Pluralizer.addUncountable('water');
      expect(Pluralizer.plural('water'), equals('water'));
      expect(Pluralizer.singular('water'), equals('water'));
    });

    test('preserves case', () {
      expect(Pluralizer.plural('Book'), equals('Books'));
      expect(Pluralizer.plural('BOOK'), equals('BOOKS'));
      expect(Pluralizer.singular('Books'), equals('Book'));
      expect(Pluralizer.singular('BOOKS'), equals('BOOK'));
    });

    test('detects plural words', () {
      expect(Pluralizer.isPlural('books'), isTrue);
      expect(Pluralizer.isPlural('children'), isTrue);
      expect(Pluralizer.isPlural('book'), isFalse);
      expect(Pluralizer.isPlural('child'), isFalse);
    });

    test('detects singular words', () {
      expect(Pluralizer.isSingular('book'), isTrue);
      expect(Pluralizer.isSingular('child'), isTrue);
      expect(Pluralizer.isSingular('books'), isFalse);
      expect(Pluralizer.isSingular('children'), isFalse);
    });

    test('handles academic words', () {
      expect(Pluralizer.plural('analysis'), equals('analyses'));
      expect(Pluralizer.plural('datum'), equals('data'));
      expect(Pluralizer.plural('thesis'), equals('theses'));
      expect(Pluralizer.singular('analyses'), equals('analysis'));
      expect(Pluralizer.singular('data'), equals('datum'));
      expect(Pluralizer.singular('theses'), equals('thesis'));
    });
  });
}
