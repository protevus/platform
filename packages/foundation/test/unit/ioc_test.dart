import 'package:illuminate_container/container.dart';
import 'package:test/test.dart';

class ABC {
  ABC();

  String sayHello() {
    return 'hello';
  }
}

void main() {
  group('IOC Container |', () {
    test('register', () {
      Container ioc = Container();
      ioc.register<ABC>((Container i) => ABC());

      ABC abc = ioc.get<ABC>();
      expect(abc.sayHello(), 'hello');
    });

    test('register by name', () {
      Container ioc = Container();
      ioc.registerByName('ABC', (Container i) => ABC());

      ABC abc = ioc.get<ABC>();
      expect(abc.sayHello(), 'hello');
    });

    test('get by name', () {
      Container ioc = Container();
      ioc.registerByName('ABC', (Container i) => ABC());

      ABC abc = ioc.getByName('ABC');
      expect(abc.sayHello(), 'hello');
    });

    test('register singleton', () {
      Container ioc = Container();
      ioc.registerSingleton<ABC>((Container i) => ABC());

      ABC abc = ioc.get<ABC>();
      ABC newAbc = ioc.get<ABC>();
      expect(abc, newAbc);
    });

    test('register singleton and get by name', () {
      Container ioc = Container();
      ioc.registerSingleton<ABC>((Container i) => ABC());

      ABC abc = ioc.getByName('ABC');
      ABC newAbc = ioc.getByName('ABC');
      expect(abc, newAbc);
    });

    test('register request', () {
      Container ioc = Container();
      ioc.registerRequest('ABC', () => ABC());

      ABC abc = ioc.get<ABC>();
      expect(abc.sayHello(), 'hello');
    });

    test('register should not equal 2 instance', () {
      Container ioc = Container();
      ioc.register<ABC>((Container i) => ABC());

      ABC abc = ioc.get<ABC>();
      ABC newAbc = ioc.get<ABC>();
      expect(abc != newAbc, true);
    });
  });
}
