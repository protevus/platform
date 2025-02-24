import 'package:illuminate_filesystem/filesystem.dart';
import 'package:illuminate_view/view.dart';

void main() {
  // Original Blade template
  final template = '''
@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')
    {# User greeting section #}
    <div class="greeting">
        @if(user != null)
            <h1>Welcome back, {{ user.name }}!</h1>
            <p>Your last login was {{ user.lastLogin }}</p>
        @else
            <h1>Welcome Guest!</h1>
            <p>Please <a href="/login">login</a> to continue.</p>
        @endif
    </div>

    {# Stats section #}
    <div class="stats">
        <h2>Your Statistics</h2>
        @foreach(stats as stat)
            <div class="stat-card {{ stat.trend > 0 ? 'trending-up' : 'trending-down' }}">
                <h3>{{ stat.label }}</h3>
                <p class="value">{{ stat.value }}</p>
                <p class="trend">
                    {!! stat.trend > 0 ? '<span class="up">↑</span>' : '<span class="down">↓</span>' !!}
                    {{ stat.trend }}%
                </p>
            </div>
        @endforeach
    </div>

    {# Recent activity #}
    <div class="activity">
        <h2>Recent Activity</h2>
        @forelse(activities as activity)
            <div class="activity-item">
                <span class="time">{{ activity.time }}</span>
                <span class="type">{{ activity.type }}</span>
                <p class="description">{!! activity.description !!}</p>
            </div>
        @empty
            <p>No recent activity.</p>
        @endforelse
    </div>
@endsection

@push('scripts')
    <script src="/js/dashboard.js"></script>
@endpush
''';

  // After compilation to Dart code
  final compiledCode = '''
// Generated from: views/dashboard.blade.dart

String render(Map<String, dynamic> data) {
  final buffer = StringBuffer();
  
  // Helper functions
  String e(String value, [bool doubleEncode = true]) {
    if (!doubleEncode) {
      value = value.replaceAll('&amp;', '&');
    }
    return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }
  
  bool isset(dynamic value) => value != null;
  bool empty(dynamic value) => value == null || value == '';
  
  // Extract variables from data
  final user = data['user'];
  final stats = data['stats'];
  final activities = data['activities'];
  
  // Start output buffering for sections
  startSection('title', 'Dashboard');
  
  // Content section
  startSection('content');
  
  // User greeting section
  buffer.write('<div class="greeting">');
  if (user != null) {
    buffer.write('<h1>Welcome back, ');
    buffer.write(e(user['name']));
    buffer.write('!</h1><p>Your last login was ');
    buffer.write(e(user['lastLogin']));
    buffer.write('</p>');
  } else {
    buffer.write(
      '<h1>Welcome Guest!</h1>'
      '<p>Please <a href="/login">login</a> to continue.</p>'
    );
  }
  buffer.write('</div>');
  
  // Stats section
  buffer.write(
    '<div class="stats">'
    '<h2>Your Statistics</h2>'
  );
  for (final stat in stats) {
    buffer.write('<div class="stat-card ');
    buffer.write(stat['trend'] > 0 ? 'trending-up' : 'trending-down');
    buffer.write('">');
    buffer.write('<h3>');
    buffer.write(e(stat['label']));
    buffer.write('</h3><p class="value">');
    buffer.write(e(stat['value']));
    buffer.write('</p><p class="trend">');
    buffer.write(stat['trend'] > 0 
      ? '<span class="up">↑</span>' 
      : '<span class="down">↓</span>');
    buffer.write(e(stat['trend'].toString()));
    buffer.write('%</p></div>');
  }
  buffer.write('</div>');
  
  // Recent activity
  buffer.write(
    '<div class="activity">'
    '<h2>Recent Activity</h2>'
  );
  if (activities.isNotEmpty) {
    for (final activity in activities) {
      buffer.write(
        '<div class="activity-item">'
        '<span class="time">'
      );
      buffer.write(e(activity['time']));
      buffer.write('</span><span class="type">');
      buffer.write(e(activity['type']));
      buffer.write('</span><p class="description">');
      buffer.write(activity['description']);
      buffer.write('</p></div>');
    }
  } else {
    buffer.write('<p>No recent activity.</p>');
  }
  buffer.write('</div>');
  
  // End content section
  stopSection();
  
  // Push scripts
  startPush('scripts');
  buffer.write('<script src="/js/dashboard.js"></script>');
  stopPush();
  
  // Extend the layout
  await extendView('layouts.app');
  
  return buffer.toString();
}
''';

  print('Original Blade Template:');
  print('======================');
  print(template);
  print('\nCompiled Dart Code:');
  print('=================');
  print(compiledCode);
}
