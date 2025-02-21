import 'abstract_paginator.dart';

/// A simple paginator implementation that doesn't require a total count.
///
/// This paginator is useful when you don't need to know the total number of items
/// or pages, and just want to provide "Previous" and "Next" navigation.
class Paginator<T> extends AbstractPaginator<T> {
  /// Whether there are more items in the data source.
  final bool _hasMore;

  /// Create a new paginator instance.
  ///
  /// Example:
  /// ```dart
  /// final paginator = Paginator(
  ///   items: items.skip((page - 1) * perPage).take(perPage + 1).toList(),
  ///   perPage: perPage,
  ///   currentPage: page,
  /// );
  /// ```
  Paginator({
    required List<T> items,
    required int perPage,
    int? currentPage,
    String? path,
    Map<String, String>? query,
    String? fragment,
    String? pageName,
  })  : _hasMore = items.length > perPage,
        super(
          items: items.length > perPage ? items.take(perPage).toList() : items,
          perPage: perPage,
          currentPage: _resolveCurrentPage(currentPage, pageName),
          path: path,
          query: query,
          fragment: fragment,
          pageName: pageName,
        );

  static int _resolveCurrentPage(int? currentPage, String? pageName) {
    final resolvedPage = currentPage ??
        AbstractPaginator.resolveCurrentPage(
          pageName: pageName ?? 'page',
          defaultPage: 1,
        );
    return resolvedPage >= 1 ? resolvedPage : 1;
  }

  @override
  bool hasMorePages() => _hasMore;

  /// Get the URL for the next page.
  String? nextPageUrl() {
    if (hasMorePages()) {
      return url(currentPage + 1);
    }
    return null;
  }

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
        'next_page_url': nextPageUrl(),
        'links': links(),
      };
}
