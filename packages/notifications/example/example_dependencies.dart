import 'package:platform_events/events.dart';
import 'package:platform_mail/mail.dart';
import 'package:platform_database/eloquent.dart';

/// Base mail manager implementation.
abstract class BaseMailManager implements MailManager {
  @override
  String get defaultDriver => 'smtp';

  @override
  Future<void> send({
    required List<Address> to,
    required List<Address> from,
    List<Address>? cc,
    List<Address>? bcc,
    List<Address>? replyTo,
    required String subject,
    String? html,
    String? text,
    List<Attachment>? attachments,
    Map<String, String>? headers,
    Map<String, String>? metadata,
    List<String>? tags,
    String? driverName,
    String? locale,
    int? priority,
  }) async {
    print('Example: Sending email to ${to.join(', ')}');
  }
}

/// Example mail manager implementation.
class YourMailManager extends BaseMailManager {
  @override
  MailDriver driver([String? name]) => throw UnimplementedError();

  @override
  Future<void> sendMailable(Mailable mailable, [String? driverName]) async {}

  @override
  void registerDriver(String name, MailDriver driver) {}

  @override
  Future<void> close() async {}
}

/// Base database connection implementation.
abstract class BaseDatabaseConnection implements Connection {
  @override
  String get name => 'default';

  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Example database connection implementation.
class YourDatabaseConnection extends BaseDatabaseConnection {
  @override
  QueryBuilder query() => YourQueryBuilder();
}

/// Base event dispatcher implementation.
abstract class BaseEventDispatcher implements EventDispatcher {
  @override
  List<dynamic>? dispatch(dynamic event,
      [dynamic payload = const [], bool halt = false]) {
    print('Example: Dispatching event ${event.runtimeType}');
    return null;
  }

  @override
  void listen(dynamic events, [dynamic listener]) {
    print('Example: Listening for events $events');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Example event dispatcher implementation.
class YourEventDispatcher extends BaseEventDispatcher {
  @override
  Function createClassListener(List<dynamic> listener,
      [bool wildcard = false]) {
    return (String event, List payload) {};
  }

  @override
  void flush(String event) {}

  @override
  void forget(String event) {}

  @override
  void forgetPushed() {}

  @override
  Map<String, List<dynamic>> getRawListeners() => {};

  @override
  bool hasListeners(String eventName) => false;

  @override
  void push(String event, [List payload = const []]) {}

  @override
  void subscribe(dynamic subscriber) {}

  @override
  dynamic until(dynamic event, [dynamic payload = const []]) {}
}

/// Example query builder implementation.
class YourQueryBuilder implements QueryBuilder {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
