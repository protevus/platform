import 'abstract_paginator.dart';
import 'cursor.dart';

/// A paginator that uses cursors for navigation.
///
/// This paginator is particularly useful for APIs and real-time data where
/// traditional offset-based pagination might lead to skipped or duplicated items.
class CursorPaginator<T> extends AbstractPaginator<T> {
  /// The previous cursor for the paginated items.
  final Cursor? _previousCursor;

  /// The next cursor for the paginated items.
  final Cursor? _nextCursor;

  /// Create a new cursor paginator instance.
  ///
  /// Example:
  /// ```dart
  /// final paginator = CursorPaginator(
  ///   items: currentPageItems,
  ///   perPage: perPage,
  ///   previousCursor: previousCursor,
  ///   nextCursor: nextCursor,
  /// );
  /// ```
  CursorPaginator({
    required List<T> items,
    required int perPage,
    Cursor? previousCursor,
    Cursor? nextCursor,
    String? path,
    Map<String, String>? query,
    String? fragment,
    String? pageName = 'cursor',
  })  : _previousCursor = previousCursor,
        _nextCursor = nextCursor,
        super(
          items: items,
          perPage: perPage,
          currentPage: 1, // Cursor pagination doesn't use page numbers
          path: path,
          query: query,
          fragment: fragment,
          pageName: pageName,
        );

  /// Get the previous cursor.
  Cursor? get previousCursor => _previousCursor;

  /// Get the next cursor.
  Cursor? get nextCursor => _nextCursor;

  /// Get the URL for the previous page.
  @override
  String? previousPageUrl() {
    if (_previousCursor != null) {
      final encoded = _previousCursor!.encode();
      if (encoded != null) {
        return url(1, cursorValue: encoded);
      }
    }
    return null;
  }

  /// Get the URL for the next page.
  String? nextPageUrl() {
    if (_nextCursor != null) {
      final encoded = _nextCursor!.encode();
      if (encoded != null) {
        return url(1, cursorValue: encoded);
      }
    }
    return null;
  }

  /// Get the URL for a given page number with an optional cursor value.
  String url(int page, {String? cursorValue}) {
    final parameters = <String, String>{
      if (cursorValue != null) pageName: cursorValue,
      ...query,
    };

    final queryString = Uri(queryParameters: parameters).query;
    final separator = path.contains('?') ? '&' : '?';
    final fragment = this.fragment != null ? '#${this.fragment}' : '';

    return '$path$separator$queryString$fragment';
  }

  @override
  bool hasMorePages() => _nextCursor != null;

  /// Get the paginator's links collection.
  ///
  /// This method returns a collection of pagination links suitable for JSON responses.
  List<Map<String, dynamic>> links() {
    return [
      {
        'url': previousPageUrl(),
        'label': 'Previous',
        'active': false,
      },
      {
        'url': nextPageUrl(),
        'label': 'Next',
        'active': false,
      },
    ];
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'next_cursor': _nextCursor?.parameter,
        'prev_cursor': _previousCursor?.parameter,
        'next_page_url': nextPageUrl(),
        'links': links(),
      };
}
