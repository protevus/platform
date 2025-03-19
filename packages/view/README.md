# illuminate_view

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/illuminate_view?include_prereleases)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Discord](https://img.shields.io/discord/1060322353214660698)](https://discord.gg/3X6bxTUdCM)
[![License](https://img.shields.io/github/license/dart-backend/angel)](LICENSE)

A powerful server-side HTML templating engine for Dart, built on Jael3's foundation with an HTML-first approach to directives.

## Features

- 🎯 **HTML-First Directives**: Uses attributes and elements instead of @ syntax
- 🔒 **Built-in Security**: XSS protection and CSRF token handling
- 🔄 **Template Inheritance**: Using blocks and yields
- 💡 **Smart Compilation**: Template caching and optimization
- 🛠️ **Rich Directives**: Comprehensive set of built-in directives
- 📦 **Extensible**: Custom elements support

## Installation

```yaml
dependencies:
  illuminate_view: ^8.2.0
```

## HTML-First Approach

illuminate_view takes an HTML-first approach to templating, treating directives as natural HTML elements and attributes rather than special syntax markers. This means directives are implemented as either HTML attributes or elements, making templates cleaner and easier to understand.

### Quick Example

```html
<extends name="layout">
  <block name="content">
    <h1>Welcome, {{ user.name }}!</h1>
    
    <div if="user.isAdmin">
      <div class="admin-panel">Admin Controls</div>
    </div>
    
    <ul>
      <li for-each="items" as="item">
        {{ item.name }} - ${{ item.price }}
      </li>
    </ul>
  </block>
</extends>
```

## Available Directives

### Template Inheritance

```html
<!-- layout.html -->
<!DOCTYPE html>
<html>
<head>
  <title><yield name="title"/></title>
  <yield name="styles"/>
</head>
<body>
  <nav>
    <yield name="navigation"/>
  </nav>
  
  <main>
    <yield name="content"/>
  </main>
  
  <footer>
    <yield name="footer">
      <!-- Default footer content -->
      <p>&copy; 2025 My Site</p>
    </yield>
  </footer>
  
  <yield name="scripts"/>
</body>
</html>

<!-- page.html -->
<extends name="layout">
  <block name="title">Welcome</block>
  
  <block name="navigation">
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </block>
  
  <block name="content">
    <h1>Welcome</h1>
    <p>Content goes here</p>
  </block>
</extends>
```

### Conditional Rendering

```html
<!-- If Conditions -->
<div if="condition">
  Content shown if condition is true
</div>
<div else-if="otherCondition">
  Content shown if otherCondition is true
</div>
<div else>
  Content shown if all conditions are false
</div>

<!-- Unless -->
<div unless="user.isSubscribed">
  <p>Please subscribe to continue</p>
</div>

<!-- Switch Statements -->
<switch value="{{ status }}">
  <case value="pending">
    <div class="alert alert-warning">Pending Review</div>
  </case>
  <case value="approved">
    <div class="alert alert-success">Approved</div>
  </case>
  <default>
    <div class="alert alert-info">Unknown Status</div>
  </default>
</switch>
```

### Variable Checks

```html
<!-- Check if Variable Exists -->
<div isset="user.preferences">
  <p>User preferences found</p>
</div>

<!-- Check if Variable is Empty -->
<div empty="user.notifications">
  <p>No notifications</p>
</div>
```

### Loops

```html
<!-- Basic Loop -->
<ul>
  <li for-each="items" as="item">
    {{ item.name }}
  </li>
</ul>

<!-- With Index -->
<ul>
  <li for-each="items" as="item" index-as="i">
    {{ i + 1 }}. {{ item.name }}
  </li>
</ul>
```

### Authentication

```html
<!-- Basic Auth Check -->
<div auth>
  <p>Hello {{ user.name }}!</p>
</div>

<!-- With Guards -->
<div auth="admin">
  <div class="admin-panel">
    <!-- Admin Controls -->
  </div>
</div>

<!-- Guest Check -->
<div guest>
  <p>Please log in</p>
</div>
```

### Forms & CSRF Protection

```html
<!-- Forms automatically include CSRF protection -->
<form method="POST">
  <input type="text" name="title">
  
  <!-- Method Spoofing for PUT/PATCH/DELETE -->
  <div method="PUT"></div>
  
  <!-- Error Handling -->
  <div error="email">
    <span class="error">{{ message }}</span>
  </div>
  
  <button type="submit">Submit</button>
</form>
```

### Environment & Production

```html
<!-- Environment Check -->
<div env="local">
  <p>Development Mode</p>
</div>

<!-- Multiple Environments -->
<div env="staging,testing">
  <div class="test-banner">
    Test Environment
  </div>
</div>

<!-- Production Check -->
<div production>
  <p>Production Mode</p>
</div>
```

### Declare Variables

```html
<declare>
  isAdmin = "user.role == 'admin'"
  formatPrice = "(num) => '\$${num.toStringAsFixed(2)}'"
</declare>

<!-- Usage -->
<div if="isAdmin">
  Admin Controls
</div>

<div>Price: {{ formatPrice(product.price) }}</div>
```

### Custom Elements

```html
<!-- Define a Custom Element -->
<element name="alert">
  <div class="alert alert-{{ type }}">
    <yield/>
  </div>
</element>

<!-- Use the Custom Element -->
<alert type="success">
  Operation completed successfully!
</alert>

<!-- With Named Slots -->
<element name="card">
  <div class="card">
    <div class="card-header">
      <yield name="header"/>
    </div>
    <div class="card-body">
      <yield/>
    </div>
    <div class="card-footer">
      <yield name="footer"/>
    </div>
  </div>
</element>

<card>
  <block name="header">
    <h3>Card Title</h3>
  </block>
  
  <p>Card content here</p>
  
  <block name="footer">
    <button>Action</button>
  </block>
</card>
```

## Common Components

### Navigation Menu

```html
<element name="nav-menu">
  <nav class="navbar">
    <div class="navbar-brand">
      <a href="/">{{ brand }}</a>
    </div>
    
    <div class="navbar-menu">
      <yield/>
      
      <!-- Auth Section -->
      <div class="navbar-end">
        <div auth>
          <div class="dropdown">
            <button>{{ user.name }}</button>
            <div class="dropdown-menu">
              <a href="/profile">Profile</a>
              <a href="/logout">Logout</a>
            </div>
          </div>
        </div>
        
        <div guest>
          <a href="/login">Login</a>
          <a href="/register">Register</a>
        </div>
      </div>
    </div>
  </nav>
</element>
```

### Data Table

```html
<element name="data-table">
  <table class="table">
    <thead>
      <tr>
        <yield name="headers"/>
      </tr>
    </thead>
    <tbody>
      <tr for-each="items" as="item">
        <yield with="{'item': item, 'index': i}"/>
      </tr>
    </tbody>
    <tfoot>
      <tr>
        <td colspan="100%">
          <div class="table-info">
            Total Items: {{ items.length }}
          </div>
        </td>
      </tr>
    </tfoot>
  </table>
</element>
```

### Form Components

```html
<element name="form-input">
  <div class="form-group">
    <label if="label">{{ label }}</label>
    
    <input type="{{ type || 'text' }}"
           name="{{ name }}"
           value="{{ value }}"
           class="form-control {{ errors[name] ? 'is-invalid' : '' }}">
           
    <div error="{{ name }}" class="invalid-feedback">
      {{ message }}
    </div>
  </div>
</element>
```

## Usage in Dart

```dart
import 'package:illuminate_view/illuminate_view.dart';

void main() {
  // Parse template
  var document = parseDocument(template);
  
  // Create scope with data
  var scope = SymbolTable(values: {
    'user': {
      'name': 'John',
      'isAdmin': true
    },
    'items': [
      {'name': 'Item 1', 'price': 99.99},
      {'name': 'Item 2', 'price': 149.99}
    ]
  });

  // Render template
  var buffer = CodeBuffer();
  const Renderer().render(document, buffer, scope);
  print(buffer);
}
```

## Security

- XSS Protection: All interpolated values are automatically escaped
- CSRF Protection: Automatically added to POST forms
- Strict Resolution: Variables must exist in scope (configurable)
- HTML5 Compliance: Proper handling of self-closing tags

## Contributing

We welcome contributions! Please see our [contributing guide](CONTRIBUTING.md) for details.

## License

illuminate_view is open-sourced software licensed under the [MIT license](LICENSE).
