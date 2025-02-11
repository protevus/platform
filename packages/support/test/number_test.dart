import 'package:test/test.dart';
import 'package:illuminate_support/support.dart';

void main() {
  group('Number', () {
    test('formats number with grouped thousands', () {
      expect(Number(1234567.89).format(), equals('1,234,567.89'));
      expect(Number(1234567.89).format(3), equals('1,234,567.890'));
      expect(Number(1234567.89).format(2, ',', ' '), equals('1 234 567,89'));
      expect(Number(-1234567.89).format(), equals('-1,234,567.89'));
      expect(Number(1234.5).format(), equals('1,234.50'));
      expect(Number(1234).format(), equals('1,234.00'));
      expect(Number(0).format(), equals('0.00'));
    });

    test('converts number to ordinal', () {
      expect(Number(1).ordinal(), equals('1st'));
      expect(Number(2).ordinal(), equals('2nd'));
      expect(Number(3).ordinal(), equals('3rd'));
      expect(Number(4).ordinal(), equals('4th'));
      expect(Number(11).ordinal(), equals('11th'));
      expect(Number(12).ordinal(), equals('12th'));
      expect(Number(13).ordinal(), equals('13th'));
      expect(Number(21).ordinal(), equals('21st'));
      expect(Number(22).ordinal(), equals('22nd'));
      expect(Number(23).ordinal(), equals('23rd'));
      expect(Number(24).ordinal(), equals('24th'));
      expect(Number(100).ordinal(), equals('100th'));
      expect(Number(101).ordinal(), equals('101st'));
      expect(Number(102).ordinal(), equals('102nd'));
      expect(Number(103).ordinal(), equals('103rd'));
      expect(Number(104).ordinal(), equals('104th'));
      expect(Number(111).ordinal(), equals('111th'));
      expect(Number(112).ordinal(), equals('112th'));
      expect(Number(113).ordinal(), equals('113th'));
    });

    test('spells out number in English', () {
      expect(Number(0).spell(), equals('zero'));
      expect(Number(1).spell(), equals('one'));
      expect(Number(9).spell(), equals('nine'));
      expect(Number(10).spell(), equals('ten'));
      expect(Number(11).spell(), equals('eleven'));
      expect(Number(19).spell(), equals('nineteen'));
      expect(Number(20).spell(), equals('twenty'));
      expect(Number(21).spell(), equals('twenty-one'));
      expect(Number(99).spell(), equals('ninety-nine'));
      expect(Number(100).spell(), equals('one hundred'));
      expect(Number(101).spell(), equals('one hundred one'));
      expect(Number(111).spell(), equals('one hundred eleven'));
      expect(Number(999).spell(), equals('nine hundred ninety-nine'));
      expect(Number(1000).spell(), equals('one thousand'));
      expect(
          Number(1234).spell(), equals('one thousand two hundred thirty-four'));
      expect(Number(1000000).spell(), equals('one million'));
      expect(Number(-1234).spell(),
          equals('negative one thousand two hundred thirty-four'));
    });

    test('formats number as currency', () {
      expect(Number(1234567.89).currency(), equals('\$1,234,567.89'));
      expect(Number(1234567.89).currency('€'), equals('€1,234,567.89'));
      expect(Number(1234567.89).currency('£', 3), equals('£1,234,567.890'));
      expect(Number(-1234567.89).currency(), equals('\$-1,234,567.89'));
      expect(Number(0).currency(), equals('\$0.00'));
    });

    test('formats number as percentage', () {
      expect(Number(0.1234).percentage(), equals('0.12%'));
      expect(Number(0.1234).percentage(3), equals('0.123%'));
      expect(Number(1.234).percentage(), equals('1.23%'));
      expect(Number(-0.1234).percentage(), equals('-0.12%'));
      expect(Number(0).percentage(), equals('0.00%'));
    });

    test('formats number as file size', () {
      expect(Number(0).fileSize(), equals('0.00 B'));
      expect(Number(1023).fileSize(), equals('1023.00 B'));
      expect(Number(1024).fileSize(), equals('1.00 KB'));
      expect(Number(1234567).fileSize(), equals('1.18 MB'));
      expect(Number(1234567890).fileSize(), equals('1.15 GB'));
      expect(Number(1234567890123).fileSize(), equals('1.12 TB'));
      expect(Number(-1234567).fileSize(), equals('1.18 MB'));
    });

    test('creates instance from value', () {
      final number = Number.from(123);
      expect(number.value, equals(123));
      expect(number.toString(), equals('123'));
    });

    test('compares instances', () {
      final a = Number(123);
      final b = Number(123);
      final c = Number(456);

      expect(a == b, isTrue);
      expect(a == c, isFalse);
      expect(a.hashCode == b.hashCode, isTrue);
      expect(a.hashCode == c.hashCode, isFalse);
    });

    test('supports macroable functionality', () {
      Number.macro('double', (dynamic instance) {
        final number = instance as Number;
        return Number(number.value * 2);
      });
      final number = Number(5);
      expect((number as dynamic).double().value, equals(10));
    });
  });
}
