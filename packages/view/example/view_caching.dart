import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add a view location
  factory.addLocation('views');

  // First request - view will be found and cached
  final view1 = await factory.make('welcome');
  print('View path: ${view1.path}');
  print('Is cached: ${factory.isCached("welcome")}'); // true
  print(
      'Cached path: ${factory.getCachedPath("welcome")}'); // shows the cached path

  // Second request - view will be retrieved from cache
  final view2 = await factory.make('welcome');
  print('View retrieved from cache');

  // Clear the view cache
  factory.flushCache();
  print('Cache cleared');
  print('Is cached: ${factory.isCached("welcome")}'); // false

  // Third request - view will be found again and cached
  final view3 = await factory.make('welcome');
  print('View found and cached again');
  print('Is cached: ${factory.isCached("welcome")}'); // true

  // The caching system improves performance by:
  // 1. Avoiding repeated filesystem operations
  // 2. Caching the resolved paths for views
  // 3. Maintaining the cache until explicitly flushed

  // Cache is automatically used by:
  // - factory.make()
  // - factory.exists()
  // - All view operations that need to resolve paths

  // Cache can be managed using:
  // - factory.isCached(view) - Check if a view is cached
  // - factory.getCachedPath(view) - Get the cached path
  // - factory.flushCache() - Clear the entire cache
}

// Example view file (views/welcome.html):
/*
<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
</head>
<body>
    <h1>Welcome to our website!</h1>
</body>
</html>
*/
