import 'package:illuminate_events/events.dart';
import 'package:illuminate_mail/mail.dart';
import 'package:illuminate_database/eloquent.dart';

/// Example mailable implementation.
class ExampleMailable extends Mailable {
  final String recipientEmail;
  final String recipientName;

  ExampleMailable(this.recipientEmail, this.recipientName);

  @override
  Future<void> build() async {
    from('noreply@example.com', 'Example System')
      ..to(recipientEmail, recipientName)
      ..subject('Welcome to Example System')
      ..template('''
        <h1>Welcome, {{name}}!</h1>
        <p>Thank you for joining our platform.</p>
      ''')
      ..withData('name', recipientName)
      ..priority(3)
      ..tag('welcome')
      ..metadata('category', 'welcome');
  }
}

/// Example mail driver implementation.
class ExampleMailDriver extends MailDriver {
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
  }) async {
    print('Example: Sending email to ${to.join(', ')}');
  }

  @override
  bool validateConfig() => true;

  @override
  Future<void> close() async {}
}

/// Base mail manager implementation.
abstract class BaseMailManager implements MailManager {
  final Map<String, MailDriver Function(MailManager)> _factories = {};
  final Map<String, MailDriver> _drivers = {};
  String? _defaultDriver;

  @override
  void extend(String name, MailDriver Function(MailManager) factory) {
    _factories[name] = factory;
  }

  @override
  void setDefaultDriver(String name) {
    if (!_factories.containsKey(name)) {
      throw MailConfigException('Mail driver "$name" not found');
    }
    _defaultDriver = name;
  }

  @override
  String getDefaultDriver() {
    return _defaultDriver ?? 'smtp';
  }

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
    final driver = this.driver(driverName);
    await driver.send(
      to: to,
      from: from,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      subject: subject,
      html: html,
      text: text,
      attachments: attachments,
      headers: headers,
      metadata: metadata,
      tags: tags,
    );
  }

  @override
  Future<void> smtp({
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
  }) {
    return send(
      to: to,
      from: from,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      subject: subject,
      html: html,
      text: text,
      attachments: attachments,
      headers: headers,
      metadata: metadata,
      tags: tags,
      driverName: 'smtp',
    );
  }

  @override
  Future<void> mailgun({
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
  }) {
    return send(
      to: to,
      from: from,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      subject: subject,
      html: html,
      text: text,
      attachments: attachments,
      headers: headers,
      metadata: metadata,
      tags: tags,
      driverName: 'mailgun',
    );
  }

  @override
  Future<void> log({
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
  }) {
    return send(
      to: to,
      from: from,
      cc: cc,
      bcc: bcc,
      replyTo: replyTo,
      subject: subject,
      html: html,
      text: text,
      attachments: attachments,
      headers: headers,
      metadata: metadata,
      tags: tags,
      driverName: 'log',
    );
  }
}

/// Example mail manager implementation.
class YourMailManager extends BaseMailManager {
  @override
  MailDriver driver([String? name]) {
    final driverName = name ?? getDefaultDriver();
    return ExampleMailDriver();
  }

  @override
  Future<void> sendMailable(Mailable mailable, [String? driverName]) async {
    await mailable.send(this);
  }

  @override
  Future<void> close() async {
    await Future.wait(
      _drivers.values.map((driver) => driver.close()),
    );
    _drivers.clear();
  }
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
