import 'dart:developer';

import 'package:angel3_mq/mq.dart';

class ServiceOne with ProducerMixin {
  Future<void> requestFoo() async {
    final res = await sendRPCMessage<String>(
      exchangeName: 'ServiceRPC',
      routingKey: 'rpcBinding',
      processId: 'foo',
      args: {},
    );
    _handleFuture(res);
  }

  void _handleFuture(String data) {
    log('Service One received: $data\n');
  }
}
