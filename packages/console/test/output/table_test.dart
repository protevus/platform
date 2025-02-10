import 'package:illuminate_console/src/output/table.dart';
import 'package:test/test.dart';

void main() {
  group('Table', () {
    test('formats basic table with box borders', () {
      final table = Table(
        headers: ['ID', 'Name'],
        rows: [
          ['1', 'John'],
          ['2', 'Jane'],
        ],
      );

      final output = table.toString().split('\n');
      expect(output[0], '┌────┬──────┐');
      expect(output[1], '│ ID │ Name │');
      expect(output[2], '│────┼──────│');
      expect(output[3], '│ 1  │ John │');
      expect(output[4], '│ 2  │ Jane │');
      expect(output[5], '└────┴──────┘');
    });

    test('formats table with ascii borders', () {
      final table = Table(
        headers: ['ID', 'Name'],
        rows: [
          ['1', 'John'],
          ['2', 'Jane'],
        ],
        borderStyle: BorderStyle.ascii,
      );

      final output = table.toString().split('\n');
      expect(output[0], '+----+------+');
      expect(output[1], '| ID | Name |');
      expect(output[2], '|----+------|');
      expect(output[3], '| 1  | John |');
      expect(output[4], '| 2  | Jane |');
      expect(output[5], '+----+------+');
    });

    test('formats table without borders', () {
      final table = Table(
        headers: ['ID', 'Name'],
        rows: [
          ['1', 'John'],
          ['2', 'Jane'],
        ],
        borderStyle: BorderStyle.none,
      );

      final output = table.toString().split('\n');
      expect(output[0], ' ID  Name ');
      expect(output[1], ' 1   John ');
      expect(output[2], ' 2   Jane ');
    });

    test('handles column alignments', () {
      final table = Table(
        headers: ['Left', 'Center', 'Right'],
        rows: [
          ['1', '2', '3'],
          ['one', 'two', 'three'],
        ],
        columnAlignments: [
          ColumnAlignment.left,
          ColumnAlignment.center,
          ColumnAlignment.right,
        ],
      );

      final output = table.toString().split('\n');
      expect(output[3].trim(), '│ 1   │   2   │     3 │');
      expect(output[4].trim(), '│ one │  two  │ three │');
    });

    test('adjusts cell padding', () {
      final table = Table(
        headers: ['A', 'B'],
        rows: [
          ['1', '2'],
        ],
        cellPadding: 2,
      );

      final output = table.toString().split('\n');
      expect(output[1], '│  A  │  B  │');
      expect(output[3], '│  1  │  2  │');
    });

    test('handles empty table', () {
      final table = Table(
        headers: ['Empty'],
        rows: [],
      );

      final output = table.toString().split('\n');
      expect(output.length,
          equals(4)); // Top border, header, separator, bottom border
      expect(output[1], contains('Empty'));
    });

    test('handles wide content', () {
      final table = Table(
        headers: ['Column'],
        rows: [
          ['A very long piece of text that should be handled properly'],
        ],
      );

      final output = table.toString().split('\n');
      expect(output[3], contains('A very long piece of text'));
      expect(output[0].length,
          equals(output[3].length)); // Border matches content width
    });

    test('throws on mismatched column count', () {
      expect(
        () => Table(
          headers: ['One', 'Two'],
          rows: [
            ['Single'],
          ],
        ),
        throwsArgumentError,
      );
    });

    test('throws on mismatched alignment count', () {
      expect(
        () => Table(
          headers: ['One', 'Two'],
          rows: [
            ['1', '2'],
          ],
          columnAlignments: [ColumnAlignment.left],
        ),
        throwsArgumentError,
      );
    });
  });
}
