import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:platform_core/src/provider/service_provider.dart';

class MockServiceProvider extends Mock implements ServiceProvider {}

void main() {
  group('ServiceProvider', () {
    late ServiceProvider provider;

    setUp(() {
      provider = MockServiceProvider();
    });

    test('setEnabled changes isEnabled', () {
      when(provider.isEnabled).thenAnswer((_) => true);
      provider.setEnabled(false);
      verify(provider.setEnabled(false)).called(1);
    });

    test('setDeferred changes isDeferred', () {
      when(provider.isDeferred).thenAnswer((_) => false);
      provider.setDeferred(true);
      verify(provider.setDeferred(true)).called(1);
    });

    test('configure adds to config', () {
      provider.configure({'key': 'value'});
      verify(provider.configure({'key': 'value'})).called(1);
    });
  });
}
