import 'dart:io';
import 'package:illuminate_view/view.dart';
import 'package:illuminate_filesystem/filesystem.dart';

// Example 2: Post composer class - demonstrates class-based composer
class PostComposer {
  void compose(View view) {
    view.withManyData({
      'post': {
        'title': 'Getting Started with View Composers',
        'author': {'name': 'John Doe'},
        'published_at': 'February 24, 2024',
        'read_time': 5,
        'content': '''
View composers are a powerful feature that allows you to share data across multiple views 
or attach data to views whenever they are rendered. This makes it easy to keep your views 
clean and maintainable while ensuring that necessary data is always available.

In this post, we'll explore different ways to use view composers and how they can help 
organize your application's view logic.
''',
      },
      'title': 'Getting Started with View Composers', // For layout
    });
  }
}

void main() async {
  // Setup view factory and filesystem
  final engines = EngineResolver();
  final finder = FileViewFinder();
  final factory = ViewFactory(engines, finder);
  final files = Filesystem()..makeDirectory('cache/views');

  // Add template files to filesystem
  final postContent =
      await File('example/blog/views/post.blade.html').readAsString();
  final layoutContent =
      await File('example/blog/views/layout.blade.html').readAsString();
  files.put('example/blog/views/post.blade.html', postContent);
  files.put('example/blog/views/layout.blade.html', layoutContent);

  print('Files in filesystem:');
  print(
      'post.blade.html exists: ${files.exists('example/blog/views/post.blade.html')}');
  print(
      'layout.blade.html exists: ${files.exists('example/blog/views/layout.blade.html')}');

  // Setup blade engine with compiler
  final compiler = BladeCompiler(files, 'cache/views', factory);
  final engine = BladeEngine(files, compiler, factory);
  // Register blade engine and extension
  engines.register('blade', () => engine);
  factory.addExtension('blade.html', 'blade');
  finder.addExtension('blade.html');
  finder.addLocation('example/blog/views');

  // Example 1: Layout composer - adds common data to all layouts
  factory.composer('layout', (String event, List<dynamic> args) {
    final view = args[0] as View;
    view.withManyData({
      'user': {
        'name': 'John Doe',
        'email': 'john@example.com',
      },
      'footerText': '© 2024 My Blog. All rights reserved.',
      'socialLinks': [
        {'name': 'Twitter', 'url': 'https://twitter.com'},
        {'name': 'GitHub', 'url': 'https://github.com'},
        {'name': 'LinkedIn', 'url': 'https://linkedin.com'},
      ],
    });
  });

  // Register post composer
  final composer = PostComposer();
  factory.composer('post', (String event, List<dynamic> args) {
    composer.compose(args[0] as View);
  });

  // Example 3: Related posts composer - demonstrates wildcard composer
  factory.composer('post.*', (String event, List<dynamic> args) {
    final view = args[0] as View;
    view.withData('relatedPosts', [
      {
        'title': 'Understanding View Inheritance',
        'excerpt':
            'Learn how to create reusable layouts with view inheritance...',
        'slug': 'understanding-view-inheritance',
      },
      {
        'title': 'Working with Blade Templates',
        'excerpt': 'Explore the powerful features of Blade templating...',
        'slug': 'working-with-blade-templates',
      },
    ]);
  });

  // Example 4: Comments composer - demonstrates conditional composer
  factory.composer('post', (String event, List<dynamic> args) {
    final view = args[0] as View;
    view.withManyData({
      'showComments': true,
      'comments': [
        {
          'author': 'Jane Smith',
          'posted_at': '2 hours ago',
          'content':
              'Great article! Very helpful explanation of view composers.',
        },
        {
          'author': 'Bob Wilson',
          'posted_at': '5 hours ago',
          'content':
              'Thanks for sharing these insights. Looking forward to more posts!',
        },
      ],
    });
  });

  // Example 5: Analytics composer - demonstrates once-only composer
  factory.composer('*', (String event, List<dynamic> args) {
    final view = args[0] as View;
    view.withData('analytics', {
      'pageView': true,
      'timestamp': DateTime.now().toIso8601String(),
    });
  });

  // Render the post view to see all composers in action
  final view = await factory.make('post');
  print(await view.render());
}
