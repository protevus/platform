# Blade Template Engine for Dart

A Dart implementation of Laravel's Blade templating engine with full feature parity and API compatibility. This package provides a powerful and flexible templating system for Dart applications, with support for template inheritance, components, and more.

## Features

- Full Laravel Blade syntax support
- Template inheritance with `@extends` and `@section`
- Component system with slots and attributes
- Conditional directives (`@if`, `@unless`, `@switch`)
- Loop directives (`@foreach`, `@forelse`, `@while`)
- Template includes and partials
- Custom directives
- Caching support
- Error handling with source maps
- Flutter compatibility

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  blade: ^0.1.0
```

## Usage

### Basic Example

```dart
import 'package:blade/blade.dart';

void main() async {
  // Create a Blade instance
  var blade = Blade(BladeConfig());

  // Your template
  var template = '''
<div>
  <h1>{{ \$title }}</h1>
  <p>{{ \$content }}</p>
</div>
''';

  // Your data
  var data = {
    'title': 'Hello, World!',
    'content': 'Welcome to Blade for Dart',
  };

  // Render the template
  var output = await blade.render(template, data);
  print(output);
}
```

### Template Inheritance

```blade
// layouts/app.blade.php
<!DOCTYPE html>
<html>
<head>
  <title>@yield('title')</title>
</head>
<body>
  <nav>@yield('nav')</nav>
  <main>@yield('content')</main>
  <footer>@yield('footer')</footer>
</body>
</html>

// pages/home.blade.php
@extends('layouts.app')

@section('title', 'Home Page')

@section('content')
  <h1>{{ \$title }}</h1>
  <div>{{ \$content }}</div>
@endsection
```

### Components

```dart
// Register a component
blade.component('alert', (attributes) {
  return AlertComponent(
    'alert',
    attributes,
    const {},
    SourceFile.fromString('').span(0),
  );
});
```

```blade
// Using the component in templates
<x-alert type="error" :message="\$errorMessage" />

// Component with slots
<x-card>
  <x-slot name="title">
    Card Title
  </x-slot>
  
  <p>Card content goes here.</p>
  
  <x-slot name="footer">
    Card footer
  </x-slot>
</x-card>
```

### Directives

```blade
// Conditionals
@if (\$user->isAdmin)
  <h1>Admin Panel</h1>
@elseif (\$user->isManager)
  <h1>Manager Dashboard</h1>
@else
  <h1>User Dashboard</h1>
@endif

// Loops
@foreach (\$items as \$item)
  <div>{{ \$item->name }}</div>
@endforeach

// Switch statements
@switch(\$type)
  @case('user')
    <p>Regular User</p>
    @break
  @case('admin')
    <p>Administrator</p>
    @break
  @default
    <p>Guest</p>
@endswitch
```

### Custom Directives

```dart
// Register a custom directive
blade.directive('datetime', (String? expression) {
  return "<?php echo date('Y-m-d H:i:s', strtotime($expression)); ?>";
});
```

```blade
// Using the custom directive
@datetime(\$timestamp)
```

## Configuration

```dart
var config = BladeConfig(
  cache: true,        // Enable template caching
  minify: true,       // Minify output HTML
  debug: false,       // Enable debug mode
  directives: {},     // Custom directives
  components: {},     // Custom components
);

var blade = Blade(config);
```

## Error Handling

The package provides detailed error messages with source maps for easy debugging:

```dart
try {
  var output = await blade.render(template, data);
  print(output);
} catch (e) {
  if (e is BladeError) {
    print('Error at line ${e.span.start.line}: ${e.message}');
    print(e.span.highlight());
  }
}
```

## Flutter Integration

The package is designed to work seamlessly with Flutter applications:

```dart
class TemplateWidget extends StatelessWidget {
  final String template;
  final Map<String, dynamic> data;

  const TemplateWidget({
    Key? key,
    required this.template,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: blade.render(template, data),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Html(data: snapshot.data!);
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
