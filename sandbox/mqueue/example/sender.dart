import 'package:angel3_mq/mq.dart';

final class Sender with ProducerMixin {
  Sender() {
    MQClient.instance.declareQueue('hello');
  }

  Future<void> sendGreeting({required String greeting}) async => sendMessage(
        routingKey: 'hello',
        payload: greeting,
      );
}
