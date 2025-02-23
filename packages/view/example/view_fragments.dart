import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add view locations
  factory.addLocation('views');

  // Create and render a view that uses fragments
  final view = await factory.make('pages/article');
  final content = await view.render();
  print(content);
}

// Example article page (views/pages/article.html):
/*
<!DOCTYPE html>
<html>
<head>
    <title>Article Page</title>
</head>
<body>
    {# Start capturing a fragment for meta tags #}
    {% fragment('meta') %}
    <meta name="description" content="Article about view fragments">
    <meta name="keywords" content="views, fragments, templates">
    {% endfragment %}

    {# Start capturing a fragment for social sharing #}
    {% fragment('social') %}
    <meta property="og:title" content="Using View Fragments">
    <meta property="og:description" content="Learn how to use view fragments">
    <meta property="og:image" content="/images/article.jpg">
    {% endfragment %}

    {# Use the captured fragments in the head #}
    {{ getFragment('meta') }}
    {{ getFragment('social') }}

    <main>
        <article>
            <h1>Using View Fragments</h1>
            
            {# Capture article content as a fragment #}
            {% fragment('article-content') %}
            <p>View fragments allow you to capture and reuse content...</p>
            <p>This content can be reused anywhere in the view...</p>
            {% endfragment %}

            {# Use the article content fragment #}
            <div class="article-body">
                {{ getFragment('article-content') }}
            </div>

            {# Reuse the same content in a preview section #}
            <div class="article-preview">
                {{ getFragment('article-content') }}
            </div>
        </article>

        {# Use a fragment with a default value #}
        <aside>
            {{ getFragment('sidebar', '<p>Default sidebar content</p>') }}
        </aside>
    </main>
</body>
</html>
*/

// Key features demonstrated:
// - Fragment capturing and reuse
// - Multiple fragments in one view
// - Default fragment content
// - Fragment reuse in multiple locations
// - Common use cases:
//   * Meta tags
//   * Social sharing tags
//   * Reusable content blocks
//   * Default content fallbacks
