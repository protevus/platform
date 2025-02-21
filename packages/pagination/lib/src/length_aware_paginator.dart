import 'dart:math' as math;
import 'package:meta/meta.dart';
import 'abstract_paginator.dart';

/// A paginator that is aware of the total number of items and pages.
///
/// This paginator is used when you have a known total number of items and want to
/// display pagination links with the total number of pages.
class LengthAwarePaginator<T> extends AbstractPaginator<T> {
  /// The total number of items before slicing.
  final int total;

  /// The last available page.
  late final int lastPage;

  /// Create a new paginator instance.
  ///
  /// Example:
  /// ```dart
  /// final paginator = LengthAwarePaginator(
  ///   items: items.skip((page - 1) * perPage).take(perPage).toList(),
  ///   total: items.length,
  ///   perPage: perPage,
  ///   currentPage: page,
  /// );
  /// ```
  LengthAwarePaginator({
    required List<T> items,
    required this.total,
    required int perPage,
    int? currentPage,
    String? path,
    Map<String, String>? query,
    String? fragment,
    String? pageName,
  }) : super(
          items: items,
          perPage: perPage,
          currentPage: _resolveCurrentPage(currentPage, pageName),
          path: path,
          query: query,
          fragment: fragment,
          pageName: pageName,
        ) {
    lastPage = math.max((total / perPage).ceil(), 1);
  }

  static int _resolveCurrentPage(int? currentPage, String? pageName) {
    final resolvedPage = currentPage ??
        AbstractPaginator.resolveCurrentPage(
          pageName: pageName ?? 'page',
          defaultPage: 1,
        );
    return resolvedPage >= 1 ? resolvedPage : 1;
  }

  @override
  bool hasMorePages() => currentPage < lastPage;

  /// Get the total number of items being paginated.
  int getTotal() => total;

  /// Get the last page number.
  int getLastPage() => lastPage;

  /// Get an array of elements to pass to the view.
  ///
  /// This method generates the pagination links array with proper spacing
  /// and ellipsis where needed.
  List<dynamic> elements() {
    final window = _calculateWindow();
    return [
      if (window['first'] != null) window['first'],
      if (window['slider'] != null && window['first'] != null) '...',
      if (window['slider'] != null) window['slider'],
      if (window['last'] != null && window['slider'] != null) '...',
      if (window['last'] != null) window['last'],
    ].where((element) => element != null).toList();
  }

  /// Calculate the sliding window of page links.
  Map<String, dynamic> _calculateWindow() {
    final onEachSide = this.onEachSide;
    final window = onEachSide * 2;

    if (lastPage < window + 6) {
      return {
        'first': _getUrlRange(1, lastPage),
        'slider': null,
        'last': null,
      };
    }

    if (currentPage <= window + 2) {
      return {
        'first': _getUrlRange(1, window + 2),
        'slider': null,
        'last': _getUrlRange(lastPage - 1, lastPage),
      };
    }

    if (currentPage > lastPage - (window + 2)) {
      final last = _getUrlRange(lastPage - (window + 2), lastPage);
      return {
        'first': _getUrlRange(1, 2),
        'slider': null,
        'last': last,
      };
    }

    return {
      'first': _getUrlRange(1, 2),
      'slider':
          _getUrlRange(currentPage - onEachSide, currentPage + onEachSide),
      'last': _getUrlRange(lastPage - 1, lastPage),
    };
  }

  Map<int, String> _getUrlRange(int start, int end) {
    return getUrlRange(start, end);
  }

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
    final elements = this.elements();
    final links = <Map<String, dynamic>>[];

    // Add previous link
    links.add({
      'url': previousPageUrl(),
      'label': 'Previous',
      'active': false,
    });

    // Add numbered links
    for (final element in elements) {
      if (element is String) {
        links.add({
          'url': null,
          'label': element,
          'active': false,
        });
      } else if (element is Map<int, String>) {
        element.forEach((page, url) {
          links.add({
            'url': url,
            'label': page.toString(),
            'active': currentPage == page,
          });
        });
      }
    }

    // Add next link
    links.add({
      'url': nextPageUrl(),
      'label': 'Next',
      'active': false,
    });

    return links;
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'last_page': lastPage,
        'last_page_url': url(lastPage),
        'links': links(),
        'next_page_url': nextPageUrl(),
        'total': total,
      };
}
