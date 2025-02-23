import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add a view location
  factory.addLocation('views');

  // Create and render a view that uses loops
  final view = await factory.make('products/list');
  final content = await view.render();
  print(content);
}

// Example view file (views/products/list.html):
/*
<!DOCTYPE html>
<html>
<head>
    <title>Product List</title>
</head>
<body>
    <h1>Our Products</h1>

    {# Simple loop with loop variable #}
    <div class="product-grid">
        {% for product in products %}
            <div class="product {{ loop.first ? 'first' : '' }} {{ loop.last ? 'last' : '' }}">
                <h3>{{ product.name }}</h3>
                <p>Price: ${{ product.price }}</p>
                <p>Item {{ loop.iteration }} of {{ loop.count }}</p>
            </div>
        {% endfor %}
    </div>

    {# Nested loops with parent access #}
    <div class="categories">
        {% for category in categories %}
            <div class="category">
                <h2>{{ category.name }} ({{ loop.index + 1 }}/{{ loop.count }})</h2>
                
                <ul class="features">
                    {% for feature in category.features %}
                        <li>
                            {{ feature }}
                            {# Access parent loop #}
                            (Category {{ loop.parent.iteration }}, Feature {{ loop.iteration }})
                        </li>
                    {% endfor %}
                </ul>
            </div>
        {% endfor %}
    </div>

    {# Loop with odd/even classes #}
    <table class="inventory">
        <tr>
            <th>Product</th>
            <th>Stock</th>
        </tr>
        {% for item in inventory %}
            <tr class="{{ loop.odd ? 'odd' : 'even' }}">
                <td>{{ item.name }}</td>
                <td>{{ item.stock }}</td>
            </tr>
        {% endfor %}
    </table>
</body>
</html>
*/

// The loop variable provides:
// - iteration: Current iteration (1-based)
// - index: Current index (0-based)
// - remaining: Items remaining
// - count: Total items
// - first: Is first iteration
// - last: Is last iteration
// - odd: Is odd iteration
// - even: Is even iteration
// - depth: Nesting level
// - parent: Parent loop information
