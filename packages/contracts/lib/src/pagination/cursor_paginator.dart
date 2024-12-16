/// Interface for cursor-based pagination.
abstract class CursorPaginator {
  /// Get the URL for a given cursor.
  String url(dynamic cursor);

  /// Add a set of query string values to the paginator.
  CursorPaginator appends(dynamic key, [String? value]);

  /// Get / set the URL fragment to be appended to URLs.
  dynamic fragment([String? fragment]);

  /// Add all current query string values to the paginator.
  CursorPaginator withQueryString();

  /// Get the URL for the previous page, or null.
  String? previousPageUrl();

  /// The URL for the next page, or null.
  String? nextPageUrl();

  /// Get all of the items being paginated.
  List<dynamic> items();

  /// Get the "cursor" of the previous set of items.
  dynamic previousCursor();

  /// Get the "cursor" of the next set of items.
  dynamic nextCursor();

  /// Determine how many items are being shown per page.
  int perPage();

  /// Get the current cursor being paginated.
  dynamic cursor();

  /// Determine if there are enough items to split into multiple pages.
  bool hasPages();

  /// Get the base path for paginator generated URLs.
  String? path();

  /// Determine if the list of items is empty or not.
  bool isEmpty();

  /// Determine if the list of items is not empty.
  bool isNotEmpty();

  /// Render the paginator using a given view.
  String render([String? view, Map<String, dynamic> data = const {}]);
}
