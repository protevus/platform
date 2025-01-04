import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:platform_log/platform_log.dart';
import 'package:test/test.dart';

import '../utils/mocks.dart';

class MockHttpClient extends http.BaseClient {
  final List<http.Request> requests = [];
  final int statusCode;
  final String responseBody;

  MockHttpClient({this.statusCode = 200, this.responseBody = 'ok'});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request as http.Request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      statusCode,
    );
  }
}

void main() {
  group('SlackLogger', () {
    late MockApplication app;
    late MockHttpClient httpClient;
    late String webhookUrl;

    setUp(() {
      app = MockApplication();
      webhookUrl = 'https://hooks.slack.com/test';
      httpClient = MockHttpClient();

      // Override the default HTTP client
      http.Client.new = () => httpClient;
    });

    test('sends log messages to Slack', () {
      final config = {
        'url': webhookUrl,
        'channel': '#logs',
        'username': 'TestBot',
        'emoji': ':test:',
        'level': 'debug',
      };

      final logger = SlackLogger(app, config);
      logger.info('test message', {'context': 'value'});

      expect(httpClient.requests, hasLength(1));
      final request = httpClient.requests.first;
      expect(request.method, equals('POST'));
      expect(request.url.toString(), equals(webhookUrl));
      expect(request.headers['Content-Type'], equals('application/json'));

      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload['username'], equals('TestBot'));
      expect(payload['icon_emoji'], equals(':test:'));
      expect(payload['channel'], equals('#logs'));
      expect(payload['attachments'], isList);

      final attachment = payload['attachments'][0] as Map<String, dynamic>;
      expect(attachment['fields'], isList);
      expect(
        attachment['fields'].any((f) =>
            f['title'] == 'Message' && f['value'].contains('test message')),
        isTrue,
      );
      expect(
        attachment['fields'].any(
            (f) => f['title'] == 'Context' && f['value'].contains('value')),
        isTrue,
      );
    });

    test('handles missing channel config', () {
      final config = {
        'url': webhookUrl,
        'level': 'debug',
      };

      final logger = SlackLogger(app, config);
      logger.info('test message');

      final payload = jsonDecode(httpClient.requests.first.body);
      expect(payload.containsKey('channel'), isFalse);
    });

    test('uses default username and emoji', () {
      final config = {
        'url': webhookUrl,
        'level': 'debug',
      };

      final logger = SlackLogger(app, config);
      logger.info('test message');

      final payload = jsonDecode(httpClient.requests.first.body);
      expect(payload['username'], equals('Laravel'));
      expect(payload['icon_emoji'], equals(':boom:'));
    });

    test('colors messages based on level', () {
      final config = {
        'url': webhookUrl,
        'level': 'debug',
      };

      final logger = SlackLogger(app, config);

      // Test different log levels
      logger.emergency('emergency');
      logger.error('error');
      logger.warning('warning');
      logger.info('info');
      logger.debug('debug');

      final requests = httpClient.requests.map((r) => jsonDecode(r.body));
      final colors =
          requests.map((r) => (r['attachments'][0] as Map)['color']).toList();

      expect(colors[0], equals('danger')); // emergency
      expect(colors[1], equals('#dc3545')); // error
      expect(colors[2], equals('warning')); // warning
      expect(colors[3], equals('good')); // info
      expect(colors[4], equals('#6c757d')); // debug
    });

    test('handles request failures', () {
      httpClient = MockHttpClient(statusCode: 500, responseBody: 'error');
      http.Client.new = () => httpClient;

      final config = {
        'url': webhookUrl,
        'level': 'debug',
      };

      final logger = SlackLogger(app, config);

      // Should not throw
      expect(() => logger.info('test message'), returnsNormally);
    });

    test('respects log level', () {
      final config = {
        'url': webhookUrl,
        'level': 'error', // Only log error and above
      };

      final logger = SlackLogger(app, config);
      logger.debug('debug message'); // Should not be sent
      logger.info('info message'); // Should not be sent
      logger.error('error message'); // Should be sent
      logger.critical('critical message'); // Should be sent

      expect(httpClient.requests, hasLength(2)); // Only error and critical
      final messages = httpClient.requests
          .map((r) => jsonDecode(r.body))
          .map((p) => p['attachments'][0]['fields']
              .firstWhere((f) => f['title'] == 'Message')['value'])
          .toList();

      expect(messages, contains('error message'));
      expect(messages, contains('critical message'));
      expect(messages, isNot(contains('debug message')));
      expect(messages, isNot(contains('info message')));
    });
  });
}
