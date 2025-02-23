import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add a view location
  factory.addLocation('views');

  // Create and render a view that extends a layout
  final view = await factory.make('pages/home');
  final content = await view.render();
  print(content);
}

// Example layout file (views/layouts/main.html):
/*
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }} - My Site</title>
    {% yield('styles') %}
</head>
<body>
    <header>
        <h1>My Website</h1>
        <nav>
            {% yield('navigation') %}
        </nav>
    </header>

    <main>
        {% yield('content') %}
    </main>

    <footer>
        {% yield('footer', 'Default footer content') %}
    </footer>

    {% yield('scripts') %}
</body>
</html>
*/

// Example page file (views/pages/home.html):
/*
{% extends('layouts/main') %}

{% section('title', 'Home') %}

{% section('styles') %}
<style>
    .hero { background: #eee; padding: 2rem; }
</style>
{% endsection %}

{% section('navigation') %}
<a href="/">Home</a>
<a href="/about">About</a>
<a href="/contact">Contact</a>
{% endsection %}

{% section('content') %}
<div class="hero">
    <h2>Welcome to our site!</h2>
    <p>This is the home page content.</p>
</div>
{% endsection %}

{% section('scripts') %}
<script>
    console.log('Home page loaded');
</script>
{% endsection %}
*/

// The rendered output will:
// 1. Use the layout as a template
// 2. Fill in each section defined in the page
// 3. Use default content for any undefined sections (like footer)
// 4. Support nested layouts and section inheritance
// 5. Allow appending to sections using @@parent
