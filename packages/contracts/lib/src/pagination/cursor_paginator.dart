abstract class CursorPaginator<T> {
  /// Get the URL for a given cursor.
  ///
  /// @param  Cursor? cursor
  /// @return String
  String url(Cursor? cursor);

  /// Add a set of query string values to the paginator.
  ///
  /// @param  List<Object>? key
  /// @param  String? value
  /// @return $this
  CursorPaginator<T> appends(dynamic key, [String? value]);

  /// Get / set the URL fragment to be appended to URLs.
  ///
  /// @param  String? fragment
  /// @return $this|String?
  dynamic fragment([String? fragment]);

  /// Add all current query string values to the paginator.
  ///
  /// @return $this
  CursorPaginator<T> withQueryString();

  /// Get the URL for the previous page, or null.
  ///
  /// @return String?
  String? previousPageUrl();

  /// The URL for the next page, or null.
  ///
  /// @return String?
  String? nextPageUrl();

  /// Get all of the items being paginated.
  ///
  /// @return List<T>
  List<T> items();

  /// Get the "cursor" of the previous set of items.
  ///
  /// @return Cursor?
  Cursor? previousCursor();

  /// Get the "cursor" of the next set of items.
  ///
  /// @return Cursor?
  Cursor? nextCursor();

  /// Determine how many items are being shown per page.
  ///
  /// @return int
  int perPage();

  /// Get the current cursor being paginated.
  ///
  /// @return Cursor?
  Cursor? cursor();

  /// Determine if there are enough items to split into multiple pages.
  ///
  /// @return bool
  bool hasPages();

  /// Get the base path for paginator generated URLs.
  ///
  /// @return String?
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
  /// @param  String? view
  /// @param  Map<String, dynamic> data
  /// @return String
  String render([String? view, Map<String, dynamic> data = const {}]);
}
