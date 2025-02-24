import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:illuminate_view/view.dart';

void main() {
  group('ViewFileViewFinder Tests', () {
    late FileViewFinder finder;

    setUp(() {
      finder = FileViewFinder();
    });

    test('find returns first matching view', () {
      finder.addLocation('views');
      finder.addExtension('blade.html');

      expect(
        () => finder.find('home'),
        throwsA(isA<ViewException>()),
      );
    });

    test('find throws error for non-existent view', () {
      finder.addLocation('views');
      finder.addExtension('blade.html');

      expect(
        () => finder.find('nonexistent'),
        throwsA(isA<ViewException>()),
      );
    });

    test('find checks multiple locations', () {
      finder.addLocation('views');
      finder.addLocation('resources/views');
      finder.addExtension('blade.html');

      expect(
        () => finder.find('home'),
        throwsA(isA<ViewException>()),
      );
    });

    test('find checks multiple extensions', () {
      finder.addLocation('views');
      finder.addExtension('blade.html');
      finder.addExtension('php');

      expect(
        () => finder.find('home'),
        throwsA(isA<ViewException>()),
      );
    });

    test('find handles dot notation', () {
      finder.addLocation('views');
      finder.addExtension('blade.html');

      expect(
        () => finder.find('auth.login'),
        throwsA(isA<ViewException>()),
      );
    });

    test('find handles namespaced views', () {
      finder.addNamespace('admin', ['admin/views']);
      finder.addExtension('blade.html');

      expect(
        () => finder.find('admin::dashboard'),
        throwsA(isA<ViewException>()),
      );
    });

    test('find handles namespaced views with dots', () {
      finder.addNamespace('admin', ['admin/views']);
      finder.addExtension('blade.html');

      expect(
        () => finder.find('admin::users.index'),
        throwsA(isA<ViewException>()),
      );
    });

    test('find uses cache for subsequent lookups', () {
      finder.addLocation('views');
      finder.addExtension('blade.html');

      // First lookup should throw
      expect(
        () => finder.find('home'),
        throwsA(isA<ViewException>()),
      );

      // Second lookup should also throw
      expect(
        () => finder.find('home'),
        throwsA(isA<ViewException>()),
      );
    });

    test('flush clears the cache', () {
      finder.addLocation('views');
      finder.addExtension('blade.html');

      // First lookup should throw
      expect(
        () => finder.find('home'),
        throwsA(isA<ViewException>()),
      );

      // Flush cache
      finder.flush();

      // Second lookup should also throw
      expect(
        () => finder.find('home'),
        throwsA(isA<ViewException>()),
      );
    });
  });
}
