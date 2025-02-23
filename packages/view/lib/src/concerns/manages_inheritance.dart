import '../contracts/base.dart';
import '../contracts/view.dart';

/// A mixin that provides view inheritance functionality.
mixin ManagesInheritance {
  /// The stack of views being rendered.
  final List<View> _renderStack = [];

  /// The parent view being extended.
  View? _parentView;

  /// Get the parent view being extended.
  View? get parentView => _parentView;

  /// Set the parent view being extended.
  set parentView(View? view) {
    _parentView = view;
  }

  /// Start rendering a view.
  void startRender(View view) {
    _renderStack.add(view);
  }

  /// Stop rendering a view.
  void stopRender() {
    if (_renderStack.isNotEmpty) {
      _renderStack.removeLast();
    }
  }

  /// Get the current view being rendered.
  View? get currentView => _renderStack.isNotEmpty ? _renderStack.last : null;

  /// Check if a view is currently being rendered.
  bool isRenderingView(View view) => _renderStack.contains(view);

  /// Check if any view is being rendered.
  bool get hasRendering => _renderStack.isNotEmpty;

  /// Get the number of views being rendered.
  int get renderCount => _renderStack.length;

  /// Check if we're done rendering all views.
  bool get doneRendering => _renderStack.isEmpty;

  /// Extend a parent view.
  Future<void> extendView(String name, [Map<String, dynamic>? data]) async {
    if (_parentView != null) {
      throw ViewException('View inheritance is already set.');
    }

    // The factory instance will be available in the implementing class
    // to create the parent view
  }

  /// Flush all inheritance state.
  void flushState() {
    _renderStack.clear();
    _parentView = null;
  }
}
