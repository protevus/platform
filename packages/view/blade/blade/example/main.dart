import 'package:blade/blade.dart';
import 'package:source_span/source_span.dart';

void main() async {
  // Create a Blade instance with default configuration
  var blade = Blade(BladeConfig());

  // Register a custom component
  blade.component('alert', (attributes) {
    return AlertComponent(
      'alert',
      attributes,
      const {},
      SourceFile.fromString('').span(0),
    );
  });

  // Example template with various Blade features
  var template = '''
@extends('layouts.app')

@section('content')
  <div class="container">
    <h1>{{ \$title }}</h1>
    
    @if (\$showAlert)
      <x-alert type="info" :message="\$alertMessage" />
    @endif
    
    @foreach (\$items as \$item)
      <div class="item">
        <h3>{{ \$item['name'] }}</h3>
        <p>{{ \$item['description'] }}</p>
        
        @if (\$item['tags'])
          <div class="tags">
            @foreach (\$item['tags'] as \$tag)
              <span class="tag">{{ \$tag }}</span>
            @endforeach
          </div>
        @endif
      </div>
    @endforeach
  </div>
@endsection

@section('sidebar')
  <nav>
    <ul>
      @foreach (\$menu as \$item)
        <li><a href="{{ \$item['url'] }}">{{ \$item['text'] }}</a></li>
      @endforeach
    </ul>
  </nav>
@endsection
''';

  // Data to pass to the template
  var data = <String, dynamic>{
    'title': 'My Dashboard',
    'showAlert': true,
    'alertMessage': 'Welcome to your dashboard!',
    'items': [
      {
        'name': 'First Item',
        'description': 'This is the first item.',
        'tags': ['new', 'featured'],
      },
      {
        'name': 'Second Item',
        'description': 'This is the second item.',
        'tags': ['sale'],
      },
    ],
    'menu': [
      {'url': '/', 'text': 'Home'},
      {'url': '/about', 'text': 'About'},
      {'url': '/contact', 'text': 'Contact'},
    ],
  };

  try {
    // Render the template with data
    var output = await blade.render(template, data);
    print('Rendered template:');
    print('----------------------------------------');
    print(output);
    print('----------------------------------------');
  } catch (e) {
    print('Error rendering template: $e');
  }

  // Example of using components directly
  var componentTemplate = '''
<div class="notifications">
  <x-alert type="success" message="Operation completed successfully" />
  <x-alert type="error" message="Some errors occurred" />
  <x-alert type="warning" message="Please review your input" />
</div>
''';

  try {
    var output = await blade.render(componentTemplate, {});
    print('\nComponent example:');
    print('----------------------------------------');
    print(output);
    print('----------------------------------------');
  } catch (e) {
    print('Error rendering components: $e');
  }

  // Example of template inheritance
  var childTemplate = '''
@extends('layouts.master')

@section('title')
  Child Page Title
@endsection

@section('content')
  <div class="child-content">
    <h2>{{ \$heading }}</h2>
    <p>{{ \$content }}</p>
    
    @include('partials.footer', ['year' => \$currentYear])
  </div>
@endsection
''';

  var childData = <String, dynamic>{
    'heading': 'Welcome to the Child Page',
    'content': 'This content is from the child template.',
    'currentYear': '2024',
  };

  try {
    var output = await blade.render(childTemplate, childData);
    print('\nTemplate inheritance example:');
    print('----------------------------------------');
    print(output);
    print('----------------------------------------');
  } catch (e) {
    print('Error rendering child template: $e');
  }
}

/// Example component implementation
class AlertComponent extends Component {
  AlertComponent(
    String name,
    Map<String, dynamic> attributes,
    Map<String, List<AstNode>> slots,
    FileSpan span,
  ) : super(name, attributes, slots, span);

  @override
  Future<String> render(Map<String, dynamic> data) async {
    var type = attributes['type'] ?? 'info';
    var message = attributes['message'] ?? '';
    var icon = _getIcon(type);

    return '''
<div class="alert alert-$type" role="alert">
  $icon
  <span class="alert-message">$message</span>
</div>''';
  }

  String _getIcon(String type) {
    switch (type) {
      case 'success':
        return '<i class="fas fa-check-circle"></i>';
      case 'error':
        return '<i class="fas fa-exclamation-circle"></i>';
      case 'warning':
        return '<i class="fas fa-exclamation-triangle"></i>';
      default:
        return '<i class="fas fa-info-circle"></i>';
    }
  }
}
