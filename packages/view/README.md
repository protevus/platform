# Laravel-like View System for Dart

This package provides a Laravel-inspired view system with Blade-like templates. The example demonstrates all major features:

## Features

1. **Template Inheritance**
   - `@extends` - Extend layout templates
   - `@section/@yield` - Define and render content blocks
   - `@parent` - Include parent section content

2. **Components**
   - `@component` - Include reusable components
   - `@slot` - Pass content to components
   - Component classes support

3. **Partials**
   - `@include` - Include sub-templates
   - `@includeIf` - Conditional includes
   - `@includeWhen` - Conditional includes with expression

4. **Asset Management**
   - `@push/@stack` - Group and render assets
   - Multiple stack support
   - Prepend/append capabilities

5. **Control Structures**
   - `@if/@else` - Conditionals
   - `@foreach` - Loops
   - `@for` - Counting loops

6. **View Composers**
   - Attach data to views
   - Share data across views
   - Event-based view modification

## Directory Structure

```
views/
├── layouts/           # Base layouts
│   └── app.blade.html
├── components/        # Reusable components
│   └── card.blade.html
├── partials/         # Partial templates
│   └── nav.blade.html
└── pages/            # Page templates
    └── home.blade.html
```

## Usage

```dart
// Setup view system
final factory = ViewFactory(engines, finder);
final compiler = BladeCompiler(files, cachePath, factory);
final bladeEngine = BladeEngine(files, compiler, factory);

// Register Blade engine
engines.register('blade', () => bladeEngine);
factory.addExtension('blade.html', 'blade');

// Add view composers
factory.composer('pages.home', (view) {
  view.withData('menuItems', getMenuItems());
});

// Render views
return view('pages.home', {
  'title': 'Welcome',
  'content': 'Page content'
});
```

See `complete_example.dart` for a full working example of all features.
