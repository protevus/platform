import 'package:illuminate_filesystem/filesystem.dart';
import 'package:illuminate_view/view.dart';

void main() async {
  // 1. Setup View System
  final files = Filesystem();
  final engines = EngineResolver();
  final finder = FileViewFinder();
  final factory = ViewFactory(engines, finder);

  // Setup Blade engine
  final compiler = BladeCompiler(files, 'storage/framework/views', factory);
  final bladeEngine = BladeEngine(files, compiler, factory);
  engines.register('blade', () => bladeEngine);

  // Add view locations
  finder.addLocation('views');

  // Register .blade.html extension
  factory.addExtension('blade.html', 'blade');

  // 2. Create Example Templates

  // Layout template
  files.put('views/layouts/app.blade.html', '''
<!DOCTYPE html>
<html>
<head>
    <title>@yield('title')</title>
    @stack('styles')
</head>
<body>
    <nav>@include('partials.nav')</nav>
    
    <div class="container">
        @yield('content')
    </div>
    
    @stack('scripts')
</body>
</html>
''');

  // Navigation partial
  files.put('views/partials/nav.blade.html', '''
<ul>
    @foreach(menuItems as item)
        <li class="{{ item.active ? 'active' : '' }}">
            <a href="{{ item.url }}">{{ item.text }}</a>
        </li>
    @endforeach
</ul>
''');

  // Card component
  files.put('views/components/card.blade.html', '''
<div class="card">
    <div class="card-header">
        {{ title }}
    </div>
    <div class="card-body">
        {{ slot }}
    </div>
    @if(hasFooter)
        <div class="card-footer">
            @yield('footer')
        </div>
    @endif
</div>
''');

  // Main page template
  files.put('views/pages/home.blade.html', '''
@extends('layouts.app')

@section('title', 'Welcome')

@push('styles')
    <link rel="stylesheet" href="app.css">
@endpush

@section('content')
    <h1>{{ title }}</h1>
    
    @foreach(posts as post)
        @component('components.card')
            @slot('title')
                {{ post.title }}
            @endslot
            
            <p>{{ post.content }}</p>
            
            @section('footer')
                Posted on {{ post.date }}
            @endsection
        @endcomponent
    @endforeach
@endsection

@push('scripts')
    <script src="app.js"></script>
@endpush
''');

  // 3. Add View Composers
  factory.composer('pages.home', (view) {
    view.withData('menuItems', [
      {'url': '/', 'text': 'Home', 'active': true},
      {'url': '/about', 'text': 'About', 'active': false},
      {'url': '/contact', 'text': 'Contact', 'active': false},
    ]);
  });

  // 4. Render the View
  final view = await factory.make('pages.home', {
    'title': 'My Blog',
    'posts': [
      {
        'title': 'First Post',
        'content': 'This is my first blog post!',
        'date': '2025-02-23',
      },
      {
        'title': 'Second Post',
        'content': 'Another interesting post.',
        'date': '2025-02-24',
      },
    ],
  });

  final output = await view.render();
  print(output);

  /* This example demonstrates:
   * 1. Template Inheritance (@extends, @section, @yield)
   * 2. Partials (@include)
   * 3. Components (@component, @slot)
   * 4. Asset Stacks (@push, @stack)
   * 5. Loops (@foreach)
   * 6. Conditionals (@if)
   * 7. Variable Output ({{ }})
   * 8. View Composers
   * 9. Proper Directory Structure
   * 10. Full Layout System
   */
}
