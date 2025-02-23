import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add a view location
  factory.addLocation('views');

  // Register a view composer for a specific view
  factory.composer('welcome', (View view) {
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

  // The view will have access to:
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
    <title>Welcome</title>
</head>
<body>
    <h1>{{ greeting }}</h1>
    <p>Hello {{ user.name }}!</p>
    
    <nav>
        {% for item in navigation %}
        <a href="{{ item.url }}">{{ item.title }}</a>
        {% endfor %}
    </nav>

    <footer>{{ footer }}</footer>
</body>
</html>
*/
