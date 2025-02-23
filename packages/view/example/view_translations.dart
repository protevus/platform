import 'package:illuminate_view/view.dart';
import 'package:illuminate_translation/translation.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add view locations
  factory.addLocation('views');

  // Create and render a view that uses translations
  final view = await factory.make('pages/welcome');
  final content = await view.render();
  print(content);
}

// Example translation files:

// translations/en.json:
/*
{
  "welcome": {
    "title": "Welcome to our application",
    "greeting": "Hello :name",
    "intro": "Welcome to our platform. We're glad to have you here!",
    "items": {
      "one": "You have 1 item",
      "other": "You have :count items"
    },
    "messages": {
      "one": "You have 1 unread message",
      "other": "You have :count unread messages"
    }
  },
  "nav": {
    "home": "Home",
    "about": "About Us",
    "contact": "Contact"
  }
}
*/

// translations/es.json:
/*
{
  "welcome": {
    "title": "Bienvenido a nuestra aplicación",
    "greeting": "Hola :name",
    "intro": "Bienvenido a nuestra plataforma. ¡Nos alegra tenerte aquí!",
    "items": {
      "one": "Tienes 1 artículo",
      "other": "Tienes :count artículos"
    },
    "messages": {
      "one": "Tienes 1 mensaje sin leer",
      "other": "Tienes :count mensajes sin leer"
    }
  },
  "nav": {
    "home": "Inicio",
    "about": "Sobre Nosotros",
    "contact": "Contacto"
  }
}
*/

// Example welcome page (views/pages/welcome.html):
/*
<!DOCTYPE html>
<html>
<head>
    <title>{{ trans('welcome.title') }}</title>
</head>
<body>
    <nav>
        <a href="/">{{ trans('nav.home') }}</a>
        <a href="/about">{{ trans('nav.about') }}</a>
        <a href="/contact">{{ trans('nav.contact') }}</a>
    </nav>

    <main>
        {# Basic translation #}
        <h1>{{ trans('welcome.title') }}</h1>

        {# Translation with parameter replacement #}
        <p>{{ trans('welcome.greeting', {'name': 'John'}) }}</p>
        <p>{{ trans('welcome.intro') }}</p>

        {# Translation choice (pluralization) #}
        <div class="items">
            {# Will output "You have 1 item" #}
            <p>{{ transChoice('welcome.items', 1) }}</p>

            {# Will output "You have 5 items" #}
            <p>{{ transChoice('welcome.items', 5, {'count': 5}) }}</p>
        </div>

        {# Translation block with parameters #}
        {% translation {'name': 'Alice', 'count': 3} %}
            welcome.greeting
            welcome.messages
        {% endtranslation %}

        {# Will output:
           Hola Alice
           Tienes 3 mensajes sin leer
        #}
    </main>
</body>
</html>
*/

// Key features demonstrated:
// - Basic translations
// - Parameter replacement
// - Pluralization with transChoice
// - Translation blocks
// - Nested translation keys
// - Multiple languages support
// - Parameter interpolation
// - Translation fallbacks
