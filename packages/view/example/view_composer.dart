import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add a view location
  factory.addLocation('views');

  // Register a view creator - runs first when view is instantiated
  factory.creator('welcome', (View view) {
    // Initialize base data
    view.withData('meta', {
      'title': 'Welcome Page',
      'description': 'Our welcome page with dynamic content'
    });
  });

  // Register multiple creators at once
  factory.creators({
    (View view) {
      // Set default template structure
      view.withData('layout', 'main');
      view.withData('sections', ['header', 'content', 'footer']);
    }: ['*'], // Apply to all views
  });

  // Register a view composer - runs after creators
  factory.composer('welcome', (View view) {
    // Add dynamic content
    view.withData('greeting', 'Welcome to our website!');
    view.withData('user', {'name': 'John Doe'});
  });

  // Register multiple composers at once
  factory.composers({
    (View view) {
      view.withData('footer', 'Copyright 2025');
    }: ['welcome', 'about'],

    (View view) {
      view.withData('navigation', [
        {'title': 'Home', 'url': '/'},
        {'title': 'About', 'url': '/about'},
        {'title': 'Contact', 'url': '/contact'},
      ]);
    }: ['*'], // Apply to all views
  });

  // Create and render a view
  final view = await factory.make('welcome');
  final content = await view.render();
  print(content);

  // The view will have access to (in order of execution):
  // From creators:
  // - meta: {"title": "Welcome Page", "description": "..."}
  // - layout: "main"
  // - sections: ["header", "content", "footer"]
  // From composers:
  // - greeting: "Welcome to our website!"
  // - user: {"name": "John Doe"}
  // - footer: "Copyright 2025"
  // - navigation: [{"title": "Home", "url": "/"}, ...]
}

// Example view file (views/welcome.html):
/*
<!DOCTYPE html>
<html>
<head>
    <title>{{ meta.title }}</title>
    <meta name="description" content="{{ meta.description }}">
</head>
<body>
    {% if layout == 'main' %}
    <header>
        <h1>{{ greeting }}</h1>
        <p>Hello {{ user.name }}!</p>
    
        <nav>
            {% for item in navigation %}
            <a href="{{ item.url }}">{{ item.title }}</a>
            {% endfor %}
        </nav>
    </header>

    <main>
        {% block content %}{% endblock %}
    </main>

    <footer>{{ footer }}</footer>
    {% endif %}
</body>
</html>
*/
