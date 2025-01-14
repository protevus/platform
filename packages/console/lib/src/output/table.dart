import 'dart:math';

/// Represents the alignment of a table column.
enum ColumnAlignment {
  left,
  center,
  right,
}

/// Represents the style of table borders.
enum BorderStyle {
  /// No borders
  none,

  /// ASCII borders (+-|)
  ascii,

  /// Unicode box drawing borders
  box,
}

/// A class for formatting and displaying tabular data in the console.
class Table {
  /// The table headers.
  final List<String> headers;

  /// The table rows.
  final List<List<String>> rows;

  /// The alignment for each column.
  final List<ColumnAlignment> columnAlignments;

  /// The border style to use.
  final BorderStyle borderStyle;

  /// The padding between cell content and borders.
  final int cellPadding;

  /// Create a new table instance.
  Table({
    required this.headers,
    required this.rows,
    List<ColumnAlignment>? columnAlignments,
    this.borderStyle = BorderStyle.box,
    this.cellPadding = 1,
  }) : columnAlignments = columnAlignments ??
            List.filled(headers.length, ColumnAlignment.left) {
    if (this.columnAlignments.length != headers.length) {
      throw ArgumentError('Column alignments length must match headers length');
    }

    for (final row in rows) {
      if (row.length != headers.length) {
        throw ArgumentError('All rows must have the same number of columns');
      }
    }
  }

  /// Get the border characters based on the style.
  ({
    String topLeft,
    String topRight,
    String bottomLeft,
    String bottomRight,
    String horizontal,
    String vertical,
    String headerSeparator,
    String cross,
    String headerCross,
  }) _getBorderChars() {
    switch (borderStyle) {
      case BorderStyle.none:
        return (
          topLeft: '',
          topRight: '',
          bottomLeft: '',
          bottomRight: '',
          horizontal: ' ',
          vertical: ' ',
          headerSeparator: '-',
          cross: ' ',
          headerCross: '-',
        );
      case BorderStyle.ascii:
        return (
          topLeft: '+',
          topRight: '+',
          bottomLeft: '+',
          bottomRight: '+',
          horizontal: '-',
          vertical: '|',
          headerSeparator: '-',
          cross: '+',
          headerCross: '+',
        );
      case BorderStyle.box:
        return (
          topLeft: '┌',
          topRight: '┐',
          bottomLeft: '└',
          bottomRight: '┘',
          horizontal: '─',
          vertical: '│',
          headerSeparator: '─',
          cross: '┼',
          headerCross: '┬',
        );
    }
  }

  /// Calculate the width of each column.
  List<int> _calculateColumnWidths() {
    final widths = List<int>.filled(headers.length, 0);

    // Check headers
    for (var i = 0; i < headers.length; i++) {
      widths[i] = max(widths[i], headers[i].length);
    }

    // Check rows
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = max(widths[i], row[i].length);
      }
    }

    // Add padding
    return widths.map((w) => w + (cellPadding * 2)).toList();
  }

  /// Align text within a given width.
  String _alignText(String text, int width, ColumnAlignment alignment) {
    final content = text
        .padRight(text.length + cellPadding)
        .padLeft(text.length + cellPadding * 2);
    final spaces = width - content.length;

    switch (alignment) {
      case ColumnAlignment.left:
        return content.padRight(width);
      case ColumnAlignment.right:
        return content.padLeft(width);
      case ColumnAlignment.center:
        final leftPad = spaces ~/ 2;
        final rightPad = spaces - leftPad;
        return content.padLeft(content.length + leftPad).padRight(width);
    }
  }

  /// Draw a horizontal border line.
  String _drawHorizontalBorder(
    List<int> columnWidths,
    String left,
    String middle,
    String right,
    String horizontal,
  ) {
    if (borderStyle == BorderStyle.none) {
      return '';
    }

    final parts = <String>[];
    parts.add(left);

    for (var i = 0; i < columnWidths.length; i++) {
      parts.add(horizontal * columnWidths[i]);
      if (i < columnWidths.length - 1) {
        parts.add(middle);
      }
    }

    parts.add(right);
    return parts.join();
  }

  /// Draw a row of data.
  String _drawRow(List<String> data, List<int> columnWidths, String vertical) {
    final parts = <String>[];
    if (borderStyle != BorderStyle.none) {
      parts.add(vertical);
    }

    for (var i = 0; i < data.length; i++) {
      parts.add(_alignText(data[i], columnWidths[i], columnAlignments[i]));
      if (i < data.length - 1 || borderStyle != BorderStyle.none) {
        parts.add(vertical);
      }
    }

    return parts.join();
  }

  /// Render the table to a string.
  String toString() {
    final borders = _getBorderChars();
    final columnWidths = _calculateColumnWidths();
    final lines = <String>[];

    // Top border
    final topBorder = _drawHorizontalBorder(
      columnWidths,
      borders.topLeft,
      borders.headerCross,
      borders.topRight,
      borders.horizontal,
    );
    if (topBorder.isNotEmpty) {
      lines.add(topBorder);
    }

    // Headers
    lines.add(_drawRow(headers, columnWidths, borders.vertical));

    // Header separator
    final headerSeparator = _drawHorizontalBorder(
      columnWidths,
      borders.vertical,
      borders.cross,
      borders.vertical,
      borders.headerSeparator,
    );
    if (headerSeparator.isNotEmpty) {
      lines.add(headerSeparator);
    }

    // Rows
    for (final row in rows) {
      lines.add(_drawRow(row, columnWidths, borders.vertical));
    }

    // Bottom border
    final bottomBorder = _drawHorizontalBorder(
      columnWidths,
      borders.bottomLeft,
      borders.cross,
      borders.bottomRight,
      borders.horizontal,
    );
    if (bottomBorder.isNotEmpty) {
      lines.add(bottomBorder);
    }

    return lines.join('\n');
  }
}
