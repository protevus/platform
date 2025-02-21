import 'package:illuminate_view/view.dart';
import 'dart:io';

void main() async {
  // Create the view factory
  final viewFactory = createViewFactory();

  // Create example view directory and template
  final viewsDir = Directory('example/views');
  if (!viewsDir.existsSync()) {
    viewsDir.createSync(recursive: true);
  }

  // Create a sample template
  final template = '''
<!DOCTYPE html>
<html>
<head>
    <title>{{title}}</title>
</head>
<body>
    <h1>{{heading}}</h1>
    <p>{{content}}</p>
</body>
</html>
''';

  File('example/views/welcome.html').writeAsStringSync(template);

  // Add the views directory to the factory
  viewFactory.addLocation(viewsDir.path);

  // Create and render a view with data
  final view = await viewFactory.make('welcome', {
    'title': 'Welcome Page',
    'heading': 'Hello from Illuminate View',
    'content': 'This is a simple example of using the view package.',
  });

  // Render the view
  final output = await view.render();
  print('Rendered View:\n');
  print(output);

  // Example of using shared data
  viewFactory.share('footer', 'Copyright © 2025');

  // Create another view that uses shared data
  final template2 = '''
<!DOCTYPE html>
<html>
<body>
    <h2>{{message}}</h2>
    <footer>{{footer}}</footer>
</body>
</html>
''';

  File('example/views/page2.html').writeAsStringSync(template2);

  final view2 = await viewFactory.make('page2', {
    'message': 'This page uses shared data',
  });

  print('\nSecond View with Shared Data:\n');
  print(await view2.render());

  // Clean up example files
  viewsDir.deleteSync(recursive: true);
}
