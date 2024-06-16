import 'paginator.dart';

abstract class LengthAwarePaginator extends Paginator {
  /// Create a range of pagination URLs.
  ///
  /// @param  int  start
  /// @param  int  end
  /// @return List<String>
  List<String> getUrlRange(int start, int end);

  /// Determine the total number of items in the data store.
  ///
  /// @return int
  int total();

  /// Get the page number of the last available page.
  ///
  /// @return int
  int lastPage();
}
