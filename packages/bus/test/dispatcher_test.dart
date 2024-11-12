import 'dart:async';

import 'package:platform_bus/angel3_bus.dart';
import 'package:platform_container/container.dart';
import 'package:angel3_event_bus/event_bus.dart';
import 'package:angel3_mq/mq.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class IsMessage extends Matcher {
  @override
  bool matches(item, Map matchState) => item is Message;

  @override
  Description describe(Description description) =>
      description.add('is a Message');
}

class MockContainer extends Mock implements Container {
  final Map<Type, dynamic> _instances = {};

  @override
  T make<T>([Type? type]) {
    type ??= T;
    return _instances[type] as T;
  }

  void registerInstance<T>(T instance) {
    _instances[T] = instance;
  }
}

class MockEventBus extends Mock implements EventBus {
  @override
  Stream<T> on<T extends AppEvent>() {
    return super.noSuchMethod(
      Invocation.method(#on, [], {#T: T}),
      returnValue: Stream<T>.empty(),
    ) as Stream<T>;
  }
}

class MockMQClient extends Mock implements MQClient {
  Message? capturedMessage;
  String? capturedExchangeName;
  String? capturedRoutingKey;

  @override
  dynamic noSuchMethod(Invocation invocation,
      {Object? returnValue, Object? returnValueForMissingStub}) {
    if (invocation.memberName == #sendMessage) {
      final namedArgs = invocation.namedArguments;
      capturedMessage = namedArgs[#message] as Message?;
      capturedExchangeName = namedArgs[#exchangeName] as String?;
      capturedRoutingKey = namedArgs[#routingKey] as String?;
      return null;
    }
    return super.noSuchMethod(invocation,
        returnValue: returnValue,
        returnValueForMissingStub: returnValueForMissingStub);
  }
}

class TestCommand implements Command {
  final String data;
  TestCommand(this.data);
}

class TestHandler implements Handler {
  @override
  Future<dynamic> handle(Command command) async {
    if (command is TestCommand) {
      return 'Handled: ${command.data}';
    }
    throw UnimplementedError();
  }
}

class TestQueuedCommand implements Command, ShouldQueue {
  final String data;
  TestQueuedCommand(this.data);
}

void main() {
  late MockContainer container;
  late MockEventBus eventBus;
  late MockMQClient mqClient;
  late Dispatcher dispatcher;

  setUp(() {
    container = MockContainer();
    eventBus = MockEventBus();
    mqClient = MockMQClient();

    container.registerInstance<EventBus>(eventBus);
    container.registerInstance<MQClient>(mqClient);

    dispatcher = Dispatcher(container);
  });

  group('Dispatcher', () {
    test('dispatchNow should handle command and return result', () async {
      final command = TestCommand('test data');
      final handler = TestHandler();

      container.registerInstance<TestHandler>(handler);
      dispatcher.map({TestCommand: TestHandler});

      final commandEventController = StreamController<CommandEvent>();
      when(eventBus.on<CommandEvent>())
          .thenAnswer((_) => commandEventController.stream);

      final future = dispatcher.dispatchNow(command);

      // Simulate the event firing
      commandEventController
          .add(CommandEvent(command, result: 'Handled: test data'));

      final result = await future;
      expect(result, equals('Handled: test data'));

      await commandEventController.close();
    });

    test('dispatch should handle regular commands immediately', () async {
      final command = TestCommand('regular');
      final handler = TestHandler();

      container.registerInstance<TestHandler>(handler);
      dispatcher.map({TestCommand: TestHandler});

      final commandEventController = StreamController<CommandEvent>();
      when(eventBus.on<CommandEvent>())
          .thenAnswer((_) => commandEventController.stream);

      final future = dispatcher.dispatch(command);

      // Simulate the event firing
      commandEventController
          .add(CommandEvent(command, result: 'Handled: regular'));

      final result = await future;
      expect(result, equals('Handled: regular'));

      await commandEventController.close();
    });

    test('dispatch should queue ShouldQueue commands', () async {
      final command = TestQueuedCommand('queued data');

      // Dispatch the command
      await dispatcher.dispatch(command);

      // Verify that sendMessage was called and check the message properties
      expect(mqClient.capturedMessage, isNotNull);
      expect(mqClient.capturedMessage!.payload, equals(command));
      expect(mqClient.capturedMessage!.headers?['commandType'],
          equals('TestQueuedCommand'));

      // Optionally, verify exchange name and routing key if needed
      expect(mqClient.capturedExchangeName, isNull);
      expect(mqClient.capturedRoutingKey, isNull);
    });

    test(
        'dispatchAfterResponse should send message to queue with specific header',
        () {
      final command = TestCommand('after response data');

      // Call dispatchAfterResponse
      dispatcher.dispatchAfterResponse(command);

      // Verify that sendMessage was called and check the message properties
      expect(mqClient.capturedMessage, isNotNull);
      expect(mqClient.capturedMessage!.payload, equals(command));
      expect(mqClient.capturedMessage!.headers?['commandType'],
          equals('TestCommand'));
      expect(mqClient.capturedMessage!.headers?['dispatchAfterResponse'],
          equals('true'));

      // Verify routing key
      expect(mqClient.capturedRoutingKey, equals('after_response_queue'));

      // Optionally, verify exchange name if needed
      expect(mqClient.capturedExchangeName, isNull);
    });
    test('map should register command handlers', () {
      dispatcher.map({TestCommand: TestHandler});

      // Mock the event bus behavior for this test
      when(eventBus.on<CommandEvent>()).thenAnswer((_) => Stream.empty());

      // This test is a bit tricky to verify directly, but we can check if dispatch doesn't throw
      expect(() => dispatcher.dispatch(TestCommand('test')), returnsNormally);
    });
  });
}
