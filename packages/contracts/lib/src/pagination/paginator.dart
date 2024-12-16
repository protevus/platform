/// Interface for pagination.
abstract class Paginator {
  /// Get the URL for a given page.
  String url(int page);

  /// Add a set of query string values to the paginator.
  Paginator appends(dynamic key, [String? value]);

  /// Get / set the URL fragment to be appended to URLs.
  dynamic fragment([String? fragment]);

  /// The URL for the next page, or null.
  String? nextPageUrl();

  /// Get the URL for the previous page, or null.
  String? previousPageUrl();

  /// Get all of the items being paginated.
  List<dynamic> items();

  /// Get the "index" of the first item being paginated.
  int? firstItem();

  /// Get the "index" of the last item being paginated.
  int? lastItem();

  /// Determine how many items are being shown per page.
  int perPage();

  /// Determine the current page being paginated.
  int currentPage();

  /// Determine if there are enough items to split into multiple pages.
  bool hasPages();

  /// Determine if there are more items in the data store.
  bool hasMorePages();

  /// Get the base path for paginator generated URLs.
  String? path();

  /// Determine if the list of items is empty or not.
  bool isEmpty();

  /// Determine if the list of items is not empty.
  bool isNotEmpty();

  /// Render the paginator using a given view.
  String render([String? view, Map<String, dynamic> data = const {}]);
}
