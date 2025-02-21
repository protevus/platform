# Illuminate View

A flexible and powerful templating system for Dart, inspired by Laravel's View system.

## Features

- Simple and intuitive template syntax using `{{variable}}` notation
- Support for multiple template engines
- Shared data across views
- Namespaced views
- File-based template loading
- Extensible engine system

## Installation

```yaml
dependencies:
  illuminate_view: ^0.0.1
```

## Usage

### Basic Example

```dart
import 'package:illuminate_view/illuminate_view.dart';

void main() async {
  // Create the view factory
  final viewFactory = createViewFactory();
  
  // Add template directories
  viewFactory.addLocation('views');
  
  // Create and render a view with data
  final view = await viewFactory.make('welcome', {
    'title': 'Welcome Page',
    'content': 'Hello from Illuminate View!',
  });
  
  // Render the view
  print(await view.render());
}
```

### Template Example

```html
<!DOCTYPE html>
<html>
<head>
    <title>{{title}}</title>
</head>
<body>
    <div class="content">
        {{content}}
    </div>
</body>
</html>
```

### Shared Data

Share data across all views:

```dart
// Make data available to all views
viewFactory.share('siteName', 'My Website');
viewFactory.share('year', '2025');

// Data will be available in all rendered views
final view1 = await viewFactory.make('page1');
final view2 = await viewFactory.make('page2');
```

### View Namespaces

Organize views in namespaces:

```dart
// Register a namespace
viewFactory.addNamespace('admin', ['admin/views']);

// Use namespaced views
final view = await viewFactory.make('admin::dashboard');
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/protevus/platform/issues).

## License

This package is open-sourced software licensed under the [MIT license](LICENSE).
