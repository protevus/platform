import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:platform_contracts/src/foundation/application.dart';
import 'package:logging/logging.dart' as logging;

import 'base_logger.dart';

/// A logger that sends messages to Slack via webhook.
class SlackLogger extends BaseLogger {
  /// Creates a new [SlackLogger] instance.
  SlackLogger(ApplicationContract app, Map<String, dynamic> config)
      : _webhookUrl = config['url'] as String,
        _channel = config['channel'] as String?,
        _username = config['username'] as String? ?? 'Laravel',
        _emoji = config['emoji'] as String? ?? ':boom:',
        super(app, config) {
    _logger = logging.Logger('slack')..level = _parseLevel(getLevel());
  }

  final String _webhookUrl;
  final String? _channel;
  final String _username;
  final String _emoji;
  late final logging.Logger _logger;

  @override
  void log(String level, Object message,
      [Map<String, dynamic> context = const {}]) {
    final payload = {
      'username': _username,
      'icon_emoji': _emoji,
      if (_channel != null) 'channel': _channel,
      'attachments': [
        {
          'color': _getColorForLevel(level),
          'fields': [
            {'title': 'Level', 'value': level, 'short': true},
            {
              'title': 'Environment',
              'value': app.environment ?? 'production',
              'short': true
            },
            {'title': 'Message', 'value': message.toString()},
            if (context.isNotEmpty)
              {'title': 'Context', 'value': jsonEncode(context)}
          ],
          'ts': DateTime.now().millisecondsSinceEpoch / 1000
        }
      ]
    };

    // Send to Slack
    http
        .post(
      Uri.parse(_webhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    )
        .then((response) {
      if (response.statusCode != 200) {
        print('Failed to send log to Slack: ${response.body}');
      }
    }).catchError((error) {
      print('Error sending log to Slack: $error');
    });

    // Also log to console in development
    if (isLocal) {
      print('[$level] $message ${context.isEmpty ? '' : context}');
    }
  }

  /// Get the color for the Slack attachment based on log level.
  String _getColorForLevel(String level) {
    return switch (level.toLowerCase()) {
      'emergency' || 'alert' || 'critical' => 'danger',
      'error' => '#dc3545',
      'warning' => 'warning',
      'notice' || 'info' => 'good',
      'debug' => '#6c757d',
      _ => '#17a2b8',
    };
  }

  /// Parse the log level string into a [Level].
  logging.Level _parseLevel(String level) {
    return switch (level.toLowerCase()) {
      'emergency' || 'alert' || 'critical' => logging.Level.SHOUT,
      'error' => logging.Level.SEVERE,
      'warning' => logging.Level.WARNING,
      'notice' || 'info' => logging.Level.INFO,
      'debug' => logging.Level.FINE,
      _ => logging.Level.INFO,
    };
  }
}
