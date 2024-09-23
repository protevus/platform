import 'dart:io';
import 'package:platform_framework/platform_framework.dart';
import 'package:test/test.dart';

void main() {
  test('custom value', () => expect(ProtevusEnvironment('hey').value, 'hey'));

  test('lowercases', () => expect(ProtevusEnvironment('HeY').value, 'hey'));
  test(
      'default to env or development',
      () => expect(ProtevusEnvironment().value,
          (Platform.environment['ANGEL_ENV'] ?? 'development').toLowerCase()));
  test('isDevelopment',
      () => expect(ProtevusEnvironment('development').isDevelopment, true));
  test('isStaging',
      () => expect(ProtevusEnvironment('staging').isStaging, true));
  test('isDevelopment',
      () => expect(ProtevusEnvironment('production').isProduction, true));
}
