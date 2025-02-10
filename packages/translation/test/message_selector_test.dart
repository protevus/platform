import 'test_helper.dart';

void main() {
  late MessageSelector selector;

  setUp(() {
    selector = MessageSelector();
  });

  group('MessageSelector', () {
    test('handles basic pluralization', () {
      final line = 'apple|apples';
      expect(selector.choose(line, 1, 'en'), 'apple');
      expect(selector.choose(line, 2, 'en'), 'apples');
    });

    test('handles explicit numbers', () {
      final line = '{1} apple|{2} apples|{3} many apples';
      expect(selector.choose(line, 1, 'en'), ' apple');
      expect(selector.choose(line, 2, 'en'), ' apples');
      expect(selector.choose(line, 3, 'en'), ' many apples');
      // Falls back to first form for unmatched numbers
      expect(selector.choose(line, 4, 'en'), ' apple');
    });

    test('handles ranges', () {
      final line = '[0,1] none or one|[2,4] a few|[5,*] many';
      expect(selector.choose(line, 0, 'en'), ' none or one');
      expect(selector.choose(line, 1, 'en'), ' none or one');
      expect(selector.choose(line, 2, 'en'), ' a few');
      expect(selector.choose(line, 4, 'en'), ' a few');
      expect(selector.choose(line, 5, 'en'), ' many');
      expect(selector.choose(line, 100, 'en'), ' many');
    });

    test('handles mixed explicit and range conditions', () {
      final line = '{1} one|[2,4] a few|[5,*] many';
      expect(selector.choose(line, 1, 'en'), ' one');
      expect(selector.choose(line, 2, 'en'), ' a few');
      expect(selector.choose(line, 4, 'en'), ' a few');
      expect(selector.choose(line, 5, 'en'), ' many');
    });

    test('handles single form', () {
      final line = 'single form';
      expect(selector.choose(line, 1, 'en'), 'single form');
      expect(selector.choose(line, 2, 'en'), 'single form');
    });

    group('locale-specific rules', () {
      test('handles English pluralization', () {
        final line = 'item|items';
        expect(selector.choose(line, 1, 'en'), 'item');
        expect(selector.choose(line, 0, 'en'), 'items');
        expect(selector.choose(line, 2, 'en'), 'items');
      });

      test('handles Russian pluralization', () {
        final line = 'элемент|элемента|элементов';
        expect(selector.choose(line, 1, 'ru'), 'элемент');
        expect(selector.choose(line, 2, 'ru'), 'элемента');
        expect(selector.choose(line, 5, 'ru'), 'элементов');
        expect(selector.choose(line, 11, 'ru'), 'элементов');
        expect(selector.choose(line, 21, 'ru'), 'элемент');
      });

      test('handles Arabic pluralization', () {
        final line = 'صفر|واحد|اثنان|القليل|الكثير|الكل';
        expect(selector.choose(line, 0, 'ar'), 'صفر');
        expect(selector.choose(line, 1, 'ar'), 'واحد');
        expect(selector.choose(line, 2, 'ar'), 'اثنان');
        expect(selector.choose(line, 3, 'ar'), 'القليل');
        expect(selector.choose(line, 11, 'ar'), 'الكثير');
        expect(selector.choose(line, 99, 'ar'), 'الكثير');
        expect(selector.choose(line, 100, 'ar'), 'الكل');
      });

      test('handles Chinese/Japanese/Korean (no pluralization)', () {
        final line = '項目';
        expect(selector.choose(line, 0, 'zh'), '項目');
        expect(selector.choose(line, 1, 'zh'), '項目');
        expect(selector.choose(line, 2, 'zh'), '項目');

        expect(selector.choose(line, 0, 'ja'), '項目');
        expect(selector.choose(line, 1, 'ja'), '項目');
        expect(selector.choose(line, 2, 'ja'), '項目');

        expect(selector.choose(line, 0, 'ko'), '項目');
        expect(selector.choose(line, 1, 'ko'), '項目');
        expect(selector.choose(line, 2, 'ko'), '項目');
      });
    });

    test('handles invalid conditions gracefully', () {
      final line = '{invalid} one|[bad] two|regular';
      expect(selector.choose(line, 1, 'en'), 'regular');
    });

    test('trims whitespace from segments', () {
      final line = ' one | two ';
      expect(selector.choose(line, 1, 'en'), 'one');
      expect(selector.choose(line, 2, 'en'), 'two');
    });

    test('supports locale variants', () {
      final line = 'item|items';
      expect(selector.choose(line, 1, 'en-US'), 'item');
      expect(selector.choose(line, 2, 'en-GB'), 'items');
    });

    test('normalizes locale codes', () {
      final line = 'item|items';
      expect(selector.choose(line, 1, 'en_US'), 'item');
      expect(selector.choose(line, 2, 'EN-gb'), 'items');
    });
  });
}
