import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add view locations
  factory.addLocation('views/layouts');
  factory.addLocation('views/pages');

  // Create and render a view that uses stacks
  final view = await factory.make('pages/home');
  final content = await view.render();
  print(content);
}

// Example layout file (views/layouts/main.html):
/*
<!DOCTYPE html>
<html>
<head>
    <title>{% yield('title') %}</title>
    
    {# Base styles that can be extended #}
    <link rel="stylesheet" href="/css/app.css">
    {% stack('styles') %}
</head>
<body>
    <header>
        <nav>
            {% stack('navigation') %}
        </nav>
    </header>

    <main>
        {% yield('content') %}
    </main>

    <footer>
        {% yield('footer') %}
    </footer>

    {# Base scripts that can be extended #}
    <script src="/js/app.js"></script>
    {% stack('scripts') %}
</body>
</html>
*/

// Example home page (views/pages/home.html):
/*
{% extends('layouts/main') %}

{% section('title', 'Home Page') %}

{# Push styles to the styles stack #}
{% push('styles') %}
<link rel="stylesheet" href="/css/home.css">
{% endpush %}

{# Prepend to navigation stack (will appear first) #}
{% prepend('navigation') %}
<a href="/" class="active">Home</a>
{% endprepend %}

{# Push to navigation stack (will appear last) #}
{% push('navigation') %}
<a href="/about">About</a>
<a href="/contact">Contact</a>
{% endpush %}

{% section('content') %}
<div class="home-content">
    <h1>Welcome</h1>
    <p>This is our home page.</p>
</div>
{% endsection %}

{% section('footer') %}
<p>&copy; 2025 Our Company</p>
{% endsection %}

{# Push scripts to the scripts stack #}
{% push('scripts') %}
<script src="/js/home.js"></script>
{% endpush %}
*/

// The rendered output will:
// 1. Include base styles + home.css
// 2. Show navigation links in order: Home, About, Contact
// 3. Include base scripts + home.js

// Key features demonstrated:
// - Stack management with push/prepend
// - Multiple stacks (styles, navigation, scripts)
// - Stack ordering (prepend vs push)
// - Integration with layouts and sections
