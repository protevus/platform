import 'paginator.dart';

/// Interface for pagination with total count awareness.
abstract class LengthAwarePaginator extends Paginator {
  /// Create a range of pagination URLs.
  List<String> getUrlRange(int start, int end);

  /// Determine the total number of items in the data store.
  int total();

  /// Get the page number of the last available page.
  int lastPage();
}
