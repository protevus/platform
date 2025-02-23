import 'package:illuminate_view/view.dart';

void main() async {
  // Create the view factory
  final factory = ViewFactory(EngineResolver(), FileViewFinder());

  // Add view locations
  factory.addLocation('views/components');
  factory.addLocation('views/pages');

  // Create and render a view that uses components
  final view = await factory.make('pages/dashboard');
  final content = await view.render();
  print(content);
}

// Example alert component (views/components/alert.html):
/*
<div class="alert alert-{{ type ?? 'info' }}">
    {% if title %}
    <h4 class="alert-title">{{ title }}</h4>
    {% endif %}
    
    <div class="alert-content">
        {{ slot }}
    </div>

    {% if dismissible %}
    <button class="alert-dismiss">&times;</button>
    {% endif %}
</div>
*/

// Example card component (views/components/card.html):
/*
<div class="card">
    {% if title %}
    <div class="card-header">
        <h3>{{ title }}</h3>
    </div>
    {% endif %}

    <div class="card-body">
        {{ slot }}
    </div>

    {% if hasSlot('footer') %}
    <div class="card-footer">
        {{ slots.footer }}
    </div>
    {% endif %}
</div>
*/

// Example dashboard page (views/pages/dashboard.html):
/*
<div class="dashboard">
    {# Using alert component with data #}
    {% component('alert', {
        'type': 'success',
        'title': 'Welcome Back!',
        'dismissible': true
    }) %}
        Your last login was 2 hours ago.
    {% endcomponent %}

    <div class="dashboard-grid">
        {# Using card component with slots #}
        {% component('card', { 'title': 'Statistics' }) %}
            <div class="stats">
                <div class="stat">Users: 1,234</div>
                <div class="stat">Orders: 567</div>
                <div class="stat">Revenue: $12,345</div>
            </div>

            {% slot('footer') %}
                <a href="/stats">View Details</a>
            {% endslot %}
        {% endcomponent %}

        {# Another card component #}
        {% component('card', { 'title': 'Recent Activity' }) %}
            <ul class="activity-list">
                <li>New user registration</li>
                <li>Order #123 completed</li>
                <li>System update scheduled</li>
            </ul>

            {% slot('footer') %}
                <a href="/activity">View All Activity</a>
            {% endslot %}
        {% endcomponent %}
    </div>
</div>
*/

// Key features demonstrated:
// - Component registration and rendering
// - Component data passing
// - Default slot content
// - Named slots
// - Conditional rendering
// - Component nesting
// - Slot attributes
