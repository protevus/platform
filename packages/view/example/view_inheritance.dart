import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add view locations
  factory.addLocation('views/layouts');
  factory.addLocation('views/pages');
  factory.addLocation('views/partials');

  // Create and render a view that uses inheritance
  final view = await factory.make('pages/dashboard');
  final content = await view.render();
  print(content);
}

// Example base layout (views/layouts/base.html):
/*
<!DOCTYPE html>
<html>
<head>
    <title>{% yield('title') %} - Admin Panel</title>
    <link rel="stylesheet" href="/css/app.css">
    {% yield('styles') %}
</head>
<body>
    <header>
        {% include('partials/navigation') %}
    </header>

    <div class="container">
        <aside class="sidebar">
            {% yield('sidebar') %}
        </aside>

        <main class="content">
            {% yield('content') %}
        </main>
    </div>

    <footer>
        {% yield('footer', 'Copyright 2025') %}
    </footer>

    <script src="/js/app.js"></script>
    {% yield('scripts') %}
</body>
</html>
*/

// Example dashboard layout (views/layouts/dashboard.html):
/*
{% extends('layouts/base') %}

{% section('sidebar') %}
<nav class="dashboard-nav">
    <a href="/dashboard">Overview</a>
    <a href="/dashboard/users">Users</a>
    <a href="/dashboard/settings">Settings</a>
</nav>
{% endsection %}

{% section('scripts') %}
<script src="/js/dashboard.js"></script>
@@parent {# Includes scripts from parent layout #}
{% endsection %}
*/

// Example dashboard page (views/pages/dashboard.html):
/*
{% extends('layouts/dashboard') %}

{% section('title', 'Dashboard') %}

{% section('styles') %}
<link rel="stylesheet" href="/css/dashboard.css">
{% endsection %}

{% section('content') %}
<div class="dashboard-widgets">
    <div class="widget">
        <h3>Users</h3>
        <p>Total users: 1,234</p>
    </div>
    <div class="widget">
        <h3>Revenue</h3>
        <p>Monthly: $12,345</p>
    </div>
</div>
{% endsection %}
*/

// Example navigation partial (views/partials/navigation.html):
/*
<nav class="main-nav">
    <a href="/">Home</a>
    <a href="/dashboard">Dashboard</a>
    <a href="/profile">Profile</a>
    <a href="/logout">Logout</a>
</nav>
*/

// The inheritance chain:
// 1. pages/dashboard extends layouts/dashboard
// 2. layouts/dashboard extends layouts/base
// 3. layouts/base includes partials/navigation

// Key features demonstrated:
// - Multi-level inheritance (page -> dashboard layout -> base layout)
// - Section definitions and overrides
// - Default section content (footer)
// - Parent content inclusion (@@parent in scripts section)
// - Partial view inclusion (navigation)
// - CSS and JS management
