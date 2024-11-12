import 'package:angel3_event_bus/res/app_event.dart';
import 'package:test/test.dart';
import 'package:platform_container/container.dart';
import 'package:angel3_mq/mq.dart';
import 'package:platform_events/dispatcher.dart'; // Replace with the actual import path

void main() {
  late Dispatcher dispatcher;
  late MockMQClient mockMQClient;

  setUp(() {
    var container = Container(EmptyReflector());
    dispatcher = Dispatcher(container);
    mockMQClient = MockMQClient();
    dispatcher.mqClient = mockMQClient; // Use the setter

    // Clear the queue before each test
    mockMQClient.queuedMessages.clear();
  });

  group('Dispatcher', () {
    test('listen and dispatch', () async {
      var callCount = 0;
      dispatcher.listen('test_event', (dynamic event, dynamic payload) {
        expect(event, equals('test_event'));
        expect(payload, equals(['test_payload']));
        callCount++;
      });
      await dispatcher.dispatch('test_event', ['test_payload']);
      expect(callCount, equals(1));
    });

    test('wildcard listener', () async {
      var callCount = 0;
      dispatcher.listen('test.*', (dynamic event, dynamic payload) {
        expect(event, matches(RegExp(r'^test\.')));
        callCount++;
      });

      await dispatcher.dispatch('test.one', ['payload1']);
      await dispatcher.dispatch('test.two', ['payload2']);
      expect(callCount, equals(2));
    });

    test('hasListeners', () {
      dispatcher.listen('test_event', (dynamic event, dynamic payload) {});
      expect(dispatcher.hasListeners('test_event'), isTrue);
      expect(dispatcher.hasListeners('non_existent_event'), isFalse);
    });

    test('until', () async {
      // Test without pushing the event immediately
      var futureResult = dispatcher.until('test_event');

      // Use a small delay to ensure the until listener is set up
      await Future.delayed(Duration(milliseconds: 10));

      await dispatcher.dispatch('test_event', ['test_payload']);
      var result = await futureResult;
      expect(result, equals(['test_payload']));

      // Test with pushing the event immediately
      result =
          await dispatcher.until('another_test_event', ['another_payload']);
      expect(result, equals(['another_payload']));
    }, timeout: Timeout(Duration(seconds: 5))); // Add a reasonable timeout

    test('forget', () async {
      var callCount = 0;
      dispatcher.listen('test_event', (dynamic event, dynamic payload) {
        callCount++;
      });
      await dispatcher.dispatch('test_event');
      expect(callCount, equals(1));

      dispatcher.forget('test_event');
      await dispatcher.dispatch('test_event');
      expect(callCount, equals(1)); // Should not increase
    });

    test('push and flush', () async {
      print('Starting push and flush test');

      // Push 4 messages
      for (var i = 0; i < 4; i++) {
        dispatcher.push('delayed_event', ['delayed_payload_$i']);
      }

      // Verify that 4 messages were queued
      expect(mockMQClient.queuedMessages['delayed_events_queue']?.length,
          equals(4),
          reason: 'Should have queued exactly 4 messages');

      print(
          'Queued messages: ${mockMQClient.queuedMessages['delayed_events_queue']?.length}');

      var callCount = 0;
      var processedPayloads = <String>[];

      // Remove any existing listeners
      dispatcher.forget('delayed_event');

      dispatcher.listen('delayed_event', (dynamic event, dynamic payload) {
        print('Listener called with payload: $payload');
        expect(event, equals('delayed_event'));
        expect(payload[0], startsWith('delayed_payload_'));
        processedPayloads.add(payload[0]);
        callCount++;
      });

      await dispatcher.flush('delayed_event');

      print('After flush - Call count: $callCount');
      print('Processed payloads: $processedPayloads');

      expect(callCount, equals(4), reason: 'Should process exactly 4 messages');
      expect(processedPayloads.toSet().length, equals(4),
          reason: 'All payloads should be unique');

      // Verify that all messages were removed from the queue
      expect(mockMQClient.queuedMessages['delayed_events_queue']?.length,
          equals(0),
          reason: 'Queue should be empty after flush');

      // Flush again to ensure no more messages are processed
      await dispatcher.flush('delayed_event');
      expect(callCount, equals(4),
          reason: 'Should still be 4 after second flush');
    });

    test('shouldBroadcast', () async {
      var broadcastEvent = BroadcastTestEvent();
      var callCount = 0;

      dispatcher.listen('BroadcastTestEvent', (dynamic event, dynamic payload) {
        callCount++;
      });

      await dispatcher.dispatch(broadcastEvent);
      expect(callCount, equals(1));
    });

    test('shouldQueue', () async {
      var queueEvent = QueueTestEvent();
      await dispatcher.dispatch(queueEvent);
      expect(mockMQClient.queuedMessages['events_queue'], isNotEmpty);
      expect(mockMQClient.queuedMessages['events_queue']!.first.payload,
          containsPair('event', 'QueueTestEvent'));
    });

    test('forgetPushed removes only pushed events', () {
      dispatcher.listen('event_pushed', (_, __) {});
      dispatcher.listen('normal_event', (_, __) {});

      dispatcher.forgetPushed();

      expect(dispatcher.hasListeners('event_pushed'), isFalse);
      expect(dispatcher.hasListeners('normal_event'), isTrue);
    });

    test('setQueueResolver and setTransactionManagerResolver', () {
      var queueResolverCalled = false;
      var transactionManagerResolverCalled = false;

      dispatcher.setQueueResolver(() {
        queueResolverCalled = true;
      });

      dispatcher.setTransactionManagerResolver(() {
        transactionManagerResolverCalled = true;
      });

      // Trigger the resolvers
      dispatcher.triggerQueueResolver();
      dispatcher.triggerTransactionManagerResolver();

      expect(queueResolverCalled, isTrue);
      expect(transactionManagerResolverCalled, isTrue);
    });

    test('getRawListeners returns unmodifiable map', () {
      dispatcher.listen('test_event', (_, __) {});
      var rawListeners = dispatcher.getRawListeners();

      expect(rawListeners, isA<Map<String, List<Function>>>());
      expect(() => rawListeners['new_event'] = [], throwsUnsupportedError);
    });

    test('multiple listeners for same event', () async {
      var callCount1 = 0;
      var callCount2 = 0;

      dispatcher.listen('multi_event', (_, __) => callCount1++);
      dispatcher.listen('multi_event', (_, __) => callCount2++);

      await dispatcher.dispatch('multi_event');

      expect(callCount1, equals(1));
      expect(callCount2, equals(1));
    });
  });
}

abstract class MQClientWrapper {
  Stream<Message> fetchQueue(String queueId);
  void sendMessage({
    required Message message,
    String? exchangeName,
    String? routingKey,
  });
  String declareQueue(String queueId);
  void declareExchange({
    required String exchangeName,
    required ExchangeType exchangeType,
  });
  void bindQueue({
    required String queueId,
    required String exchangeName,
    String? bindingKey,
  });
  void close();
}

class RealMQClientWrapper implements MQClientWrapper {
  final MQClient _client;

  RealMQClientWrapper(this._client);

  @override
  Stream<Message> fetchQueue(String queueId) => _client.fetchQueue(queueId);

  @override
  void sendMessage({
    required Message message,
    String? exchangeName,
    String? routingKey,
  }) =>
      _client.sendMessage(
        message: message,
        exchangeName: exchangeName,
        routingKey: routingKey,
      );

  @override
  String declareQueue(String queueId) => _client.declareQueue(queueId);

  @override
  void declareExchange({
    required String exchangeName,
    required ExchangeType exchangeType,
  }) =>
      _client.declareExchange(
        exchangeName: exchangeName,
        exchangeType: exchangeType,
      );

  @override
  void bindQueue({
    required String queueId,
    required String exchangeName,
    String? bindingKey,
  }) =>
      _client.bindQueue(
        queueId: queueId,
        exchangeName: exchangeName,
        bindingKey: bindingKey,
      );

  @override
  void close() => _client.close();
}

class MockMQClient implements MQClient {
  Map<String, List<Message>> queuedMessages = {};
  int _messageIdCounter = 0;

  void queueMessage(String queueName, Message message) {
    queuedMessages.putIfAbsent(queueName, () => []).add(message);
    print(
        'Queued message. Queue $queueName now has ${queuedMessages[queueName]?.length} messages');
  }

  @override
  String declareQueue(String queueId) {
    queuedMessages[queueId] = [];
    return queueId;
  }

  @override
  void deleteQueue(String queueId) {
    queuedMessages.remove(queueId);
  }

  @override
  Stream<Message> fetchQueue(String queueId) {
    print('Fetching queue: $queueId');
    return Stream.fromIterable(queuedMessages[queueId] ?? []);
  }

  @override
  void sendMessage({
    required Message message,
    String? exchangeName,
    String? routingKey,
  }) {
    print('Sending message to queue: $routingKey');
    final newMessage = Message(
      payload: message.payload,
      headers: message.headers,
      timestamp: message.timestamp,
      id: 'msg_${_messageIdCounter++}',
    );
    queueMessage(routingKey ?? '', newMessage);
  }

  @override
  Message? getLatestMessage(String queueId) {
    final messages = queuedMessages[queueId];
    return messages?.isNotEmpty == true ? messages!.last : null;
  }

  @override
  void bindQueue({
    required String queueId,
    required String exchangeName,
    String? bindingKey,
  }) {
    // Implement if needed for your tests
  }

  @override
  void unbindQueue({
    required String queueId,
    required String exchangeName,
    String? bindingKey,
  }) {
    // Implement if needed for your tests
  }

  @override
  void declareExchange({
    required String exchangeName,
    required ExchangeType exchangeType,
  }) {
    // Implement if needed for your tests
  }

  @override
  void deleteExchange(String exchangeName) {
    // Implement if needed for your tests
  }

  @override
  List<String> listQueues() {
    return queuedMessages.keys.toList();
  }

  @override
  void close() {
    queuedMessages.clear();
  }

  @override
  void deleteMessage(String queueId, Message message) {
    print('Deleting message from queue: $queueId');
    queuedMessages[queueId]?.removeWhere((m) => m.id == message.id);
    print(
        'After deletion, queue $queueId has ${queuedMessages[queueId]?.length} messages');
  }
}

class BroadcastTestEvent implements AppEvent, ShouldBroadcast {
  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;

  @override
  DateTime get timestamp => DateTime.now();
}

class QueueTestEvent implements AppEvent, ShouldQueue {
  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;

  @override
  DateTime get timestamp => DateTime.now();
}

// This is a simple implementation of Reflector that does nothing
class EmptyReflector implements Reflector {
  const EmptyReflector();

  @override
  ReflectedType reflectType(Type type) {
    throw UnimplementedError();
  }

  @override
  ReflectedInstance reflectInstance(Object object) {
    throw UnimplementedError();
  }

  @override
  ReflectedType reflectFutureOf(Type type) {
    throw UnimplementedError();
  }

  @override
  String? getName(Symbol symbol) {
    // TODO: implement getName
    throw UnimplementedError();
  }

  @override
  ReflectedClass? reflectClass(Type clazz) {
    // TODO: implement reflectClass
    throw UnimplementedError();
  }

  @override
  ReflectedFunction? reflectFunction(Function function) {
    // TODO: implement reflectFunction
    throw UnimplementedError();
  }
}
