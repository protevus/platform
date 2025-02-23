import 'base.dart';

/// Contract for the View implementation.
abstract class View implements Arrayable, Htmlable {
  /// Get the name of the view.
  String get name;

  /// Get the array of view data.
  Map<String, dynamic> get data;

  /// Get the path to the view file.
  String get path;

  /// Add a piece of data to the view.
  View withData(String key, dynamic value);

  /// Add multiple pieces of data to the view.
  View withManyData(Map<String, dynamic> data);

  /// Get the evaluated contents of the view.
  ///
  /// Throws a [ViewException] if rendering fails.
  Future<String> render();

  /// Get the string contents of the view.
  ///
  /// This is an alias for [render].
  @override
  String toString() => 'View($name)';

  /// Get the parent view being extended.
  View? get parent;

  /// Set the parent view being extended.
  set parent(View? view);

  /// Check if this view extends another view.
  bool get hasParent;

  /// Implementation of [Arrayable]
  @override
  Map<String, dynamic> toArray() => data;

  /// Implementation of [Htmlable]
  @override
  String toHtml() => toString();
}

/// Contract for the View Factory implementation.
abstract class ViewFactoryContract {
  /// Get the evaluated view contents for the given view.
  Future<View> make(String view, [Map<String, dynamic>? data]);

  /// Determine if a given view exists.
  bool exists(String view);

  /// Register a view creator.
  void creator(dynamic views, Function callback);

  /// Register multiple view creators via an array.
  void creators(Map<Function, List<String>> creators);

  /// Call the creator for a given view.
  void callCreator(View view);

  /// Register a view composer.
  void composer(dynamic views, Function callback);

  /// Register multiple view composers via an array.
  void composers(Map<Function, List<String>> composers);

  /// Call the composer for a given view.
  void callComposer(View view);

  /// Add a piece of shared data to the environment.
  void share(String key, dynamic value);

  /// Add a location to the array of view locations.
  void addLocation(String location);

  /// Add a new namespace to the loader.
  ViewFactoryContract addNamespace(String namespace, List<String> hints);

  /// Register a valid view extension and its engine.
  void addExtension(String extension, String engine);

  /// Get all of the shared data for the environment.
  Map<String, dynamic> get shared;

  /// Determine if a view path is cached.
  bool isCached(String view);

  /// Get the cached path to a view.
  String? getCachedPath(String view);

  /// Clear the view cache.
  void flushCache();

  /// Start injecting content into a section.
  void startSection(String section, [String? content]);

  /// Stop injecting content into a section.
  String stopSection({bool overwrite = false});

  /// Stop injecting content into a section and append it.
  String appendSection();

  /// Get the string contents of a section.
  String yieldContent(String section, [String defaultContent = '']);

  /// Check if section exists.
  bool hasSection(String name);

  /// Check if section does not exist.
  bool sectionMissing(String name);

  /// Get the contents of a section.
  String? getSection(String name, [String? defaultContent]);

  /// Get all sections.
  Map<String, String> get sections;

  /// Flush all of the sections.
  void flushSections();

  /// Start rendering a view.
  void startRender(View view);

  /// Stop rendering a view.
  void stopRender();

  /// Get the current view being rendered.
  View? get currentView;

  /// Check if a view is currently being rendered.
  bool isRenderingView(View view);

  /// Check if any view is being rendered.
  bool get hasRendering;

  /// Get the number of views being rendered.
  int get renderCount;

  /// Check if we're done rendering all views.
  bool get doneRendering;

  /// Extend a parent view.
  Future<void> extendView(String name, [Map<String, dynamic>? data]);

  /// Flush all inheritance state.
  void flushState();

  /// Add new loop to the stack.
  void addLoop(dynamic data);

  /// Increment the top loop's indices.
  void incrementLoopIndices();

  /// Pop a loop from the top of the loop stack.
  void popLoop();

  /// Get an instance of the last loop in the stack.
  Map<String, dynamic>? getLastLoop();

  /// Get the entire loop stack.
  List<Map<String, dynamic>> getLoopStack();

  /// Flush all loops.
  void flushLoops();

  /// Start injecting content into a push section.
  void startPush(String section, [String content = '']);

  /// Stop injecting content into a push section.
  String stopPush();

  /// Start prepending content into a push section.
  void startPrepend(String section, [String content = '']);

  /// Stop prepending content into a push section.
  String stopPrepend();

  /// Get the string contents of a push section.
  String yieldPushContent(String section, [String defaultContent = '']);

  /// Flush all of the stacks.
  void flushStacks();
}

/// Contract for the View Engine implementation.
abstract class ViewEngine {
  /// Get the evaluated contents of the view.
  Future<String> get(String path, Map<String, dynamic> data);
}

/// Contract for the View Finder implementation.
abstract class ViewFinder {
  /// Get the fully qualified location of the view.
  String find(String view);

  /// Add a location to the finder.
  void addLocation(String location);

  /// Add a namespace hint to the finder.
  void addNamespace(String namespace, List<String> hints);

  /// Add a valid view extension.
  void addExtension(String extension);

  /// Flush the cache of located views.
  void flush();
}
