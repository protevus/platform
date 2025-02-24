import 'package:illuminate_filesystem/filesystem.dart';
import 'package:illuminate_view/view.dart';

void main() async {
  // Create the filesystem instance
  final files = Filesystem();

  // Create the engine resolver
  final engines = EngineResolver();

  // Create the view factory
  final finder = FileViewFinder();
  final factory = ViewFactory(engines, finder);

  // Create blade compiler and engine
  final compiler = BladeCompiler(files, 'storage/framework/views', factory);
  final bladeEngine = BladeEngine(files, compiler, factory);
  engines.register('blade', () => bladeEngine);

  // Example blade template
  final template = '''
// Template: home.blade.dart
// This will be compiled to a Dart function that returns HTML

String view(Map<String, dynamic> data) {
  final buffer = StringBuffer();

  buffer.write(\'\'\'
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }}</title>
</head>
<body>
    {# Navigation menu #}
    <nav>
        @foreach(menuItems as item)
            <a href="{{ item.url }}" class="{{ item.active ? 'active' : '' }}">
                {{ item.text }}
            </a>
        @endforeach
    </nav>

    <main>
        {# Show welcome message if user is logged in #}
        @if(user != null)
            <h1>Welcome back, {{ user.name }}!</h1>
        @else
            <h1>Welcome Guest!</h1>
        @endif

        {# Content section #}
        <div class="content">
            {!! content !!}
        </div>

        {# Footer with unescaped HTML #}
        <footer>
            {!! footerHtml !!}
        </footer>
    </main>
</body>
</html>
\'\'\');

  return buffer.toString();
}
''';

  // Save the template
  files.put('views/home.blade.dart', template);

  // Register .blade.dart extension to use blade engine
  factory.addExtension('blade.dart', 'blade');

  // Example data
  final data = {
    'title': 'My Website',
    'menuItems': [
      {'url': '/', 'text': 'Home', 'active': true},
      {'url': '/about', 'text': 'About', 'active': false},
      {'url': '/contact', 'text': 'Contact', 'active': false},
    ],
    'user': {
      'name': 'John Doe',
      'email': 'john@example.com',
    },
    'content': '<p>This is the main content of the page.</p>',
    'footerHtml': '<p>&copy; 2025 My Website. All rights reserved.</p>',
  };

  // Create and render the view
  final view = await factory.make('views/home', data);
  final output = await view.render();
  print(output);

  /* The compiler will transform the template into Dart code like this:
  String render(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    
    // Extract variables from data
    final title = data['title'];
    final menuItems = data['menuItems'];
    final user = data['user'];
    final content = data['content'];
    final footerHtml = data['footerHtml'];
    
    buffer.write('<!DOCTYPE html><html><head>');
    buffer.write(e('<title>${title}</title>'));
    buffer.write('<body><nav>');
    
    for (final item in menuItems) {
      buffer.write('<a href="${e(item['url'])}" ');
      buffer.write('class="${item['active'] ? 'active' : ''}"');
      buffer.write('>${e(item['text'])}</a>');
    }
    
    buffer.write('</nav><main>');
    
    if (user != null) {
      buffer.write('<h1>Welcome back, ${e(user['name'])}!</h1>');
    } else {
      buffer.write('<h1>Welcome Guest!</h1>');
    }
    
    buffer.write('<div class="content">${content}</div>');
    buffer.write('<footer>${footerHtml}</footer>');
    buffer.write('</main></body></html>');
    
    return buffer.toString();
  }
  */

  // Key features demonstrated:
  // - Templates are compiled to Dart code
  // - Comments using {# #}
  // - Escaped output using {{ }}
  // - Unescaped output using {!! !!}
  // - Conditionals using @if, @else
  // - Loops using @foreach
  // - Accessing nested data using dot notation
  // - Ternary operations
  // - HTML escaping by default
  // - Compilation to efficient Dart code
  // - Integration with view factory and engine resolver
}
