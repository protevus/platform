abstract class Paginator {
  /// Get the URL for a given page.
  ///
  /// @param  int  $page
  /// @return string
  String url(int page);

  /// Add a set of query string values to the paginator.
  ///
  /// @param  array|string|null  $key
  /// @param  string|null  $value
  /// @return $this
  Paginator appends(dynamic key, [String? value]);

  /// Get / set the URL fragment to be appended to URLs.
  ///
  /// @param  string|null  $fragment
  /// @return $this|string|null
  dynamic fragment([String? fragment]);

  /// The URL for the next page, or null.
  ///
  /// @return string|null
  String? nextPageUrl();

  /// Get the URL for the previous page, or null.
  ///
  /// @return string|null
  String? previousPageUrl();

  /// Get all of the items being paginated.
  ///
  /// @return array
  List<dynamic> items();

  /// Get the "index" of the first item being paginated.
  ///
  /// @return int|null
  int? firstItem();

  /// Get the "index" of the last item being paginated.
  ///
  /// @return int|null
  int? lastItem();

  /// Determine how many items are being shown per page.
  ///
  /// @return int
  int perPage();

  /// Determine the current page being paginated.
  ///
  /// @return int
  int currentPage();

  /// Determine if there are enough items to split into multiple pages.
  ///
  /// @return bool
  bool hasPages();

  /// Determine if there are more items in the data store.
  ///
  /// @return bool
  bool hasMorePages();

  /// Get the base path for paginator generated URLs.
  ///
  /// @return string|null
  String? path();

  /// Determine if the list of items is empty or not.
  ///
  /// @return bool
  bool isEmpty();

  /// Determine if the list of items is not empty.
  ///
  /// @return bool
  bool isNotEmpty();

  /// Render the paginator using a given view.
  ///
  /// @param  string|null  $view
  /// @param  array  $data
  /// @return string
  String render([String? view, Map<String, dynamic> data = const {}]);
}
