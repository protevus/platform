import 'dart:developer';

import 'package:angel3_mq/mq.dart';

final class Receiver with ConsumerMixin {
  Receiver() {
    MQClient.instance.declareQueue('hello');
  }

  void listenToGreeting() => subscribe(
        queueId: 'hello',
        callback: (Message message) {
          log('Received: ${message.payload}');
        },
      );

  void stopListening() => unsubscribe(queueId: 'hello');
}
