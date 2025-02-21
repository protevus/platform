import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

/// Base class for pagination implementations.
///
/// This class provides core pagination functionality that can be extended
/// by concrete implementations like [LengthAwarePaginator] and [Paginator].
abstract class AbstractPaginator<T> with ListMixin<T> {
  /// All items being paginated.
  List<T> _items;

  /// Number of items to be shown per page.
  final int perPage;

  /// Current page being "viewed".
  final int currentPage;

  /// Base path to assign to all URLs.
  String _path = '/';

  /// Query parameters to add to all URLs.
  final Map<String, String> _query = {};

  /// Protected getter for query parameters.
  @protected
  Map<String, String> get query => Map.unmodifiable(_query);

  /// URL fragment to add to all URLs.
  String? _fragment;

  /// Query string variable used to store the page.
  String _pageName = 'page';

  /// Number of links to display on each side of current page link.
  int onEachSide = 3;

  /// Default pagination view.
  static String defaultView = 'tailwind';

  /// Default "simple" pagination view.
  static String defaultSimpleView = 'simple-tailwind';

  /// Current path resolver callback.
  static String Function()? _currentPathResolver;

  /// Current page resolver callback.
  static int Function(String)? _currentPageResolver;

  /// Query string resolver callback.
  static Map<String, String> Function()? _queryStringResolver;

  AbstractPaginator({
    required List<T> items,
    required this.perPage,
    required this.currentPage,
    String? path,
    Map<String, String>? query,
    String? fragment,
    String? pageName,
  }) : _items = List.unmodifiable(items) {
    if (path != null) _path = path;
    if (query != null) _query.addAll(query);
    if (fragment != null) _fragment = fragment;
    if (pageName != null) _pageName = pageName;
  }

  /// Determine if the given value is a valid page number.
  @protected
  bool isValidPageNumber(int page) => page >= 1;

  /// Get the URL for the previous page.
  String? previousPageUrl() {
    if (currentPage > 1) {
      return url(currentPage - 1);
    }
    return null;
  }

  /// Create a range of pagination URLs.
  Map<int, String> getUrlRange(int start, int end) {
    return Map.fromEntries(
      List.generate(end - start + 1, (i) => i + start)
          .map((page) => MapEntry(page, url(page))),
    );
  }

  /// Get the URL for a given page number.
  String url(int page) {
    if (page <= 0) {
      page = 1;
    }

    final parameters = <String, String>{
      _pageName: page.toString(),
      ..._query,
    };

    final queryString = Uri(queryParameters: parameters).query;
    final separator = _path.contains('?') ? '&' : '?';
    final fragment = _fragment != null ? '#$_fragment' : '';

    return '$_path$separator$queryString$fragment';
  }

  /// Get/set the URL fragment to be appended to URLs.
  String? get fragment => _fragment;
  set fragment(String? value) => _fragment = value;

  /// Add a set of query string values to the paginator.
  void appendQueryString(Map<String, String> parameters) {
    _query.addAll(parameters);
  }

  /// Add all current query string values to the paginator.
  void withQueryString() {
    if (_queryStringResolver != null) {
      appendQueryString(_queryStringResolver!());
    }
  }

  /// Get the slice of items being paginated.
  List<T> items() => _items;

  /// Get the number of the first item in the slice.
  int? firstItem() {
    return _items.isNotEmpty ? (currentPage - 1) * perPage + 1 : null;
  }

  /// Get the number of items in the paginator.
  @override
  int count() => length;

  /// Get the number of the last item in the slice.
  int? lastItem() {
    return _items.isNotEmpty ? firstItem()! + length - 1 : null;
  }

  /// Transform each item in the slice of items using a callback.
  void through(T Function(T item) callback) {
    _items = List.unmodifiable(_items.map(callback));
  }

  /// Determine if there are enough items to split into multiple pages.
  bool hasPages() => currentPage != 1 || hasMorePages();

  /// Determine if the paginator is on the first page.
  bool onFirstPage() => currentPage <= 1;

  /// Determine if the paginator is on the last page.
  bool onLastPage() => !hasMorePages();

  /// Get the query string variable used to store the page.
  String get pageName => _pageName;
  set pageName(String value) => _pageName = value;

  /// Set the base path to assign to all URLs.
  set path(String value) => _path = value;
  String get path => _path;

  /// Set the number of links to display on each side of current page link.
  void setOnEachSide(int count) => onEachSide = count;

  /// Resolve the current request path or return the default value.
  static String resolveCurrentPath([String defaultPath = '/']) {
    return _currentPathResolver?.call() ?? defaultPath;
  }

  /// Set the current request path resolver callback.
  static void setCurrentPathResolver(String Function() resolver) {
    _currentPathResolver = resolver;
  }

  /// Resolve the current page or return the default value.
  static int resolveCurrentPage({
    String pageName = 'page',
    int defaultPage = 1,
  }) {
    return _currentPageResolver?.call(pageName) ?? defaultPage;
  }

  /// Set the current page resolver callback.
  static void setCurrentPageResolver(int Function(String) resolver) {
    _currentPageResolver = resolver;
  }

  /// Resolve the query string or return the default value.
  static Map<String, String> resolveQueryString([
    Map<String, String>? defaultValue,
  ]) {
    return _queryStringResolver?.call() ?? defaultValue ?? {};
  }

  /// Set with query string resolver callback.
  static void setQueryStringResolver(
    Map<String, String> Function() resolver,
  ) {
    _queryStringResolver = resolver;
  }

  /// Set the default pagination view.
  static void setDefaultView(String view) {
    defaultView = view;
  }

  /// Set the default "simple" pagination view.
  static void setDefaultSimpleView(String view) {
    defaultSimpleView = view;
  }

  /// Indicate that Tailwind styling should be used for generated links.
  static void useTailwind() {
    defaultView = 'tailwind';
    defaultSimpleView = 'simple-tailwind';
  }

  /// Indicate that Bootstrap 5 styling should be used for generated links.
  static void useBootstrap() {
    defaultView = 'bootstrap-5';
    defaultSimpleView = 'simple-bootstrap-5';
  }

  // ListMixin implementation
  @override
  int get length => _items.length;

  @override
  set length(int newLength) {
    throw UnsupportedError('Cannot modify length of paginated items');
  }

  @override
  T operator [](int index) => _items[index];

  @override
  void operator []=(int index, T value) {
    throw UnsupportedError('Cannot modify paginated items');
  }

  /// Abstract method to be implemented by concrete classes
  bool hasMorePages();

  /// Convert the paginator into a JSON-serializable Map.
  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': _items,
        'first_page_url': url(1),
        'from': firstItem(),
        'path': path,
        'per_page': perPage,
        'prev_page_url': previousPageUrl(),
        'to': lastItem(),
      };
}
